import 'dart:async';

import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/data/home_product_snapshot_cache.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/home_product_fixture.dart';

typedef Page = ({List<HomeProduct> products, bool hasMore});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String? owner;
  late DateTime now;
  late HomeProductSnapshotCache cache;
  const rows = <Map<String, dynamic>>[
    {
      'commodity_id': 1,
      'effective_price': 12,
      '_snapshot_farm': {'farm_id': 2},
    },
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    owner = 'buyer-a';
    now = DateTime.utc(2026, 10, 15);
    cache = HomeProductSnapshotCache(owner: () => owner, now: () => now);
  });

  test('snapshot survives a new cache instance for the same owner', () async {
    await cache.save(owner, 25, rows);
    final restored = HomeProductSnapshotCache(
      owner: () => owner,
      now: () => now,
    );
    expect(await restored.read(25), rows);
    expect(await restored.read(13), isNull);
  });

  test(
    'another account and signed-out callers cannot load a snapshot',
    () async {
      await cache.save(owner, 25, rows);
      owner = 'buyer-b';
      expect(await cache.read(25), isNull);
      await cache.save('buyer-a', 25, [
        {'commodity_id': 999},
      ]);
      owner = null;
      expect(await cache.read(25), isNull);
      owner = 'buyer-a';
      expect(await cache.read(25), rows);
    },
  );

  test('expired, future-dated and corrupt snapshots are ignored', () async {
    await cache.save(owner, 25, rows);
    now = now.add(const Duration(minutes: 16));
    expect(await cache.read(25), isNull);
    now = now.subtract(const Duration(minutes: 17));
    expect(await cache.read(25), isNull);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(HomeProductSnapshotCache.storageKey, '{broken');
    expect(await cache.read(25), isNull);
  });

  test(
    'logout cancels queued writes and removes the stored snapshot',
    () async {
      await cache.save(owner, 25, rows);
      final pending = cache.save(owner, 25, rows);
      final clearing = cache.clear();
      await Future.wait([pending, clearing]);
      expect(await cache.read(25), isNull);
      expect(
        (await SharedPreferences.getInstance()).containsKey(
          HomeProductSnapshotCache.storageKey,
        ),
        isFalse,
      );
    },
  );

  test('cache bounds stored data to the requested first page', () async {
    await cache.save(owner, 1, [...rows, ...rows]);
    expect(await cache.read(1), hasLength(1));
  });

  test(
    'a request from before logout cannot save after the same owner returns',
    () async {
      final generation = cache.generation;
      await cache.clear();
      await cache.save(owner, 25, rows, generation: generation);
      expect(await cache.read(25), isNull);
    },
  );

  test('cached products appear before the pending network refresh', () async {
    final repository = _SnapshotRepository();
    final controller = HomeProductCatalogController(repository: repository);
    addTearDown(controller.dispose);
    final loading = controller.load();
    await Future<void>.delayed(Duration.zero);
    expect(repository.networkStarted, isTrue);
    expect(controller.products.single.id, testHomeProducts.first.id);
    expect(controller.status, HomeProductCatalogStatus.loading);
    await controller.loadMore();
    expect(repository.networkCalls, 1);
    repository.network.complete((
      products: [testHomeProducts[1]],
      hasMore: false,
    ));
    await loading;
    expect(controller.products.single.id, testHomeProducts[1].id);
    expect(controller.status, HomeProductCatalogStatus.ready);
  });

  test('late cache cannot replace fresh network products', () async {
    final repository = _SnapshotRepository(delayedCache: true);
    final controller = HomeProductCatalogController(repository: repository);
    addTearDown(controller.dispose);
    final loading = controller.load();
    repository.network.complete((
      products: [testHomeProducts[1]],
      hasMore: false,
    ));
    await loading;
    repository.cached.complete((
      products: [testHomeProducts.first],
      hasMore: true,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(controller.products.single.id, testHomeProducts[1].id);
  });

  test(
    'failed refresh preserves displayed products and reports error',
    () async {
      final repository = _SnapshotRepository();
      final controller = HomeProductCatalogController(repository: repository);
      addTearDown(controller.dispose);
      final loading = controller.load();
      await Future<void>.delayed(Duration.zero);
      repository.network.completeError(const HomeProductException('offline'));
      await loading;
      expect(controller.products.single.id, testHomeProducts.first.id);
      expect(controller.status, HomeProductCatalogStatus.error);
      expect(controller.error, isA<HomeProductException>());
    },
  );

  test('disposed controllers ignore late snapshots and responses', () async {
    final repository = _SnapshotRepository(delayedCache: true);
    final controller = HomeProductCatalogController(repository: repository);
    final loading = controller.load();
    controller.dispose();
    repository.cached.complete((
      products: [testHomeProducts.first],
      hasMore: true,
    ));
    repository.network.complete((
      products: [testHomeProducts[1]],
      hasMore: false,
    ));
    await loading;
    await Future<void>.delayed(Duration.zero);
    expect(controller.products, isEmpty);
  });
}

class _SnapshotRepository extends HomeProductRepository {
  _SnapshotRepository({this.delayedCache = false});
  final bool delayedCache;
  final network = Completer<Page>();
  final cached = Completer<Page?>();
  bool networkStarted = false;
  int networkCalls = 0;

  @override
  Future<Page?> loadCachedProductsPage({int limit = 24}) async => delayedCache
      ? cached.future
      : (products: [testHomeProducts.first], hasMore: true);

  @override
  Future<Page> loadProductsPage({int limit = 24, int offset = 0}) {
    networkStarted = true;
    networkCalls++;
    return network.future;
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_product_publisher.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_context.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'support/supabase_session_fixture.dart';

const owner = 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa';
const key = '20000000-0000-4000-8000-000000000001';
FarmerDashboardProduct draft() => FarmerDashboardProduct(
  name: 'Tomato',
  price: '50',
  unit: 'per kg',
  harvestDate: 'October 20, 2026',
  category: 'Vegetables',
  imageBytes: Uint8List.fromList([1, 2, 3]),
  availableWeight: '10 kg',
  minimumOrderQuantity: '1',
  description: 'Fresh tomatoes',
  harvestedAt: DateTime(2026, 10, 20),
  sellUntil: DateTime(2026, 10, 25),
);
http.Response jsonResponse(
  Object value, [
  int status = 200,
  http.Request? request,
]) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json'},
  request: request,
);

void main() {
  for (final referenced in [false, true]) {
    test(
      'definite failure removes only an unreferenced upload (referenced=$referenced)',
      () async {
        var deletes = 0;
        final calls = <String>[];
        final client = SupabaseClient(
          'https://example.supabase.co',
          'key',
          httpClient: MockClient((r) async {
            calls.add('${r.method} ${r.url.path}');
            if (r.method == 'DELETE') {
              deletes++;
              return jsonResponse([]);
            }
            if (r.url.path.contains('/functions/'))
              return jsonResponse({
                'code': '22023',
                'message': 'Bad stock date',
              }, 400);
            if (r.url.path.contains('/rest/v1/commodities'))
              return jsonResponse(
                referenced
                    ? [
                        {'commodity_id': 42},
                      ]
                    : [],
                200,
                r,
              );
            return jsonResponse({'Key': 'farmer-media/test.jpg'});
          }),
        );
        addTearDown(client.dispose);
        await setTestSupabaseSession(client);
        final publisher = FarmerProductPublisher(
          client,
          loadContext: () async => const FarmerCommodityContext(owner, 7, true),
        );
        await expectLater(
          publisher.publish(draft(), key),
          throwsA(isA<FarmerCommodityException>()),
        );
        expect(deletes, referenced ? 0 : 1, reason: calls.join('\n'));
      },
    );
  }
  test(
    'a lost publication response retains the image and retries the same payload through the gateway',
    () async {
      final uploads = <String>[];
      final payloads = <Map<String, dynamic>>[];
      var deletes = 0;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'key',
        httpClient: MockClient((r) async {
          if (r.method == 'DELETE') {
            deletes++;
            return jsonResponse([]);
          }
          if (r.url.path.contains('/functions/')) {
            expect(
              r.url.path,
              '/functions/v1/application-api/rest/rpc/publish_current_farmer_product',
            );
            final body = jsonDecode(r.body) as Map<String, dynamic>;
            payloads.add(body);
            if (payloads.length == 1)
              throw http.ClientException('Response lost');
            return jsonResponse({
              'commodity_id': 42,
              'available_quantity': 10,
              'image_url': body['p_product']['image_url'],
            });
          }
          uploads.add(r.url.path);
          return jsonResponse({'Key': 'farmer-media/test.jpg'});
        }),
      );
      addTearDown(client.dispose);
      await setTestSupabaseSession(client);
      final publisher = FarmerProductPublisher(
        client,
        loadContext: () async => const FarmerCommodityContext(owner, 7, true),
      );
      await expectLater(publisher.publish(draft(), key), throwsA(anything));
      final saved = await publisher.publish(draft(), key);
      expect(saved.commodityId, 42);
      expect(saved.availableQuantity, 10);
      expect(uploads, hasLength(2));
      expect(uploads[0], uploads[1]);
      expect(payloads[0], payloads[1]);
      expect(payloads[0]['p_request_key'], key);
      expect(payloads[0]['p_product']['category_name'], 'Vegetables');
      expect(payloads[0]['p_product'].containsKey('category_id'), isFalse);
      expect(deletes, 0);
    },
  );
  test('pending approval makes no upload or publish request', () async {
    var requests = 0;
    final client = SupabaseClient(
      'https://example.supabase.co',
      'key',
      httpClient: MockClient((_) async {
        requests++;
        return jsonResponse({});
      }),
    );
    addTearDown(client.dispose);
    await setTestSupabaseSession(client);
    final publisher = FarmerProductPublisher(
      client,
      loadContext: () async => const FarmerCommodityContext(owner, 7, false),
    );
    await expectLater(
      publisher.publish(draft(), key),
      throwsA(isA<FarmerCommodityException>()),
    );
    expect(requests, 0);
  });
}

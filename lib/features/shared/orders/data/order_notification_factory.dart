import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

HomeNotification orderNotification({
  required PlacedOrder order,
  required String title,
  required String description,
  Set<AuthRole> visibleTo = const {AuthRole.buyer, AuthRole.farmer},
}) {
  return HomeNotification(
    id: 'order-update-${order.id}-${DateTime.now().microsecondsSinceEpoch}',
    title: title,
    description: description,
    image: order.items.isEmpty ? '' : order.items.first.image,
    imageLabel: '${order.title} order update photo',
    showChevron: true,
    createdAt: DateTime.now(),
    visibleTo: visibleTo,
  );
}

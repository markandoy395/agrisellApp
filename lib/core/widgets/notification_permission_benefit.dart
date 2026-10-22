enum NotificationPermissionBenefit {
  buyer(
    'Know when your order is on its way',
    'Get alerts when the farmer confirms your order and your rider updates your delivery.',
  ),
  farmer(
    'Know when buyers order your produce',
    'Get alerts for new orders, buyer messages, and pickup updates.',
  ),
  rider(
    'Catch delivery requests while you are online',
    'Get alerts for delivery requests, pickup updates, and customer messages.',
  );

  const NotificationPermissionBenefit(this.title, this.message);
  final String title;
  final String message;
}

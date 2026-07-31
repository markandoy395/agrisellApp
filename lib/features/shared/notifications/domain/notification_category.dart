enum NotificationCategory { orders, deliveries, messages, system }

enum NotificationFilter {
  all('All'),
  orders('Orders'),
  deliveries('Deliveries'),
  messages('Messages'),
  system('System');

  const NotificationFilter(this.label);

  final String label;

  bool includes(NotificationCategory category) => switch (this) {
    NotificationFilter.all => true,
    NotificationFilter.orders => category == NotificationCategory.orders,
    NotificationFilter.deliveries =>
      category == NotificationCategory.deliveries,
    NotificationFilter.messages => category == NotificationCategory.messages,
    NotificationFilter.system => category == NotificationCategory.system,
  };
}

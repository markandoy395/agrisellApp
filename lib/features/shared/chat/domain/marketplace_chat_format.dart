String marketplaceInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+'))
    ..removeWhere((word) => word.isEmpty);
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first[0].toUpperCase();
  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

String marketplaceTimeLabel(DateTime value, [DateTime? clock]) {
  final local = value.toLocal();
  final now = (clock ?? DateTime.now()).toLocal();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  if (!sameDay) return '${local.month}/${local.day}/${local.year}';
  final hour = local.hour == 0
      ? 12
      : (local.hour > 12 ? local.hour - 12 : local.hour);
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
}

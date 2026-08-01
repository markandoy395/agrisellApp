String formatBasketPeso(num value) {
  final amount = value.toDouble();
  final text = amount % 1 == 0
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);

  return '\u20B1 $text';
}

double authScale(double width) {
  return ((width - 360) / 70).clamp(0, 1).toDouble();
}

double lerpDouble(double min, double max, double scale) {
  return min + ((max - min) * scale);
}

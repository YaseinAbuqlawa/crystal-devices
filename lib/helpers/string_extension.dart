extension StringExtention on String {
  double toDouble() {
    return double.tryParse(this) ?? 0;
  }
}

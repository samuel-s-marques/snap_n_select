extension DoubleExtension on double {
  // TODO: Comment function
  double toPrecision({int precision = 2, bool round = true}) {
    final double value = this;

    if (round) {
      return double.parse(value.toStringAsPrecision(precision));
    }

    return double.parse('$value'.substring(0, '$value'.indexOf('.') + precision + 1));
  }
}

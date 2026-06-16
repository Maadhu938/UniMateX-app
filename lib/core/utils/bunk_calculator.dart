import 'dart:math';

class BunkCalculator {
  static int canBunk({
    required int present,
    required int total,
    required double target,
  }) {
    if (target <= 0) return 0;
    return max(0, ((present - target * total) / target).floor());
  }

  static int classesNeeded({
    required int present,
    required int total,
    required double target,
  }) {
    if (target >= 1) return 0;
    return max(0, ((target * total - present) / (1 - target)).ceil());
  }
}

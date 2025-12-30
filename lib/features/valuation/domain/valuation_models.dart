class ValuationResult {
  final double fairValue;
  final double upside;
  final String verdict;
  final DCFResult? dcf;
  final GrahamResult? graham;
  final LynchResult? lynch;

  ValuationResult({
    required this.fairValue,
    required this.upside,
    required this.verdict,
    this.dcf,
    this.graham,
    this.lynch,
  });
}

class DCFResult {
  final double fairValue;
  final double upside;
  final double wacc;
  final double growthRate;
  final double terminalValue;
  final List<double> projectedFCF;

  DCFResult({
    required this.fairValue,
    required this.upside,
    required this.wacc,
    required this.growthRate,
    required this.terminalValue,
    required this.projectedFCF,
  });
}

class GrahamResult {
  final double fairValue;
  final double upside;

  GrahamResult({required this.fairValue, required this.upside});
}

class LynchResult {
  final double fairValue;
  final double upside;
  final double pegRatio;

  LynchResult({required this.fairValue, required this.upside, required this.pegRatio});
}

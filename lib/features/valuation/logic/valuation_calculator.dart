import 'dart:math';
import 'package:stock_valuation_app/features/dashboard/domain/stock.dart';
import 'package:stock_valuation_app/features/valuation/domain/valuation_models.dart';

class ValuationCalculator {
  static const double riskFreeRate = 4.25;
  static const double equityRiskPremium = 5.0;
  static const double defaultTerminalGrowth = 2.5;

  // Calculate Weighted Average Cost of Capital (CAPM method)
  static double calculateWacc(double beta) {
    double costOfEquity = riskFreeRate + (beta * equityRiskPremium);
    // Clamp to reasonable range
    return max(6.0, min(18.0, costOfEquity));
  }

  static ValuationResult calculate(Stock stock) {
    final wacc = calculateWacc(stock.beta);
    // Default growth rate assumption (simplified)
    const growthRate = 8.0; 
    
    final dcf = _calculateDCF(stock, wacc, growthRate);
    final graham = _calculateGraham(stock);
    final lynch = _calculateLynch(stock, growthRate);

    // Synthesis
    List<double> values = [];
    if (dcf.fairValue > 0) values.add(dcf.fairValue);
    if (graham.fairValue > 0) values.add(graham.fairValue);
    if (lynch.fairValue > 0) values.add(lynch.fairValue);

    double averageFairValue = 0;
    if (values.isNotEmpty) {
      averageFairValue = values.reduce((a, b) => a + b) / values.length;
    }

    // Conservative Estimate (Margin of Safety)
    double conservativeValue = averageFairValue * 0.8;
    double upside = stock.price > 0 ? ((conservativeValue / stock.price) - 1) * 100 : 0;

    String verdict = 'HOLD';
    if (upside >= 30) verdict = 'STRONG BUY';
    else if (upside >= 15) verdict = 'BUY';
    else if (upside >= -10) verdict = 'HOLD';
    else verdict = 'SELL';

    return ValuationResult(
      fairValue: conservativeValue,
      upside: upside,
      verdict: verdict,
      dcf: dcf,
      graham: graham,
      lynch: lynch,
    );
  }

  static DCFResult _calculateDCF(Stock stock, double wacc, double growthRate) {
    if (stock.freeCashFlow <= 0 || stock.sharesOutstanding <= 0) {
      return DCFResult(fairValue: 0, upside: 0, wacc: wacc, growthRate: growthRate, terminalValue: 0, projectedFCF: []);
    }

    final fcfPerShare = stock.freeCashFlow / stock.sharesOutstanding;
    final waccDecimal = wacc / 100;
    final growthDecimal = growthRate / 100;
    final terminalDecimal = defaultTerminalGrowth / 100;
    
    // Projection (5 Years)
    List<double> projectedFCF = [];
    double currentFCF = fcfPerShare;
    
    for (int i = 1; i <= 5; i++) {
        // Linear fade logic
        double fade = (5 - i) / 5;
        double yearGrowth = terminalDecimal + ((growthDecimal - terminalDecimal) * fade);
        currentFCF = currentFCF * (1 + yearGrowth);
        projectedFCF.add(currentFCF);
    }

    // Discounting
    double pvOfFCF = 0;
    for (int i = 0; i < 5; i++) {
        pvOfFCF += projectedFCF[i] / pow(1 + waccDecimal, i + 1);
    }

    // Terminal Value
    double terminalFCF = projectedFCF.last;
    double terminalValue = (terminalFCF * (1 + terminalDecimal)) / (waccDecimal - terminalDecimal);
    double pvTerminal = terminalValue / pow(1 + waccDecimal, 5);

    double fairValue = pvOfFCF + pvTerminal;
    double upside = stock.price > 0 ? ((fairValue / stock.price) - 1) * 100 : 0;

    return DCFResult(
        fairValue: fairValue,
        upside: upside,
        wacc: wacc,
        growthRate: growthRate,
        terminalValue: terminalValue,
        projectedFCF: projectedFCF
    );
  }

  static GrahamResult _calculateGraham(Stock stock) {
      // Graham Number = sqrt(22.5 * EPS * BVPS)
      // Since we don't have EPS/BVPS in simple stock model yet, we'll approximate or return 0
      // In a real app we'd need those fields in Stock model
      
      // Placeholder
      return GrahamResult(fairValue: 0, upside: 0);
  }

  static LynchResult _calculateLynch(Stock stock, double growthRate) {
      // Basic Lynch: Fair PE = Growth Rate
      // Fair Price = EPS * Growth
      
      // Need EPS
      if (stock.peRatio <= 0) return LynchResult(fairValue: 0, upside: 0, pegRatio: 0);
      
      double eps = stock.price / stock.peRatio;
      double fairValue = eps * growthRate;
      double upside = stock.price > 0 ? ((fairValue / stock.price) - 1) * 100 : 0;
      double peg = stock.peRatio / growthRate;

      return LynchResult(fairValue: fairValue, upside: upside, pegRatio: peg);
  }
}

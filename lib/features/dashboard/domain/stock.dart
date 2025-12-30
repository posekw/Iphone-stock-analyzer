import 'package:stock_valuation_app/features/dashboard/domain/chart_data.dart';

class Stock {
  final String symbol;
  final String companyName;
  final double price;
  final double change;
  final double changePercent;
  final double marketCap;
  final double peRatio;
  final double beta;
  final double volume;

  // Valuation specific data
  final double freeCashFlow;
  final double sharesOutstanding;
  
  // Chart data
  final List<ChartData> historicalPrices;
  
  Stock({
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.marketCap,
    required this.peRatio,
    required this.beta,
    required this.volume,
    required this.freeCashFlow,
    required this.sharesOutstanding,
    this.historicalPrices = const [],
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is Map && value.containsKey('raw')) return parseDouble(value['raw']); // Yahoo format
      return double.tryParse(value.toString()) ?? 0.0;
    }

    String parseString(dynamic value) {
       if (value == null) return '';
       if (value is String) return value;
       // Yahoo sometimes wraps strings in objects? mostly no, but checks raw just in case
        return value.toString();
    }

    // Handle Yahoo Finance 'quoteSummary' structure
    // We expect the 'json' to be the merged result map (price + summaryDetail + defaultKeyStatistics)
    
    // Check if we are parsing the old WordPress format or new Yahoo format
    // Yahoo format usually has 'regularMarketPrice' etc.
    final bool isYahoo = json.containsKey('regularMarketPrice');
    
    if (isYahoo) {
         return Stock(
            symbol: parseString(json['symbol']),
            companyName: parseString(json['longName'] ?? json['shortName']),
            price: parseDouble(json['regularMarketPrice']),
            change: parseDouble(json['regularMarketChange']),
            changePercent: parseDouble(json['regularMarketChangePercent']) * 100, // Yahoo uses 0.015 for 1.5%
            marketCap: parseDouble(json['marketCap']),
            peRatio: parseDouble(json['trailingPE']),
            beta: parseDouble(json['beta']),
            volume: parseDouble(json['regularMarketVolume']),
            // FCF is hard to get from this endpoint, default to PE-implied or 0
            freeCashFlow: parseDouble(json['operatingCashflow']), // Approximation
            sharesOutstanding: parseDouble(json['sharesOutstanding']),
         );
    }
    
    // Fallback to old format (WordPress)
    final quote = json['quote'] ?? {};
    final metrics = json['metrics'] ?? {};

    return Stock(
      symbol: quote['symbol'] ?? '',
      companyName: quote['companyName'] ?? '',
      price: parseDouble(quote['price']),
      change: parseDouble(quote['change']),
      changePercent: parseDouble(quote['changesPercentage']),
      marketCap: parseDouble(quote['marketCap']),
      peRatio: parseDouble(quote['pe']),
      beta: parseDouble(metrics['beta']),
      volume: parseDouble(quote['volume']),
      freeCashFlow: parseDouble(metrics['freeCashFlow'] ?? 0),
      sharesOutstanding: parseDouble(metrics['sharesOutstanding']),
      historicalPrices: [],
    );
  }
}

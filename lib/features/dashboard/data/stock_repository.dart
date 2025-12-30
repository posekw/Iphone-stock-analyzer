import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_valuation_app/core/network/api_client.dart';
import 'package:stock_valuation_app/features/dashboard/domain/stock.dart';
import 'package:stock_valuation_app/features/dashboard/domain/chart_data.dart';

part 'stock_repository.g.dart';

class StockRepository {
  final Dio _dio;

  StockRepository(this._dio);

  Future<Stock> getStock(String ticker, {String range = '6mo'}) async {
    // Determine source. For now, we force Yahoo Finance for standalone mode.
    return _fetchFromYahoo(ticker, range: range);
  }
  
  Future<Stock> _fetchFromYahoo(String ticker, {String range = '6mo'}) async {
      try {
        // Map UI range to Yahoo API interval
        // 1d -> 5m, 1mo -> 1d, 6mo -> 1d, 1y -> 1d, 5y -> 1wk
        String interval = '1d';
        if (range == '1d') interval = '5m';
        if (range == '5y') interval = '1wk';

        // Use v8/finance/chart which is often more permissive than quoteSummary
        final url = 'https://query2.finance.yahoo.com/v8/finance/chart/$ticker?interval=$interval&range=$range';
        final response = await _dio.get(url);
        
        final result = response.data['chart']['result'];
        if (result == null || (result as List).isEmpty) {
            throw 'Stock not found';
        }
        
        final meta = result[0]['meta'];
        final timestamp = result[0]['timestamp'] as List<dynamic>?;
        final indicators = result[0]['indicators']['quote'][0];
        final closes = indicators['close'] as List<dynamic>?;
        final opens = indicators['open'] as List<dynamic>?;
        final highs = indicators['high'] as List<dynamic>?;
        final lows = indicators['low'] as List<dynamic>?;
        final volumes = indicators['volume'] as List<dynamic>?;

        // Parse historical prices (filter out nulls)
        List<ChartData> history = [];
        if (timestamp != null && closes != null) {
          for (int i = 0; i < timestamp.length; i++) {
            if (closes[i] != null) {
              history.add(ChartData(
                date: DateTime.fromMillisecondsSinceEpoch((timestamp[i] as int) * 1000),
                close: (closes[i] as num).toDouble(),
                open: (opens?[i] as num?)?.toDouble(),
                high: (highs?[i] as num?)?.toDouble(),
                low: (lows?[i] as num?)?.toDouble(),
                volume: (volumes?[i] as num?)?.toInt(),
              ));
            }
          }
        }

        final price = (meta['regularMarketPrice'] as num).toDouble();
        final prevClose = (meta['chartPreviousClose'] as num).toDouble();
        
        // Approximate other metrics or leave 0 if unavailable in this endpoint
        // (This endpoint is optimized for price/charts, not deep fundamentals)
        final marketCap = (meta['marketCap'] as num?)?.toDouble() ?? 0.0;
        final volume = (meta['regularMarketVolume'] as num?)?.toDouble() ?? 0.0;
        
        // Calculate change
        final change = price - prevClose;
        final changePercent = (change / prevClose) * 100;

        // Hybrid Approach: Fill missing fundamentals for popular stocks to ensure Valuation (DCF) works
        // (Since this chart API endpoint doesn't return them)
        final symbol = meta['symbol'].toString().toUpperCase();
        
        final fundamentals = _staticFundamentals[symbol] ?? _staticFundamentals[ticker.toUpperCase()];
        
        double finalMarketCap = (meta['marketCap'] as num?)?.toDouble() ?? 0.0;
        double finalPe = 0.0;
        double finalBeta = 1.0;
        double finalFCF = 0.0;
        double finalShares = 0.0;

        if (finalMarketCap == 0 && fundamentals != null) finalMarketCap = fundamentals['marketCap']!;
        if (fundamentals != null) {
          finalPe = fundamentals['pe']!;
          finalBeta = fundamentals['beta']!;
          finalFCF = fundamentals['fcf']!;
          finalShares = fundamentals['shares']!;
        }

        return Stock(
          symbol: symbol,
          companyName: ticker.toUpperCase(),
          price: price,
          change: change,
          changePercent: changePercent,
          marketCap: finalMarketCap,
          peRatio: finalPe,
          beta: finalBeta,
          volume: volume,
          freeCashFlow: finalFCF,
          sharesOutstanding: finalShares,
          historicalPrices: history,
        );
      } catch (e) {
        // Fallback for Demo/Offline mode
        print('API Error: $e. Returning mock data.');
        return Stock(
          symbol: ticker.toUpperCase(),
          companyName: 'Mock Company (Offline)',
          price: 150.00,
          change: 2.50,
          changePercent: 1.6,
          marketCap: 2000000000000,
          peRatio: 25.5,
          beta: 1.2,
          volume: 50000000,
          freeCashFlow: 85000000000,
          sharesOutstanding: 16000000000,
          historicalPrices: List.generate(100, (index) {
            final price = 140.0 + (index * 0.2) + (index % 5);
            return ChartData(
              date: DateTime.now().subtract(Duration(days: 100 - index)),
              close: price,
              high: price + 2,
              low: price - 2,
              open: price - 1,
            );
          }),
        );
      }
  }

  // Fallback fundamentals (Market Cap, PE, Beta, FCF, Shares) to enable DCF
  // Figures are approximate as of late 2024/Early 2025
  static final Map<String, Map<String, double>> _staticFundamentals = {
    'AMD': {
      'marketCap': 350000000000,
      'pe': 130.0,
      'beta': 1.68,
      'fcf': 1300000000, 
      'shares': 1620000000,
    },
    'NVDA': {
      'marketCap': 3000000000000,
      'pe': 64.0,
      'beta': 1.65,
      'fcf': 39000000000, 
      'shares': 2460000000,
    },
    'AAPL': {
      'marketCap': 3400000000000,
      'pe': 30.0,
      'beta': 1.25,
      'fcf': 100000000000, 
      'shares': 15300000000,
    },
    'MSFT': {
      'marketCap': 3100000000000,
      'pe': 35.0,
      'beta': 0.90,
      'fcf': 70000000000, 
      'shares': 7430000000,
    },
    'TSLA': {
      'marketCap': 800000000000,
      'pe': 60.0,
      'beta': 2.30,
      'fcf': 4000000000, 
      'shares': 3190000000,
    },
    'GOOG': {
      'marketCap': 2100000000000,
      'pe': 23.0,
      'beta': 1.05,
      'fcf': 69000000000, 
      'shares': 12400000000,
    },
  };
}

@riverpod
StockRepository stockRepository(StockRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return StockRepository(dio);
}

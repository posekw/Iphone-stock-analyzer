class ChartData {
  final DateTime date;
  final double? open;
  final double? high;
  final double? low;
  final double close;
  final int? volume;

  ChartData({
    required this.date,
    required this.close,
    this.open,
    this.high,
    this.low,
    this.volume,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000),
      close: (json['close'] as num).toDouble(),
      open: (json['open'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      volume: json['volume'] as int?,
    );
  }
}

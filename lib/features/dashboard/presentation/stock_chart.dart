import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_valuation_app/features/dashboard/domain/chart_data.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/chart_range_provider.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/dashboard_controller.dart';
import 'package:intl/intl.dart';

class StockChart extends ConsumerWidget {
  final List<ChartData> prices;
  final bool isPositive;
  final String ticker; // Needed to refetch data

  const StockChart({
    super.key,
    required this.prices,
    required this.ticker,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (prices.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(child: Text('No chart data available')),
      );
    }

    final currentRange = ref.watch(chartRangeProvider);
    final closePrices = prices.map((e) => e.close).toList();

    // Min/Max for Viewport
    double minPrice = closePrices.reduce((curr, next) => curr < next ? curr : next);
    double maxPrice = closePrices.reduce((curr, next) => curr > next ? curr : next);
    
    // Support/Resistance Logic
    final supportLevel = prices
        .map((e) => e.low ?? e.close)
        .reduce((curr, next) => curr < next ? curr : next);

    final resistanceLevel = prices
        .map((e) => e.high ?? e.close)
        .reduce((curr, next) => curr > next ? curr : next);

    // Pivot (Last Candle)
    final last = prices.last;
    final pivotPoint = ((last.high ?? last.close) + (last.low ?? last.close) + last.close) / 3;

    // Viewport Padding
    final padding = (maxPrice - minPrice) * 0.15;
    final minY = (supportLevel - padding).clamp(0.0, double.infinity);
    final maxY = resistanceLevel + padding;

    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Technical Analysis',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                   _LegendItem(color: Colors.red.withOpacity(0.5), label: 'Res'),
                   const SizedBox(width: 8),
                   _LegendItem(color: Colors.blue.withOpacity(0.5), label: 'Piv'),
                   const SizedBox(width: 8),
                   _LegendItem(color: Colors.green.withOpacity(0.5), label: 'Sup'),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  horizontalInterval: (maxPrice - minPrice) / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (maxPrice - minPrice) / 4,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (prices.length / 4).floorToDouble(), // Show ~4 dates
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= prices.length) return const SizedBox();
                        final date = prices[index].date;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: prices.length.toDouble() - 1,
                minY: minY,
                maxY: maxY,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: resistanceLevel,
                      color: Colors.red.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                    HorizontalLine(
                      y: pivotPoint,
                      color: Colors.blue.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [2, 2],
                    ),
                    HorizontalLine(
                      y: supportLevel,
                      color: Colors.green.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Theme.of(context).cardColor,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = prices[spot.x.toInt()].date;
                        return LineTooltipItem(
                          '${DateFormat('MMM dd, yyyy').format(date)}\n\$${spot.y.toStringAsFixed(2)}',
                          TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: closePrices.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Interactive Range Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                '1d', '5d', '1mo', '3mo', '6mo', '1y', '5y'
              ].map((range) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _RangeButton(
                  text: range.toUpperCase(),
                  selected: currentRange == range,
                  onTap: () {
                    // Update Provider State
                    ref.read(chartRangeProvider.notifier).setRange(range);
                    // Trigger Data Refresh via DashboardController
                    ref.read(dashboardControllerProvider.notifier).updateRange(ticker);
                  },
                ),
              )).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _RangeButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _RangeButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: Colors.white10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_valuation_app/features/dashboard/domain/chart_data.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/chart_range_provider.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/dashboard_controller.dart';
import 'package:intl/intl.dart';

class StockChart extends ConsumerStatefulWidget {
  final List<ChartData> prices;
  final bool isPositive;
  final String ticker;

  const StockChart({
    super.key,
    required this.prices,
    required this.ticker,
    this.isPositive = true,
  });

  @override
  ConsumerState<StockChart> createState() => _StockChartState();
}

class _StockChartState extends ConsumerState<StockChart> {
  String _selectedRange = '6mo';
  
  @override
  void initState() {
    super.initState();
    _selectedRange = '6mo';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prices.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(child: Text('No chart data available')),
      );
    }

    final closePrices = widget.prices.map((e) => e.close).toList();

    double minPrice = closePrices.reduce((curr, next) => curr < next ? curr : next);
    double maxPrice = closePrices.reduce((curr, next) => curr > next ? curr : next);
    
    final supportLevel = widget.prices
        .map((e) => e.low ?? e.close)
        .reduce((curr, next) => curr < next ? curr : next);

    final resistanceLevel = widget.prices
        .map((e) => e.high ?? e.close)
        .reduce((curr, next) => curr > next ? curr : next);

    final last = widget.prices.last;
    final pivotPoint = ((last.high ?? last.close) + (last.low ?? last.close) + last.close) / 3;

    final padding = (maxPrice - minPrice) * 0.15;
    final minY = (supportLevel - padding).clamp(0.0, double.infinity);
    final maxY = resistanceLevel + padding;

    final color = widget.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      height: 380,
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
          // Header
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
          const SizedBox(height: 16),
          
          // Chart - Simple fl_chart with native touch
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
                      reservedSize: 45,
                      interval: (maxPrice - minPrice) / 4,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (widget.prices.length / 5).floorToDouble().clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= widget.prices.length) return const SizedBox();
                        final date = widget.prices[index].date;
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: widget.prices.length.toDouble() - 1,
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
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF27272A),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= widget.prices.length) return null;
                        final date = widget.prices[index].date;
                        return LineTooltipItem(
                          '${DateFormat('MMM dd').format(date)}\n\$${spot.y.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: const Color(0xFF10B981).withOpacity(0.5),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: const Color(0xFF10B981),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: closePrices.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: color,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
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
          
          // Range Selector Buttons
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['1d', '5d', '1mo', '3mo', '6mo', '1y', '5y'].map((range) {
                final isSelected = _selectedRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRange = range;
                      });
                      // Also update the provider for data fetching
                      ref.read(chartRangeProvider.notifier).setRange(range);
                      ref.read(dashboardControllerProvider.notifier).updateRange(widget.ticker);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF10B981) : const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF3F3F46),
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          range.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
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

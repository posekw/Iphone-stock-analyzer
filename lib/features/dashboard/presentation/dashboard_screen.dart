import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/dashboard_controller.dart';
import 'package:stock_valuation_app/features/auth/presentation/auth_controller.dart';
import 'package:stock_valuation_app/features/valuation/logic/valuation_calculator.dart';
import 'package:stock_valuation_app/features/valuation/presentation/valuation_card.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/stock_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_searchController.text.isNotEmpty) {
      ref.read(dashboardControllerProvider.notifier).searchStock(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter Ticker (e.g. AAPL)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _onSearch,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: stockState.when(
                data: (stock) {
                  if (stock == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics, size: 64, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(height: 16),
                          const Text('Search for a stock to begin analysis'),
                        ],
                      ),
                    );
                  }

                  final isPositive = stock.change >= 0;
                  final color = isPositive ? Colors.green : Colors.red;

                  return ListView(
                    children: [
                      // Stock Header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    stock.symbol,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stock.companyName,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '\$${stock.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Stock Chart
                      StockChart(
                        prices: stock.historicalPrices,
                        ticker: stock.symbol,
                        isPositive: isPositive,
                      ),
                      const SizedBox(height: 16),
                      
                      // Metrics Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          _buildMetricCard(context, 'Market Cap', '\$${(stock.marketCap / 1e9).toStringAsFixed(2)}B'),
                          _buildMetricCard(context, 'P/E Ratio', stock.peRatio.toStringAsFixed(2)),
                          _buildMetricCard(context, 'Beta', stock.beta.toStringAsFixed(2)),
                          _buildMetricCard(context, 'Volume', '${(stock.volume / 1e6).toStringAsFixed(1)}M'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Valuation Analysis
                      ValuationCard(result: ValuationCalculator.calculate(stock)),
                    ],
                  );
                },
                error: (error, _) => Center(
                  child: Text(
                    'Error: $error',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

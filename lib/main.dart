import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_valuation_app/core/theme/app_theme.dart';
import 'package:stock_valuation_app/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: StockValuationApp()));
}

class StockValuationApp extends ConsumerWidget {
  const StockValuationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Stock Valuation Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Default to dark as per requirements
      routerConfig: router,
    );
  }
}

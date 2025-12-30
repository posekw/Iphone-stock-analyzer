import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_valuation_app/features/dashboard/data/stock_repository.dart';
import 'package:stock_valuation_app/features/dashboard/domain/stock.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/chart_range_provider.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<Stock?> build() {
    return null;
  }

  Future<void> searchStock(String ticker) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(stockRepositoryProvider);
      return await repository.getStock(ticker, range: ref.read(chartRangeProvider));
    });
  }

  Future<void> updateRange(String ticker) async {
    // Ideally we separate chart state, but for now reuse main state
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(stockRepositoryProvider);
      return await repository.getStock(ticker, range: ref.read(chartRangeProvider));
    });
  }
}

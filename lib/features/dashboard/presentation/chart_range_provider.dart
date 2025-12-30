import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chart_range_provider.g.dart';

@riverpod
class ChartRange extends _$ChartRange {
  @override
  String build() {
    return '6mo';
  }

  void setRange(String range) {
    state = range;
  }
}

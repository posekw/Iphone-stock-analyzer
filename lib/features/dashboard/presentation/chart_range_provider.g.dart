// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_range_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChartRange)
final chartRangeProvider = ChartRangeProvider._();

final class ChartRangeProvider extends $NotifierProvider<ChartRange, String> {
  ChartRangeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chartRangeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chartRangeHash();

  @$internal
  @override
  ChartRange create() => ChartRange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$chartRangeHash() => r'1c2c55a771486bd555526c20ed1b250c4469bd8c';

abstract class _$ChartRange extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DashboardController)
final dashboardControllerProvider = DashboardControllerProvider._();

final class DashboardControllerProvider
    extends $AsyncNotifierProvider<DashboardController, Stock?> {
  DashboardControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardControllerHash();

  @$internal
  @override
  DashboardController create() => DashboardController();
}

String _$dashboardControllerHash() =>
    r'3b8f95625c743127e7e25f2a3858aa6495ca50aa';

abstract class _$DashboardController extends $AsyncNotifier<Stock?> {
  FutureOr<Stock?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Stock?>, Stock?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Stock?>, Stock?>,
        AsyncValue<Stock?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

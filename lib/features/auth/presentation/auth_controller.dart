import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_valuation_app/features/auth/data/auth_repository.dart';
import 'package:stock_valuation_app/features/auth/domain/user.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() {
    return null; // Initial state is null (not logged in)
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.login(username, password);
    });
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncData(null);
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_valuation_app/core/network/api_client.dart';
import 'package:stock_valuation_app/features/auth/domain/user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['token'];
      final user = User.fromJson(response.data, token);

      // Persist token
      await _storage.write(key: 'jwt_token', value: token);
      
      return user;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getStoredToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  const storage = FlutterSecureStorage();
  return AuthRepository(dio, storage);
}

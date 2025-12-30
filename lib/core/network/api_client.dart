import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  // TODO: Update with your actual WordPress site URL
  // If testing on Android Emulator, use 'http://10.0.2.2/wordpress/wp-json/svp/v1'
  // If testing on iOS Simulator, use 'http://localhost/wordpress/wp-json/svp/v1'
  final options = BaseOptions(
    // baseUrl: 'http://10.0.2.2/wordpress/wp-json/svp/v1', 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    },
  );

  final dio = Dio(options);

  // Add interceptors
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../storage/secure_storage.dart';
import 'api_interceptor.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final apiClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final env = EnvConfig.current;

  final dio = Dio(
    BaseOptions(
      baseUrl: '${env.baseUrl}/${env.apiVersion}',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(ApiInterceptor(secureStorage: secureStorage));

  return dio;
});

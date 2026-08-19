import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/storage_constants.dart';
import '../storage/secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorage secureStorage;

  ApiInterceptor({required this.secureStorage});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.read(StorageConstants.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final orgId = await secureStorage.read(StorageConstants.selectedOrgId);
    if (orgId != null && orgId.isNotEmpty) {
      options.headers['X-Organization-Id'] = orgId;
    }

    final branchId = await secureStorage.read(StorageConstants.selectedBranchId);
    if (branchId != null && branchId.isNotEmpty) {
      options.headers['X-Branch-Id'] = branchId;
    }

    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('\n┌────────────────────────────────────────────────────────────');
      buffer.writeln('│ 🌐 [API REQUEST] ➔ ${options.method.toUpperCase()} ${options.uri}');
      buffer.writeln('├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄');
      if (options.headers.isNotEmpty) {
        buffer.writeln('│ 🔑 Headers:');
        options.headers.forEach((key, value) {
          buffer.writeln('│    • $key: $value');
        });
      }
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('│ 🔍 Query Parameters:');
        options.queryParameters.forEach((key, value) {
          buffer.writeln('│    • $key: $value');
        });
      }
      if (options.data != null) {
        buffer.writeln('│ 📦 Request Body:');
        try {
          final prettyJson = const JsonEncoder.withIndent('   ').convert(options.data);
          buffer.writeln('│    $prettyJson');
        } catch (_) {
          buffer.writeln('│    ${options.data}');
        }
      }
      buffer.writeln('└────────────────────────────────────────────────────────────');
      developer.log(buffer.toString(), name: 'NETWORK');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      final statusCode = response.statusCode ?? 200;
      final statusIcon = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️';

      buffer.writeln('\n┌────────────────────────────────────────────────────────────');
      buffer.writeln('│ $statusIcon [API RESPONSE] ➔ [$statusCode] ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
      buffer.writeln('├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄');
      if (response.data != null) {
        buffer.writeln('│ 📄 Response Body:');
        try {
          final prettyJson = const JsonEncoder.withIndent('   ').convert(response.data);
          buffer.writeln('│    $prettyJson');
        } catch (_) {
          buffer.writeln('│    ${response.data}');
        }
      }
      buffer.writeln('└────────────────────────────────────────────────────────────');
      developer.log(buffer.toString(), name: 'NETWORK');
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      final statusCode = err.response?.statusCode ?? 'NO_STATUS';

      buffer.writeln('\n┌────────────────────────────────────────────────────────────');
      buffer.writeln('│ ❌ [API ERROR] ➔ [$statusCode] ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');
      buffer.writeln('├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄');
      buffer.writeln('│ 🚨 Error Type: ${err.type}');
      buffer.writeln('│ 💬 Message: ${err.message}');
      if (err.response?.data != null) {
        buffer.writeln('│ 📄 Error Response Body:');
        try {
          final prettyJson = const JsonEncoder.withIndent('   ').convert(err.response?.data);
          buffer.writeln('│    $prettyJson');
        } catch (_) {
          buffer.writeln('│    ${err.response?.data}');
        }
      }
      buffer.writeln('└────────────────────────────────────────────────────────────');
      developer.log(buffer.toString(), name: 'NETWORK');
    }

    return handler.next(err);
  }
}

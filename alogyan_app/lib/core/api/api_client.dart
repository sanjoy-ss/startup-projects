import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  final String tenantId;
  final String? branchId;

  ApiClient({
    required String baseUrl,
    required this.tenantId,
    this.branchId,
    Dio? customDio,
  }) : dio = customDio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['x-tenant-id'] = tenantId;
          if (branchId != null) {
            options.headers['x-branch-id'] = branchId;
          }
          return handler.next(options);
        },
      ),
    );
  }
}

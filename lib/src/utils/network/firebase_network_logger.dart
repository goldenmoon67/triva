import 'package:dio/dio.dart';
import 'package:triva/src/utils/logger/app_logger.dart';

/// Firebase HTTP isteklerini ve yanıtlarını loglamak için kullanılan sınıf
class FirebaseNetworkLogger {
  static final FirebaseNetworkLogger _instance = FirebaseNetworkLogger._internal();
  
  factory FirebaseNetworkLogger() {
    return _instance;
  }
  
  FirebaseNetworkLogger._internal();
  
  late Dio _dio;
  
  void initialize() {
    _dio = Dio();
    _setupInterceptors();
  }
  
  Dio get dio => _dio;
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.httpRequest(
            options.method,
            options.uri.toString(),
            headers: options.headers,
            body: options.data,
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.httpResponse(
            response.requestOptions.method,
            response.requestOptions.uri.toString(),
            response.statusCode ?? 0,
            response.data,
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.httpResponse(
            e.requestOptions.method,
            e.requestOptions.uri.toString(),
            e.response?.statusCode ?? 0,
            e.response?.data,
            error: e,
          );
          return handler.next(e);
        },
      ),
    );
  }
  
  /// Firebase API'sine bir istek gönderir
  Future<Response> request({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.request(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          method: method,
          headers: headers,
        ),
      );
      return response;
    } catch (e) {
      AppLogger.error('Firebase HTTP isteği başarısız', error: e);
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';

import 'package:triva/src/utils/logger/app_logger.dart';

/// Firebase Auth işlemlerini REST API üzerinden gerçekleştiren servis
class FirebaseAuthRestService {
  final Dio _dio = Dio();
  
  
  // Firebase Web API Key - Bu değeri Firebase Console'dan almalısınız
  // Normalde bu değer güvenli bir şekilde saklanmalıdır
  // Bu örnek için boş bırakıyoruz, gerçek uygulamada doldurulmalıdır
  final String _apiKey = "AIzaSyD7vUxcjMjbv1UIp_ZO-rMVuoJCsFwMl0U"; // Firebase Console -> Project Settings -> Web API Key
  
  FirebaseAuthRestService() {
    _setupDioInterceptors();
  }
  
  void _setupDioInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.firebase('REST API İsteği: ${options.method} ${options.path}');
          AppLogger.firebase('REST API İstek Verileri: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.firebase('REST API Yanıtı: ${response.statusCode}');
          AppLogger.firebase('REST API Yanıt Verileri: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.error('REST API Hatası', error: e);
          AppLogger.firebase('REST API Hata Detayı: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }
  
  /// REST API üzerinden kullanıcı oluşturur
  Future<Map<String, dynamic>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebase('REST API ile kullanıcı oluşturma başlıyor');
      
      if (_apiKey.isEmpty) {
        throw Exception('Firebase Web API Key tanımlanmamış. Firebase Console -> Project Settings -> Web API Key değerini alın.');
      }
      
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp',
        queryParameters: {'key': _apiKey},
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      
      AppLogger.firebase('REST API kullanıcı oluşturma başarılı');
      return response.data;
    } catch (e) {
      AppLogger.error('REST API kullanıcı oluşturma hatası', error: e);
      rethrow;
    }
  }
  
  /// REST API üzerinden kullanıcı girişi yapar
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebase('REST API ile kullanıcı girişi başlıyor');
      
      if (_apiKey.isEmpty) {
        throw Exception('Firebase Web API Key tanımlanmamış. Firebase Console -> Project Settings -> Web API Key değerini alın.');
      }
      
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword',
        queryParameters: {'key': _apiKey},
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      
      AppLogger.firebase('REST API kullanıcı girişi başarılı');
      return response.data;
    } catch (e) {
      AppLogger.error('REST API kullanıcı girişi hatası', error: e);
      rethrow;
    }
  }
  
  /// REST API üzerinden kullanıcı profili günceller
  Future<Map<String, dynamic>> updateProfile({
    required String idToken,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      AppLogger.firebase('REST API ile profil güncelleme başlıyor');
      
      if (_apiKey.isEmpty) {
        throw Exception('Firebase Web API Key tanımlanmamış. Firebase Console -> Project Settings -> Web API Key değerini alın.');
      }
      
      final data = {
        'idToken': idToken,
        'returnSecureToken': true,
      };
      
      if (displayName != null) {
        data['displayName'] = displayName;
      }
      
      if (photoUrl != null) {
        data['photoUrl'] = photoUrl;
      }
      
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:update',
        queryParameters: {'key': _apiKey},
        data: data,
      );
      
      AppLogger.firebase('REST API profil güncelleme başarılı');
      return response.data;
    } catch (e) {
      AppLogger.error('REST API profil güncelleme hatası', error: e);
      rethrow;
    }
  }
  

}

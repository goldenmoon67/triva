import 'dart:developer' as developer;
import 'dart:convert';

/// Firebase ve diğer işlemleri detaylı şekilde loglamak için kullanılan sınıf
class AppLogger {
  static const String _firebaseTag = 'Firebase';
  static const String _authTag = 'FirebaseAuth';
  static const String _firestoreTag = 'Firestore';
  static const String _storageTag = 'Storage';
  static const String _networkTag = 'Network';
  static const String _errorTag = 'Error';

  /// Firebase ile ilgili genel loglar
  static void firebase(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_firebaseTag, message, error: error, stackTrace: stackTrace);
  }

  /// Firebase Authentication ile ilgili loglar
  static void auth(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_authTag, message, error: error, stackTrace: stackTrace);
  }

  /// Firestore ile ilgili loglar
  static void firestore(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_firestoreTag, message, error: error, stackTrace: stackTrace);
  }

  /// Firebase Storage ile ilgili loglar
  static void storage(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_storageTag, message, error: error, stackTrace: stackTrace);
  }

  /// Network istekleri ile ilgili loglar
  static void network(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_networkTag, message, error: error, stackTrace: stackTrace);
  }

  /// Hata logları
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_errorTag, message, error: error, stackTrace: stackTrace, isError: true);
  }

  /// Genel log metodu
  static void log(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(tag, message, error: error, stackTrace: stackTrace);
  }

  /// Log yazdırma işlemini gerçekleştiren temel metod
  static void _log(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool isError = false,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    
    if (isError) {
      developer.log(
        logMessage,
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      developer.log(
        logMessage,
        name: tag,
        error: error,
      );
    }
    
    // Konsola daha okunaklı bir format ile yazdır
    print('[$timestamp] [$tag] $message');
    if (error != null) {
      print('[$timestamp] [$tag] Error: $error');
    }
    if (stackTrace != null) {
      print('[$timestamp] [$tag] StackTrace: $stackTrace');
    }
  }
  
  /// Firebase isteklerini ve yanıtlarını detaylı loglamak için
  static void firebaseRequest(String method, String path, {Map<String, dynamic>? data}) {
    final requestInfo = data != null 
        ? 'İstek: $method $path, Data: $data' 
        : 'İstek: $method $path';
    _log(_firebaseTag, requestInfo);
  }
  
  /// Firebase yanıtlarını loglamak için
  static void firebaseResponse(String method, String path, dynamic response, {Object? error}) {
    if (error != null) {
      _log(_firebaseTag, 'Yanıt Hatası: $method $path', error: error, isError: true);
    } else {
      _log(_firebaseTag, 'Yanıt Başarılı: $method $path, Yanıt: $response');
    }
  }
  
  /// HTTP isteklerini loglamak için
  static void httpRequest(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    final requestInfo = StringBuffer();
    requestInfo.writeln('HTTP İstek: $method $url');
    
    if (headers != null && headers.isNotEmpty) {
      requestInfo.writeln('Headers: ${_formatJson(headers)}');
    }
    
    if (body != null) {
      requestInfo.writeln('Body: ${_formatJson(body)}');
    }
    
    _log(_networkTag, requestInfo.toString());
  }
  
  /// HTTP yanıtlarını loglamak için
  static void httpResponse(String method, String url, int statusCode, dynamic body, {Object? error}) {
    final responseInfo = StringBuffer();
    responseInfo.writeln('HTTP Yanıt: $method $url');
    responseInfo.writeln('Status: $statusCode');
    
    if (error != null) {
      _log(_networkTag, responseInfo.toString(), error: error, isError: true);
    } else {
      if (body != null) {
        responseInfo.writeln('Body: ${_formatJson(body)}');
      }
      _log(_networkTag, responseInfo.toString());
    }
  }
  
  /// JSON formatında veriyi düzenli göstermek için
  static String _formatJson(dynamic json) {
    if (json == null) return 'null';
    
    try {
      if (json is String) {
        // Eğer zaten string ise, JSON olarak parse etmeyi dene
        final object = jsonDecode(json);
        return const JsonEncoder.withIndent('  ').convert(object);
      } else if (json is Map || json is List) {
        // Map veya List ise doğrudan encode et
        return const JsonEncoder.withIndent('  ').convert(json);
      } else {
        // Diğer tipler için toString kullan
        return json.toString();
      }
    } catch (e) {
      // JSON parse edilemezse orijinal değeri döndür
      return json.toString();
    }
  }
}

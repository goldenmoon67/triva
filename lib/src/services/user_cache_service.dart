import 'package:shared_preferences/shared_preferences.dart';
import 'package:triva/src/utils/logger/app_logger.dart';

/// Kullanıcı bilgilerini önbellekte saklayan servis
class UserCacheService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserDisplayName = 'user_display_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLastLoginTime = 'last_login_time';

  /// Kullanıcı giriş bilgilerini önbelleğe kaydet
  static Future<bool> saveUserLoginInfo({
    required String userId,
    String? email,
    String? displayName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final now = DateTime.now();
      AppLogger.log('UserCacheService', 'Kullanıcı bilgileri önbelleğe kaydediliyor: $userId');
      
      await prefs.setString(_keyUserId, userId);
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyLastLoginTime, now.toIso8601String());
      
      if (email != null) {
        await prefs.setString(_keyUserEmail, email);
      }
      
      if (displayName != null) {
        await prefs.setString(_keyUserDisplayName, displayName);
      }
      
      AppLogger.log('UserCacheService', 'Kullanıcı bilgileri başarıyla önbelleğe kaydedildi');
      return true;
    } catch (e) {
      AppLogger.error('Kullanıcı bilgileri önbelleğe kaydedilemedi', error: e);
      return false;
    }
  }

  /// Kullanıcı ID'sini önbellekten al
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);
      
      if (userId != null) {
        AppLogger.log('UserCacheService', 'Kullanıcı ID önbellekten alındı: $userId');
      } else {
        AppLogger.log('UserCacheService', 'Önbellekte kullanıcı ID bulunamadı');
      }
      
      return userId;
    } catch (e) {
      AppLogger.error('Kullanıcı ID önbellekten alınamadı', error: e);
      return null;
    }
  }

  /// Kullanıcı email adresini önbellekten al
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      AppLogger.error('Kullanıcı email önbellekten alınamadı', error: e);
      return null;
    }
  }

  /// Kullanıcı görünen adını önbellekten al
  static Future<String?> getUserDisplayName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserDisplayName);
    } catch (e) {
      AppLogger.error('Kullanıcı görünen adı önbellekten alınamadı', error: e);
      return null;
    }
  }

  /// Kullanıcının giriş yapıp yapmadığını kontrol et
  static Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      AppLogger.error('Kullanıcı giriş durumu önbellekten alınamadı', error: e);
      return false;
    }
  }

  /// Son giriş zamanını al
  static Future<DateTime?> getLastLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_keyLastLoginTime);
      
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      AppLogger.error('Son giriş zamanı önbellekten alınamadı', error: e);
      return null;
    }
  }

  /// Kullanıcı çıkış yaptığında önbellekteki bilgileri temizle
  static Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserDisplayName);
      await prefs.setBool(_keyIsLoggedIn, false);
      
      AppLogger.log('UserCacheService', 'Kullanıcı bilgileri önbellekten temizlendi');
      return true;
    } catch (e) {
      AppLogger.error('Kullanıcı bilgileri önbellekten temizlenemedi', error: e);
      return false;
    }
  }
}

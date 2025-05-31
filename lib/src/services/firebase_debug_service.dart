import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triva/src/utils/logger/app_logger.dart';
import 'package:triva/src/utils/network/firebase_network_logger.dart';

/// Firebase işlemlerini detaylı şekilde loglamak için kullanılan servis
class FirebaseDebugService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseNetworkLogger _networkLogger;
  
  FirebaseDebugService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore,
       _networkLogger = FirebaseNetworkLogger() {
    _networkLogger.initialize();
    _setupAuthStateListener();
  }
  
  void _setupAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        AppLogger.auth('Auth durumu değişti: Kullanıcı giriş yaptı - ${user.uid}');
        _logUserDetails(user);
      } else {
        AppLogger.auth('Auth durumu değişti: Kullanıcı çıkış yaptı');
      }
    });
  }
  
  void _logUserDetails(User user) {
    final details = {
      'uid': user.uid,
      'email': user.email,
      'emailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'providerData': user.providerData.map((info) => {
        'providerId': info.providerId,
        'uid': info.uid,
        'displayName': info.displayName,
        'email': info.email,
      }).toList(),
    };
    
    AppLogger.auth('Kullanıcı detayları: ${details.toString()}');
  }
  
  /// Kullanıcı oluşturma işlemini detaylı şekilde loglar
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebase('DEBUG: createUserWithEmailAndPassword başlıyor');
      AppLogger.firebase('DEBUG: Email: $email, Password: ***');
      
      // Firebase Auth'un çalışıp çalışmadığını kontrol et
      try {
        final currentUser = _auth.currentUser;
        AppLogger.firebase('Mevcut kullanıcı kontrolü: ${currentUser != null ? "Oturum açık" : "Oturum kapalı"}');
      } catch (authCheckError) {
        AppLogger.error('Firebase Auth kontrolü hatası', error: authCheckError);
      }
      
      // Firebase Auth kullanıcı oluşturma - try/catch içinde adım adım ilerle
      AppLogger.firebase('createUserWithEmailAndPassword metodu çağrılıyor...');
      
      try {
        // Önce email ve password parametrelerini kontrol et
        if (email.isEmpty || password.isEmpty) {
          throw Exception('Email veya şifre boş olamaz');
        }
        
        // Firebase Auth'un hazır olduğunu kontrol et
        if (!_auth.isSignInWithEmailLink(email)) {
          AppLogger.firebase('Email ile giriş bağlantısı değil, normal kayıt devam ediyor');
        }
        
        // Kullanıcı oluştur
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        AppLogger.firebase('Kullanıcı başarıyla oluşturuldu - UID: ${userCredential.user?.uid}');
        
        if (userCredential.user != null) {
          AppLogger.firebase('DEBUG: User tipi: ${userCredential.user.runtimeType}');
          AppLogger.firebase('DEBUG: User metadata: ${userCredential.user?.metadata.toString()}');
        }
        
        return userCredential;
      } catch (innerError) {
        AppLogger.error('createUserWithEmailAndPassword iç hatası', error: innerError);
        AppLogger.firebase('İç hata tipi: ${innerError.runtimeType}');
        AppLogger.firebase('İç hata mesajı: ${innerError.toString()}');
        
        // Hata türüne göre özel işlemler
        if (innerError is FirebaseAuthException) {
          AppLogger.firebase('Firebase Auth Hata Kodu: ${innerError.code}');
          AppLogger.firebase('Firebase Auth Hata Mesajı: ${innerError.message}');
          
          // Hata koduna göre özel işlemler
          switch (innerError.code) {
            case 'email-already-in-use':
              AppLogger.firebase('Bu email adresi zaten kullanımda');
              break;
            case 'invalid-email':
              AppLogger.firebase('Geçersiz email formatı');
              break;
            case 'operation-not-allowed':
              AppLogger.firebase('Email/şifre girişi etkin değil');
              break;
            case 'weak-password':
              AppLogger.firebase('Şifre çok zayıf');
              break;
            default:
              AppLogger.firebase('Bilinmeyen Firebase Auth hatası');
          }
        }
        
        rethrow;
      }
    } catch (e) {
      AppLogger.error('Kullanıcı oluşturma hatası', error: e);
      AppLogger.firebase('Genel hata tipi: ${e.runtimeType}');
      AppLogger.error('DEBUG: Kullanıcı oluşturma hatası', error: e);
      AppLogger.firebase('DEBUG: Hata tipi: ${e.runtimeType}');
      AppLogger.firebase('DEBUG: Hata mesajı: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Kullanıcı girişi işlemini detaylı şekilde loglar
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebase('DEBUG: signInWithEmailAndPassword başlıyor');
      AppLogger.firebase('DEBUG: Email: $email, Password: ***');
      
      // İstek detaylarını loglama
      final requestData = {
        'email': email,
        'password': '***', // Güvenlik için şifreyi loglamıyoruz
        'returnSecureToken': true,
      };
      
      AppLogger.firebase('DEBUG: İstek verisi: $requestData');
      
      // Kullanıcı girişi
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Yanıt detaylarını loglama
      AppLogger.firebase('DEBUG: Kullanıcı giriş yaptı: ${userCredential.user?.uid}');
      
      if (userCredential.user != null) {
        _logUserDetails(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      AppLogger.error('DEBUG: Kullanıcı girişi hatası', error: e);
      AppLogger.firebase('DEBUG: Hata tipi: ${e.runtimeType}');
      AppLogger.firebase('DEBUG: Hata mesajı: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Firestore belgesini detaylı şekilde loglar
  Future<DocumentSnapshot> getDocument(String path) async {
    try {
      AppLogger.firebase('DEBUG: Firestore belge okuma başlıyor: $path');
      
      final docRef = _firestore.doc(path);
      AppLogger.firebase('DEBUG: Belge referansı: ${docRef.toString()}');
      
      final snapshot = await docRef.get();
      
      if (snapshot.exists) {
        AppLogger.firebase('DEBUG: Belge bulundu: $path');
        AppLogger.firebase('DEBUG: Belge verisi: ${snapshot.data().toString()}');
      } else {
        AppLogger.firebase('DEBUG: Belge bulunamadı: $path');
      }
      
      return snapshot;
    } catch (e) {
      AppLogger.error('DEBUG: Firestore belge okuma hatası', error: e);
      rethrow;
    }
  }
  
  /// Firestore belgesini detaylı şekilde loglar ve kaydeder
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    try {
      AppLogger.firebase('DEBUG: Firestore belge yazma başlıyor: $path');
      AppLogger.firebase('DEBUG: Belge verisi: $data');
      
      final docRef = _firestore.doc(path);
      AppLogger.firebase('DEBUG: Belge referansı: ${docRef.toString()}');
      
      await docRef.set(data);
      
      AppLogger.firebase('DEBUG: Belge başarıyla kaydedildi: $path');
    } catch (e) {
      AppLogger.error('DEBUG: Firestore belge yazma hatası', error: e);
      rethrow;
    }
  }
}

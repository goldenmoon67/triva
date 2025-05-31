import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:triva/src/models/user_model.dart';
import 'package:triva/src/utils/logger/app_logger.dart';
import 'package:triva/src/services/user_cache_service.dart';

/// A service class that provides access to Firebase services
class FirebaseService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Getters for Firebase instances
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  
  // Firebase bağlantısını kontrol et ve logla
  Future<bool> checkFirebaseConnection() async {
    bool isConnected = true;
    
    try {
      // Firestore'a bağlantıyı kontrol et
      AppLogger.firebaseRequest('GET', 'collection/test');
      final result = await _firestore.collection('test').limit(1).get();
      AppLogger.firestore('Firebase Firestore bağlantısı başarılı');
      AppLogger.firebaseResponse('GET', 'collection/test', 'Döküman sayısı: ${result.docs.length}');
    } catch (e) {
      AppLogger.error('Firestore bağlantı hatası', error: e);
      isConnected = false;
    }
    
    try {
      // Auth servisini kontrol et
      AppLogger.firebaseRequest('GET', 'authStateChanges');
      await _auth.authStateChanges().first;
      AppLogger.auth('Firebase Auth bağlantısı başarılı');
      AppLogger.firebaseResponse('GET', 'authStateChanges', 'Başarılı');
    } catch (e) {
      AppLogger.error('Auth bağlantı hatası', error: e);
      isConnected = false;
    }
    
    try {
      // Storage bağlantısını kontrol et - sadece referans alarak test et
      AppLogger.firebaseRequest('GET', 'storage/ref');
      _storage.ref(); // Referansı alıp herhangi bir işlem yapmadan bağlantıyı test ediyoruz
      AppLogger.storage('Firebase Storage bağlantısı başarılı');
      AppLogger.firebaseResponse('GET', 'storage/ref', 'Başarılı');
    } catch (e) {
      AppLogger.error('Storage bağlantı hatası', error: e);
      isConnected = false;
    }
    
    if (isConnected) {
      AppLogger.firebase('Tüm Firebase servisleri başarıyla bağlandı');
    } else {
      AppLogger.error('Bazı Firebase servisleri bağlanamadı');
    }
    
    return isConnected;
  }
  
  // Current user getter
  User? get currentUser => _auth.currentUser;
  
  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.firebaseRequest('POST', 'auth/signInWithEmailAndPassword', data: {'email': email});
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.auth('Kullanıcı girişi başarılı: ${result.user?.uid}');
      AppLogger.firebaseResponse('POST', 'auth/signInWithEmailAndPassword', 'Kullanıcı ID: ${result.user?.uid}');
      return result;
    } catch (e) {
      AppLogger.error('Kullanıcı girişi başarısız', error: e);
      AppLogger.firebaseResponse('POST', 'auth/signInWithEmailAndPassword', null, error: e);
      rethrow;
    }
  }
  
  // Create user with email and password and save to Firestore
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      AppLogger.firebase('Kullanıcı oluşturma başlıyor - Email: $email');
      AppLogger.firebaseRequest('POST', 'auth/createUserWithEmailAndPassword', 
          data: {'email': email, 'displayName': displayName});
      
      // Firebase Auth sürümünü loglama
      AppLogger.firebase('Firebase Auth sürümü: ${_auth.runtimeType}');
      
      // Kullanıcı oluşturma işlemini try-catch içinde izole edelim
      UserCredential userCredential;
      try {
        // Alternatif yöntem kullanarak kullanıcı oluşturma
        AppLogger.firebase('createUserWithEmailAndPassword metodu çağrılıyor');
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        AppLogger.firebase('createUserWithEmailAndPassword metodu başarılı');
      } catch (authError) {
        AppLogger.error('Firebase Auth kullanıcı oluşturma hatası', error: authError);
        AppLogger.firebase('Hata detayı: ${authError.toString()}');
        AppLogger.firebase('Hata tipi: ${authError.runtimeType}');
        rethrow;
      }
      
      // UserCredential detaylarını loglama
      AppLogger.firebase('UserCredential oluşturuldu: ${userCredential.toString()}');
      AppLogger.firebase('UserCredential tipi: ${userCredential.runtimeType}');
      
      // Kullanıcı null kontrolü
      final user = userCredential.user;
      AppLogger.firebase('Kullanıcı nesnesi: ${user.toString()}');
      
      if (user == null) {
        AppLogger.error('Kullanıcı oluşturuldu ancak kullanıcı nesnesi null');
        throw Exception('Kullanıcı oluşturuldu ancak kullanıcı nesnesi null');
      }
      
      AppLogger.auth('Kullanıcı oluşturuldu: ${user.uid}');
      
      // Create user model
      final userModel = UserModel.initial(user.uid, email);
      AppLogger.firebase('Kullanıcı modeli oluşturuldu: ${userModel.id}');
      
      // Save user to Firestore
      try {
        AppLogger.firebase('Kullanıcı Firestore\'a kaydediliyor');
        await saveUserToFirestore(userModel);
        AppLogger.firebase('Kullanıcı Firestore\'a başarıyla kaydedildi');
      } catch (firestoreError) {
        AppLogger.error('Kullanıcı Firestore\'a kaydedilemedi, ancak Auth\'da oluşturuldu', error: firestoreError);
        // Firestore hatası olsa bile devam ediyoruz, kullanıcı oluştu
      }
      
      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        try {
          AppLogger.firebase('Kullanıcı profili güncelleniyor: $displayName');
          AppLogger.firebaseRequest('POST', 'auth/updateProfile', 
              data: {'uid': user.uid, 'displayName': displayName});
          
          await user.updateDisplayName(displayName);
          await updateUserData(user.uid, {'displayName': displayName});
          
          AppLogger.auth('Kullanıcı profili güncellendi: ${user.uid}');
        } catch (profileError) {
          AppLogger.error('Profil güncellenemedi, ancak kullanıcı oluşturuldu', error: profileError);
          // Profil güncelleme hatası olsa bile devam ediyoruz
        }
      }
      
      AppLogger.firebase('Kullanıcı başarıyla oluşturuldu ve Firestore\'a kaydedildi');
      AppLogger.firebaseResponse('POST', 'auth/createUserWithEmailAndPassword', 
          'Kullanıcı ID: ${user.uid}');
      
      return userCredential;
    } catch (e) {
      AppLogger.error('Kullanıcı oluşturma hatası', error: e);
      AppLogger.firebase('Genel hata detayı: ${e.toString()}');
      AppLogger.firebase('Genel hata tipi: ${e.runtimeType}');
      AppLogger.firebaseResponse('POST', 'auth/createUserWithEmailAndPassword', null, error: e);
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      AppLogger.firebaseRequest('POST', 'auth/signOut');
      
      // Önce önbellekteki kullanıcı bilgilerini temizle
      final userId = _auth.currentUser?.uid;
      await UserCacheService.clearUserData();
      AppLogger.log('FirebaseService', 'Kullanıcı bilgileri önbellekten temizlendi');
      
      // Sonra Firebase Auth'dan çıkış yap
      await _auth.signOut();
      
      AppLogger.auth('Kullanıcı çıkış yaptı' + (userId != null ? ': $userId' : ''));
      AppLogger.firebaseResponse('POST', 'auth/signOut', 'Başarılı');
    } catch (e) {
      AppLogger.error('Kullanıcı çıkış yapamadı', error: e);
      AppLogger.firebaseResponse('POST', 'auth/signOut', null, error: e);
      rethrow;
    }
  }
  
  // Get a Firestore collection reference
  CollectionReference collection(String path) {
    AppLogger.firestore('Koleksiyon referansı alındı: $path');
    return _firestore.collection(path);
  }
  
  // Get a Firestore document reference
  DocumentReference document(String path) {
    AppLogger.firestore('Doküman referansı alındı: $path');
    return _firestore.doc(path);
  }
  
  // Get a Storage reference
  Reference storageRef(String path) {
    AppLogger.storage('Storage referansı alındı: $path');
    return _storage.ref(path);
  }
  
  // Firebase durumunu konsola yazdır
  void logFirebaseStatus() {
    AppLogger.firebase('Firebase durumu:');
    AppLogger.auth('Auth başlatıldı');
    AppLogger.firestore('Firestore başlatıldı');
    AppLogger.storage('Storage başlatıldı');
    
    // Bağlantı kontrolünü başlat
    checkFirebaseConnection().then((success) {
      AppLogger.firebase('Firebase bağlantı testi sonucu: ${success ? "BAŞARILI" : "BAŞARISIZ"}');
    });
  }
  
  // Save user to Firestore
  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      AppLogger.firebaseRequest('SET', 'users/${user.id}', data: user.toMap());
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      AppLogger.firestore('Kullanıcı Firestore\'a kaydedildi: ${user.id}');
      AppLogger.firebaseResponse('SET', 'users/${user.id}', 'Başarılı');
    } catch (e) {
      AppLogger.error('Kullanıcı Firestore\'a kaydedilemedi', error: e);
      AppLogger.firebaseResponse('SET', 'users/${user.id}', null, error: e);
      rethrow;
    }
  }
  
  // Get user from Firestore
  Future<UserModel?> getUserFromFirestore(String uid) async {
    try {
      AppLogger.firebaseRequest('GET', 'users/$uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!);
        AppLogger.firestore('Kullanıcı Firestore\'dan alındı: $uid');
        AppLogger.firebaseResponse('GET', 'users/$uid', 'Kullanıcı bulundu: ${user.email}');
        return user;
      }
      
      AppLogger.firestore('Kullanıcı bulunamadı: $uid');
      AppLogger.firebaseResponse('GET', 'users/$uid', 'Kullanıcı bulunamadı');
      return null;
    } catch (e) {
      AppLogger.error('Kullanıcı Firestore\'dan alınamadı', error: e);
      AppLogger.firebaseResponse('GET', 'users/$uid', null, error: e);
      return null;
    }
  }
  
  // Firestore'dan kullanıcı verilerini alma
  Future<UserModel?> getUserData(String userId) async {
    try {
      AppLogger.firebaseRequest('GET', 'users/$userId');
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      if (docSnapshot.exists) {
        final userData = docSnapshot.data();
        if (userData != null) {
          AppLogger.firebaseResponse('GET', 'users/$userId', 'Başarılı');
          
          // Timestamp'leri DateTime'a çevir
          final createdAt = userData['createdAt'] is Timestamp 
              ? (userData['createdAt'] as Timestamp).toDate() 
              : DateTime.now();
          
          final updatedAt = userData['updatedAt'] is Timestamp 
              ? (userData['updatedAt'] as Timestamp).toDate() 
              : DateTime.now();
          
          // UserModel oluştur
          return UserModel(
            id: userData['id'] as String? ?? userId,
            email: userData['email'] as String? ?? '',
            displayName: userData['displayName'] as String?,
            photoUrl: userData['photoUrl'] as String?,
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
        }
      }
      
      // Kullanıcı bulunamadıysa, Firebase Auth'daki bilgilerle temel bir model oluştur
      final user = _auth.currentUser;
      if (user != null) {
        return UserModel.initial(userId, user.email ?? '');
      }
      
      AppLogger.firebaseResponse('GET', 'users/$userId', 'Kullanıcı bulunamadı');
      return null;
    } catch (e) {
      AppLogger.error('Kullanıcı verileri alınamadı', error: e);
      AppLogger.firebaseResponse('GET', 'users/$userId', null, error: e);
      return null;
    }
  }
  
  // Önbellekteki kullanıcı ID'si ile Firestore'dan kullanıcı verilerini çekme
  Future<Map<String, dynamic>?> getUserDataFromFirestore(String userId) async {
    try {
      AppLogger.log('FirebaseService', 'Firestore\'dan kullanıcı verileri çekiliyor: $userId');
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      if (docSnapshot.exists) {
        final userData = docSnapshot.data();
        if (userData != null) {
          AppLogger.log('FirebaseService', 'Kullanıcı verileri başarıyla çekildi');
          return userData;
        }
      }
      
      // Kullanıcı verisi yoksa, temel kullanıcı bilgilerini oluştur
      final user = _auth.currentUser;
      if (user != null) {
        final basicUserData = {
          'id': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'Kullanıcı',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'photoURL': user.photoURL,
          'phoneNumber': user.phoneNumber,
        };
        
        // Temel kullanıcı verilerini Firestore'a kaydet
        await _firestore.collection('users').doc(userId).set(basicUserData);
        AppLogger.log('FirebaseService', 'Temel kullanıcı verileri oluşturuldu ve kaydedildi');
        
        return basicUserData;
      }
      
      AppLogger.log('FirebaseService', 'Kullanıcı verileri bulunamadı');
      return null;
    } catch (e) {
      AppLogger.error('Firestore\'dan kullanıcı verileri çekilemedi', error: e);
      return null;
    }
  }
  
  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      final updateData = {
        ...data,
        'updatedAt': Timestamp.now(),
      };
      
      AppLogger.firebaseRequest('UPDATE', 'users/$uid', data: updateData);
      await _firestore.collection('users').doc(uid).update(updateData);
      
      AppLogger.firestore('Kullanıcı bilgileri güncellendi: $uid');
      AppLogger.firebaseResponse('UPDATE', 'users/$uid', 'Başarılı');
    } catch (e) {
      AppLogger.error('Kullanıcı bilgileri güncellenemedi', error: e);
      AppLogger.firebaseResponse('UPDATE', 'users/$uid', null, error: e);
      rethrow;
    }
  }
  
  // Delete user from Firebase Auth and Firestore
  Future<void> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final uid = user.uid;
        
        // Delete from Firestore first
        AppLogger.firebaseRequest('DELETE', 'users/$uid');
        await _firestore.collection('users').doc(uid).delete();
        AppLogger.firestore('Kullanıcı Firestore\'dan silindi: $uid');
        
        // Then delete from Auth
        AppLogger.firebaseRequest('DELETE', 'auth/user');
        await user.delete();
        AppLogger.auth('Kullanıcı Auth\'dan silindi: $uid');
        
        AppLogger.firebase('Kullanıcı tamamen silindi: $uid');
        AppLogger.firebaseResponse('DELETE', 'users/$uid', 'Başarılı');
        AppLogger.firebaseResponse('DELETE', 'auth/user', 'Başarılı');
      }
    } catch (e) {
      AppLogger.error('Kullanıcı silinemedi', error: e);
      AppLogger.firebaseResponse('DELETE', 'auth/user', null, error: e);
      rethrow;
    }
  }
}

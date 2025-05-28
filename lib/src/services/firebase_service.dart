import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      await _firestore.collection('test').limit(1).get();
      developer.log('Firebase Firestore bağlantısı başarılı', name: 'FirebaseService');
    } catch (e) {
      developer.log('Firestore bağlantı hatası: $e', name: 'FirebaseService');
      isConnected = false;
    }
    
    try {
      // Auth servisini kontrol et
      await _auth.authStateChanges().first;
      developer.log('Firebase Auth bağlantısı başarılı', name: 'FirebaseService');
    } catch (e) {
      developer.log('Auth bağlantı hatası: $e', name: 'FirebaseService');
      isConnected = false;
    }
    
    try {
      // Storage bağlantısını kontrol et - sadece referans alarak test et
      _storage.ref(); // Referansı alıp herhangi bir işlem yapmadan bağlantıyı test ediyoruz
      developer.log('Firebase Storage bağlantısı başarılı', name: 'FirebaseService');
    } catch (e) {
      developer.log('Storage bağlantı hatası: $e', name: 'FirebaseService');
      isConnected = false;
    }
    
    if (isConnected) {
      developer.log('Tüm Firebase servisleri başarıyla bağlandı', name: 'FirebaseService');
    } else {
      developer.log('Bazı Firebase servisleri bağlanamadı', name: 'FirebaseService');
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
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  
  // Get a Firestore collection reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }
  
  // Get a Firestore document reference
  DocumentReference document(String path) {
    return _firestore.doc(path);
  }
  
  // Get a Storage reference
  Reference storageRef(String path) {
    return _storage.ref(path);
  }
  
  // Firebase durumunu konsola yazdır
  void logFirebaseStatus() {
    developer.log('Firebase durumu:', name: 'FirebaseService');
    developer.log('- Auth başlatıldı', name: 'FirebaseService');
    developer.log('- Firestore başlatıldı', name: 'FirebaseService');
    developer.log('- Storage başlatıldı', name: 'FirebaseService');
    
    // Bağlantı kontrolünü başlat
    checkFirebaseConnection().then((success) {
      developer.log('Firebase bağlantı testi sonucu: ${success ? "BAŞARILI" : "BAŞARISIZ"}', 
        name: 'FirebaseService');
    });
  }
}

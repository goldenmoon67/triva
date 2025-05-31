import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:triva/src/services/firebase_service.dart';
import 'package:triva/src/services/user_cache_service.dart';
import 'package:triva/src/utils/logger/app_logger.dart';
import 'package:triva/src/utils/navigation/app_router.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Firebase bağlantısını kontrol et
      await _firebaseService.checkFirebaseConnection();
      
      // Önbellekteki kullanıcı durumunu kontrol et
      final isLoggedIn = await UserCacheService.isUserLoggedIn();
      final cachedUserId = await UserCacheService.getUserId();
      
      AppLogger.log('SplashScreen', 'Önbellek kontrolü - Giriş durumu: $isLoggedIn, Kullanıcı ID: $cachedUserId');
      
      // Firebase Auth'daki mevcut kullanıcıyı kontrol et
      final currentUser = _firebaseService.currentUser;
      
      // 2 saniye bekleyerek splash ekranını göster
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      if (currentUser != null && isLoggedIn) {
        // Kullanıcı hem Firebase'de hem önbellekte giriş yapmış durumda
        AppLogger.log('SplashScreen', 'Kullanıcı giriş yapmış: ${currentUser.uid}');
        
        // Önbellekteki ID ile Firebase ID'si uyuşuyor mu kontrol et
        if (cachedUserId != currentUser.uid) {
          // ID'ler uyuşmuyorsa önbelleği güncelle
          AppLogger.log('SplashScreen', 'Önbellekteki ID ile Firebase ID uyuşmuyor, önbellek güncelleniyor');
          await UserCacheService.saveUserLoginInfo(
            userId: currentUser.uid,
            email: currentUser.email,
            displayName: currentUser.displayName,
          );
        }
        
        // Dashboard ekranına yönlendir
        _navigateToDashboard();
      } else if (currentUser != null && !isLoggedIn) {
        // Firebase'de oturum var ama önbellekte yok, önbelleği güncelle
        AppLogger.log('SplashScreen', 'Firebase\'de oturum var ama önbellekte yok, önbellek güncelleniyor');
        await UserCacheService.saveUserLoginInfo(
          userId: currentUser.uid,
          email: currentUser.email,
          displayName: currentUser.displayName,
        );
        
        // Dashboard ekranına yönlendir
        _navigateToDashboard();
      } else if (currentUser == null && isLoggedIn) {
        // Önbellekte oturum var ama Firebase'de yok, önbelleği temizle
        AppLogger.log('SplashScreen', 'Önbellekte oturum var ama Firebase\'de yok, önbellek temizleniyor');
        await UserCacheService.clearUserData();
        
        // Ana ekrana yönlendir
        _navigateToHome();
      } else {
        // Kullanıcı giriş yapmamış
        AppLogger.log('SplashScreen', 'Kullanıcı giriş yapmamış');
        
        // Ana ekrana yönlendir
        _navigateToHome();
      }
    } catch (e) {
      AppLogger.error('Kimlik doğrulama durumu kontrol edilirken hata', error: e);
      
      // Hata durumunda ana ekrana yönlendir
      if (mounted) {
        _navigateToHome();
      }
    }
  }
  
  void _navigateToDashboard() {
    try {
      context.router.replace(const DashboardRoute());
      AppLogger.log('SplashScreen', 'Dashboard ekranına yönlendirildi');
    } catch (e) {
      AppLogger.error('Dashboard yönlendirme hatası', error: e);
      _navigateToHome(); // Fallback olarak ana ekrana yönlendir
    }
  }
  
  void _navigateToHome() {
    try {
      context.router.replace(const HomeRoute());
      AppLogger.log('SplashScreen', 'Ana ekrana yönlendirildi');
    } catch (e) {
      AppLogger.error('Ana ekran yönlendirme hatası', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo veya icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.safety_check,
                  size: 72,
                  color: Color(0xFF004CFF),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Uygulama adı
            const Text(
              'Triva',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w700,
                fontSize: 36,
                color: Color(0xFF202020),
              ),
            ),
            const SizedBox(height: 8),
            // Slogan
            const Text(
              'Eşyalarınızı güvenle emanet edin',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w300,
                fontSize: 16,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 48),
            // Yükleniyor göstergesi
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004CFF)),
            ),
          ],
        ),
      ),
    );
  }
}

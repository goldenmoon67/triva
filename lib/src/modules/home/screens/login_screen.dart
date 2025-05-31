import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:triva/src/services/firebase_service.dart';
import 'package:triva/src/utils/logger/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triva/src/utils/navigation/app_router.dart';
import 'package:triva/src/services/user_cache_service.dart';
import 'package:triva/src/modules/home/screens/dashboard_screen.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen e-posta adresinizi girin';
      });
      return;
    }
    
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen şifrenizi girin';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.log('LoginScreen', 'Giriş denemesi: ${_emailController.text.trim()}');
      
      // Kullanıcı girişi
      final userCredential = await _firebaseService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Kullanıcı bilgilerini önbelleğe kaydet
      if (userCredential.user != null) {
        await UserCacheService.saveUserLoginInfo(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: userCredential.user!.displayName,
        );
        AppLogger.log('LoginScreen', 'Kullanıcı bilgileri önbelleğe kaydedildi: ${userCredential.user!.uid}');
      }
      
      AppLogger.log('LoginScreen', 'Giriş başarılı');
      
      if (mounted) {
        // Başarılı giriş sonrası ana sayfaya yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giriş başarılı!')),
        );
        
        // Dashboard sayfasına yönlendir
        try {
          // Önce AutoRoute ile deneyelim
          context.router.replace(const DashboardRoute());
          AppLogger.log('LoginScreen', 'Dashboard sayfasına yönlendirildi (AutoRoute)');
        } catch (autoRouteError) {
          AppLogger.error('AutoRoute yönlendirme hatası', error: autoRouteError);
          
          // AutoRoute başarısız olursa doğrudan Navigator kullan
          try {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
            AppLogger.log('LoginScreen', 'Dashboard sayfasına yönlendirildi (Navigator)');
          } catch (navigationError) {
            AppLogger.error('Navigator yönlendirme hatası', error: navigationError);
            
            // Son çare olarak HomeScreen'e git
            try {
              context.router.replace(const HomeRoute());
              AppLogger.log('LoginScreen', 'Ana sayfaya yönlendirildi (alternatif)');
            } catch (e) {
              AppLogger.error('Alternatif yönlendirme hatası', error: e);
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Giriş hatası', error: e);
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFirebaseErrorMessage(dynamic error) {
    AppLogger.log('LoginScreen', 'Hata mesajı oluşturuluyor: ${error.runtimeType}');
    if (error is FirebaseAuthException) {
      AppLogger.log('LoginScreen', 'FirebaseAuthException kodu: ${error.code}');
      switch (error.code) {
        case 'user-not-found':
          return 'Bu e-posta ile kayıtlı bir kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Yanlış şifre girdiniz.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'user-disabled':
          return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
        case 'network-request-failed':
          return 'İnternet bağlantınızı kontrol edin. (Firebase)';
        case 'too-many-requests':
          return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
        case 'email-already-in-use': // Bu normalde kayıt için ama yine de ekleyelim
            return 'Bu e-posta adresi zaten kullanımda.';
        // Diğer Firebase Auth hata kodları eklenebilir
        default:
          return error.message ?? 'Bir Firebase kimlik doğrulama hatası oluştu.';
      }
    } else if (error.toString().toLowerCase().contains('network') || error.toString().toLowerCase().contains('socketexception')) {
      return 'İnternet bağlantınızı kontrol edin.';
    }
    AppLogger.error('Bilinmeyen giriş hatası tipi', error: error, stackTrace: StackTrace.current);
    return 'Giriş sırasında beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Üst büyük mavi baloncuk (daha küçük ve yukarıda)
          const Positioned(
            top:0,
            left: -80,
            child: _Bubble(color: Color(0xFF004BFE), size: 260),
          ),
          // Üst açık mavi baloncuk (daha küçük ve yukarıda)
          const Positioned(
            top: -60,
            left: 100,
            child: _Bubble(color: Color(0xFFF2F5FE), size: 170),
          ),
          // Sağ orta mavi baloncuk
          const Positioned(
            top: 180,
            right: -30,
            child: _Bubble(color: Color(0xFF004BFE), size: 70),
          ),
          // Alt sol açık mavi baloncuk (daha küçük)
          const Positioned(
            bottom: -30,
            left: -30,
            child: _Bubble(color: Color(0xFFF2F5FE), size: 90),
          ),
          // Sağ alt mavi baloncuk (daha küçük)
          const Positioned(
            bottom: -30,
            right: -30,
            child: _Bubble(color: Color(0xFF004BFE), size: 60),
          ),
          // Ana içerik
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 200),
                    // Giriş Yap başlık
                    const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w700,
                        fontSize: 52,
                        color: Color(0xFF202020),
                        letterSpacing: -1.0,
                        height: 1.17,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Açıklama ve kalp (tek satır, sola hizalı)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Seni yeniden gördüğümüz için mutluyuz',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w300,
                              fontSize: 19,
                              color: Color(0xFF202020),
                              height: 1.84,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.favorite, color: Colors.black, size: 20),
                      ],
                    ),
                    const SizedBox(height: 36),
                    // Email alanı
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(59),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFFD2D2D2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Şifre alanı
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(59),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Şifre',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFFD2D2D2),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[700],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Giriş Yap butonu
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Giriş Yap',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w300,
                              fontSize: 22,
                              color: Color(0xFFF3F3F3),
                            ),
                          ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Color color;
  final double size;
  const _Bubble({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
} 
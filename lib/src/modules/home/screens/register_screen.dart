import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:triva/src/services/firebase_service.dart';
import 'package:triva/src/services/firebase_debug_service.dart';
import 'package:triva/src/services/firebase_auth_rest_service.dart';
import 'package:triva/src/utils/logger/app_logger.dart';
import 'package:triva/src/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _firebaseService = FirebaseService();
  late final FirebaseDebugService _firebaseDebugService;
  final _firebaseAuthRestService = FirebaseAuthRestService();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  
  @override
  void initState() {
    super.initState();
    _firebaseDebugService = FirebaseDebugService(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
  
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.log('RegisterScreen', 'Kayıt denemesi: ${_emailController.text.trim()}');
      
      // REST API ile kullanıcı oluşturmayı dene
      AppLogger.firebase('REGISTER: REST API ile kullanıcı oluşturma başlıyor');
      
      try {
        // Önce REST API ile deneyelim
        final response = await _firebaseAuthRestService.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        AppLogger.firebase('REGISTER: REST API ile kullanıcı oluşturma başarılı');
        AppLogger.firebase('REGISTER: Kullanıcı ID: ${response['localId']}');
        
        // Kullanıcı modelini Firestore'a kaydet
        if (response['localId'] != null) {
          final userId = response['localId'];
          
          // Firestore'a kullanıcı bilgilerini kaydet
          await _firebaseService.saveUserToFirestore(
            UserModel.initial(userId, _emailController.text.trim())
          );
          
          // Display name güncelleme
          if (_displayNameController.text.trim().isNotEmpty) {
            // Profil güncelleme
            await _firebaseAuthRestService.updateProfile(
              idToken: response['idToken'],
              displayName: _displayNameController.text.trim(),
            );
            
            // Firestore'da display name güncelleme
            await _firebaseService.updateUserData(
              userId, 
              {'displayName': _displayNameController.text.trim()}
            );
          }
        }
      } catch (restError) {
        AppLogger.error('REGISTER: REST API ile kullanıcı oluşturma başarısız', error: restError);
        AppLogger.firebase('REGISTER: Debug Service ile devam ediliyor');
        
        try {
          // REST API başarısız olursa, Debug Service'i dene
          final userCredential = await _firebaseDebugService.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          
          AppLogger.firebase('REGISTER: Debug Service ile kullanıcı oluşturma başarılı');
          
          // Display name güncelleme
          if (_displayNameController.text.trim().isNotEmpty && userCredential.user != null) {
            await userCredential.user!.updateDisplayName(_displayNameController.text.trim());
            await _firebaseService.updateUserData(
              userCredential.user!.uid, 
              {'displayName': _displayNameController.text.trim()}
            );
          }
        } catch (debugError) {
          AppLogger.error('REGISTER: Debug Service ile kullanıcı oluşturma başarısız', error: debugError);
          AppLogger.firebase('REGISTER: Normal servis ile devam ediliyor');
          
          // Eğer Debug Service başarısız olursa, normal servisi kullan
          await _firebaseService.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _displayNameController.text.trim(),
          );
        }
      }
      
      AppLogger.log('RegisterScreen', 'Kayıt başarılı');
      
      if (mounted) {
        // Başarılı kayıt sonrası bildirim göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
        );
        
        // Giriş sayfasına yönlendir
        context.router.replaceNamed('/login');
      }
    } catch (e) {
      AppLogger.error('Kayıt hatası', error: e);
      AppLogger.firebase('REGISTER: Hata detayı: ${e.toString()}');
      AppLogger.firebase('REGISTER: Hata tipi: ${e.runtimeType}');
      
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    if (errorCode.contains('email-already-in-use')) {
      return 'Bu e-posta adresi zaten kullanılıyor.';
    } else if (errorCode.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    } else if (errorCode.contains('weak-password')) {
      return 'Şifre çok zayıf. Daha güçlü bir şifre belirleyin.';
    } else if (errorCode.contains('network-request-failed')) {
      return 'İnternet bağlantınızı kontrol edin.';
    }
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Üst sol büyük açık mavi baloncuk
          const Positioned(
            top: -100,
            left: -80,
            child: _Bubble(color: Color(0xFFF2F5FE), size: 400),
          ),
          // Sağ üst büyük mavi baloncuk
          const Positioned(
            top: 0,
            right: -60,
            child: _Bubble(color: Color(0xFF004BFE), size: 180),
          ),
          // Ana içerik
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Siyah bar (placeholder)
                    
                    const SizedBox(height: 32),
                    // Başlık
                    const Text(
                      'Hesap\nOluştur',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w700,
                        fontSize: 50,
                        color: Color(0xFF202020),
                        letterSpacing: -1.0,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Ad Soyad
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(59),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            child: TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Ad Soyad',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFFD2D2D2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Lütfen adınızı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Email
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(59),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'E-posta',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFFD2D2D2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Lütfen e-posta adresinizi girin';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Geçerli bir e-posta adresi girin';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Şifre
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
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
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
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Lütfen şifrenizi girin';
                                      }
                                      if (value.length < 6) {
                                        return 'Şifre en az 6 karakter olmalıdır';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[700],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                    const SizedBox(height: 32),
                    // Kayıt Ol butonu
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
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w300,
                              fontSize: 22,
                              color: Color(0xFFF3F3F3),
                            ),
                          ),
                      ),
                    ),
                    
                    // Giriş Yap butonu
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.router.replaceNamed('/login'),
                        child: const Text(
                          'Zaten bir hesabınız var mı? Giriş Yap',
                          style: TextStyle(color: Color(0xFF004CFF)),
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

// Kullanılmayan sınıflar kaldırıldı

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
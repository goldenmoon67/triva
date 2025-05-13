import 'package:auto_route/auto_route.dart';
import 'package:triva/src/modules/home/screens/login_screen.dart';
import 'package:triva/src/modules/home/screens/register_screen.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            
            const SizedBox(height: 24),
            _TopImage(),
            const SizedBox(height: 32),
            // Başlık
            const Text(
              'Triva',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w700,
                fontSize: 48,
                color: Color(0xFF202020),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Açıklama
            const Text(
              'Eşyalarınızı güvenle emanet\nedin',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w300,
                fontSize: 17,
                color: Color(0xFF202020),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Kayıt Ol Butonu
            _RegisterButton(),
            const SizedBox(height: 24),
            // Alt buton
            _LoginButton(),
          ],
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004CFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
        },
        child: const Text(
          'Kayıt Ol',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w300,
            fontSize: 22,
            color: Color(0xFFF3F3F3),
          ),
        ),
      ),
    );
  }
}

class _TopImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Text(
                  'Zaten bir hesabınız var mı? Giriş yapın',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                    color: Color(0xFF202020),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF004CFF),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

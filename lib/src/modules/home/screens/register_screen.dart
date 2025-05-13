import 'package:triva/src/modules/home/screens/verify_otp_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
            child: _Bubble(color: Color(0xFFF2F5FE), size: 200),
          ),
          // Sağ üst büyük mavi baloncuk
          const Positioned(
            top: 0,
            right: -60,
            child: _Bubble(color: Color(0xFF004BFE), size: 140),
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
                    Center(
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(34),
                        ),
                      ),
                    ),
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
                    // Kullanıcı Adı
                    const _RegisterField(hint: 'Kullanıcı Adı'),
                    const SizedBox(height: 16),
                    // İsim Soyisim
                    const _RegisterField(hint: 'İsim Soyisim'),
                    const SizedBox(height: 16),
                    // TC Kimlik No
                    const _RegisterField(hint: 'TC Kimlik No'),
                    const SizedBox(height: 16),
                    // Telefon Numarası (ülke kodu ve ok ikonu placeholder)
                    _PhoneField(),
                    const SizedBox(height: 32),
                    // Şimdi Kayıt Ol butonu
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
                        onPressed: () {Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const VerifyOtpScreen()),
);},
                        child: const Text(
                          'Şimdi Kayıt Ol',
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

class _RegisterField extends StatelessWidget {
  final String hint;
  const _RegisterField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(59),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFFD2D2D2),
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(59),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        children: [
          // Ülke bayrağı ve ok ikonu için placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🇹🇷', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Telefon Numarası',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFFD2D2D2),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
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
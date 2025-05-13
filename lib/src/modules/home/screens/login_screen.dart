import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

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
                    const SizedBox(height: 100),
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
                      child: const TextField(
                        decoration: InputDecoration(
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
                        onPressed: () {},
                        child: const Text(
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
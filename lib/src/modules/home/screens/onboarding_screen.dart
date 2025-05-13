import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<_OnboardingCardData> cards = [
      _OnboardingCardData(
        image: 'assets/locker.png',
        title: 'Merhaba',
        description: 'En yakında dolapları keşfet!\nİstediğin süre boyunca eşyanı güvenle sakla!',
        false,
        button: null
      ),
      _OnboardingCardData(
        image: 'assets/locker_open.png',
        title: 'Başlayalım mı?',
        description: 'Senin için her şey hazır görünüyor.',
         true,
        button: null
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Üstteki mavi eğik alan
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _TopBlueClipper(),
              child: Container(
                height: 220,
                color: const Color(0xFF004BFE),
              ),
            ),
          ),
          // Kartlar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 1000, // Kart yüksekliği + padding (örnek)
              child: PageView.builder(
                controller: _pageController,
                itemCount: cards.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _OnboardingCard(card: card);
                },
              ),
            ),
          ),
          // Dots
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cards.length, (i) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == _currentPage ? const Color(0xFF004CFF) : const Color(0xFFC7D6FB),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // İkinci ekranda buton kartın dışında, dots'ın hemen altında
       
           
          // Alt bar
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCardData {
  final String image;
  final String title;
  final String description;
  final Widget? button;
  final bool showButton;
  _OnboardingCardData(this.showButton, {
    required this.image,
    required this.title,
    required this.description,
    this.button,
  });
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardingCardData card;
  const _OnboardingCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 37,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fotoğraf
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Image.asset(
                card.image,
                width: 320,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            // Başlık
            Text(
              card.title,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Color(0xFF202020),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Açıklama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                card.description,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  color: Colors.black,
                  height: 1.42,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 200),

            if(card.showButton)
             Positioned(
            
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004BFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  onPressed: () {
                    // Başla butonuna tıklanınca yapılacaklar
                  },
                  child: const Text(
                    'Hadi Başlayalım!',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Üstteki mavi alan için özel clipper
class _TopBlueClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 
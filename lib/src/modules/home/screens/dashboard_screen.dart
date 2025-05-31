import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:triva/src/services/firebase_service.dart';
import 'package:triva/src/services/user_cache_service.dart';
import 'package:triva/src/utils/logger/app_logger.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _userName = 'Kullanıcı';
  bool _isLoading = true;
  
  // Kullanıcı istatistikleri
  int _totalItems = 0;
  int _activeLoans = 0;
  int _borrowers = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Önbellekten kullanıcı ID'sini al
      final userId = await UserCacheService.getUserId();
      
      if (userId != null && userId.isNotEmpty) {
        AppLogger.log('DashboardScreen', 'Önbellekten kullanıcı ID alındı: $userId');
        
        // Firestore'dan kullanıcı verilerini çek
        final userModel = await _firebaseService.getUserData(userId);
        final userData = await _firebaseService.getUserDataFromFirestore(userId);
        
        if (mounted) {
          setState(() {
            // Kullanıcı adını ayarla
            if (userModel?.displayName != null) {
              _userName = userModel!.displayName!;
            } else if (userData != null && userData['displayName'] != null) {
              _userName = userData['displayName'] as String;
            }
            
            // Kullanıcı istatistiklerini ayarla
            if (userData != null) {
              _totalItems = userData['totalItems'] as int? ?? 0;
              _activeLoans = userData['activeLoans'] as int? ?? 0;
              _borrowers = userData['borrowers'] as int? ?? 0;
            }
            
            _isLoading = false;
          });
          AppLogger.log('DashboardScreen', 'Kullanıcı verileri yüklendi: $_userName');
        }
      } else {
        // Önbellekte kullanıcı ID yoksa Firebase'den mevcut kullanıcıyı kontrol et
        final user = _firebaseService.currentUser;
        
        if (user != null) {
          AppLogger.log('DashboardScreen', 'Firebase kullanıcısı bulundu: ${user.uid}');
          
          // Kullanıcı ID'sini önbelleğe kaydet
          await UserCacheService.saveUserLoginInfo(
            userId: user.uid,
            email: user.email,
            displayName: user.displayName,
          );
          
          // Firestore'dan kullanıcı verilerini çek
          final userModel = await _firebaseService.getUserData(user.uid);
          final userData = await _firebaseService.getUserDataFromFirestore(user.uid);
          
          if (mounted) {
            setState(() {
              // Kullanıcı adını ayarla
              if (userModel?.displayName != null) {
                _userName = userModel!.displayName!;
              } else if (userData != null && userData['displayName'] != null) {
                _userName = userData['displayName'] as String;
              } else if (user.displayName != null) {
                _userName = user.displayName!;
              }
              
              // Kullanıcı istatistiklerini ayarla
              if (userData != null) {
                _totalItems = userData['totalItems'] as int? ?? 0;
                _activeLoans = userData['activeLoans'] as int? ?? 0;
                _borrowers = userData['borrowers'] as int? ?? 0;
              }
              
              _isLoading = false;
            });
            AppLogger.log('DashboardScreen', 'Kullanıcı verileri yüklendi: $_userName');
          }
        } else {
          // Kullanıcı bulunamadı
          if (mounted) {
            setState(() {
              _userName = 'Kullanıcı';
              _isLoading = false;
            });
            AppLogger.log('DashboardScreen', 'Kullanıcı bulunamadı');
          }
        }
      }
    } catch (e) {
      AppLogger.error('Kullanıcı verileri yüklenirken hata', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildDashboardContent(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF004CFF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Merhaba, $_userName',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  // Bildirimler sayfasına yönlendirme
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Bugün eşyalarınız güvende',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardContent() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Özet Kart
          _buildSummaryCard(),
          const SizedBox(height: 24),
          
          // Hızlı İşlemler
          const Text(
            'Hızlı İşlemler',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF202020),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Son Aktiviteler
          const Text(
            'Son Aktiviteler',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF202020),
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivities(),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF004CFF), Color(0xFF0078FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004CFF).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Özet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_totalItems',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Toplam Eşya',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_activeLoans',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Aktif Ödünç',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_borrowers',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ödünç Alan',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.add_circle_outline,
          label: 'Eşya Ekle',
          onTap: () {
            // Eşya ekleme sayfasına yönlendirme
          },
        ),
        _buildActionButton(
          icon: Icons.send_outlined,
          label: 'Emanet Ver',
          onTap: () {
            // Emanet verme sayfasına yönlendirme
          },
        ),
        _buildActionButton(
          icon: Icons.history_outlined,
          label: 'Geçmiş',
          onTap: () {
            // Geçmiş sayfasına yönlendirme
          },
        ),
        _buildActionButton(
          icon: Icons.settings_outlined,
          label: 'Ayarlar',
          onTap: () {
            // Ayarlar sayfasına yönlendirme
          },
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF004CFF),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xFF202020),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivities() {
    // Örnek aktiviteler
    List<Map<String, dynamic>> activities = [
      {
        'title': 'Kitap emanet verildi',
        'subtitle': 'Ahmet Yılmaz\'a',
        'time': '2 saat önce',
        'icon': Icons.book_outlined,
      },
      {
        'title': 'Bisiklet geri alındı',
        'subtitle': 'Mehmet Demir\'den',
        'time': 'Dün',
        'icon': Icons.directions_bike_outlined,
      },
      {
        'title': 'Kamera eklendi',
        'subtitle': 'Yeni eşya',
        'time': '3 gün önce',
        'icon': Icons.camera_alt_outlined,
      },
    ];
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: const Color(0xFF004CFF),
            ),
          ),
          title: Text(
            activity['title'] as String,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF202020),
            ),
          ),
          subtitle: Text(
            activity['subtitle'] as String,
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),
          trailing: Text(
            activity['time'] as String,
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),
        );
      },
    );
  }
}

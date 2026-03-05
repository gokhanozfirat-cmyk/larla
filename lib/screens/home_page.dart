import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/version_service.dart';
import 'prayer_detail_page.dart';
import 'journeys_page.dart';
import 'admin_page.dart';
import 'prayer_times_page.dart';
import 'support_page.dart';
import 'qibla_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  int _tapCount = 0;

  // Altın rengi
  static const Color _goldColor = Color(0xFFD4AF37);
  static const int _prayersPerAd = 4;
  static const String _androidReleaseBannerAdUnitId =
      'ca-app-pub-6339367633683720/7550845979';
  static const String _iosReleaseBannerAdUnitId = '';
  static const String _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  final Map<int, BannerAd> _bannerAds = {};
  final Set<int> _loadedBannerSlots = <int>{};

  @override
  void initState() {
    super.initState();
    // Uygulama açılışında versiyon kontrolü
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VersionService.checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    for (final ad in _bannerAds.values) {
      ad.dispose();
    }
    super.dispose();
  }

  // Cami silüeti içinde kalp ikonu
  Widget _buildMosqueHeartIcon() {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: MosquePainter(color: _goldColor),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.favorite,
              size: 12,
              color: _goldColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showAdminPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Girişi'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Şifre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text == '465486') {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yanlış şifre!')),
                );
              }
            },
            child: const Text('Giriş'),
          ),
        ],
      ),
    );
  }

  bool get _adsSupported {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (kReleaseMode && _androidReleaseBannerAdUnitId.isNotEmpty) {
        return _androidReleaseBannerAdUnitId;
      }
      return _androidTestBannerAdUnitId;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (kReleaseMode && _iosReleaseBannerAdUnitId.isNotEmpty) {
        return _iosReleaseBannerAdUnitId;
      }
      return _iosTestBannerAdUnitId;
    }
    return _androidTestBannerAdUnitId;
  }

  int _adCountForPrayerCount(int prayerCount) {
    if (!_adsSupported) return 0;
    return prayerCount ~/ _prayersPerAd;
  }

  bool _isAdIndex(int listIndex) {
    return _adsSupported && (listIndex + 1) % (_prayersPerAd + 1) == 0;
  }

  int _prayerIndexFromListIndex(int listIndex) {
    return listIndex - (listIndex ~/ (_prayersPerAd + 1));
  }

  BannerAd _createBannerAd(int slot) {
    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _loadedBannerSlots.add(slot);
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAds.remove(slot);
          _loadedBannerSlots.remove(slot);
        },
      ),
    );
    ad.load();
    return ad;
  }

  Widget _buildBannerTile(int slot) {
    final ad = _bannerAds.putIfAbsent(slot, () => _createBannerAd(slot));
    final isLoaded = _loadedBannerSlots.contains(slot);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.center,
      height: 60,
      child: isLoaded
          ? SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final journeys = provider.journeys.where((j) => !j.isCompleted).toList();
    final filteredPrayers = provider.prayers
        .where((p) =>
            p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.content.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    final filteredJourneys = journeys
        .where((j) =>
            j.prayerTitle.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    final adCount = _adCountForPrayerCount(filteredPrayers.length);
    final listItemCount = filteredPrayers.length + adCount;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _tapCount++;
            if (_tapCount >= 12) {
              _tapCount = 0;
              _showAdminPasswordDialog();
            }
          },
          child: const Text('Dualar'),
        ),
        backgroundColor: Colors.green,
        actions: [
          TextButton.icon(
            onPressed: provider.increaseFontSize,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text(
              'Büyüt',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          TextButton.icon(
            onPressed: provider.decreaseFontSize,
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            label: const Text(
              'Küçült',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Ara...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cami.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          children: [
            if (filteredJourneys.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yolculuklarım',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...filteredJourneys.map((journey) => ListTile(
                          title: Text(journey.prayerTitle),
                          subtitle: Text(
                              'Gün ${journey.currentDay}/${journey.totalDays ?? '∞'} - Okuma ${journey.currentReadCount}/${journey.timesPerDay ?? '∞'}'),
                          trailing: Text(
                              journey.lastReadDate.toString().split(' ')[0]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const JourneysPage()),
                            );
                          },
                        )),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: listItemCount,
                itemBuilder: (context, index) {
                  if (_isAdIndex(index)) {
                    final slot = index ~/ (_prayersPerAd + 1);
                    return _buildBannerTile(slot);
                  }

                  final prayer = filteredPrayers[_prayerIndexFromListIndex(index)];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        prayer.title,
                        style: TextStyle(
                            fontSize: provider.fontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: prayer.description.isNotEmpty
                          ? Text(
                              prayer.description,
                              style: TextStyle(fontSize: provider.fontSize - 2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PrayerDetailPage(prayer: prayer),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Ana Sayfa'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.route), label: 'Yolculuklarım'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Namazlarım'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: 'Kible'),
          BottomNavigationBarItem(
              icon: _buildMosqueHeartIcon(), label: 'Destekle'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JourneysPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrayerTimesPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QiblaPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportPage()),
            );
          }
        },
      ),
    );
  }
}

// Cami silüeti çizen CustomPainter
class MosquePainter extends CustomPainter {
  final Color color;

  MosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    final w = size.width;
    final h = size.height;

    // Ana kubbe (ortada büyük)
    path.moveTo(w * 0.25, h * 0.45);
    path.quadraticBezierTo(w * 0.5, h * 0.05, w * 0.75, h * 0.45);

    // Kubbe tepesindeki hilal/ay
    path.moveTo(w * 0.5, h * 0.02);
    path.lineTo(w * 0.5, h * 0.12);

    // Sol minare
    path.moveTo(w * 0.1, h * 0.2);
    path.lineTo(w * 0.1, h * 0.95);
    path.moveTo(w * 0.05, h * 0.2);
    path.quadraticBezierTo(w * 0.1, h * 0.08, w * 0.15, h * 0.2);

    // Sağ minare
    path.moveTo(w * 0.9, h * 0.2);
    path.lineTo(w * 0.9, h * 0.95);
    path.moveTo(w * 0.85, h * 0.2);
    path.quadraticBezierTo(w * 0.9, h * 0.08, w * 0.95, h * 0.2);

    // Alt çizgi (taban)
    path.moveTo(w * 0.05, h * 0.95);
    path.lineTo(w * 0.95, h * 0.95);

    // Yan duvarlar
    path.moveTo(w * 0.25, h * 0.45);
    path.lineTo(w * 0.25, h * 0.95);
    path.moveTo(w * 0.75, h * 0.45);
    path.lineTo(w * 0.75, h * 0.95);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

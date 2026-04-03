import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../services/prayer_time_api_service.dart';
import 'home_page.dart';
import 'journeys_page.dart';
import 'prayer_times_page.dart';
import 'support_page.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  bool _loading = true;
  String? _error;
  double? _bearing;
  double? _lat;
  double? _lon;
  double? _heading;
  double? _lastHeading;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _loadQibla();
    _startCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen(
      (event) {
        if (!mounted) return;
        final newHeading = event.heading;
        if (newHeading == null) return;
        if (_lastHeading == null || (newHeading - _lastHeading!).abs() > 1.0) {
          _lastHeading = newHeading;
          setState(() {
            _heading = newHeading;
          });
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _error = 'Pusula sensörü hatası: $e';
        });
      },
    );
  }

  Future<void> _loadQibla() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final position = await PrayerTimeApiService.getCurrentLocation();
      if (position == null) {
        setState(() {
          _error =
              'Konum alinamadi. Konum izni verdiginizden emin olun.';
          _loading = false;
        });
        return;
      }

      final bearing = _bearingToKaaba(position.latitude, position.longitude);
      setState(() {
        _bearing = bearing;
        _lat = position.latitude;
        _lon = position.longitude;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Hata: $e';
        _loading = false;
      });
    }
  }

  double _bearingToKaaba(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;
    final lat1 = _degToRad(lat);
    final lat2 = _degToRad(kaabaLat);
    final dLon = _degToRad(kaabaLon - lon);

    final y = sin(dLon) * cos(lat2);
    final x =
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final brng = atan2(y, x);
    return (_radToDeg(brng) + 360) % 360;
  }

  double _degToRad(double deg) => deg * pi / 180.0;
  double _radToDeg(double rad) => rad * 180.0 / pi;

  String _cardinalDirection(double bearing) {
    const directions = [
      'Kuzey',
      'Kuzeydogu',
      'Dogu',
      'Guneydogu',
      'Guney',
      'Guneybati',
      'Bati',
      'Kuzeybati',
    ];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: _loadQibla,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _loadQibla,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar dene'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCompass(
                        bearing: _bearing ?? 0,
                        heading: _heading,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kıble yonu: ${(_bearing ?? 0).toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yaklasik yon: ${_cardinalDirection(_bearing ?? 0)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      if (_lat != null && _lon != null)
                        Text(
                          'Konum: ${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'Not: Ok, cihaz yönüne göre canlı döner.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Ana Sayfa'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.route), label: 'Yolculuklarim'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Namazlarim'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: 'Kıble'),
          BottomNavigationBarItem(
              icon: _buildMosqueHeartIcon(), label: 'Destekle'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JourneysPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PrayerTimesPage()),
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

  Widget _buildCompass({required double bearing, double? heading}) {
    final deviceHeading = heading ?? 0.0;
    final relative = (bearing - deviceHeading) * pi / 180.0;
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 3),
              color: Colors.green.withOpacity(0.05),
            ),
          ),
          Positioned(
            top: 12,
            child: Transform.rotate(
              angle: relative,
              child: const Text(
                'Kıble',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: relative,
            child: const Icon(
              Icons.navigation,
              size: 120,
              color: Colors.green,
            ),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildMosqueHeartIcon() {
    const goldColor = Color(0xFFD4AF37);
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _MosquePainter(color: goldColor),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.favorite, size: 12, color: goldColor),
          ),
        ),
      ),
    );
  }
}

class _MosquePainter extends CustomPainter {
  final Color color;

  _MosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.9);
    path.lineTo(size.width * 0.1, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.9, size.height * 0.6);
    path.lineTo(size.width * 0.9, size.height * 0.9);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

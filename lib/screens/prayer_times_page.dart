import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../services/prayer_time_api_service.dart';
import 'home_page.dart';
import 'journeys_page.dart';
import 'support_page.dart';
import 'qibla_page.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  late TextEditingController sabahController;
  late TextEditingController ogleController;
  late TextEditingController ikindiController;
  late TextEditingController aksamController;

  // Ezan vakitleri controller'ları
  late TextEditingController fajrTimeController;
  late TextEditingController dhuhrTimeController;
  late TextEditingController asrTimeController;
  late TextEditingController maghribTimeController;
  late TextEditingController ishaTimeController;

  bool _ezanNotificationEnabled = false;
  bool _isLoadingPrayerTimes = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    sabahController =
        TextEditingController(text: provider.prayerTimes.sabah.toString());
    ogleController =
        TextEditingController(text: provider.prayerTimes.ogle.toString());
    ikindiController =
        TextEditingController(text: provider.prayerTimes.ikindi.toString());
    aksamController =
        TextEditingController(text: provider.prayerTimes.aksam.toString());

    // Ezan vakitleri
    fajrTimeController =
        TextEditingController(text: provider.prayerTimes.fajrTime ?? '');
    dhuhrTimeController =
        TextEditingController(text: provider.prayerTimes.dhuhrTime ?? '');
    asrTimeController =
        TextEditingController(text: provider.prayerTimes.asrTime ?? '');
    maghribTimeController =
        TextEditingController(text: provider.prayerTimes.maghribTime ?? '');
    ishaTimeController =
        TextEditingController(text: provider.prayerTimes.ishaTime ?? '');

    _ezanNotificationEnabled = provider.prayerTimes.ezanNotificationEnabled;

    // Sayfa açıldığında otomatik vakitleri çek
    _fetchPrayerTimesFromApi();
  }

  @override
  void dispose() {
    sabahController.dispose();
    ogleController.dispose();
    ikindiController.dispose();
    aksamController.dispose();
    fajrTimeController.dispose();
    dhuhrTimeController.dispose();
    asrTimeController.dispose();
    maghribTimeController.dispose();
    ishaTimeController.dispose();
    super.dispose();
  }

  // API'den namaz vakitlerini çek
  Future<void> _fetchPrayerTimesFromApi() async {
    setState(() {
      _isLoadingPrayerTimes = true;
    });

    try {
      final times =
          await PrayerTimeApiService.fetchPrayerTimesForCurrentLocation();

      if (times != null) {
        final cleanedFajr = _cleanTime(times['fajr'] ?? '');
        final cleanedDhuhr = _cleanTime(times['dhuhr'] ?? '');
        final cleanedAsr = _cleanTime(times['asr'] ?? '');
        final cleanedMaghrib = _cleanTime(times['maghrib'] ?? '');
        final cleanedIsha = _cleanTime(times['isha'] ?? '');

        setState(() {
          // API'den gelen saatler "HH:mm (TZ)" formatında olabilir, sadece "HH:mm" al
          fajrTimeController.text = cleanedFajr;
          dhuhrTimeController.text = cleanedDhuhr;
          asrTimeController.text = cleanedAsr;
          maghribTimeController.text = cleanedMaghrib;
          ishaTimeController.text = cleanedIsha;
        });

        // Yeni vakitleri kalıcı olarak kaydet
        final provider = Provider.of<AppProvider>(context, listen: false);
        final prayerTimes = provider.prayerTimes;
        prayerTimes.fajrTime = cleanedFajr;
        prayerTimes.dhuhrTime = cleanedDhuhr;
        prayerTimes.asrTime = cleanedAsr;
        prayerTimes.maghribTime = cleanedMaghrib;
        prayerTimes.ishaTime = cleanedIsha;
        provider.updatePrayerTimes(prayerTimes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Namaz vakitleri konumunuza göre güncellendi! 📍'),
            backgroundColor: Colors.green,
          ),
        );

        // Ezan bildirimi açıksa yeni vakitlerle otomatik yeniden planla
        if (_ezanNotificationEnabled) {
          await _saveEzanTimes(showFeedback: false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Vakitler alınamadı. Konum izni verdiğinizden emin olun.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingPrayerTimes = false;
      });
    }
  }

  // Saat formatını temizle (örn: "05:30 (+03)" -> "05:30")
  String _cleanTime(String time) {
    if (time.contains(' ')) {
      return time.split(' ')[0];
    }
    return time;
  }

  Future<void> _selectTime(
      TextEditingController controller, String label) async {
    TimeOfDay initialTime = TimeOfDay.now();

    // Mevcut değeri parse et
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: '$label Vakti Seçin',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveEzanTimes({bool showFeedback = true}) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final prayerTimes = provider.prayerTimes;

    prayerTimes.fajrTime = fajrTimeController.text;
    prayerTimes.dhuhrTime = dhuhrTimeController.text;
    prayerTimes.asrTime = asrTimeController.text;
    prayerTimes.maghribTime = maghribTimeController.text;
    prayerTimes.ishaTime = ishaTimeController.text;
    prayerTimes.ezanNotificationEnabled = _ezanNotificationEnabled;

    provider.updatePrayerTimes(prayerTimes);

    // Bildirimleri ayarla
    if (_ezanNotificationEnabled) {
      final result =
          await NotificationService().scheduleAllEzanNotifications(
        fajrTime: fajrTimeController.text,
        dhuhrTime: dhuhrTimeController.text,
        asrTime: asrTimeController.text,
        maghribTime: maghribTimeController.text,
        ishaTime: ishaTimeController.text,
      );
      if (showFeedback && mounted) {
        String message;
        Color bgColor;
        switch (result) {
          case 'success':
            message = 'Ezan bildirimleri aktif edildi! 🕌';
            bgColor = Colors.green;
            break;
          case 'no_permission':
            message = 'Bildirim izni verilmedi. Lütfen ayarlardan bildirim iznini açın.';
            bgColor = Colors.red;
            // İzin yoksa switch'i kapat
            setState(() {
              _ezanNotificationEnabled = false;
            });
            prayerTimes.ezanNotificationEnabled = false;
            provider.updatePrayerTimes(prayerTimes);
            break;
          case 'no_times':
            message = 'Namaz vakitleri boş. Lütfen önce vakitleri girin veya konumdan alın.';
            bgColor = Colors.orange;
            break;
          default: // schedule_failed
            message = 'Bildirimler planlanırken bir hata oluştu. Lütfen tekrar deneyin.';
            bgColor = Colors.red;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: bgColor),
        );
      }
    } else {
      await NotificationService().cancelAllEzanNotifications();
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ezan bildirimleri kapatıldı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Namazlarım'),
        backgroundColor: Colors.green,
        actions: [
          TextButton.icon(
            onPressed: provider.increaseFontSize,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text('Büyüt',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          TextButton.icon(
            onPressed: provider.decreaseFontSize,
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            label: const Text('Küçült',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cami.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EZAN VAKİTLERİ BÖLÜMÜ
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active,
                                color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'Ezan Vakitleri',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _isLoadingPrayerTimes
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Vakitler alınıyor...',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              )
                            : const Text(
                                'Vakitler konumunuza göre otomatik güncellenir',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                        const SizedBox(height: 16),

                        // Bildirim açma/kapama switch
                        SwitchListTile(
                          title: const Text('Ezan Bildirimi'),
                          subtitle: Text(
                            _ezanNotificationEnabled
                                ? 'Sesli bildirim açık 🔔'
                                : 'Sesli bildirim kapalı',
                          ),
                          value: _ezanNotificationEnabled,
                          activeColor: Colors.green,
                          onChanged: _isLoadingPrayerTimes
                              ? null
                              : (value) {
                                  setState(() {
                                    _ezanNotificationEnabled = value;
                                  });
                                  _saveEzanTimes(); // Ayarları anında kaydet ve bildirimleri ayarla
                                },
                        ),
                        const Divider(),

                        _buildEzanTimeField(
                            'Sabah (İmsak)', fajrTimeController),
                        _buildEzanTimeField('Öğle', dhuhrTimeController),
                        _buildEzanTimeField('İkindi', asrTimeController),
                        _buildEzanTimeField('Akşam', maghribTimeController),
                        _buildEzanTimeField('Yatsı', ishaTimeController),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _saveEzanTimes,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Ezan Vakitlerini Kaydet',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // KAZA NAMAZLARI BÖLÜMÜ
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              'Kaza Namazları',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPrayerTimeField('Sabah', sabahController),
                        const SizedBox(height: 12),
                        _buildPrayerTimeField('Öğle', ogleController),
                        const SizedBox(height: 12),
                        _buildPrayerTimeField('İkindi', ikindiController),
                        const SizedBox(height: 12),
                        _buildPrayerTimeField('Akşam', aksamController),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              final prayerTimes = provider.prayerTimes;
                              prayerTimes.sabah =
                                  int.tryParse(sabahController.text) ?? 0;
                              prayerTimes.ogle =
                                  int.tryParse(ogleController.text) ?? 0;
                              prayerTimes.ikindi =
                                  int.tryParse(ikindiController.text) ?? 0;
                              prayerTimes.aksam =
                                  int.tryParse(aksamController.text) ?? 0;

                              provider.updatePrayerTimes(prayerTimes);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Kaza namazları kaydedildi!')),
                              );
                            },
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Kaza Namazlarını Kaydet',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
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

  Widget _buildMosqueHeartIcon() {
    const goldColor = Color(0xFFD4AF37);
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: MosquePainter(color: goldColor),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.favorite, size: 12, color: goldColor),
          ),
        ),
      ),
    );
  }

  Widget _buildEzanTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () => _selectTime(controller, label),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.text.isEmpty ? 'Seç' : controller.text,
                  style: TextStyle(
                    color: controller.text.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

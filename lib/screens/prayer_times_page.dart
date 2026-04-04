import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
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
          SnackBar(
            content: Text(AppStrings.of(context).timesUpdatedByLocation),
            backgroundColor: Colors.green,
          ),
        );

        // Ezan bildirimi açıksa yeni vakitlerle otomatik yeniden planla
        if (_ezanNotificationEnabled) {
          await _saveEzanTimes(showFeedback: false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).timesFetchFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      final t = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.errorWithDetails(e)),
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
    final t = AppStrings.of(context);
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
      helpText: t.selectPrayerTime(label),
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
    final notificationService = NotificationService();

    final normalizedFajr =
        notificationService.normalizeTimeText(fajrTimeController.text);
    final normalizedDhuhr =
        notificationService.normalizeTimeText(dhuhrTimeController.text);
    final normalizedAsr =
        notificationService.normalizeTimeText(asrTimeController.text);
    final normalizedMaghrib =
        notificationService.normalizeTimeText(maghribTimeController.text);
    final normalizedIsha =
        notificationService.normalizeTimeText(ishaTimeController.text);

    fajrTimeController.text = normalizedFajr;
    dhuhrTimeController.text = normalizedDhuhr;
    asrTimeController.text = normalizedAsr;
    maghribTimeController.text = normalizedMaghrib;
    ishaTimeController.text = normalizedIsha;

    prayerTimes.fajrTime = normalizedFajr;
    prayerTimes.dhuhrTime = normalizedDhuhr;
    prayerTimes.asrTime = normalizedAsr;
    prayerTimes.maghribTime = normalizedMaghrib;
    prayerTimes.ishaTime = normalizedIsha;
    prayerTimes.ezanNotificationEnabled = _ezanNotificationEnabled;

    provider.updatePrayerTimes(prayerTimes);

    // Bildirimleri ayarla
    if (_ezanNotificationEnabled) {
      final result = await NotificationService().scheduleAllEzanNotifications(
        fajrTime: normalizedFajr,
        dhuhrTime: normalizedDhuhr,
        asrTime: normalizedAsr,
        maghribTime: normalizedMaghrib,
        ishaTime: normalizedIsha,
      );
      if (showFeedback && mounted) {
        final t = AppStrings.of(context);
        String message;
        Color bgColor;
        switch (result) {
          case 'success':
            message = t.ezanEnabled;
            bgColor = Colors.green;
            break;
          case 'no_permission':
            message = t.permissionDenied;
            bgColor = Colors.red;
            // İzin yoksa switch'i kapat
            setState(() {
              _ezanNotificationEnabled = false;
            });
            prayerTimes.ezanNotificationEnabled = false;
            provider.updatePrayerTimes(prayerTimes);
            break;
          case 'no_times':
            message = t.noTimes;
            bgColor = Colors.orange;
            break;
          default: // schedule_failed
            message = t.scheduleError;
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
          SnackBar(content: Text(AppStrings.of(context).ezanDisabled)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.myPrayerTimes),
        backgroundColor: Colors.green,
        actions: [
          TextButton.icon(
            onPressed: provider.increaseFontSize,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: Text(t.increase,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          TextButton.icon(
            onPressed: provider.decreaseFontSize,
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            label: Text(t.decrease,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                            Text(
                              t.ezanTimes,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _isLoadingPrayerTimes
                            ? Padding(
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
                                    Text(t.timesLoading,
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              )
                            : Text(
                                t.timesAutoUpdated,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                        const SizedBox(height: 16),

                        // Bildirim açma/kapama switch
                        SwitchListTile(
                          title: Text(t.ezanNotification),
                          subtitle: Text(
                            _ezanNotificationEnabled ? t.voiceOn : t.voiceOff,
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
                            t.prayerNameFajr(), fajrTimeController),
                        _buildEzanTimeField(
                            t.prayerNameDhuhr(), dhuhrTimeController),
                        _buildEzanTimeField(
                            t.prayerNameAsr(), asrTimeController),
                        _buildEzanTimeField(
                            t.prayerNameMaghrib(), maghribTimeController),
                        _buildEzanTimeField(
                            t.prayerNameIsha(), ishaTimeController),

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
                            label: Text(
                              t.saveEzanTimes,
                              style: const TextStyle(color: Colors.white),
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
                            Text(
                              t.qazaPrayers,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPrayerTimeField(
                            t.prayerNameFajr(), sabahController),
                        const SizedBox(height: 12),
                        _buildPrayerTimeField(
                            t.prayerNameDhuhr(), ogleController),
                        const SizedBox(height: 12),
                        _buildPrayerTimeField(
                            t.prayerNameAsr(), ikindiController),
                        const SizedBox(height: 12),
                        _buildPrayerTimeField(
                            t.prayerNameMaghrib(), aksamController),
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
                                SnackBar(content: Text(t.qazaSaved)),
                              );
                            },
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              t.saveQazaPrayers,
                              style: const TextStyle(color: Colors.white),
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
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
          BottomNavigationBarItem(
              icon: const Icon(Icons.route), label: t.myJourneys),
          BottomNavigationBarItem(
              icon: const Icon(Icons.schedule), label: t.myPrayerTimes),
          BottomNavigationBarItem(
              icon: const Icon(Icons.explore), label: t.qibla),
          BottomNavigationBarItem(
              icon: _buildMosqueHeartIcon(), label: t.support),
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
                  controller.text.isEmpty
                      ? AppStrings.of(context).select
                      : controller.text,
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

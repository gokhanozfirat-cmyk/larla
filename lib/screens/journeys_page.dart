import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/app_provider.dart';
import '../models/journey.dart';
import '../models/prayer.dart';
import '../services/notification_service.dart';
import 'support_page.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'prayer_detail_page.dart';
import 'qibla_page.dart';

class JourneysPage extends StatefulWidget {
  const JourneysPage({super.key});

  @override
  _JourneysPageState createState() => _JourneysPageState();
}

class _JourneysPageState extends State<JourneysPage> {
  final Map<String, int> _tesbihCounters = {};
  final Map<String, TextEditingController> _controllers = {};
  AppStrings get _t => AppStrings.of(context);
  String get _languageCode => Localizations.localeOf(context).languageCode;

  void _enableReminder(Journey journey) {
    NotificationService().scheduleNoonNotification(
      journey.id,
      journey.prayerTitle,
      journey.timesPerDay ?? 0,
    );
    Provider.of<AppProvider>(context, listen: false).updateJourney(journey);
  }

  void _disableReminder(Journey journey) {
    NotificationService().cancelNotification(journey.id);
    journey.reminderEnabled = false;
    Provider.of<AppProvider>(context, listen: false).updateJourney(journey);
  }

  void _processRead(Journey journey, int count) {
    if (count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t.pleaseEnterValidNumber)),
      );
      return;
    }
    final today = DateTime.now();
    final bool isFirstReadToday = journey.lastReadDate.day != today.day ||
        journey.lastReadDate.month != today.month ||
        journey.lastReadDate.year != today.year;

    setState(() {
      journey.totalReads += count;
      // accumulate today's reads
      journey.currentReadCount = (journey.currentReadCount + count);

      if (journey.timesPerDay == null) {
        // Unconditional prayers: increment day on first read of the calendar day
        if (isFirstReadToday) {
          journey.currentDay += 1;
          journey.lastCompletionDate = today;
        }
      } else {
        // Conditional prayers: only increment day when daily target is reached
        if (journey.currentReadCount >= journey.timesPerDay!) {
          journey.currentReadCount = journey.timesPerDay!;
          final completedBefore = journey.hasCompletedTodaysReading();
          journey.lastCompletionDate = today;
          if (!completedBefore) {
            journey.currentDay += 1;
          }
          if (journey.totalDays != null &&
              journey.currentDay >= journey.totalDays!) {
            journey.isCompleted = true;
          }
        }
      }

      journey.lastReadDate = today;
      _tesbihCounters[journey.id] = 0;
    });

    Provider.of<AppProvider>(context, listen: false).updateJourney(journey);
  }

  void _processConditionalRead(Journey journey, int count) {
    // For prayers with a timesPerDay limit
    final remaining = journey.timesPerDay! - journey.currentReadCount;

    if (count <= 0) {
      final controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_t.howMuchRead),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: _t.howManyTimes),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t.cancel),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text) ?? 0;
                Navigator.pop(context);
                if (value > 0) {
                  _processConditionalRead(journey, value);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_t.pleaseEnterValidNumber)),
                  );
                }
              },
              child: Text(_t.save),
            ),
          ],
        ),
      ).then((_) => controller.dispose());
      return;
    }

    if (count > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t.todayMaxReads(remaining))),
      );
      return;
    }

    // Apply read count using the same rules as unconditional reads
    _processRead(journey, count);

    // Show success message
    String message = _t.readingSaved;
    if (journey.hasCompletedTodaysReading()) {
      message = _t.dailyGoalCompleted(journey.timesPerDay!, journey.currentDay);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    setState(() {
      _controllers[journey.id]?.clear();
      _tesbihCounters[journey.id] = 0;
    });
    Provider.of<AppProvider>(context, listen: false).updateJourney(journey);
  }

  // Cami silüeti içinde kalp ikonu
  Widget _buildMosqueHeartIcon() {
    const Color _goldColor = Color(0xFFD4AF37);
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

  void _showAddJourneyDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final t = AppStrings.of(context);
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final daysController = TextEditingController();
    final timesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.manualJourneyAdd),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: t.journeyName),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: t.prayerContent),
                maxLines: 3,
              ),
              TextField(
                controller: daysController,
                decoration: InputDecoration(labelText: t.howManyDays),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: timesController,
                decoration: InputDecoration(labelText: t.howManyTimesPerDay),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              final journey = Journey(
                id: DateTime.now().toString(),
                prayerId: 'manual_${DateTime.now().toString()}',
                prayerTitle: titleController.text.isEmpty
                    ? t.manualJourney
                    : titleController.text,
                content: contentController.text,
                totalDays: daysController.text.isEmpty
                    ? null
                    : int.tryParse(daysController.text),
                timesPerDay: timesController.text.isEmpty
                    ? null
                    : int.tryParse(timesController.text),
              );
              provider.startJourney(journey);
              Navigator.pop(context);
            },
            child: Text(t.save),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      contentController.dispose();
      daysController.dispose();
      timesController.dispose();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final journeys = provider.journeys;
    final t = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.myJourneys),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: provider.increaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: provider.decreaseFontSize,
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
        child: ListView.builder(
          itemCount: journeys.length,
          itemBuilder: (context, index) {
            final journey = journeys[index];
            final prayer = provider.prayers.firstWhere(
              (p) => p.id == journey.prayerId,
              orElse: () => Prayer(
                  id: '', title: journey.prayerTitle, content: t.manualJourney),
            );
            _tesbihCounters.putIfAbsent(journey.id, () => 0);
            _controllers.putIfAbsent(journey.id, () => TextEditingController());
            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journey.prayerTitle,
                                style: TextStyle(
                                    fontSize: provider.fontSize + 4,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (journey.totalDays != null &&
                                  journey.timesPerDay != null)
                                Row(
                                  children: [
                                    Switch(
                                      value: journey.reminderEnabled,
                                      onChanged: (value) {
                                        setState(() {
                                          journey.reminderEnabled = value;
                                        });
                                        if (value) {
                                          _enableReminder(journey);
                                        } else {
                                          _disableReminder(journey);
                                        }
                                      },
                                    ),
                                    Text(
                                      t.remindMe,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _disableReminder(journey);
                                provider.removeJourney(journey.id);
                                setState(() {
                                  _tesbihCounters.remove(journey.id);
                                  _controllers.remove(journey.id);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (prayer.localizedDescription(_languageCode).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.saidItWas,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              prayer.localizedDescription(_languageCode),
                              style: TextStyle(fontSize: provider.fontSize - 2),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    Text(
                      t.showRecitation,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if ((prayer.arabicContent.isNotEmpty))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.visibility),
                          label: Text(t.showRecitation),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PrayerDetailPage(prayer: prayer),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (journey.totalDays != null &&
                        journey.timesPerDay != null)
                      Column(
                        children: [
                          Text(t.dayProgress(
                              journey.currentDay, journey.totalDays!)),
                          Text(t.readProgress(
                              journey.currentReadCount, journey.timesPerDay!)),
                          Text(
                              '${t.lastRead}: ${journey.lastReadDate.toString().split(' ')[0]}'),
                          const SizedBox(height: 16),
                          // Tesbih Counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: (journey.canReadToday() &&
                                        !journey.isCompleted &&
                                        !journey.hasCompletedTodaysReading())
                                    ? () {
                                        setState(() {
                                          if (_tesbihCounters[journey.id]! >
                                              0) {
                                            _tesbihCounters[journey.id] =
                                                _tesbihCounters[journey.id]! -
                                                    1;
                                          }
                                        });
                                      }
                                    : null,
                              ),
                              GestureDetector(
                                onTap: (journey.canReadToday() &&
                                        !journey.isCompleted &&
                                        !journey.hasCompletedTodaysReading())
                                    ? () {
                                        setState(() {
                                          _tesbihCounters[journey.id] =
                                              _tesbihCounters[journey.id]! + 1;
                                        });
                                      }
                                    : null,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (journey.canReadToday() &&
                                            !journey.isCompleted &&
                                            !journey
                                                .hasCompletedTodaysReading())
                                        ? Colors.green.shade700
                                        : Colors.grey,
                                    border: Border.all(
                                        color: (journey.canReadToday() &&
                                                !journey.isCompleted &&
                                                !journey
                                                    .hasCompletedTodaysReading())
                                            ? Colors.green.shade900
                                            : Colors.grey.shade600,
                                        width: 4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_tesbihCounters[journey.id]}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: (journey.canReadToday() &&
                                        !journey.isCompleted &&
                                        !journey.hasCompletedTodaysReading())
                                    ? () {
                                        setState(() {
                                          final remaining =
                                              journey.timesPerDay! -
                                                  journey.currentReadCount;
                                          if (_tesbihCounters[journey.id]! <
                                              remaining) {
                                            _tesbihCounters[journey.id] =
                                                _tesbihCounters[journey.id]! +
                                                    1;
                                          }
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (journey.canReadToday() &&
                                          !journey.isCompleted &&
                                          !journey.hasCompletedTodaysReading())
                                      ? () {
                                          final tesbih =
                                              _tesbihCounters[journey.id] ?? 0;
                                          if (tesbih > 0) {
                                            _processConditionalRead(
                                                journey, tesbih);
                                            return;
                                          }
                                          final controller =
                                              TextEditingController();
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(t.howMuchRead),
                                              content: TextField(
                                                controller: controller,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(t.cancel),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final value = int.tryParse(
                                                            controller.text) ??
                                                        0;
                                                    Navigator.pop(context);
                                                    if (value > 0) {
                                                      _processConditionalRead(
                                                          journey, value);
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(t
                                                                .pleaseEnterValidNumber)),
                                                      );
                                                    }
                                                  },
                                                  child: Text(t.save),
                                                ),
                                              ],
                                            ),
                                          ).then((_) => controller.dispose());
                                        }
                                      : null,
                                  child: Text(t.readToday),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: (journey.canReadToday() &&
                                        !journey.isCompleted &&
                                        !journey.hasCompletedTodaysReading())
                                    ? () {
                                        final controller =
                                            TextEditingController();
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(t.howManyDeduct),
                                            content: TextField(
                                              controller: controller,
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(t.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  final deduct = int.tryParse(
                                                          controller.text) ??
                                                      0;
                                                  setState(() {
                                                    journey.totalReads =
                                                        (journey.totalReads -
                                                                deduct)
                                                            .clamp(0,
                                                                double.infinity)
                                                            .toInt();
                                                  });
                                                  provider
                                                      .updateJourney(journey);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(t.ok),
                                              ),
                                            ],
                                          ),
                                        ).then((_) => controller.dispose());
                                      }
                                    : null,
                                child: Text(t.wrongEntry),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text('${t.readDays}: ${journey.currentDay}'),
                          Text('${t.todayRead}: ${journey.currentReadCount}'),
                          Text('${t.totalRead}: ${journey.totalReads}'),
                          Text(
                              '${t.lastRead}: ${journey.lastReadDate.toString().split(' ')[0]}'),
                          const SizedBox(height: 16),
                          // Tesbih Counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_tesbihCounters[journey.id]! > 0) {
                                      _tesbihCounters[journey.id] =
                                          _tesbihCounters[journey.id]! - 1;
                                    }
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _tesbihCounters[journey.id] =
                                        _tesbihCounters[journey.id]! + 1;
                                  });
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.shade700,
                                    border: Border.all(
                                        color: Colors.amber.shade900, width: 4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_tesbihCounters[journey.id]}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _tesbihCounters[journey.id] =
                                        _tesbihCounters[journey.id]! + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _controllers[journey.id],
                            decoration:
                                InputDecoration(labelText: t.readTodayPrompt),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final tesbih =
                                        _tesbihCounters[journey.id] ?? 0;
                                    if (tesbih > 0) {
                                      _processRead(journey, tesbih);
                                      return;
                                    }
                                    final controller = TextEditingController();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(t.howMuchRead),
                                        content: TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(t.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final value = int.tryParse(
                                                      controller.text) ??
                                                  0;
                                              Navigator.pop(context);
                                              if (value > 0) {
                                                _processRead(journey, value);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(t
                                                          .pleaseEnterValidNumber)),
                                                );
                                              }
                                            },
                                            child: Text(t.save),
                                          ),
                                        ],
                                      ),
                                    ).then((_) => controller.dispose());
                                  },
                                  child: Text(t.readToday),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  final controller = TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(t.howManyDeduct),
                                      content: TextField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(t.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final deduct =
                                                int.tryParse(controller.text) ??
                                                    0;
                                            setState(() {
                                              journey.totalReads =
                                                  (journey.totalReads - deduct)
                                                      .clamp(0, double.infinity)
                                                      .toInt();
                                            });
                                            provider.updateJourney(journey);
                                            Navigator.pop(context);
                                          },
                                          child: Text(t.ok),
                                        ),
                                      ],
                                    ),
                                  ).then((_) => controller.dispose());
                                },
                                child: Text(t.wrongEntry),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 48.0), // Navigasyon barı üstüne çıkar
        child: FloatingActionButton(
          onPressed: () => _showAddJourneyDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
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
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PrayerTimesPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const QiblaPage()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SupportPage()),
            );
          }
        },
      ),
    ); // Scaffold'un doğru kapanışı
  }

  // Added missing closing brace to balance the class/file structure
}

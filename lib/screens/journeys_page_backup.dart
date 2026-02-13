import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/journey.dart';
import '../models/prayer.dart';
import 'home_page.dart';
import 'admin_page.dart';

class JourneysPage extends StatelessWidget {
  const JourneysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final journeys = provider.journeys;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yolculuklarım'),
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
            opacity: 0.1,
          ),
        ),
        child: ListView.builder(
        itemCount: journeys.length,
        itemBuilder: (context, index) {
          final journey = journeys[index];
          final prayer = provider.prayers.firstWhere(
            (p) => p.id == journey.prayerId,
            orElse: () => Prayer(id: '', title: journey.prayerTitle, content: 'Manuel yolculuk'),
          );
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
                        child: Text(
                          journey.prayerTitle,
                          style: TextStyle(fontSize: provider.fontSize + 4, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.removeJourney(journey.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    journey.content ?? prayer.content,
                    style: TextStyle(fontSize: provider.fontSize),
                  ),
                  const SizedBox(height: 8),
                  if (journey.totalDays != null && journey.timesPerDay != null)
                    Column(
                      children: [
                        Text('Gün: ${journey.currentDay}/${journey.totalDays}'),
                        Text('Okuma: ${journey.currentReadCount}/${journey.timesPerDay}'),
                        Text('Son Okuma: ${journey.lastReadDate.toString().split(' ')[0]}'),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text('Okunan Gün: ${journey.currentDay}'),
                        Text('Bugün Okuma: ${journey.currentReadCount}'),
                        Text('Toplam Okuma: ${journey.totalReads}'),
                        Text('Son Okuma: ${journey.lastReadDate.toString().split(' ')[0]}'),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (journey.totalDays != null && journey.timesPerDay != null)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: journey.canReadToday() && !journey.isCompleted
                              ? () {
                                  journey.incrementRead();
                                  provider.updateJourney(journey);
                                }
                              : null,
                          child: CircleAvatar(
                            backgroundColor: journey.canReadToday() && !journey.isCompleted ? Colors.green.shade800 : Colors.grey,
                            radius: 24,
                            child: Text(
                              '${journey.currentReadCount}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: journey.canReadToday() && !journey.isCompleted
                              ? () {
                                  for (int i = journey.currentReadCount; i < journey.timesPerDay!; i++) {
                                    journey.incrementRead();
                                  }
                                  provider.updateJourney(journey);
                                }
                              : null,
                          child: const Text('Bugün Okudum'),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              journey.incrementRead();
                              provider.updateJourney(journey);
                            },
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade700,
                                border: Border.all(color: Colors.amber.shade900, width: 4),
                              ),
                              child: Center(
                                child: Text(
                                  '${journey.currentReadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(),
                                decoration: const InputDecoration(labelText: 'Kaç Kere Okudun?'),
                                keyboardType: TextInputType.number,
                                onSubmitted: (value) {
                                  final count = int.tryParse(value) ?? 0;
                                  for (int i = 0; i < count; i++) {
                                    journey.incrementRead();
                                  }
                                  provider.updateJourney(journey);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                final controller = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Kaç Kere Okudun?'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('İptal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final count = int.tryParse(controller.text) ?? 0;
                                          for (int i = 0; i < count; i++) {
                                            journey.incrementRead();
                                          }
                                          provider.updateJourney(journey);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Tamam'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Bugün Okudum'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJourneyDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Kısayol'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          }
        },
      ),
    );
  }

  void _showAddJourneyDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    final _daysController = TextEditingController();
    final _timesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manuel Yolculuk Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Yolculuk Adı'),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Dua İçeriği'),
                maxLines: 3,
              ),
              TextField(
                controller: _daysController,
                decoration: const InputDecoration(labelText: 'Kaç Gün Okuyacaksın?'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _timesController,
                decoration: const InputDecoration(labelText: 'Günde Kaç Kere Okuyacaksın?'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final journey = Journey(
                id: DateTime.now().toString(),
                prayerId: 'manual_${DateTime.now().toString()}',
                prayerTitle: _titleController.text.isEmpty ? 'Manuel Yolculuk' : _titleController.text,
                content: _contentController.text,
                totalDays: _daysController.text.isEmpty ? null : int.tryParse(_daysController.text),
                timesPerDay: _timesController.text.isEmpty ? null : int.tryParse(_timesController.text),
              );
              provider.startJourney(journey);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/prayer.dart';
import '../models/journey.dart';
import 'journeys_page.dart';

class PrayerDetailPage extends StatelessWidget {
  final Prayer prayer;

  const PrayerDetailPage({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(prayer.title),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (prayer.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buyrulmuştur:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prayer.description,
                        style: TextStyle(fontSize: provider.fontSize),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (prayer.arabicContent.isNotEmpty) ...[
                      Text(
                        prayer.arabicContent,
                        style: GoogleFonts.amiri(
                          fontSize: provider.fontSize + 4,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      prayer.content,
                      style: TextStyle(fontSize: provider.fontSize),
                    ),
                    const SizedBox(height: 24),
                    if (prayer.hasCondition)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          final journey = Journey(
                            id: DateTime.now().toString(),
                            prayerId: prayer.id,
                            prayerTitle: prayer.title,
                            totalDays: prayer.days,
                            timesPerDay: prayer.timesPerDay,
                          );
                          provider.startJourney(journey);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yolculuk başlatıldı!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const JourneysPage()),
                          );
                        },
                        child: const Text('Yolculuğumu Başlat'),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          final journey = Journey(
                            id: DateTime.now().toString(),
                            prayerId: prayer.id,
                            prayerTitle: prayer.title,
                            content: prayer.content,
                          );
                          provider.startJourney(journey);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yolculuk başlatıldı!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const JourneysPage()),
                          );
                        },
                        child: const Text('Yolculuğumu Başlat'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
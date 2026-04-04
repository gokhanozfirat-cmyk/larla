import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../l10n/app_strings.dart';
import '../providers/app_provider.dart';
import '../models/prayer.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _arabicContentController = TextEditingController();
  final _contentController = TextEditingController();
  final _daysController = TextEditingController();
  final _timesController = TextEditingController();
  bool _hasCondition = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _arabicContentController.dispose();
    _contentController.dispose();
    _daysController.dispose();
    _timesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminPanel),
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
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: t.prayerTitle),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: t.descriptionOptional),
                maxLines: 2,
              ),
              TextField(
                controller: _arabicContentController,
                decoration: InputDecoration(labelText: t.arabicTextOptional),
                maxLines: 3,
                style: GoogleFonts.amiri(),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: t.prayerContent),
                maxLines: 5,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _hasCondition,
                    onChanged: (value) {
                      setState(() {
                        _hasCondition = value ?? false;
                      });
                    },
                  ),
                  Text(t.hasCondition),
                ],
              ),
              if (_hasCondition) ...[
                TextField(
                  controller: _daysController,
                  decoration: InputDecoration(labelText: t.dayCount),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _timesController,
                  decoration: InputDecoration(labelText: t.dailyReadCount),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.prayerTitleEmpty)),
                    );
                    return;
                  }
                  if (_contentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.prayerContentEmpty)),
                    );
                    return;
                  }
                  final prayer = Prayer(
                    id: DateTime.now().toString(),
                    title: _titleController.text.trim(),
                    description: _descriptionController.text,
                    arabicContent: _arabicContentController.text,
                    content: _contentController.text,
                    hasCondition: _hasCondition,
                    days: _hasCondition
                        ? int.tryParse(_daysController.text)
                        : null,
                    timesPerDay: _hasCondition
                        ? int.tryParse(_timesController.text)
                        : null,
                  );
                  provider.addPrayer(prayer);
                  _titleController.clear();
                  _descriptionController.clear();
                  _arabicContentController.clear();
                  _contentController.clear();
                  _daysController.clear();
                  _timesController.clear();
                  setState(() {
                    _hasCondition = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.prayerAdded)),
                  );
                },
                child: Text(t.addPrayer),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final prayersJson =
                      provider.prayers.map((p) => p.toJson()).toList();
                  final jsonString =
                      const JsonEncoder.withIndent('  ').convert(prayersJson);
                  Clipboard.setData(ClipboardData(text: jsonString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.jsonCopied)),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text(t.copyPrayersJson),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.prayers.length,
                  itemBuilder: (context, index) {
                    final prayer = provider.prayers[index];
                    return ListTile(
                      title: Text(prayer.title),
                      subtitle:
                          Text(prayer.hasCondition ? t.conditional : t.normal),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.removePrayer(prayer.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionService {
  // GitHub Gist Raw URL
  static const String _versionCheckUrl = 
      'https://gist.githubusercontent.com/gokhanozfirat-cmyk/e3637d13ead9d28b998b9ee829e1b6f0/raw/dualarla_version.json';
  
  // Play Store URL
  static const String _playStoreUrl = 
      'https://play.google.com/store/apps/details?id=com.dualarla.app';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(_versionCheckUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final minVersion = data['min_version'] as String;
        final latestVersion = data['latest_version'] as String;
        final forceUpdate = data['force_update'] as bool;
        final updateMessage = data['update_message'] as String;

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isVersionLower(currentVersion, minVersion)) {
          // Zorunlu güncelleme
          if (context.mounted) {
            _showForceUpdateDialog(context, updateMessage);
          }
        } else if (_isVersionLower(currentVersion, latestVersion) && !forceUpdate) {
          // Opsiyonel güncelleme
          if (context.mounted) {
            _showOptionalUpdateDialog(context, updateMessage);
          }
        }
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
      print('Version check failed: $e');
    }
  }

  static bool _isVersionLower(String current, String target) {
    final currentParts = current.split('.').map(int.parse).toList();
    final targetParts = target.split('.').map(int.parse).toList();

    for (int i = 0; i < targetParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (currentParts[i] < targetParts[i]) return true;
      if (currentParts[i] > targetParts[i]) return false;
    }
    return false;
  }

  static void _showForceUpdateDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Güncelleme Gerekli'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => _openStore(),
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showOptionalUpdateDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Güncelleme Mevcut'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Daha Sonra'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openStore();
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  static Future<void> _openStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

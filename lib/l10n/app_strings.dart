import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en'),
    Locale('ar'),
    Locale('id'),
    Locale('ur'),
    Locale('bn'),
    Locale('fr'),
    Locale('fa'),
  ];

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    final strings = Localizations.of<AppStrings>(context, AppStrings);
    assert(strings != null, 'AppStrings bulunamadi.');
    return strings!;
  }

  static String normalizeLanguageCode(String? rawCode) {
    switch ((rawCode ?? '').toLowerCase()) {
      case 'tr':
      case 'en':
      case 'ar':
      case 'id':
      case 'ur':
      case 'bn':
      case 'fr':
      case 'fa':
        return rawCode!.toLowerCase();
      default:
        return 'tr';
    }
  }

  static Locale resolveLocale(Locale? locale) {
    final code = normalizeLanguageCode(locale?.languageCode);
    return Locale(code);
  }

  factory AppStrings.forLanguageCode(String? code) {
    return AppStrings(Locale(normalizeLanguageCode(code)));
  }

  factory AppStrings.fromPlatform() {
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return AppStrings(resolveLocale(platformLocale));
  }

  String get languageCode => normalizeLanguageCode(locale.languageCode);

  String _t(String key) {
    return _translations[languageCode]?[key] ??
        _translations['tr']![key] ??
        key;
  }

  String _f(String key, Map<String, String> values) {
    var template = _t(key);
    values.forEach((k, v) => template = template.replaceAll('{$k}', v));
    return template;
  }

  String get appTitle => _t('appTitle');
  String get prayers => _t('prayers');
  String get myJourneys => _t('myJourneys');
  String get myPrayerTimes => _t('myPrayerTimes');
  String get qibla => _t('qibla');
  String get support => _t('support');
  String get home => _t('home');
  String get search => _t('search');
  String get increase => _t('increase');
  String get decrease => _t('decrease');
  String get adminLogin => _t('adminLogin');
  String get adminPanel => _t('adminPanel');
  String get password => _t('password');
  String get login => _t('login');
  String get wrongPassword => _t('wrongPassword');
  String get cancel => _t('cancel');
  String get save => _t('save');
  String get ok => _t('ok');
  String get remindMe => _t('remindMe');
  String get saidItWas => _t('saidItWas');
  String get showRecitation => _t('showRecitation');
  String get day => _t('day');
  String get read => _t('read');
  String get lastRead => _t('lastRead');
  String get readDays => _t('readDays');
  String get todayRead => _t('todayRead');
  String get totalRead => _t('totalRead');
  String get readTodayPrompt => _t('readTodayPrompt');
  String get readToday => _t('readToday');
  String get wrongEntry => _t('wrongEntry');
  String get howMuchRead => _t('howMuchRead');
  String get howManyTimes => _t('howManyTimes');
  String get howManyDeduct => _t('howManyDeduct');
  String get pleaseEnterValidNumber => _t('pleaseEnterValidNumber');
  String get readingSaved => _t('readingSaved');
  String get manualJourneyAdd => _t('manualJourneyAdd');
  String get journeyName => _t('journeyName');
  String get prayerContent => _t('prayerContent');
  String get howManyDays => _t('howManyDays');
  String get howManyTimesPerDay => _t('howManyTimesPerDay');
  String get manualJourney => _t('manualJourney');
  String get startJourney => _t('startJourney');
  String get journeyStarted => _t('journeyStarted');
  String get descriptionOptional => _t('descriptionOptional');
  String get prayerTitle => _t('prayerTitle');
  String get arabicTextOptional => _t('arabicTextOptional');
  String get hasCondition => _t('hasCondition');
  String get dayCount => _t('dayCount');
  String get dailyReadCount => _t('dailyReadCount');
  String get prayerTitleEmpty => _t('prayerTitleEmpty');
  String get prayerContentEmpty => _t('prayerContentEmpty');
  String get prayerAdded => _t('prayerAdded');
  String get addPrayer => _t('addPrayer');
  String get copyPrayersJson => _t('copyPrayersJson');
  String get jsonCopied => _t('jsonCopied');
  String get conditional => _t('conditional');
  String get normal => _t('normal');
  String get ezanTimes => _t('ezanTimes');
  String get timesLoading => _t('timesLoading');
  String get timesAutoUpdated => _t('timesAutoUpdated');
  String get ezanNotification => _t('ezanNotification');
  String get voiceOn => _t('voiceOn');
  String get voiceOff => _t('voiceOff');
  String get saveEzanTimes => _t('saveEzanTimes');
  String get qazaPrayers => _t('qazaPrayers');
  String get saveQazaPrayers => _t('saveQazaPrayers');
  String get qazaSaved => _t('qazaSaved');
  String get timesUpdatedByLocation => _t('timesUpdatedByLocation');
  String get timesFetchFailed => _t('timesFetchFailed');
  String get permissionDenied => _t('permissionDenied');
  String get noTimes => _t('noTimes');
  String get scheduleError => _t('scheduleError');
  String get ezanEnabled => _t('ezanEnabled');
  String get ezanDisabled => _t('ezanDisabled');
  String get select => _t('select');
  String get locationUnavailable => _t('locationUnavailable');
  String get refresh => _t('refresh');
  String get retry => _t('retry');
  String get qiblaNote => _t('qiblaNote');
  String get supportError => _t('supportError');
  String get thankYou => _t('thankYou');
  String get supportThanksBody => _t('supportThanksBody');
  String get supportPageTitle => _t('supportPageTitle');
  String get supportPageSubtitle => _t('supportPageSubtitle');
  String get supportFooter => _t('supportFooter');
  String get purchaseUnavailable => _t('purchaseUnavailable');
  String get playPriceLoading => _t('playPriceLoading');
  String get supporter => _t('supporter');
  String get updateRequired => _t('updateRequired');
  String get updateAvailable => _t('updateAvailable');
  String get updateNow => _t('updateNow');
  String get later => _t('later');
  String get prayerReminderTitle => _t('prayerReminderTitle');
  String get prayerReminderChannelName => _t('prayerReminderChannelName');
  String get prayerReminderChannelDescription =>
      _t('prayerReminderChannelDescription');
  String get ezanChannelName => _t('ezanChannelName');
  String get ezanChannelDescription => _t('ezanChannelDescription');

  String homeJourneySummary(
    Object currentDay,
    Object totalDays,
    Object currentRead,
    Object timesPerDay,
  ) {
    return _f('homeJourneySummary', {
      'currentDay': '$currentDay',
      'totalDays': '$totalDays',
      'currentRead': '$currentRead',
      'timesPerDay': '$timesPerDay',
    });
  }

  String dayProgress(Object currentDay, Object totalDays) {
    return _f('dayProgress', {
      'currentDay': '$currentDay',
      'totalDays': '$totalDays',
    });
  }

  String readProgress(Object currentRead, Object timesPerDay) {
    return _f('readProgress', {
      'currentRead': '$currentRead',
      'timesPerDay': '$timesPerDay',
    });
  }

  String todayMaxReads(Object remaining) {
    return _f('todayMaxReads', {'remaining': '$remaining'});
  }

  String dailyGoalCompleted(Object timesPerDay, Object currentDay) {
    return _f('dailyGoalCompleted', {
      'timesPerDay': '$timesPerDay',
      'currentDay': '$currentDay',
    });
  }

  String qiblaDirection(Object degree) {
    return _f('qiblaDirection', {'degree': '$degree'});
  }

  String approxDirection(Object direction) {
    return _f('approxDirection', {'direction': '$direction'});
  }

  String location(Object latitude, Object longitude) {
    return _f('location', {
      'latitude': '$latitude',
      'longitude': '$longitude',
    });
  }

  String supportNowYouAre(Object packageName) {
    return _f('supportNowYouAre', {'packageName': '$packageName'});
  }

  String selectPrayerTime(Object label) {
    return _f('selectPrayerTime', {'label': '$label'});
  }

  String errorWithDetails(Object message) {
    return _f('errorWithDetails', {'message': '$message'});
  }

  String compassError(Object message) {
    return _f('compassError', {'message': '$message'});
  }

  String prayerReminderBody(Object prayerTitle, Object dailyCount) {
    return _f('prayerReminderBody', {
      'prayerTitle': '$prayerTitle',
      'dailyCount': '$dailyCount',
    });
  }

  String prayerTimeTitle(Object prayerName) {
    return _f('prayerTimeTitle', {'prayerName': '$prayerName'});
  }

  String prayerNameFajr() => _t('fajr');
  String prayerNameDhuhr() => _t('dhuhr');
  String prayerNameAsr() => _t('asr');
  String prayerNameMaghrib() => _t('maghrib');
  String prayerNameIsha() => _t('isha');

  String directionName(int index) {
    const keys = [
      'north',
      'northeast',
      'east',
      'southeast',
      'south',
      'southwest',
      'west',
      'northwest',
    ];
    return _t(keys[index % keys.length]);
  }

  String supportPackageName(String productId) {
    switch (productId) {
      case 'bronze_supporter':
        return _t('bronzeSupporter');
      case 'silver_supporter':
        return _t('silverSupporter');
      case 'gold_supporter':
        return _t('goldSupporter');
      case 'diamond_supporter':
        return _t('diamondSupporter');
      default:
        return supporter;
    }
  }

  String supportPackageDescription(String productId) {
    switch (productId) {
      case 'bronze_supporter':
        return _t('bronzeSupporterDesc');
      case 'silver_supporter':
        return _t('silverSupporterDesc');
      case 'gold_supporter':
        return _t('goldSupporterDesc');
      case 'diamond_supporter':
        return _t('diamondSupporterDesc');
      default:
        return '';
    }
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    final code = AppStrings.normalizeLanguageCode(locale.languageCode);
    return AppStrings.supportedLocales.any((l) => l.languageCode == code);
  }

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(
      AppStrings(Locale(AppStrings.normalizeLanguageCode(locale.languageCode))),
    );
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

const Map<String, Map<String, String>> _translations = {
  'tr': {
    'appTitle': 'Dualarla',
    'prayers': 'Dualar',
    'myJourneys': 'Yolculuklarım',
    'myPrayerTimes': 'Namazlarım',
    'qibla': 'Kıble',
    'support': 'Destekle',
    'home': 'Ana Sayfa',
    'search': 'Ara...',
    'increase': 'Büyüt',
    'decrease': 'Küçült',
    'adminLogin': 'Admin Girişi',
    'adminPanel': 'Admin Panel',
    'password': 'Şifre',
    'login': 'Giriş',
    'wrongPassword': 'Yanlış şifre!',
    'cancel': 'İptal',
    'save': 'Kaydet',
    'ok': 'Tamam',
    'remindMe': 'Bana hatırlat',
    'saidItWas': 'Buyrulmuştur:',
    'showRecitation': 'Okunuşunu Göster',
    'day': 'Gün',
    'read': 'Okuma',
    'lastRead': 'Son Okuma',
    'readDays': 'Okunan Gün',
    'todayRead': 'Bugün Okuma',
    'totalRead': 'Toplam Okuma',
    'readTodayPrompt': 'Bugün Ne Kadar Okudun?',
    'readToday': 'Bugün Okudum',
    'wrongEntry': 'Yanlış Giriş',
    'howMuchRead': 'Ne kadar okudun?',
    'howManyTimes': 'Kaç kere okudunuz?',
    'howManyDeduct': 'Kaç Eksilteceksin?',
    'pleaseEnterValidNumber': 'Lütfen geçerli bir sayı girin.',
    'todayMaxReads': 'Bugün en fazla {remaining} kere okuyabilirsiniz.',
    'readingSaved': 'Okuma kaydedildi!',
    'dailyGoalCompleted':
        'Bugün {timesPerDay}x okumayı tamamladınız! Gün {currentDay}',
    'manualJourneyAdd': 'Manuel Yolculuk Ekle',
    'journeyName': 'Yolculuk Adı',
    'prayerContent': 'Dua İçeriği',
    'howManyDays': 'Kaç Gün Okuyacaksın?',
    'howManyTimesPerDay': 'Günde Kaç Kere Okuyacaksın?',
    'manualJourney': 'Manuel Yolculuk',
    'startJourney': 'Yolculuğumu Başlat',
    'journeyStarted': 'Yolculuk başlatıldı!',
    'descriptionOptional': 'Tanım (İsteğe Bağlı)',
    'prayerTitle': 'Dua Başlığı',
    'arabicTextOptional': 'Arapça Metin (İsteğe Bağlı)',
    'hasCondition': 'Koşul Var',
    'dayCount': 'Gün Sayısı',
    'dailyReadCount': 'Günlük Okuma Sayısı',
    'prayerTitleEmpty': 'Dua başlığı boş olamaz.',
    'prayerContentEmpty': 'Dua içeriği boş olamaz.',
    'prayerAdded': 'Dua eklendi!',
    'addPrayer': 'Dua Ekle',
    'copyPrayersJson': 'Duaları JSON Olarak Kopyala',
    'jsonCopied':
        'JSON panoya kopyalandı! assets/prayers.json dosyasına yapıştırın.',
    'conditional': 'Koşullu',
    'normal': 'Normal',
    'ezanTimes': 'Ezan Vakitleri',
    'timesLoading': 'Vakitler alınıyor...',
    'timesAutoUpdated': 'Vakitler konumunuza göre otomatik güncellenir',
    'ezanNotification': 'Ezan Bildirimi',
    'voiceOn': 'Sesli bildirim açık 🔔',
    'voiceOff': 'Sesli bildirim kapalı',
    'saveEzanTimes': 'Ezan Vakitlerini Kaydet',
    'qazaPrayers': 'Kaza Namazları',
    'saveQazaPrayers': 'Kaza Namazlarını Kaydet',
    'qazaSaved': 'Kaza namazları kaydedildi!',
    'timesUpdatedByLocation': 'Namaz vakitleri konumunuza göre güncellendi! 📍',
    'timesFetchFailed':
        'Vakitler alınamadı. Konum izni verdiğinizden emin olun.',
    'permissionDenied':
        'Bildirim izni verilmedi. Lütfen ayarlardan bildirim iznini açın.',
    'noTimes':
        'Namaz vakitleri boş. Lütfen önce vakitleri girin veya konumdan alın.',
    'scheduleError':
        'Bildirimler planlanırken bir hata oluştu. Lütfen tekrar deneyin.',
    'ezanEnabled': 'Ezan bildirimleri aktif edildi! 🕌',
    'ezanDisabled': 'Ezan bildirimleri kapatıldı',
    'select': 'Seç',
    'selectPrayerTime': '{label} Vakti Seçin',
    'locationUnavailable':
        'Konum alınamadı. Konum izni verdiğinizden emin olun.',
    'refresh': 'Yenile',
    'retry': 'Tekrar dene',
    'qiblaDirection': 'Kıble yönü: {degree}°',
    'approxDirection': 'Yaklaşık yön: {direction}',
    'location': 'Konum: {latitude}, {longitude}',
    'qiblaNote': 'Not: Ok, cihaz yönüne göre canlı döner.',
    'north': 'Kuzey',
    'northeast': 'Kuzeydoğu',
    'east': 'Doğu',
    'southeast': 'Güneydoğu',
    'south': 'Güney',
    'southwest': 'Güneybatı',
    'west': 'Batı',
    'northwest': 'Kuzeybatı',
    'supportError': 'Hata',
    'thankYou': 'Teşekkürler!',
    'supportNowYouAre': 'Artık {packageName} oldunuz!',
    'supportThanksBody':
        'Desteğiniz için çok teşekkür ederiz. Allah razı olsun.',
    'supportPageTitle': 'Dualarla\'yı Destekleyin',
    'supportPageSubtitle':
        'Desteğiniz sayesinde uygulamayı geliştirmeye ve daha fazla içerik eklemeye devam edebiliyoruz.',
    'supportFooter':
        'Tüm destek paketleri tek seferlik bağıştır.\nDesteğiniz direkt uygulama geliştirmeye gider.',
    'purchaseUnavailable':
        'Satın alma şu anda kullanılamıyor. Google Play Store\'dan indirdiğinizde aktif olacak.',
    'playPriceLoading': 'Play fiyatı yükleniyor',
    'supporter': 'Destekçi',
    'bronzeSupporter': 'Bronz Destekçi',
    'silverSupporter': 'Gümüş Destekçi',
    'goldSupporter': 'Altın Destekçi',
    'diamondSupporter': 'Elmas Destekçi',
    'bronzeSupporterDesc': 'Uygulamaya küçük bir katkıda bulunun',
    'silverSupporterDesc': 'Uygulamanın gelişimine destek olun',
    'goldSupporterDesc': 'Büyük bir destek verin',
    'diamondSupporterDesc': 'En değerli destekçimiz olun',
    'updateRequired': 'Güncelleme Gerekli',
    'updateAvailable': 'Yeni Güncelleme Mevcut',
    'updateNow': 'Güncelle',
    'later': 'Daha Sonra',
    'prayerReminderTitle': 'Dua Hatırlatması',
    'prayerReminderBody':
        'Bugünkü tekrarlarını unutma! 📖\n{prayerTitle} - {dailyCount} kez oku',
    'prayerReminderChannelName': 'Dua Hatırlatmaları',
    'prayerReminderChannelDescription': 'Günlük dua hatırlatmaları',
    'prayerTimeTitle': '{prayerName} Namazı Vakti',
    'ezanChannelName': 'Ezan Bildirimleri',
    'ezanChannelDescription': 'Namaz vakti bildirimleri',
    'fajr': 'Sabah',
    'dhuhr': 'Öğle',
    'asr': 'İkindi',
    'maghrib': 'Akşam',
    'isha': 'Yatsı',
    'homeJourneySummary':
        'Gün {currentDay}/{totalDays} - Okuma {currentRead}/{timesPerDay}',
    'dayProgress': 'Gün: {currentDay}/{totalDays}',
    'readProgress': 'Okuma: {currentRead}/{timesPerDay}',
    'errorWithDetails': 'Hata: {message}',
    'compassError': 'Pusula sensörü hatası: {message}',
  },
  'en': {
    'appTitle': 'Dualarla',
    'prayers': 'Prayers',
    'myJourneys': 'My Journeys',
    'myPrayerTimes': 'My Prayers',
    'qibla': 'Qibla',
    'support': 'Support',
    'home': 'Home',
    'search': 'Search...',
    'increase': 'Larger',
    'decrease': 'Smaller',
    'adminLogin': 'Admin Login',
    'adminPanel': 'Admin Panel',
    'password': 'Password',
    'login': 'Login',
    'wrongPassword': 'Wrong password!',
    'cancel': 'Cancel',
    'save': 'Save',
    'ok': 'OK',
    'remindMe': 'Remind me',
    'saidItWas': 'It is said:',
    'showRecitation': 'Show Recitation',
    'day': 'Day',
    'read': 'Read',
    'lastRead': 'Last Read',
    'readDays': 'Read Days',
    'todayRead': 'Today\'s Read',
    'totalRead': 'Total Read',
    'readTodayPrompt': 'How much did you read today?',
    'readToday': 'I Read Today',
    'wrongEntry': 'Wrong Entry',
    'howMuchRead': 'How much did you read?',
    'howManyTimes': 'How many times did you read?',
    'howManyDeduct': 'How much to deduct?',
    'pleaseEnterValidNumber': 'Please enter a valid number.',
    'todayMaxReads': 'You can read at most {remaining} times today.',
    'readingSaved': 'Reading saved!',
    'dailyGoalCompleted':
        'You completed {timesPerDay} reads today! Day {currentDay}',
    'manualJourneyAdd': 'Add Manual Journey',
    'journeyName': 'Journey Name',
    'prayerContent': 'Prayer Content',
    'howManyDays': 'How many days will you read?',
    'howManyTimesPerDay': 'How many times per day?',
    'manualJourney': 'Manual Journey',
    'startJourney': 'Start My Journey',
    'journeyStarted': 'Journey started!',
    'descriptionOptional': 'Description (Optional)',
    'prayerTitle': 'Prayer Title',
    'arabicTextOptional': 'Arabic Text (Optional)',
    'hasCondition': 'Has Condition',
    'dayCount': 'Day Count',
    'dailyReadCount': 'Daily Read Count',
    'prayerTitleEmpty': 'Prayer title cannot be empty.',
    'prayerContentEmpty': 'Prayer content cannot be empty.',
    'prayerAdded': 'Prayer added!',
    'addPrayer': 'Add Prayer',
    'copyPrayersJson': 'Copy Prayers as JSON',
    'jsonCopied': 'JSON copied to clipboard! Paste into assets/prayers.json.',
    'conditional': 'Conditional',
    'normal': 'Normal',
    'ezanTimes': 'Prayer Times',
    'timesLoading': 'Loading times...',
    'timesAutoUpdated':
        'Times are automatically updated based on your location',
    'ezanNotification': 'Prayer Time Notification',
    'voiceOn': 'Sound notification on 🔔',
    'voiceOff': 'Sound notification off',
    'saveEzanTimes': 'Save Prayer Times',
    'qazaPrayers': 'Qaza Prayers',
    'saveQazaPrayers': 'Save Qaza Prayers',
    'qazaSaved': 'Qaza prayers saved!',
    'timesUpdatedByLocation': 'Prayer times updated based on your location! 📍',
    'timesFetchFailed':
        'Could not fetch times. Please make sure location permission is granted.',
    'permissionDenied':
        'Notification permission denied. Please enable it in settings.',
    'noTimes':
        'Prayer times are empty. Please enter times first or fetch by location.',
    'scheduleError':
        'An error occurred while scheduling notifications. Please try again.',
    'ezanEnabled': 'Prayer time notifications enabled! 🕌',
    'ezanDisabled': 'Prayer time notifications disabled',
    'select': 'Select',
    'selectPrayerTime': 'Select {label} Time',
    'locationUnavailable':
        'Location unavailable. Please make sure location permission is granted.',
    'refresh': 'Refresh',
    'retry': 'Try again',
    'qiblaDirection': 'Qibla direction: {degree}°',
    'approxDirection': 'Approximate direction: {direction}',
    'location': 'Location: {latitude}, {longitude}',
    'qiblaNote': 'Note: The arrow rotates live according to device direction.',
    'north': 'North',
    'northeast': 'Northeast',
    'east': 'East',
    'southeast': 'Southeast',
    'south': 'South',
    'southwest': 'Southwest',
    'west': 'West',
    'northwest': 'Northwest',
    'supportError': 'Error',
    'thankYou': 'Thank you!',
    'supportNowYouAre': 'You are now a {packageName}!',
    'supportThanksBody':
        'Thank you very much for your support. May Allah bless you.',
    'supportPageTitle': 'Support Dualarla',
    'supportPageSubtitle':
        'Thanks to your support, we can keep improving the app and adding more content.',
    'supportFooter':
        'All support packages are one-time donations.\nYour support goes directly to app development.',
    'purchaseUnavailable':
        'Purchases are currently unavailable. It will be active when installed from Google Play Store.',
    'playPriceLoading': 'Loading Play price',
    'supporter': 'Supporter',
    'bronzeSupporter': 'Bronze Supporter',
    'silverSupporter': 'Silver Supporter',
    'goldSupporter': 'Gold Supporter',
    'diamondSupporter': 'Diamond Supporter',
    'bronzeSupporterDesc': 'Make a small contribution to the app',
    'silverSupporterDesc': 'Support the app development',
    'goldSupporterDesc': 'Give strong support',
    'diamondSupporterDesc': 'Become our most valuable supporter',
    'updateRequired': 'Update Required',
    'updateAvailable': 'New Update Available',
    'updateNow': 'Update',
    'later': 'Later',
    'prayerReminderTitle': 'Prayer Reminder',
    'prayerReminderBody':
        'Do not forget your repetitions today! 📖\n{prayerTitle} - read {dailyCount} times',
    'prayerReminderChannelName': 'Prayer Reminders',
    'prayerReminderChannelDescription': 'Daily prayer reminders',
    'prayerTimeTitle': '{prayerName} Prayer Time',
    'ezanChannelName': 'Prayer Time Notifications',
    'ezanChannelDescription': 'Prayer time notifications',
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
    'homeJourneySummary':
        'Day {currentDay}/{totalDays} - Read {currentRead}/{timesPerDay}',
    'dayProgress': 'Day: {currentDay}/{totalDays}',
    'readProgress': 'Read: {currentRead}/{timesPerDay}',
    'errorWithDetails': 'Error: {message}',
    'compassError': 'Compass sensor error: {message}',
  },
  'ar': {
    'appTitle': 'مع الدعاء',
    'prayers': 'الأدعية',
    'myJourneys': 'رحلاتي',
    'myPrayerTimes': 'صلواتي',
    'qibla': 'القبلة',
    'support': 'ادعم',
    'home': 'الرئيسية',
    'search': 'بحث...',
    'increase': 'تكبير',
    'decrease': 'تصغير',
    'adminLogin': 'دخول المشرف',
    'adminPanel': 'لوحة المشرف',
    'password': 'كلمة المرور',
    'login': 'دخول',
    'wrongPassword': 'كلمة المرور خاطئة!',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'ok': 'حسنًا',
    'remindMe': 'ذكّرني',
    'saidItWas': 'ورد:',
    'showRecitation': 'عرض القراءة',
    'day': 'اليوم',
    'read': 'القراءة',
    'lastRead': 'آخر قراءة',
    'readDays': 'أيام القراءة',
    'todayRead': 'قراءة اليوم',
    'totalRead': 'إجمالي القراءة',
    'readTodayPrompt': 'كم قرأت اليوم؟',
    'readToday': 'قرأت اليوم',
    'wrongEntry': 'إدخال خاطئ',
    'howMuchRead': 'كم قرأت؟',
    'howManyTimes': 'كم مرة قرأت؟',
    'howManyDeduct': 'كم تريد الخصم؟',
    'pleaseEnterValidNumber': 'يرجى إدخال رقم صحيح.',
    'todayMaxReads': 'يمكنك القراءة بحد أقصى {remaining} مرة اليوم.',
    'readingSaved': 'تم حفظ القراءة!',
    'dailyGoalCompleted': 'أكملت {timesPerDay} قراءة اليوم! اليوم {currentDay}',
    'manualJourneyAdd': 'إضافة رحلة يدوية',
    'journeyName': 'اسم الرحلة',
    'prayerContent': 'محتوى الدعاء',
    'howManyDays': 'كم يومًا ستقرأ؟',
    'howManyTimesPerDay': 'كم مرة يوميًا؟',
    'manualJourney': 'رحلة يدوية',
    'startJourney': 'ابدأ رحلتي',
    'journeyStarted': 'بدأت الرحلة!',
    'descriptionOptional': 'الوصف (اختياري)',
    'prayerTitle': 'عنوان الدعاء',
    'arabicTextOptional': 'النص العربي (اختياري)',
    'hasCondition': 'يوجد شرط',
    'dayCount': 'عدد الأيام',
    'dailyReadCount': 'عدد القراءة اليومي',
    'prayerTitleEmpty': 'لا يمكن أن يكون عنوان الدعاء فارغًا.',
    'prayerContentEmpty': 'لا يمكن أن يكون محتوى الدعاء فارغًا.',
    'prayerAdded': 'تمت إضافة الدعاء!',
    'addPrayer': 'إضافة دعاء',
    'copyPrayersJson': 'نسخ الأدعية بصيغة JSON',
    'jsonCopied': 'تم نسخ JSON إلى الحافظة!',
    'conditional': 'مشروط',
    'normal': 'عادي',
    'ezanTimes': 'أوقات الصلاة',
    'timesLoading': 'جارٍ تحميل الأوقات...',
    'timesAutoUpdated': 'يتم تحديث الأوقات تلقائيًا حسب موقعك',
    'ezanNotification': 'تنبيه الأذان',
    'voiceOn': 'التنبيه الصوتي مُفعّل 🔔',
    'voiceOff': 'التنبيه الصوتي مُعطل',
    'saveEzanTimes': 'حفظ أوقات الصلاة',
    'qazaPrayers': 'صلوات القضاء',
    'saveQazaPrayers': 'حفظ صلوات القضاء',
    'qazaSaved': 'تم حفظ صلوات القضاء!',
    'timesUpdatedByLocation': 'تم تحديث أوقات الصلاة حسب موقعك! 📍',
    'timesFetchFailed': 'تعذر جلب الأوقات. تأكد من إذن الموقع.',
    'permissionDenied': 'تم رفض إذن الإشعارات. فعّله من الإعدادات.',
    'noTimes': 'أوقات الصلاة فارغة. أدخل الأوقات أولًا أو اجلبها من الموقع.',
    'scheduleError': 'حدث خطأ أثناء جدولة الإشعارات. حاول مرة أخرى.',
    'ezanEnabled': 'تم تفعيل إشعارات الأذان! 🕌',
    'ezanDisabled': 'تم إيقاف إشعارات الأذان',
    'select': 'اختر',
    'selectPrayerTime': 'اختر وقت {label}',
    'locationUnavailable': 'تعذر الحصول على الموقع. تأكد من منح الإذن.',
    'refresh': 'تحديث',
    'retry': 'إعادة المحاولة',
    'qiblaDirection': 'اتجاه القبلة: {degree}°',
    'approxDirection': 'الاتجاه التقريبي: {direction}',
    'location': 'الموقع: {latitude}, {longitude}',
    'qiblaNote': 'ملاحظة: السهم يدور مباشرة حسب اتجاه الجهاز.',
    'north': 'شمال',
    'northeast': 'شمال شرقي',
    'east': 'شرق',
    'southeast': 'جنوب شرقي',
    'south': 'جنوب',
    'southwest': 'جنوب غربي',
    'west': 'غرب',
    'northwest': 'شمال غربي',
    'supportError': 'خطأ',
    'thankYou': 'شكرًا لك!',
    'supportNowYouAre': 'أنت الآن {packageName}!',
    'supportThanksBody': 'شكرًا جزيلًا لدعمك. جزاك الله خيرًا.',
    'supportPageTitle': 'ادعم تطبيق مع الدعاء',
    'supportPageSubtitle':
        'بفضل دعمك نستمر في تطوير التطبيق وإضافة المزيد من المحتوى.',
    'supportFooter':
        'جميع باقات الدعم تبرع لمرة واحدة.\nدعمك يذهب مباشرة لتطوير التطبيق.',
    'purchaseUnavailable':
        'الشراء غير متاح الآن. سيتفعّل عند التثبيت من متجر Google Play.',
    'playPriceLoading': 'جارٍ تحميل السعر',
    'supporter': 'داعم',
    'bronzeSupporter': 'داعم برونزي',
    'silverSupporter': 'داعم فضي',
    'goldSupporter': 'داعم ذهبي',
    'diamondSupporter': 'داعم ألماسي',
    'bronzeSupporterDesc': 'قدّم مساهمة صغيرة للتطبيق',
    'silverSupporterDesc': 'ادعم تطوير التطبيق',
    'goldSupporterDesc': 'قدّم دعمًا كبيرًا',
    'diamondSupporterDesc': 'كن الداعم الأكثر قيمة',
    'updateRequired': 'التحديث مطلوب',
    'updateAvailable': 'يتوفر تحديث جديد',
    'updateNow': 'تحديث',
    'later': 'لاحقًا',
    'prayerReminderTitle': 'تذكير بالدعاء',
    'prayerReminderBody':
        'لا تنس تكرارات اليوم! 📖\n{prayerTitle} - اقرأ {dailyCount} مرة',
    'prayerReminderChannelName': 'تذكيرات الدعاء',
    'prayerReminderChannelDescription': 'تذكيرات الدعاء اليومية',
    'prayerTimeTitle': 'وقت صلاة {prayerName}',
    'ezanChannelName': 'إشعارات الأذان',
    'ezanChannelDescription': 'إشعارات وقت الصلاة',
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
    'homeJourneySummary':
        'اليوم {currentDay}/{totalDays} - القراءة {currentRead}/{timesPerDay}',
    'dayProgress': 'اليوم: {currentDay}/{totalDays}',
    'readProgress': 'القراءة: {currentRead}/{timesPerDay}',
    'errorWithDetails': 'خطأ: {message}',
    'compassError': 'خطأ في مستشعر البوصلة: {message}',
  },
  'id': {
    'appTitle': 'Dengan Doa',
    'prayers': 'Doa',
    'myJourneys': 'Perjalananku',
    'myPrayerTimes': 'Salatku',
    'qibla': 'Kiblat',
    'support': 'Dukung',
    'home': 'Beranda',
    'search': 'Cari...',
    'increase': 'Perbesar',
    'decrease': 'Perkecil',
    'adminLogin': 'Masuk Admin',
    'adminPanel': 'Panel Admin',
    'password': 'Kata Sandi',
    'login': 'Masuk',
    'wrongPassword': 'Kata sandi salah!',
    'cancel': 'Batal',
    'save': 'Simpan',
    'ok': 'OK',
    'remindMe': 'Ingatkan saya',
    'saidItWas': 'Diriwayatkan:',
    'showRecitation': 'Tampilkan Bacaan',
    'day': 'Hari',
    'read': 'Bacaan',
    'lastRead': 'Bacaan Terakhir',
    'readDays': 'Hari Dibaca',
    'todayRead': 'Bacaan Hari Ini',
    'totalRead': 'Total Bacaan',
    'readTodayPrompt': 'Berapa yang kamu baca hari ini?',
    'readToday': 'Saya Sudah Membaca Hari Ini',
    'wrongEntry': 'Input Salah',
    'howMuchRead': 'Berapa yang kamu baca?',
    'howManyTimes': 'Berapa kali kamu membaca?',
    'howManyDeduct': 'Kurangi berapa?',
    'pleaseEnterValidNumber': 'Masukkan angka yang valid.',
    'todayMaxReads': 'Hari ini maksimal {remaining} kali membaca.',
    'readingSaved': 'Bacaan disimpan!',
    'dailyGoalCompleted':
        'Kamu menyelesaikan {timesPerDay}x bacaan hari ini! Hari {currentDay}',
    'manualJourneyAdd': 'Tambah Perjalanan Manual',
    'journeyName': 'Nama Perjalanan',
    'prayerContent': 'Isi Doa',
    'howManyDays': 'Berapa hari kamu akan membaca?',
    'howManyTimesPerDay': 'Berapa kali per hari?',
    'manualJourney': 'Perjalanan Manual',
    'startJourney': 'Mulai Perjalananku',
    'journeyStarted': 'Perjalanan dimulai!',
    'descriptionOptional': 'Deskripsi (Opsional)',
    'prayerTitle': 'Judul Doa',
    'arabicTextOptional': 'Teks Arab (Opsional)',
    'hasCondition': 'Ada Syarat',
    'dayCount': 'Jumlah Hari',
    'dailyReadCount': 'Jumlah Bacaan Harian',
    'prayerTitleEmpty': 'Judul doa tidak boleh kosong.',
    'prayerContentEmpty': 'Isi doa tidak boleh kosong.',
    'prayerAdded': 'Doa ditambahkan!',
    'addPrayer': 'Tambah Doa',
    'copyPrayersJson': 'Salin Doa sebagai JSON',
    'jsonCopied': 'JSON disalin ke clipboard!',
    'conditional': 'Bersyarat',
    'normal': 'Normal',
    'ezanTimes': 'Waktu Salat',
    'timesLoading': 'Memuat waktu...',
    'timesAutoUpdated': 'Waktu diperbarui otomatis berdasarkan lokasi',
    'ezanNotification': 'Notifikasi Azan',
    'voiceOn': 'Notifikasi suara aktif 🔔',
    'voiceOff': 'Notifikasi suara nonaktif',
    'saveEzanTimes': 'Simpan Waktu Salat',
    'qazaPrayers': 'Salat Qadha',
    'saveQazaPrayers': 'Simpan Salat Qadha',
    'qazaSaved': 'Salat qadha disimpan!',
    'timesUpdatedByLocation': 'Waktu salat diperbarui berdasarkan lokasi! 📍',
    'timesFetchFailed':
        'Gagal mengambil waktu. Pastikan izin lokasi diberikan.',
    'permissionDenied': 'Izin notifikasi ditolak. Aktifkan dari pengaturan.',
    'noTimes': 'Waktu salat kosong. Isi dulu atau ambil dari lokasi.',
    'scheduleError': 'Terjadi kesalahan saat menjadwalkan notifikasi.',
    'ezanEnabled': 'Notifikasi azan diaktifkan! 🕌',
    'ezanDisabled': 'Notifikasi azan dimatikan',
    'select': 'Pilih',
    'selectPrayerTime': 'Pilih waktu {label}',
    'locationUnavailable':
        'Lokasi tidak tersedia. Pastikan izin lokasi diberikan.',
    'refresh': 'Muat Ulang',
    'retry': 'Coba lagi',
    'qiblaDirection': 'Arah kiblat: {degree}°',
    'approxDirection': 'Arah perkiraan: {direction}',
    'location': 'Lokasi: {latitude}, {longitude}',
    'qiblaNote': 'Catatan: Panah berputar sesuai arah perangkat.',
    'north': 'Utara',
    'northeast': 'Timur Laut',
    'east': 'Timur',
    'southeast': 'Tenggara',
    'south': 'Selatan',
    'southwest': 'Barat Daya',
    'west': 'Barat',
    'northwest': 'Barat Laut',
    'supportError': 'Kesalahan',
    'thankYou': 'Terima kasih!',
    'supportNowYouAre': 'Sekarang kamu adalah {packageName}!',
    'supportThanksBody':
        'Terima kasih atas dukunganmu. Semoga Allah membalas kebaikanmu.',
    'supportPageTitle': 'Dukung Dualarla',
    'supportPageSubtitle':
        'Berkat dukunganmu, kami terus mengembangkan aplikasi ini.',
    'supportFooter':
        'Semua paket dukungan adalah donasi satu kali.\nDukunganmu langsung untuk pengembangan aplikasi.',
    'purchaseUnavailable':
        'Pembelian saat ini tidak tersedia. Aktif saat diinstal dari Google Play Store.',
    'playPriceLoading': 'Harga Play sedang dimuat',
    'supporter': 'Pendukung',
    'bronzeSupporter': 'Pendukung Perunggu',
    'silverSupporter': 'Pendukung Perak',
    'goldSupporter': 'Pendukung Emas',
    'diamondSupporter': 'Pendukung Berlian',
    'bronzeSupporterDesc': 'Beri kontribusi kecil untuk aplikasi',
    'silverSupporterDesc': 'Dukung pengembangan aplikasi',
    'goldSupporterDesc': 'Beri dukungan besar',
    'diamondSupporterDesc': 'Jadilah pendukung paling berharga',
    'updateRequired': 'Pembaruan Diperlukan',
    'updateAvailable': 'Pembaruan Baru Tersedia',
    'updateNow': 'Perbarui',
    'later': 'Nanti',
    'prayerReminderTitle': 'Pengingat Doa',
    'prayerReminderBody':
        'Jangan lupa bacaan hari ini! 📖\n{prayerTitle} - baca {dailyCount} kali',
    'prayerReminderChannelName': 'Pengingat Doa',
    'prayerReminderChannelDescription': 'Pengingat doa harian',
    'prayerTimeTitle': 'Waktu Salat {prayerName}',
    'ezanChannelName': 'Notifikasi Azan',
    'ezanChannelDescription': 'Notifikasi waktu salat',
    'fajr': 'Subuh',
    'dhuhr': 'Dzuhur',
    'asr': 'Ashar',
    'maghrib': 'Maghrib',
    'isha': 'Isya',
    'homeJourneySummary':
        'Hari {currentDay}/{totalDays} - Bacaan {currentRead}/{timesPerDay}',
    'dayProgress': 'Hari: {currentDay}/{totalDays}',
    'readProgress': 'Bacaan: {currentRead}/{timesPerDay}',
    'errorWithDetails': 'Kesalahan: {message}',
    'compassError': 'Kesalahan sensor kompas: {message}',
  },
  'ur': {
    'appTitle': 'دعاؤں کے ساتھ',
    'prayers': 'دعائیں',
    'myJourneys': 'میرا سفر',
    'myPrayerTimes': 'میری نمازیں',
    'qibla': 'قبلہ',
    'support': 'سپورٹ',
    'home': 'ہوم',
    'search': 'تلاش...',
    'increase': 'بڑا',
    'decrease': 'چھوٹا',
    'adminLogin': 'ایڈمن لاگ اِن',
    'adminPanel': 'ایڈمن پینل',
    'password': 'پاس ورڈ',
    'login': 'لاگ اِن',
    'wrongPassword': 'غلط پاس ورڈ!',
    'cancel': 'منسوخ',
    'save': 'محفوظ کریں',
    'ok': 'ٹھیک ہے',
    'remindMe': 'مجھے یاد دلاؤ',
    'saidItWas': 'ارشاد ہے:',
    'showRecitation': 'پڑھائی دکھائیں',
    'day': 'دن',
    'read': 'پڑھائی',
    'lastRead': 'آخری پڑھائی',
    'readDays': 'پڑھے گئے دن',
    'todayRead': 'آج کی پڑھائی',
    'totalRead': 'کل پڑھائی',
    'readTodayPrompt': 'آج کتنا پڑھا؟',
    'readToday': 'میں نے آج پڑھا',
    'wrongEntry': 'غلط اندراج',
    'howMuchRead': 'آپ نے کتنا پڑھا؟',
    'howManyTimes': 'آپ نے کتنی بار پڑھا؟',
    'howManyDeduct': 'کتنا کم کرنا ہے؟',
    'pleaseEnterValidNumber': 'براہ کرم درست عدد درج کریں۔',
    'todayMaxReads': 'آج زیادہ سے زیادہ {remaining} بار پڑھ سکتے ہیں۔',
    'readingSaved': 'پڑھائی محفوظ ہوگئی!',
    'dailyGoalCompleted':
        'آپ نے آج {timesPerDay} بار مکمل کرلیا! دن {currentDay}',
    'manualJourneyAdd': 'مینول سفر شامل کریں',
    'journeyName': 'سفر کا نام',
    'prayerContent': 'دعا کا متن',
    'howManyDays': 'کتنے دن پڑھو گے؟',
    'howManyTimesPerDay': 'روزانہ کتنی بار؟',
    'manualJourney': 'مینول سفر',
    'startJourney': 'میرا سفر شروع کریں',
    'journeyStarted': 'سفر شروع ہوگیا!',
    'descriptionOptional': 'تفصیل (اختیاری)',
    'prayerTitle': 'دعا کا عنوان',
    'arabicTextOptional': 'عربی متن (اختیاری)',
    'hasCondition': 'شرط موجود ہے',
    'dayCount': 'دنوں کی تعداد',
    'dailyReadCount': 'روزانہ پڑھائی کی تعداد',
    'prayerTitleEmpty': 'دعا کا عنوان خالی نہیں ہوسکتا۔',
    'prayerContentEmpty': 'دعا کا متن خالی نہیں ہوسکتا۔',
    'prayerAdded': 'دعا شامل ہوگئی!',
    'addPrayer': 'دعا شامل کریں',
    'copyPrayersJson': 'دعائیں JSON میں کاپی کریں',
    'jsonCopied': 'JSON کلپ بورڈ میں کاپی ہوگیا!',
    'conditional': 'مشروط',
    'normal': 'عام',
    'ezanTimes': 'نماز کے اوقات',
    'timesLoading': 'اوقات لوڈ ہو رہے ہیں...',
    'timesAutoUpdated': 'اوقات آپ کے مقام کے مطابق خودکار اپڈیٹ ہوتے ہیں',
    'ezanNotification': 'اذان نوٹیفکیشن',
    'voiceOn': 'آواز والا نوٹیفکیشن آن ہے 🔔',
    'voiceOff': 'آواز والا نوٹیفکیشن آف ہے',
    'saveEzanTimes': 'نماز کے اوقات محفوظ کریں',
    'qazaPrayers': 'قضا نمازیں',
    'saveQazaPrayers': 'قضا نمازیں محفوظ کریں',
    'qazaSaved': 'قضا نمازیں محفوظ ہوگئیں!',
    'timesUpdatedByLocation': 'نماز کے اوقات مقام کے مطابق اپڈیٹ ہوگئے! 📍',
    'timesFetchFailed': 'اوقات حاصل نہ ہوسکے۔ مقام کی اجازت چیک کریں۔',
    'permissionDenied': 'نوٹیفکیشن کی اجازت نہیں ملی۔ سیٹنگز سے اجازت دیں۔',
    'noTimes':
        'نماز کے اوقات خالی ہیں۔ پہلے وقت درج کریں یا مقام سے حاصل کریں۔',
    'scheduleError': 'نوٹیفکیشن شیڈول کرتے وقت مسئلہ ہوا۔ دوبارہ کوشش کریں۔',
    'ezanEnabled': 'اذان نوٹیفکیشن فعال ہوگئے! 🕌',
    'ezanDisabled': 'اذان نوٹیفکیشن بند ہوگئے',
    'select': 'منتخب کریں',
    'selectPrayerTime': '{label} کا وقت منتخب کریں',
    'locationUnavailable': 'مقام دستیاب نہیں۔ براہ کرم مقام کی اجازت دیں۔',
    'refresh': 'ریفریش',
    'retry': 'دوبارہ کوشش کریں',
    'qiblaDirection': 'قبلہ رخ: {degree}°',
    'approxDirection': 'تقریبی سمت: {direction}',
    'location': 'مقام: {latitude}, {longitude}',
    'qiblaNote': 'نوٹ: تیر ڈیوائس کی سمت کے مطابق گھومتا ہے۔',
    'north': 'شمال',
    'northeast': 'شمال مشرق',
    'east': 'مشرق',
    'southeast': 'جنوب مشرق',
    'south': 'جنوب',
    'southwest': 'جنوب مغرب',
    'west': 'مغرب',
    'northwest': 'شمال مغرب',
    'supportError': 'خرابی',
    'thankYou': 'شکریہ!',
    'supportNowYouAre': 'اب آپ {packageName} ہیں!',
    'supportThanksBody': 'آپ کے تعاون کا بہت شکریہ۔ اللہ آپ کو جزائے خیر دے۔',
    'supportPageTitle': 'Dualarla کو سپورٹ کریں',
    'supportPageSubtitle':
        'آپ کے تعاون سے ہم ایپ بہتر بناتے اور نیا مواد شامل کرتے رہتے ہیں۔',
    'supportFooter':
        'تمام سپورٹ پیکیج ایک بار کے عطیات ہیں۔\nآپ کا تعاون براہ راست ایپ ڈویلپمنٹ میں جاتا ہے۔',
    'purchaseUnavailable':
        'خریداری فی الحال دستیاب نہیں۔ گوگل پلے سے انسٹال پر فعال ہوگی۔',
    'playPriceLoading': 'Play قیمت لوڈ ہو رہی ہے',
    'supporter': 'سپورٹر',
    'bronzeSupporter': 'برونز سپورٹر',
    'silverSupporter': 'سلور سپورٹر',
    'goldSupporter': 'گولڈ سپورٹر',
    'diamondSupporter': 'ڈائمنڈ سپورٹر',
    'bronzeSupporterDesc': 'ایپ میں چھوٹا تعاون کریں',
    'silverSupporterDesc': 'ایپ کی ترقی میں مدد کریں',
    'goldSupporterDesc': 'بڑا تعاون دیں',
    'diamondSupporterDesc': 'سب سے قیمتی سپورٹر بنیں',
    'updateRequired': 'اپڈیٹ ضروری ہے',
    'updateAvailable': 'نیا اپڈیٹ دستیاب ہے',
    'updateNow': 'اپڈیٹ',
    'later': 'بعد میں',
    'prayerReminderTitle': 'دعا یاد دہانی',
    'prayerReminderBody':
        'آج کی تکرار نہ بھولیں! 📖\n{prayerTitle} - {dailyCount} بار پڑھیں',
    'prayerReminderChannelName': 'دعا یاد دہانیاں',
    'prayerReminderChannelDescription': 'روزانہ دعا یاد دہانیاں',
    'prayerTimeTitle': '{prayerName} نماز کا وقت',
    'ezanChannelName': 'اذان نوٹیفکیشن',
    'ezanChannelDescription': 'نماز وقت نوٹیفکیشن',
    'fajr': 'فجر',
    'dhuhr': 'ظہر',
    'asr': 'عصر',
    'maghrib': 'مغرب',
    'isha': 'عشاء',
    'homeJourneySummary':
        'دن {currentDay}/{totalDays} - پڑھائی {currentRead}/{timesPerDay}',
    'dayProgress': 'دن: {currentDay}/{totalDays}',
    'readProgress': 'پڑھائی: {currentRead}/{timesPerDay}',
    'errorWithDetails': 'خرابی: {message}',
    'compassError': 'کمپاس سینسر خرابی: {message}',
  },
  'bn': {
    'appTitle': 'দোয়ার সাথে',
    'prayers': 'দোয়া',
    'myJourneys': 'আমার যাত্রা',
    'myPrayerTimes': 'আমার নামাজ',
    'qibla': 'কিবলা',
    'support': 'সহায়তা',
    'home': 'হোম',
    'search': 'খুঁজুন...',
    'increase': 'বড়',
    'decrease': 'ছোট',
    'adminLogin': 'অ্যাডমিন লগইন',
    'adminPanel': 'অ্যাডমিন প্যানেল',
    'password': 'পাসওয়ার্ড',
    'login': 'লগইন',
    'wrongPassword': 'ভুল পাসওয়ার্ড!',
    'cancel': 'বাতিল',
    'save': 'সেভ',
    'ok': 'ঠিক আছে',
    'remindMe': 'আমাকে মনে করান',
    'saidItWas': 'বর্ণিত হয়েছে:',
    'showRecitation': 'পাঠ দেখুন',
    'day': 'দিন',
    'read': 'পড়া',
    'lastRead': 'শেষ পড়া',
    'readDays': 'পড়া দিনের সংখ্যা',
    'todayRead': 'আজকের পড়া',
    'totalRead': 'মোট পড়া',
    'readTodayPrompt': 'আজ কত পড়েছেন?',
    'readToday': 'আজ আমি পড়েছি',
    'wrongEntry': 'ভুল ইনপুট',
    'howMuchRead': 'আপনি কত পড়েছেন?',
    'howManyTimes': 'কতবার পড়েছেন?',
    'howManyDeduct': 'কত কমাবেন?',
    'pleaseEnterValidNumber': 'দয়া করে সঠিক সংখ্যা লিখুন।',
    'todayMaxReads': 'আজ সর্বোচ্চ {remaining} বার পড়তে পারবেন।',
    'readingSaved': 'পড়া সেভ হয়েছে!',
    'dailyGoalCompleted': 'আজ {timesPerDay} বার পড়া সম্পন্ন! দিন {currentDay}',
    'manualJourneyAdd': 'ম্যানুয়াল যাত্রা যোগ করুন',
    'journeyName': 'যাত্রার নাম',
    'prayerContent': 'দোয়ার বিষয়বস্তু',
    'howManyDays': 'কত দিন পড়বেন?',
    'howManyTimesPerDay': 'দিনে কতবার?',
    'manualJourney': 'ম্যানুয়াল যাত্রা',
    'startJourney': 'আমার যাত্রা শুরু করুন',
    'journeyStarted': 'যাত্রা শুরু হয়েছে!',
    'descriptionOptional': 'বর্ণনা (ঐচ্ছিক)',
    'prayerTitle': 'দোয়ার শিরোনাম',
    'arabicTextOptional': 'আরবি লেখা (ঐচ্ছিক)',
    'hasCondition': 'শর্ত আছে',
    'dayCount': 'দিনের সংখ্যা',
    'dailyReadCount': 'দৈনিক পড়ার সংখ্যা',
    'prayerTitleEmpty': 'দোয়ার শিরোনাম খালি হতে পারবে না।',
    'prayerContentEmpty': 'দোয়ার বিষয়বস্তু খালি হতে পারবে না।',
    'prayerAdded': 'দোয়া যোগ হয়েছে!',
    'addPrayer': 'দোয়া যোগ করুন',
    'copyPrayersJson': 'দোয়া JSON কপি করুন',
    'jsonCopied': 'JSON ক্লিপবোর্ডে কপি হয়েছে!',
    'conditional': 'শর্তযুক্ত',
    'normal': 'স্বাভাবিক',
    'ezanTimes': 'নামাজের সময়',
    'timesLoading': 'সময় লোড হচ্ছে...',
    'timesAutoUpdated': 'লোকেশন অনুযায়ী সময় স্বয়ংক্রিয়ভাবে আপডেট হয়',
    'ezanNotification': 'আজান নোটিফিকেশন',
    'voiceOn': 'সাউন্ড নোটিফিকেশন চালু 🔔',
    'voiceOff': 'সাউন্ড নোটিফিকেশন বন্ধ',
    'saveEzanTimes': 'নামাজের সময় সেভ করুন',
    'qazaPrayers': 'কাযা নামাজ',
    'saveQazaPrayers': 'কাযা নামাজ সেভ করুন',
    'qazaSaved': 'কাযা নামাজ সেভ হয়েছে!',
    'timesUpdatedByLocation': 'লোকেশন অনুযায়ী নামাজের সময় আপডেট হয়েছে! 📍',
    'timesFetchFailed': 'সময় আনা যায়নি। লোকেশন পারমিশন দিন।',
    'permissionDenied': 'নোটিফিকেশন অনুমতি দেওয়া হয়নি। সেটিংস থেকে দিন।',
    'noTimes': 'নামাজের সময় খালি। আগে সময় দিন বা লোকেশন থেকে আনুন।',
    'scheduleError': 'নোটিফিকেশন সেট করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।',
    'ezanEnabled': 'আজান নোটিফিকেশন চালু হয়েছে! 🕌',
    'ezanDisabled': 'আজান নোটিফিকেশন বন্ধ হয়েছে',
    'select': 'নির্বাচন',
    'selectPrayerTime': '{label} সময় নির্বাচন করুন',
    'locationUnavailable': 'লোকেশন পাওয়া যায়নি। অনুমতি আছে কি না দেখুন।',
    'refresh': 'রিফ্রেশ',
    'retry': 'আবার চেষ্টা করুন',
    'qiblaDirection': 'কিবলার দিক: {degree}°',
    'approxDirection': 'আনুমানিক দিক: {direction}',
    'location': 'লোকেশন: {latitude}, {longitude}',
    'qiblaNote': 'নোট: তীর ডিভাইসের দিক অনুযায়ী ঘুরে।',
    'north': 'উত্তর',
    'northeast': 'উত্তর-পূর্ব',
    'east': 'পূর্ব',
    'southeast': 'দক্ষিণ-পূর্ব',
    'south': 'দক্ষিণ',
    'southwest': 'দক্ষিণ-পশ্চিম',
    'west': 'পশ্চিম',
    'northwest': 'উত্তর-পশ্চিম',
    'supportError': 'ত্রুটি',
    'thankYou': 'ধন্যবাদ!',
    'supportNowYouAre': 'এখন আপনি {packageName}!',
    'supportThanksBody':
        'আপনার সহযোগিতার জন্য ধন্যবাদ। আল্লাহ আপনাকে উত্তম প্রতিদান দিন।',
    'supportPageTitle': 'Dualarla-কে সহায়তা করুন',
    'supportPageSubtitle':
        'আপনার সহায়তায় আমরা অ্যাপ উন্নত করি এবং নতুন কনটেন্ট যোগ করি।',
    'supportFooter':
        'সব সহায়তা প্যাকেজ এককালীন দান।\nআপনার সহায়তা সরাসরি অ্যাপ উন্নয়নে যায়।',
    'purchaseUnavailable':
        'কেনাকাটা এখন সম্ভব নয়। Google Play থেকে ইনস্টল করলে সক্রিয় হবে।',
    'playPriceLoading': 'Play মূল্য লোড হচ্ছে',
    'supporter': 'সহায়তাকারী',
    'bronzeSupporter': 'ব্রোঞ্জ সহায়তাকারী',
    'silverSupporter': 'সিলভার সহায়তাকারী',
    'goldSupporter': 'গোল্ড সহায়তাকারী',
    'diamondSupporter': 'ডায়মন্ড সহায়তাকারী',
    'bronzeSupporterDesc': 'অ্যাপে ছোট সহায়তা করুন',
    'silverSupporterDesc': 'অ্যাপ উন্নয়নে সহায়তা করুন',
    'goldSupporterDesc': 'বড় সহায়তা দিন',
    'diamondSupporterDesc': 'সবচেয়ে মূল্যবান সহায়তাকারী হোন',
    'updateRequired': 'আপডেট প্রয়োজন',
    'updateAvailable': 'নতুন আপডেট আছে',
    'updateNow': 'আপডেট',
    'later': 'পরে',
    'prayerReminderTitle': 'দোয়া রিমাইন্ডার',
    'prayerReminderBody':
        'আজকের পড়া ভুলবেন না! 📖\n{prayerTitle} - {dailyCount} বার পড়ুন',
    'prayerReminderChannelName': 'দোয়া রিমাইন্ডার',
    'prayerReminderChannelDescription': 'দৈনিক দোয়া রিমাইন্ডার',
    'prayerTimeTitle': '{prayerName} নামাজের সময়',
    'ezanChannelName': 'আজান নোটিফিকেশন',
    'ezanChannelDescription': 'নামাজ সময় নোটিফিকেশন',
    'fajr': 'ফজর',
    'dhuhr': 'যোহর',
    'asr': 'আসর',
    'maghrib': 'মাগরিব',
    'isha': 'এশা',
    'homeJourneySummary':
        'দিন {currentDay}/{totalDays} - পড়া {currentRead}/{timesPerDay}',
    'dayProgress': 'দিন: {currentDay}/{totalDays}',
    'readProgress': 'পড়া: {currentRead}/{timesPerDay}',
    'errorWithDetails': 'ত্রুটি: {message}',
    'compassError': 'কম্পাস সেন্সর ত্রুটি: {message}',
  },
  'fr': {
    'appTitle': 'Avec Prières',
    'prayers': 'Prières',
    'myJourneys': 'Mes Parcours',
    'myPrayerTimes': 'Mes Prières',
    'qibla': 'Qibla',
    'support': 'Soutenir',
    'home': 'Accueil',
    'search': 'Rechercher...',
    'increase': 'Agrandir',
    'decrease': 'Réduire',
    'adminLogin': 'Connexion Admin',
    'adminPanel': 'Panneau Admin',
    'password': 'Mot de passe',
    'login': 'Connexion',
    'wrongPassword': 'Mot de passe incorrect !',
    'cancel': 'Annuler',
    'save': 'Enregistrer',
    'ok': 'OK',
    'remindMe': 'Me rappeler',
    'saidItWas': 'Il est dit :',
    'showRecitation': 'Afficher la récitation',
    'day': 'Jour',
    'read': 'Lecture',
    'lastRead': 'Dernière lecture',
    'readDays': 'Jours lus',
    'todayRead': 'Lecture du jour',
    'totalRead': 'Total des lectures',
    'readTodayPrompt': 'Combien avez-vous lu aujourd\'hui ?',
    'readToday': 'J\'ai lu aujourd\'hui',
    'wrongEntry': 'Entrée incorrecte',
    'howMuchRead': 'Combien avez-vous lu ?',
    'howManyTimes': 'Combien de fois avez-vous lu ?',
    'howManyDeduct': 'Combien déduire ?',
    'pleaseEnterValidNumber': 'Veuillez saisir un nombre valide.',
    'todayMaxReads':
        'Vous pouvez lire au maximum {remaining} fois aujourd\'hui.',
    'readingSaved': 'Lecture enregistrée !',
    'dailyGoalCompleted':
        'Vous avez complété {timesPerDay} lectures aujourd\'hui ! Jour {currentDay}',
    'manualJourneyAdd': 'Ajouter un parcours manuel',
    'journeyName': 'Nom du parcours',
    'prayerContent': 'Contenu de la prière',
    'howManyDays': 'Combien de jours allez-vous lire ?',
    'howManyTimesPerDay': 'Combien de fois par jour ?',
    'manualJourney': 'Parcours manuel',
    'startJourney': 'Commencer mon parcours',
    'journeyStarted': 'Parcours commencé !',
    'descriptionOptional': 'Description (optionnelle)',
    'prayerTitle': 'Titre de la prière',
    'arabicTextOptional': 'Texte arabe (optionnel)',
    'hasCondition': 'A une condition',
    'dayCount': 'Nombre de jours',
    'dailyReadCount': 'Nombre quotidien',
    'prayerTitleEmpty': 'Le titre de la prière ne peut pas être vide.',
    'prayerContentEmpty': 'Le contenu de la prière ne peut pas être vide.',
    'prayerAdded': 'Prière ajoutée !',
    'addPrayer': 'Ajouter une prière',
    'copyPrayersJson': 'Copier les prières en JSON',
    'jsonCopied': 'JSON copié dans le presse-papiers !',
    'conditional': 'Conditionnelle',
    'normal': 'Normale',
    'ezanTimes': 'Horaires de prière',
    'timesLoading': 'Chargement des horaires...',
    'timesAutoUpdated':
        'Les horaires sont mis à jour automatiquement selon votre position',
    'ezanNotification': 'Notification d\'adhan',
    'voiceOn': 'Notification sonore activée 🔔',
    'voiceOff': 'Notification sonore désactivée',
    'saveEzanTimes': 'Enregistrer les horaires',
    'qazaPrayers': 'Prières à rattraper',
    'saveQazaPrayers': 'Enregistrer les rattrapages',
    'qazaSaved': 'Prières à rattraper enregistrées !',
    'timesUpdatedByLocation':
        'Horaires de prière mis à jour selon votre position ! 📍',
    'timesFetchFailed':
        'Impossible de récupérer les horaires. Vérifiez la permission de localisation.',
    'permissionDenied':
        'Permission de notification refusée. Activez-la dans les paramètres.',
    'noTimes':
        'Les horaires sont vides. Saisissez-les ou récupérez-les via la position.',
    'scheduleError':
        'Une erreur est survenue lors de la planification des notifications.',
    'ezanEnabled': 'Notifications d\'adhan activées ! 🕌',
    'ezanDisabled': 'Notifications d\'adhan désactivées',
    'select': 'Choisir',
    'selectPrayerTime': 'Choisir l\'horaire {label}',
    'locationUnavailable': 'Localisation indisponible. Vérifiez la permission.',
    'refresh': 'Actualiser',
    'retry': 'Réessayer',
    'qiblaDirection': 'Direction de la Qibla : {degree}°',
    'approxDirection': 'Direction approximative : {direction}',
    'location': 'Position : {latitude}, {longitude}',
    'qiblaNote': 'Note : la flèche tourne selon l\'orientation de l\'appareil.',
    'north': 'Nord',
    'northeast': 'Nord-est',
    'east': 'Est',
    'southeast': 'Sud-est',
    'south': 'Sud',
    'southwest': 'Sud-ouest',
    'west': 'Ouest',
    'northwest': 'Nord-ouest',
    'supportError': 'Erreur',
    'thankYou': 'Merci !',
    'supportNowYouAre': 'Vous êtes maintenant {packageName} !',
    'supportThanksBody':
        'Merci beaucoup pour votre soutien. Qu\'Allah vous récompense.',
    'supportPageTitle': 'Soutenez Dualarla',
    'supportPageSubtitle':
        'Grâce à votre soutien, nous continuons à améliorer l\'application.',
    'supportFooter':
        'Tous les packs de soutien sont des dons uniques.\nVotre soutien va directement au développement.',
    'purchaseUnavailable':
        'Achat indisponible pour le moment. Actif via Google Play Store.',
    'playPriceLoading': 'Prix Play en chargement',
    'supporter': 'Soutien',
    'bronzeSupporter': 'Soutien Bronze',
    'silverSupporter': 'Soutien Argent',
    'goldSupporter': 'Soutien Or',
    'diamondSupporter': 'Soutien Diamant',
    'bronzeSupporterDesc': 'Apportez une petite contribution',
    'silverSupporterDesc': 'Soutenez le développement',
    'goldSupporterDesc': 'Apportez un grand soutien',
    'diamondSupporterDesc': 'Devenez notre soutien le plus précieux',
    'updateRequired': 'Mise à jour requise',
    'updateAvailable': 'Nouvelle mise à jour disponible',
    'updateNow': 'Mettre à jour',
    'later': 'Plus tard',
    'prayerReminderTitle': 'Rappel de prière',
    'prayerReminderBody':
        'N\'oubliez pas vos répétitions d\'aujourd\'hui ! 📖\n{prayerTitle} - lire {dailyCount} fois',
    'prayerReminderChannelName': 'Rappels de prière',
    'prayerReminderChannelDescription': 'Rappels quotidiens de prière',
    'prayerTimeTitle': 'Heure de prière {prayerName}',
    'ezanChannelName': 'Notifications d\'adhan',
    'ezanChannelDescription': 'Notifications d\'horaire de prière',
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
    'homeJourneySummary':
        'Jour {currentDay}/{totalDays} - Lecture {currentRead}/{timesPerDay}',
    'dayProgress': 'Jour : {currentDay}/{totalDays}',
    'readProgress': 'Lecture : {currentRead}/{timesPerDay}',
    'errorWithDetails': 'Erreur : {message}',
    'compassError': 'Erreur du capteur boussole : {message}',
  },
  'fa': {
    'appTitle': 'با دعا',
    'prayers': 'دعاها',
    'myJourneys': 'مسیرهای من',
    'myPrayerTimes': 'نمازهای من',
    'qibla': 'قبله',
    'support': 'حمایت',
    'home': 'خانه',
    'search': 'جستجو...',
    'increase': 'بزرگ‌تر',
    'decrease': 'کوچک‌تر',
    'adminLogin': 'ورود ادمین',
    'adminPanel': 'پنل ادمین',
    'password': 'رمز عبور',
    'login': 'ورود',
    'wrongPassword': 'رمز عبور اشتباه است!',
    'cancel': 'لغو',
    'save': 'ذخیره',
    'ok': 'باشه',
    'remindMe': 'یادآوری کن',
    'saidItWas': 'نقل شده است:',
    'showRecitation': 'نمایش قرائت',
    'day': 'روز',
    'read': 'خواندن',
    'lastRead': 'آخرین خواندن',
    'readDays': 'روزهای خوانده‌شده',
    'todayRead': 'خواندن امروز',
    'totalRead': 'مجموع خواندن',
    'readTodayPrompt': 'امروز چقدر خواندی؟',
    'readToday': 'امروز خواندم',
    'wrongEntry': 'ورودی اشتباه',
    'howMuchRead': 'چقدر خواندی؟',
    'howManyTimes': 'چند بار خواندی؟',
    'howManyDeduct': 'چقدر کم شود؟',
    'pleaseEnterValidNumber': 'لطفاً عدد معتبر وارد کنید.',
    'todayMaxReads': 'امروز حداکثر {remaining} بار می‌توانید بخوانید.',
    'readingSaved': 'خواندن ذخیره شد!',
    'dailyGoalCompleted':
        'خواندن {timesPerDay} بار امروز کامل شد! روز {currentDay}',
    'manualJourneyAdd': 'افزودن مسیر دستی',
    'journeyName': 'نام مسیر',
    'prayerContent': 'متن دعا',
    'howManyDays': 'چند روز می‌خوانید؟',
    'howManyTimesPerDay': 'روزانه چند بار؟',
    'manualJourney': 'مسیر دستی',
    'startJourney': 'شروع مسیر من',
    'journeyStarted': 'مسیر شروع شد!',
    'descriptionOptional': 'توضیح (اختیاری)',
    'prayerTitle': 'عنوان دعا',
    'arabicTextOptional': 'متن عربی (اختیاری)',
    'hasCondition': 'دارای شرط',
    'dayCount': 'تعداد روز',
    'dailyReadCount': 'تعداد روزانه خواندن',
    'prayerTitleEmpty': 'عنوان دعا نباید خالی باشد.',
    'prayerContentEmpty': 'متن دعا نباید خالی باشد.',
    'prayerAdded': 'دعا اضافه شد!',
    'addPrayer': 'افزودن دعا',
    'copyPrayersJson': 'کپی دعاها به JSON',
    'jsonCopied': 'JSON در کلیپ‌بورد کپی شد!',
    'conditional': 'شرط‌دار',
    'normal': 'عادی',
    'ezanTimes': 'اوقات نماز',
    'timesLoading': 'در حال دریافت اوقات...',
    'timesAutoUpdated': 'اوقات بر اساس موقعیت شما خودکار به‌روزرسانی می‌شود',
    'ezanNotification': 'اعلان اذان',
    'voiceOn': 'اعلان صوتی روشن است 🔔',
    'voiceOff': 'اعلان صوتی خاموش است',
    'saveEzanTimes': 'ذخیره اوقات نماز',
    'qazaPrayers': 'نمازهای قضا',
    'saveQazaPrayers': 'ذخیره نمازهای قضا',
    'qazaSaved': 'نمازهای قضا ذخیره شد!',
    'timesUpdatedByLocation':
        'اوقات نماز بر اساس موقعیت شما به‌روزرسانی شد! 📍',
    'timesFetchFailed': 'دریافت اوقات ممکن نشد. مجوز مکان را بررسی کنید.',
    'permissionDenied': 'مجوز اعلان داده نشد. از تنظیمات فعال کنید.',
    'noTimes': 'اوقات نماز خالی است. ابتدا وارد کنید یا از مکان بگیرید.',
    'scheduleError': 'در زمان‌بندی اعلان‌ها خطا رخ داد. دوباره تلاش کنید.',
    'ezanEnabled': 'اعلان‌های اذان فعال شد! 🕌',
    'ezanDisabled': 'اعلان‌های اذان غیرفعال شد',
    'select': 'انتخاب',
    'selectPrayerTime': 'انتخاب وقت {label}',
    'locationUnavailable': 'موقعیت دریافت نشد. مجوز مکان را بررسی کنید.',
    'refresh': 'تازه‌سازی',
    'retry': 'تلاش مجدد',
    'qiblaDirection': 'جهت قبله: {degree}°',
    'approxDirection': 'جهت تقریبی: {direction}',
    'location': 'موقعیت: {latitude}, {longitude}',
    'qiblaNote': 'نکته: فلش با جهت دستگاه به‌صورت زنده می‌چرخد.',
    'north': 'شمال',
    'northeast': 'شمال‌شرق',
    'east': 'شرق',
    'southeast': 'جنوب‌شرق',
    'south': 'جنوب',
    'southwest': 'جنوب‌غرب',
    'west': 'غرب',
    'northwest': 'شمال‌غرب',
    'supportError': 'خطا',
    'thankYou': 'متشکریم!',
    'supportNowYouAre': 'اکنون شما {packageName} هستید!',
    'supportThanksBody':
        'از حمایت شما بسیار سپاسگزاریم. خداوند به شما جزای خیر دهد.',
    'supportPageTitle': 'از Dualarla حمایت کنید',
    'supportPageSubtitle':
        'با حمایت شما می‌توانیم اپ را بهتر کنیم و محتوای بیشتری اضافه کنیم.',
    'supportFooter':
        'همه بسته‌های حمایت، کمک یک‌باره هستند.\nحمایت شما مستقیماً صرف توسعه اپ می‌شود.',
    'purchaseUnavailable':
        'خرید فعلاً در دسترس نیست. با نصب از گوگل‌پلی فعال می‌شود.',
    'playPriceLoading': 'در حال بارگذاری قیمت',
    'supporter': 'حامی',
    'bronzeSupporter': 'حامی برنزی',
    'silverSupporter': 'حامی نقره‌ای',
    'goldSupporter': 'حامی طلایی',
    'diamondSupporter': 'حامی الماسی',
    'bronzeSupporterDesc': 'یک حمایت کوچک انجام دهید',
    'silverSupporterDesc': 'از توسعه برنامه حمایت کنید',
    'goldSupporterDesc': 'حمایت بزرگ انجام دهید',
    'diamondSupporterDesc': 'ارزشمندترین حامی ما شوید',
    'updateRequired': 'به‌روزرسانی لازم است',
    'updateAvailable': 'به‌روزرسانی جدید موجود است',
    'updateNow': 'به‌روزرسانی',
    'later': 'بعداً',
    'prayerReminderTitle': 'یادآور دعا',
    'prayerReminderBody':
        'تکرارهای امروز را فراموش نکن! 📖\n{prayerTitle} - {dailyCount} بار بخوان',
    'prayerReminderChannelName': 'یادآورهای دعا',
    'prayerReminderChannelDescription': 'یادآورهای روزانه دعا',
    'prayerTimeTitle': 'وقت نماز {prayerName}',
    'ezanChannelName': 'اعلان‌های اذان',
    'ezanChannelDescription': 'اعلان وقت نماز',
    'fajr': 'صبح',
    'dhuhr': 'ظهر',
    'asr': 'عصر',
    'maghrib': 'مغرب',
    'isha': 'عشاء',
    'homeJourneySummary':
        'روز {currentDay}/{totalDays} - خواندن {currentRead}/{timesPerDay}',
    'dayProgress': 'روز: {currentDay}/{totalDays}',
    'readProgress': 'خواندن: {currentRead}/{timesPerDay}',
    'errorWithDetails': 'خطا: {message}',
    'compassError': 'خطای حسگر قطب‌نما: {message}',
  },
};

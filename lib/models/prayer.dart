class Prayer {
  final String id;
  final String title;
  final String description;
  final String descriptionEng;
  final String descriptionAr;
  final String descriptionId;
  final String descriptionUr;
  final String descriptionBn;
  final String descriptionFr;
  final String descriptionFa;
  final String arabicContent;
  final String content;
  final bool hasCondition;
  final int? days;
  final int? timesPerDay;

  Prayer({
    required this.id,
    required this.title,
    this.description = '',
    this.descriptionEng = '',
    this.descriptionAr = '',
    this.descriptionId = '',
    this.descriptionUr = '',
    this.descriptionBn = '',
    this.descriptionFr = '',
    this.descriptionFa = '',
    this.arabicContent = '',
    required this.content,
    this.hasCondition = false,
    this.days,
    this.timesPerDay,
  });

  String localizedDescription(String languageCode) {
    final code = languageCode.toLowerCase();
    final candidate = switch (code) {
      'en' => descriptionEng,
      'ar' => descriptionAr,
      'id' => descriptionId,
      'ur' => descriptionUr,
      'bn' => descriptionBn,
      'fr' => descriptionFr,
      'fa' => descriptionFa,
      _ => description,
    };
    if (candidate.trim().isNotEmpty) {
      return candidate;
    }
    return description;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'descriptionEng': descriptionEng,
        'descriptionAr': descriptionAr,
        'descriptionId': descriptionId,
        'descriptionUr': descriptionUr,
        'descriptionBn': descriptionBn,
        'descriptionFr': descriptionFr,
        'descriptionFa': descriptionFa,
        'arabicContent': arabicContent,
        'content': content,
        'hasCondition': hasCondition,
        'days': days,
        'timesPerDay': timesPerDay,
      };

  factory Prayer.fromJson(Map<String, dynamic> json) => Prayer(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        descriptionEng: json['descriptionEng'] ??
            json['description_eng'] ??
            json['description_ing'] ??
            '',
        descriptionAr: json['descriptionAr'] ?? json['description_ar'] ?? '',
        descriptionId: json['descriptionId'] ?? json['description_id'] ?? '',
        descriptionUr: json['descriptionUr'] ?? json['description_ur'] ?? '',
        descriptionBn: json['descriptionBn'] ?? json['description_bn'] ?? '',
        descriptionFr: json['descriptionFr'] ?? json['description_fr'] ?? '',
        descriptionFa: json['descriptionFa'] ?? json['description_fa'] ?? '',
        arabicContent: json['arabicContent'] ?? '',
        content: json['content'] ?? '',
        hasCondition: json['hasCondition'] ?? false,
        days: json['days'],
        timesPerDay: json['timesPerDay'],
      );
}

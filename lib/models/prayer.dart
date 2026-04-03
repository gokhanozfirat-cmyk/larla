class Prayer {
  final String id;
  final String title;
  final String description;
  final String arabicContent;
  final String content;
  final bool hasCondition;
  final int? days;
  final int? timesPerDay;

  Prayer({
    required this.id,
    required this.title,
    this.description = '',
    this.arabicContent = '',
    required this.content,
    this.hasCondition = false,
    this.days,
    this.timesPerDay,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
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
        arabicContent: json['arabicContent'] ?? '',
        content: json['content'] ?? '',
        hasCondition: json['hasCondition'] ?? false,
        days: json['days'],
        timesPerDay: json['timesPerDay'],
      );
}
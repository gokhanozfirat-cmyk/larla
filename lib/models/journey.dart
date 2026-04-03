class Journey {
  final String id;
  final String prayerId;
  final String prayerTitle;
  final String? content;
  final int? totalDays;
  final int? timesPerDay;
  int currentDay;
  int currentReadCount;
  int totalReads;
  DateTime lastReadDate;
  DateTime lastCompletionDate; // Track when daily reading was last completed
  bool isCompleted;
  bool reminderEnabled;

  Journey({
    required this.id,
    required this.prayerId,
    required this.prayerTitle,
    this.content,
    this.totalDays,
    this.timesPerDay,
    this.currentDay = 0,
    this.currentReadCount = 0,
    this.totalReads = 0,
    DateTime? lastReadDate,
    DateTime? lastCompletionDate,
    this.isCompleted = false,
    this.reminderEnabled = false,
  }) : lastReadDate = lastReadDate ?? DateTime(2000),
       lastCompletionDate = lastCompletionDate ?? DateTime(2000);

  void incrementRead() {
    final now = DateTime.now();
    final prev = lastReadDate;
    currentReadCount++;
    totalReads++;

    if (timesPerDay == null) {
      // Unconditional prayers: any read on a new calendar day counts as a new "okunan gün"
      final isFirstReadToday = prev.day != now.day || prev.month != now.month || prev.year != now.year;
      if (isFirstReadToday) {
        currentDay++;
        lastCompletionDate = now;
      }
    } else {
      // Conditional prayers: only increment day when daily target is reached
      if (currentReadCount >= timesPerDay!) {
        currentDay++;
        currentReadCount = 0;
        lastCompletionDate = now;
        if (totalDays != null && currentDay >= totalDays!) {
          isCompleted = true;
        }
      }
    }

    lastReadDate = now;
  }

  bool canReadToday() {
    final today = DateTime.now();
    if (timesPerDay == null) {
      // For prayers without specific times per day, always allow reading
      return true;
    }
    // Check if already completed today's reading
    final completedToday = lastCompletionDate.day == today.day &&
                          lastCompletionDate.month == today.month &&
                          lastCompletionDate.year == today.year;
    if (completedToday) {
      return false;
    }
    // Check if it's a new day
    final isNewDay = lastReadDate.day != today.day ||
                    lastReadDate.month != today.month ||
                    lastReadDate.year != today.year;
    return isNewDay || currentReadCount < timesPerDay!;
  }

  bool hasCompletedTodaysReading() {
    final today = DateTime.now();
    return lastCompletionDate.day == today.day &&
           lastCompletionDate.month == today.month &&
           lastCompletionDate.year == today.year;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prayerId': prayerId,
        'prayerTitle': prayerTitle,
        'content': content,
        'totalDays': totalDays,
        'timesPerDay': timesPerDay,
        'currentDay': currentDay,
        'currentReadCount': currentReadCount,
        'totalReads': totalReads,
        'lastReadDate': lastReadDate.toIso8601String(),
        'lastCompletionDate': lastCompletionDate.toIso8601String(),
        'isCompleted': isCompleted,
        'reminderEnabled': reminderEnabled,
      };

  factory Journey.fromJson(Map<String, dynamic> json) => Journey(
        id: json['id'],
        prayerId: json['prayerId'],
        prayerTitle: json['prayerTitle'],
        content: json['content'],
        totalDays: json['totalDays'],
        timesPerDay: json['timesPerDay'],
        currentDay: json['currentDay'] ?? 0,
        currentReadCount: json['currentReadCount'] ?? 0,
        totalReads: json['totalReads'] ?? 0,
        lastReadDate: json['lastReadDate'] != null ? DateTime.parse(json['lastReadDate']) : DateTime(2000),
        lastCompletionDate: json['lastCompletionDate'] != null 
            ? DateTime.parse(json['lastCompletionDate']) 
            : DateTime(2000),
        isCompleted: json['isCompleted'] ?? false,
        reminderEnabled: json['reminderEnabled'] ?? false,
      );
}
const _timelineTaskUnchanged = Object();

class TimelineTask {
  const TimelineTask({
    required this.id,
    required this.title,
    required this.description,
    required this.taskDate,
    required this.startAt,
    required this.endAt,
    required this.importance,
    required this.colorArgb,
    required this.isCompleted,
    required this.isStarred,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime taskDate;
  final DateTime? startAt;
  final DateTime? endAt;
  final TimelineImportance importance;
  final int colorArgb;
  final bool isCompleted;
  final bool isStarred;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimelineTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? taskDate,
    Object? startAt = _timelineTaskUnchanged,
    Object? endAt = _timelineTaskUnchanged,
    TimelineImportance? importance,
    int? colorArgb,
    bool? isCompleted,
    bool? isStarred,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimelineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskDate: taskDate ?? this.taskDate,
      startAt: identical(startAt, _timelineTaskUnchanged)
          ? this.startAt
          : startAt as DateTime?,
      endAt: identical(endAt, _timelineTaskUnchanged)
          ? this.endAt
          : endAt as DateTime?,
      importance: importance ?? this.importance,
      colorArgb: colorArgb ?? this.colorArgb,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarred: isStarred ?? this.isStarred,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TimelineTaskDraft {
  TimelineTaskDraft({
    required this.title,
    required this.taskDate,
    this.description = '',
    this.startAt,
    this.endAt,
    this.importance = TimelineImportance.medium,
    int? colorArgb,
    this.isCompleted = false,
    this.isStarred = false,
  }) : colorArgb =
           colorArgb ?? TimelineTaskDefaults.colorForImportance(importance);

  final String title;
  final String description;
  final DateTime taskDate;
  final DateTime? startAt;
  final DateTime? endAt;
  final TimelineImportance importance;
  final int colorArgb;
  final bool isCompleted;
  final bool isStarred;
}

enum TimelineImportance {
  low,
  medium,
  high;

  static TimelineImportance fromStorageValue(String value) {
    return TimelineImportance.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TimelineImportance.medium,
    );
  }
}

class TimelineTaskDefaults {
  const TimelineTaskDefaults._();

  static const lowColorArgb = 0xFF57B884;
  static const mediumColorArgb = 0xFF5B8DEF;
  static const highColorArgb = 0xFFE86F61;

  static int colorForImportance(TimelineImportance importance) {
    return switch (importance) {
      TimelineImportance.low => lowColorArgb,
      TimelineImportance.medium => mediumColorArgb,
      TimelineImportance.high => highColorArgb,
    };
  }
}

class TimelineTaskSort {
  const TimelineTaskSort._();

  static List<TimelineTask> sortedForTimeline(Iterable<TimelineTask> tasks) {
    final sorted = tasks.toList();
    sorted.sort((a, b) {
      final dateCompare = _dateOnly(
        a.taskDate,
      ).compareTo(_dateOnly(b.taskDate));
      if (dateCompare != 0) {
        return dateCompare;
      }

      final startCompare = _compareStartAt(a.startAt, b.startAt);
      if (startCompare != 0) {
        return startCompare;
      }

      if (a.isStarred != b.isStarred) {
        return b.isStarred ? 1 : -1;
      }

      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static int _compareStartAt(DateTime? a, DateTime? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return a.compareTo(b);
  }
}

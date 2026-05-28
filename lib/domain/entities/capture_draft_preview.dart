import 'timeline_task.dart';

enum CaptureDraftType { note, task }

class CaptureClockTime {
  const CaptureClockTime({required this.hour, required this.minute});

  final int hour;
  final int minute;

  DateTime onDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  bool operator ==(Object other) {
    return other is CaptureClockTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}

class CaptureDraftPreview {
  const CaptureDraftPreview._({
    required this.type,
    required this.title,
    required this.content,
    this.folderName,
    this.taskDate,
    this.startTime,
    this.endTime,
    this.importance,
  });

  factory CaptureDraftPreview.note({
    required String title,
    required String content,
    String? folderName,
  }) {
    return CaptureDraftPreview._(
      type: CaptureDraftType.note,
      title: title,
      content: content,
      folderName: _blankToNull(folderName),
    );
  }

  factory CaptureDraftPreview.task({
    required String title,
    required String content,
    required DateTime taskDate,
    CaptureClockTime? startTime,
    CaptureClockTime? endTime,
    TimelineImportance importance = TimelineImportance.medium,
  }) {
    return CaptureDraftPreview._(
      type: CaptureDraftType.task,
      title: title,
      content: content,
      taskDate: DateTime(taskDate.year, taskDate.month, taskDate.day),
      startTime: startTime,
      endTime: endTime,
      importance: importance,
    );
  }

  final CaptureDraftType type;
  final String title;
  final String content;
  final String? folderName;
  final DateTime? taskDate;
  final CaptureClockTime? startTime;
  final CaptureClockTime? endTime;
  final TimelineImportance? importance;
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

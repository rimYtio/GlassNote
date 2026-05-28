import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/entities/timeline_task.dart';

class CaptureDraftPreviewParser {
  const CaptureDraftPreviewParser._();

  static List<CaptureDraftPreview> parseList(List<Map<String, Object?>> items) {
    return items.map(parse).toList();
  }

  static CaptureDraftPreview parse(Map<String, Object?> json) {
    final title = _string(json['title']) ?? '语音捕获';
    final content = _string(json['content']) ?? '';
    final folderName = _string(json['folderName']);
    final type = _string(json['type']);
    final task = json['task'];
    final taskJson = task is Map ? task.cast<String, Object?>() : null;
    final taskDate = _date(_string(taskJson?['date']));

    if (type == 'task' && taskDate != null) {
      return CaptureDraftPreview.task(
        title: title,
        content: content,
        taskDate: taskDate,
        startTime: _clockTime(_string(taskJson?['startTime'])),
        endTime: _clockTime(_string(taskJson?['endTime'])),
        importance: _importance(_string(taskJson?['importance'])),
      );
    }

    return CaptureDraftPreview.note(
      title: title,
      content: content,
      folderName: folderName,
    );
  }

  static String? _string(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _date(String? value) {
    if (value == null) {
      return null;
    }
    final match = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(value);
    if (match == null) {
      return null;
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  static CaptureClockTime? _clockTime(String? value) {
    if (value == null) {
      return null;
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value);
    if (match == null) {
      return null;
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return CaptureClockTime(hour: hour, minute: minute);
  }

  static TimelineImportance _importance(String? value) {
    return TimelineImportance.values.firstWhere(
      (importance) => importance.name == value,
      orElse: () => TimelineImportance.medium,
    );
  }
}

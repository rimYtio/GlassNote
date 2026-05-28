import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/capture/capture_draft_preview_parser.dart';
import 'package:glass_note/domain/entities/capture_draft_preview.dart';
import 'package:glass_note/domain/entities/timeline_task.dart';

void main() {
  test('parses note preview from DeepSeek JSON', () {
    final preview = CaptureDraftPreviewParser.parse({
      'type': 'note',
      'title': '会议纪要',
      'content': '今天讨论项目计划。',
      'folderName': '工作',
      'task': null,
    });

    expect(preview.type, CaptureDraftType.note);
    expect(preview.title, '会议纪要');
    expect(preview.content, '今天讨论项目计划。');
    expect(preview.folderName, '工作');
    expect(preview.taskDate, isNull);
  });

  test('parses task preview and falls back invalid importance to medium', () {
    final preview = CaptureDraftPreviewParser.parse({
      'type': 'task',
      'title': '提交报告',
      'content': '整理周报并提交。',
      'folderName': null,
      'task': {
        'date': '2026-06-03',
        'startTime': '09:30',
        'endTime': null,
        'importance': 'urgent',
      },
    });

    expect(preview.type, CaptureDraftType.task);
    expect(preview.taskDate, DateTime(2026, 6, 3));
    expect(preview.startTime, const CaptureClockTime(hour: 9, minute: 30));
    expect(preview.endTime, isNull);
    expect(preview.importance, TimelineImportance.medium);
  });

  test('downgrades task without clear date to note', () {
    final preview = CaptureDraftPreviewParser.parse({
      'type': 'task',
      'title': '提醒事项',
      'content': '找时间整理资料。',
      'task': {'importance': 'high'},
    });

    expect(preview.type, CaptureDraftType.note);
    expect(preview.taskDate, isNull);
    expect(preview.importance, isNull);
  });
}

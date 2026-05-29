class Reminder {
  const Reminder({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.triggerTime,
    required this.notificationId,
    required this.enabled,
    required this.createdAt,
  });

  final String id;
  final String targetType; // 'note' or 'schedule'
  final String targetId;
  final DateTime triggerTime;
  final int notificationId;
  final bool enabled;
  final DateTime createdAt;

  Reminder copyWith({
    String? id,
    String? targetType,
    String? targetId,
    DateTime? triggerTime,
    int? notificationId,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      triggerTime: triggerTime ?? this.triggerTime,
      notificationId: notificationId ?? this.notificationId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

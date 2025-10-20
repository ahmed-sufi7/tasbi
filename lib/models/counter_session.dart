class CounterSession {
  final String? id;
  final String duroodId;
  final int count;
  final int target;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final String? notes;

  CounterSession({
    this.id,
    required this.duroodId,
    required this.count,
    required this.target,
    DateTime? startTime,
    this.endTime,
    this.isCompleted = false,
    this.notes,
  }) : startTime = startTime ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duroodId': duroodId,
      'count': count,
      'target': target,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'notes': notes,
    };
  }

  // Create from Map
  factory CounterSession.fromMap(Map<String, dynamic> map) {
    return CounterSession(
      id: map['id'] as String?,
      duroodId: map['duroodId'] as String,
      count: map['count'] as int,
      target: map['target'] as int,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null 
          ? DateTime.parse(map['endTime'] as String) 
          : null,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
    );
  }

  // Copy with method
  CounterSession copyWith({
    String? id,
    String? duroodId,
    int? count,
    int? target,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    String? notes,
  }) {
    return CounterSession(
      id: id ?? this.id,
      duroodId: duroodId ?? this.duroodId,
      count: count ?? this.count,
      target: target ?? this.target,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  // Calculate duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  // Calculate progress percentage
  double get progress {
    if (target == 0) return 0;
    return (count / target).clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'CounterSession(id: $id, duroodId: $duroodId, count: $count, target: $target, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

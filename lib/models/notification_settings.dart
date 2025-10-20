class NotificationSettings {
  final bool isEnabled;
  final List<NotificationTime> times;
  final bool vibrate;
  final String sound;

  NotificationSettings({
    this.isEnabled = true,
    List<NotificationTime>? times,
    this.vibrate = true,
    this.sound = 'default',
  }) : times = times ?? [];

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'times': times.map((t) => t.toMap()).toList(),
      'vibrate': vibrate,
      'sound': sound,
    };
  }

  // Create from Map
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      isEnabled: map['isEnabled'] as bool? ?? true,
      times: (map['times'] as List<dynamic>?)
          ?.map((t) => NotificationTime.fromMap(t as Map<String, dynamic>))
          .toList(),
      vibrate: map['vibrate'] as bool? ?? true,
      sound: map['sound'] as String? ?? 'default',
    );
  }

  NotificationSettings copyWith({
    bool? isEnabled,
    List<NotificationTime>? times,
    bool? vibrate,
    String? sound,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      times: times ?? this.times,
      vibrate: vibrate ?? this.vibrate,
      sound: sound ?? this.sound,
    );
  }
}

class NotificationTime {
  final int hour;
  final int minute;
  final bool isEnabled;
  final String? message;

  NotificationTime({
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.message,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
      'message': message,
    };
  }

  // Create from Map
  factory NotificationTime.fromMap(Map<String, dynamic> map) {
    return NotificationTime(
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isEnabled: map['isEnabled'] as bool? ?? true,
      message: map['message'] as String?,
    );
  }

  // Get formatted time string
  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  NotificationTime copyWith({
    int? hour,
    int? minute,
    bool? isEnabled,
    String? message,
  }) {
    return NotificationTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

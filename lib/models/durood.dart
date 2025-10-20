class Durood {
  final String? id;
  final String name;
  final String arabic;
  final String? transliteration;
  final String? translation;
  final int target;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Durood({
    this.id,
    required this.name,
    required this.arabic,
    this.transliteration,
    this.translation,
    this.target = 100,
    this.isDefault = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
      'target': target,
      'isDefault': isDefault ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Map
  factory Durood.fromMap(Map<String, dynamic> map) {
    return Durood(
      id: map['id'] as String?,
      name: map['name'] as String,
      arabic: map['arabic'] as String,
      transliteration: map['transliteration'] as String?,
      translation: map['translation'] as String?,
      target: map['target'] as int? ?? 100,
      isDefault: (map['isDefault'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
    );
  }

  // Copy with method
  Durood copyWith({
    String? id,
    String? name,
    String? arabic,
    String? transliteration,
    String? translation,
    int? target,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Durood(
      id: id ?? this.id,
      name: name ?? this.name,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      target: target ?? this.target,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Durood(id: $id, name: $name, target: $target, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Durood && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

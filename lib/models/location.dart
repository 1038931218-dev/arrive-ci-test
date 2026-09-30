class Location {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final int repeatMinutes;
  final bool enabled;
  final int? createdAt;
  final int? updatedAt;
  final String? note;

  const Location({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 50.0,
    this.repeatMinutes = 0,
    this.enabled = true,
    this.createdAt,
    this.updatedAt,
    this.note,
  });

  Location copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    int? repeatMinutes,
    bool? enabled,
    int? createdAt,
    int? updatedAt,
    String? note,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      repeatMinutes: repeatMinutes ?? this.repeatMinutes,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'repeat_minutes': repeatMinutes,
      'enabled': enabled ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'note': note,
    };
  }

  factory Location.fromMap(Map<String, dynamic> m) {
    return Location(
      id: m['id'] as int?,
      name: m['name'] as String,
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      radius: (m['radius'] as num?)?.toDouble() ?? 50.0,
      repeatMinutes: (m['repeat_minutes'] as int?) ?? 0,
      enabled: ((m['enabled'] as int?) ?? 1) == 1,
      createdAt: m['created_at'] as int?,
      updatedAt: m['updated_at'] as int?,
      note: m['note'] as String?,
    );
  }
}

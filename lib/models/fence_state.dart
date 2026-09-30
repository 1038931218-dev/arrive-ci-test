class FenceState {
  final int? id;
  final int locationId;
  final int? enteredAt;
  final int? lastRemindAt;
  final bool isInside;
  final int? currentBroadcast;
  final int? updatedAt;

  const FenceState({
    this.id,
    required this.locationId,
    this.enteredAt,
    this.lastRemindAt,
    this.isInside = false,
    this.currentBroadcast,
    this.updatedAt,
  });

  FenceState copyWith({
    int? id,
    int? locationId,
    int? enteredAt,
    int? lastRemindAt,
    bool? isInside,
    int? currentBroadcast,
    int? updatedAt,
  }) {
    return FenceState(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      enteredAt: enteredAt ?? this.enteredAt,
      lastRemindAt: lastRemindAt ?? this.lastRemindAt,
      isInside: isInside ?? this.isInside,
      currentBroadcast: currentBroadcast ?? this.currentBroadcast,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
      'entered_at': enteredAt,
      'last_remind_at': lastRemindAt,
      'is_inside': isInside ? 1 : 0,
      'current_broadcast': currentBroadcast,
      'updated_at': updatedAt,
    };
  }

  factory FenceState.fromMap(Map<String, dynamic> m) {
    return FenceState(
      id: m['id'] as int?,
      locationId: m['location_id'] as int,
      enteredAt: m['entered_at'] as int?,
      lastRemindAt: m['last_remind_at'] as int?,
      isInside: ((m['is_inside'] as int?) ?? 0) == 1,
      currentBroadcast: m['current_broadcast'] as int?,
      updatedAt: m['updated_at'] as int?,
    );
  }
}

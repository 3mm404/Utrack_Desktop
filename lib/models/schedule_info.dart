/// Read-only information supplied by Laravel through the engine.
class ScheduleInfo {
  const ScheduleInfo({
    required this.id,
    required this.name,
    required this.timezone,
    required this.stopOutsideSlots,
    required this.slots,
  });
  final String id, name, timezone;
  final bool stopOutsideSlots;
  final List<ScheduleSlotInfo> slots;

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) => ScheduleInfo(
    id: json['schedule_id'] as String,
    name: json['name'] as String,
    timezone: json['timezone'] as String,
    stopOutsideSlots: json['stop_outside_slots'] as bool? ?? false,
    slots: List.unmodifiable(
      (json['slots'] as List? ?? []).map(
        (slot) =>
            ScheduleSlotInfo.fromJson(Map<String, dynamic>.from(slot as Map)),
      ),
    ),
  );
}

class ScheduleSlotInfo {
  const ScheduleSlotInfo({
    required this.id,
    required this.days,
    required this.startsAt,
    required this.endsAt,
    required this.crossesMidnight,
    required this.playlistName,
    this.volume,
  });
  final String id, startsAt, endsAt, playlistName;
  final List<int> days;
  final bool crossesMidnight;
  final int? volume;

  factory ScheduleSlotInfo.fromJson(Map<String, dynamic> json) =>
      ScheduleSlotInfo(
        id: json['slot_id'] as String,
        days: List.unmodifiable((json['days'] as List).cast<int>()),
        startsAt: json['starts_at'] as String,
        endsAt: json['ends_at'] as String,
        crossesMidnight: json['crosses_midnight'] as bool? ?? false,
        playlistName: json['playlist_name'] as String? ?? '',
        volume: (json['volume'] as num?)?.toInt(),
      );

  String get dayLabel {
    const names = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mié',
      4: 'Jue',
      5: 'Vie',
      6: 'Sáb',
      7: 'Dom',
    };
    return days.map((day) => names[day] ?? '—').join(' · ');
  }
}

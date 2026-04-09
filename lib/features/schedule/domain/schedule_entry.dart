import 'package:flutter/material.dart';

enum ClassType { lecture, tutorial, lab, other }

class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.title,
    required this.dayOfWeek,
    required this.startMinute,
    required this.endMinute,
    required this.colorValue,
    this.location,
    this.type = ClassType.lecture,
  });

  final int id;
  final String title;
  final int dayOfWeek; // 0 = Sunday … 6 = Saturday
  final int startMinute; // minutes from midnight
  final int endMinute;
  final int colorValue;
  final String? location;
  final ClassType type;

  TimeOfDay get startTime =>
      TimeOfDay(hour: startMinute ~/ 60, minute: startMinute % 60);
  TimeOfDay get endTime =>
      TimeOfDay(hour: endMinute ~/ 60, minute: endMinute % 60);

  String get formattedStart => _fmt(startTime);
  String get formattedEnd => _fmt(endTime);

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  ScheduleEntry copyWith({
    int? id,
    String? title,
    int? dayOfWeek,
    int? startMinute,
    int? endMinute,
    int? colorValue,
    String? location,
    ClassType? type,
  }) {
    return ScheduleEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      colorValue: colorValue ?? this.colorValue,
      location: location ?? this.location,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dayOfWeek': dayOfWeek,
    'startMinute': startMinute,
    'endMinute': endMinute,
    'colorValue': colorValue,
    'location': location,
    'type': type.name,
  };

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] as int,
      title: json['title'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startMinute: json['startMinute'] as int,
      endMinute: json['endMinute'] as int,
      colorValue: json['colorValue'] as int,
      location: json['location'] as String?,
      type: ClassType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ClassType.lecture,
      ),
    );
  }
}

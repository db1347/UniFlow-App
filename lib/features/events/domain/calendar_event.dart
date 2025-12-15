import 'package:equatable/equatable.dart';

enum EventRepeat { none, daily, weekly, monthly, yearly }

class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.duration = 60,
    this.repeat = EventRepeat.none,
    this.colorHex = '#ff7acb',
  });

  final int id;
  final String title;
  final DateTime date;
  final String? time; // HH:mm
  final int duration;
  final EventRepeat repeat;
  final String colorHex;

  CalendarEvent copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? time,
    int? duration,
    EventRepeat? repeat,
    String? colorHex,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      repeat: repeat ?? this.repeat,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'time': time,
        'duration': duration,
        'repeat': repeat.name,
        'colorHex': colorHex,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      duration: json['duration'] as int? ?? 60,
      repeat: EventRepeat.values.firstWhere(
        (element) => element.name == json['repeat'],
        orElse: () => EventRepeat.none,
      ),
      colorHex: json['colorHex'] as String? ?? '#ff7acb',
    );
  }

  @override
  List<Object?> get props => [id, title, date, time, duration, repeat, colorHex];
}

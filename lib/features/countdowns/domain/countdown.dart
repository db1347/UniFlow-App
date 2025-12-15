import 'package:equatable/equatable.dart';

enum CountdownVariant { red, blue, gold }

class Countdown extends Equatable {
  const Countdown({
    required this.id,
    required this.title,
    required this.date,
    required this.startDate,
    required this.emoji,
    this.variant = CountdownVariant.gold,
    this.linkedTaskId,
  });

  final int id;
  final String title;
  final DateTime date;
  final DateTime startDate;
  final String emoji;
  final CountdownVariant variant;
  final int? linkedTaskId;

  Countdown copyWith({
    int? id,
    String? title,
    DateTime? date,
    DateTime? startDate,
    String? emoji,
    CountdownVariant? variant,
    int? linkedTaskId,
  }) {
    return Countdown(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      emoji: emoji ?? this.emoji,
      variant: variant ?? this.variant,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'emoji': emoji,
        'variant': variant.name,
        'linkedTaskId': linkedTaskId,
      };

  factory Countdown.fromJson(Map<String, dynamic> json) {
    return Countdown(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      emoji: json['emoji'] as String? ?? '',
      variant: CountdownVariant.values.firstWhere(
        (element) => element.name == json['variant'],
        orElse: () => CountdownVariant.gold,
      ),
      linkedTaskId: json['linkedTaskId'] as int?,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, date, startDate, emoji, variant, linkedTaskId];
}

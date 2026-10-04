import 'enums.dart';

class Delivery {
  const Delivery({
    required this.id,
    required this.title,
    required this.discipline,
    required this.dueDate,
    required this.priority,
    this.status = DeliveryStatus.pendente,
    this.notes,
  });

  final String id;
  final String title;
  final String discipline;
  final DateTime dueDate;
  final TaskPriority priority;
  final DeliveryStatus status;
  final String? notes;

  bool isOverdue(DateTime today) {
    final day = DateTime(today.year, today.month, today.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return status == DeliveryStatus.pendente && due.isBefore(day);
  }

  Delivery copyWith({
    String? title,
    String? discipline,
    DateTime? dueDate,
    TaskPriority? priority,
    DeliveryStatus? status,
    String? notes,
  }) {
    return Delivery(
      id: id,
      title: title ?? this.title,
      discipline: discipline ?? this.discipline,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'discipline': discipline,
      'due_date': dueDate.toIso8601String().split('T').first,
      'priority': priority.name,
      'status': status.name,
      'notes': notes,
    };
  }

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      title: json['title'] as String,
      discipline: json['discipline'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      priority: TaskPriority.fromStorage(json['priority'] as String),
      status: DeliveryStatus.fromStorage(json['status'] as String? ?? 'pendente'),
      notes: json['notes'] as String?,
    );
  }
}

class Student {
  const Student({
    required this.name,
    required this.course,
    required this.rm,
    required this.institution,
  });

  final String name;
  final String course;
  final String rm;
  final String institution;

  String get firstName => name.split(' ').first;
}

class WeekLoad {
  const WeekLoad({
    required this.number,
    required this.start,
    required this.end,
    required this.deliveries,
    required this.score,
    required this.fill,
    required this.level,
  });

  final int number;
  final DateTime start;
  final DateTime end;
  final List<Delivery> deliveries;
  final int score;
  final double fill;
  final LoadLevel level;

  List<Delivery> get pending =>
      deliveries.where((item) => item.status == DeliveryStatus.pendente).toList();

  int get altaCount =>
      pending.where((item) => item.priority == TaskPriority.alta).length;
}

class LoadAlert {
  const LoadAlert({
    required this.week,
    required this.title,
    required this.message,
  });

  final WeekLoad week;
  final String title;
  final String message;
}

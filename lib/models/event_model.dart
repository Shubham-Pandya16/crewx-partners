import 'package:cloud_firestore/cloud_firestore.dart';

class EventRole {
  final String role;
  final int count;
  final int filled;

  EventRole({
    required this.role,
    required this.count,
    this.filled = 0,
  });

  factory EventRole.fromMap(Map<String, dynamic> map) {
    return EventRole(
      role: map['role'] ?? '',
      count: map['count'] ?? 0,
      filled: map['filled'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'count': count,
      'filled': filled,
    };
  }
}

class EventModel {
  final String eventId;
  final String organiserId;
  final String title;
  final Timestamp date;
  final Timestamp? endDate;
  final String city;
  final String venue;
  final String? description;
  final String? payInfo;
  final List<EventRole> roles;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  EventModel({
    required this.eventId,
    required this.organiserId,
    required this.title,
    required this.date,
    this.endDate,
    required this.city,
    required this.venue,
    this.description,
    this.payInfo,
    required this.roles,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EventModel(
      eventId: doc.id,
      organiserId: d['organiserId'] ?? '',
      title: d['title'] ?? '',
      date: d['date'] as Timestamp,
      endDate: d['endDate'] as Timestamp?,
      city: d['city'] ?? '',
      venue: d['venue'] ?? '',
      description: d['description'],
      payInfo: d['payInfo'],
      roles: (d['roles'] as List? ?? [])
          .map((r) => EventRole.fromMap(r as Map<String, dynamic>))
          .toList(),
      status: d['status'] ?? 'open',
      createdAt: d['createdAt'] as Timestamp,
      updatedAt: d['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organiserId': organiserId,
      'title': title,
      'date': date,
      'endDate': endDate,
      'city': city,
      'venue': venue,
      'description': description,
      'payInfo': payInfo,
      'roles': roles.map((r) => r.toMap()).toList(),
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

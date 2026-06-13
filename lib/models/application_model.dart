import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String applicationId;
  final String eventId;
  final String volunteerId;
  final String organiserId;
  final String role;
  final String? note;
  final String status;
  final String? rejectionReason;
  final Timestamp appliedAt;
  final Timestamp? respondedAt;

  ApplicationModel({
    required this.applicationId,
    required this.eventId,
    required this.volunteerId,
    required this.organiserId,
    required this.role,
    this.note,
    this.status = 'pending',
    this.rejectionReason,
    required this.appliedAt,
    this.respondedAt,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      applicationId: doc.id,
      eventId: d['eventId'] ?? '',
      volunteerId: d['volunteerId'] ?? '',
      organiserId: d['organiserId'] ?? '',
      role: d['role'] ?? '',
      note: d['note'],
      status: d['status'] ?? 'pending',
      rejectionReason: d['rejectionReason'],
      appliedAt: d['appliedAt'] as Timestamp,
      respondedAt: d['respondedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'volunteerId': volunteerId,
      'organiserId': organiserId,
      'role': role,
      'note': note,
      'status': status,
      'rejectionReason': rejectionReason,
      'appliedAt': appliedAt,
      'respondedAt': respondedAt,
    };
  }
}

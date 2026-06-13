import 'package:cloud_firestore/cloud_firestore.dart';

class OrganiserModel {
  final String uid;
  final String phone;
  final bool onboardingComplete;
  final String organisationType;
  final String? contactName;
  final String? companyName;
  final String? city;
  final String? logoUrl;
  final String? gstNumber;
  final String? panNumber;
  final String kycStatus;
  final Timestamp? kycSubmittedAt;
  final Timestamp? kycReviewedAt;
  final String? kycRejectionReason;
  final bool verified;
  final int totalEventsPosted;
  final int totalVolunteersHired;
  final String? fcmToken;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  OrganiserModel({
    required this.uid,
    required this.phone,
    this.onboardingComplete = false,
    this.organisationType = 'supplier',
    this.contactName,
    this.companyName,
    this.city,
    this.logoUrl,
    this.gstNumber,
    this.panNumber,
    this.kycStatus = 'not_submitted',
    this.kycSubmittedAt,
    this.kycReviewedAt,
    this.kycRejectionReason,
    this.verified = false,
    this.totalEventsPosted = 0,
    this.totalVolunteersHired = 0,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  factory OrganiserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrganiserModel(
      uid: doc.id,
      phone: d['phone'] ?? '',
      onboardingComplete: d['onboardingComplete'] ?? false,
      organisationType: d['organisationType'] ?? 'supplier',
      contactName: d['contactName'],
      companyName: d['companyName'],
      city: d['city'],
      logoUrl: d['logoUrl'],
      gstNumber: d['gstNumber'],
      panNumber: d['panNumber'],
      kycStatus: d['kycStatus'] ?? 'not_submitted',
      kycSubmittedAt: d['kycSubmittedAt'],
      kycReviewedAt: d['kycReviewedAt'],
      kycRejectionReason: d['kycRejectionReason'],
      verified: d['verified'] ?? false,
      totalEventsPosted: d['totalEventsPosted'] ?? 0,
      totalVolunteersHired: d['totalVolunteersHired'] ?? 0,
      fcmToken: d['fcmToken'],
      createdAt: d['createdAt'],
      updatedAt: d['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'onboardingComplete': onboardingComplete,
      'organisationType': organisationType,
      'contactName': contactName,
      'companyName': companyName,
      'city': city,
      'logoUrl': logoUrl,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'kycStatus': kycStatus,
      'kycSubmittedAt': kycSubmittedAt,
      'kycReviewedAt': kycReviewedAt,
      'kycRejectionReason': kycRejectionReason,
      'verified': verified,
      'totalEventsPosted': totalEventsPosted,
      'totalVolunteersHired': totalVolunteersHired,
      'fcmToken': fcmToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  OrganiserModel copyWith({
    bool? onboardingComplete,
    String? contactName,
    String? companyName,
    String? city,
    String? logoUrl,
    String? gstNumber,
    String? panNumber,
    String? kycStatus,
    Timestamp? kycSubmittedAt,
    Timestamp? kycReviewedAt,
    String? kycRejectionReason,
    bool? verified,
    int? totalEventsPosted,
    int? totalVolunteersHired,
    String? fcmToken,
    Timestamp? updatedAt,
  }) {
    return OrganiserModel(
      uid: uid,
      phone: phone,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      organisationType: organisationType,
      contactName: contactName ?? this.contactName,
      companyName: companyName ?? this.companyName,
      city: city ?? this.city,
      logoUrl: logoUrl ?? this.logoUrl,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      kycStatus: kycStatus ?? this.kycStatus,
      kycSubmittedAt: kycSubmittedAt ?? this.kycSubmittedAt,
      kycReviewedAt: kycReviewedAt ?? this.kycReviewedAt,
      kycRejectionReason: kycRejectionReason ?? this.kycRejectionReason,
      verified: verified ?? this.verified,
      totalEventsPosted: totalEventsPosted ?? this.totalEventsPosted,
      totalVolunteersHired: totalVolunteersHired ?? this.totalVolunteersHired,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

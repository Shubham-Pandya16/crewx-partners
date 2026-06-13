import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/application_model.dart';
import '../../models/event_model.dart';
import '../../models/organiser_model.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUserDoc(String uid, String phone) async {
    final userRef = _db.collection('users').doc(uid);
    final organiserRef = _db.collection('organisers').doc(uid);

    await _db.runTransaction((transaction) async {
      transaction.set(userRef, {
        'uid': uid,
        'role': 'organiser',
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(organiserRef, {
        'uid': uid,
        'phone': phone,
        'onboardingComplete': false,
        'organisationType': 'supplier',
        'kycStatus': 'not_submitted',
        'verified': false,
        'totalEventsPosted': 0,
        'totalVolunteersHired': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<bool> userExists(String uid) async {
    final doc = await _db.collection('organisers').doc(uid).get();
    return doc.exists;
  }

  Future<bool> onboardingComplete(String uid) async {
    final doc = await _db.collection('organisers').doc(uid).get();
    return doc.data()?['onboardingComplete'] ?? false;
  }

  Future<OrganiserModel?> getOrganiser(String uid) async {
    final doc = await _db.collection('organisers').doc(uid).get();
    if (doc.exists) {
      return OrganiserModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<OrganiserModel?> organiserStream(String uid) {
    return _db.collection('organisers').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return OrganiserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> updateOrganiserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('organisers').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeOnboarding(
    String uid, {
    required String contactName,
    required String companyName,
    required String city,
    String? logoUrl,
  }) async {
    await _db.collection('organisers').doc(uid).update({
      'contactName': contactName,
      'companyName': companyName,
      'city': city,
      if (logoUrl != null) 'logoUrl': logoUrl,
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createEvent(EventModel event) async {
    final eventRef = _db.collection('events').doc();
    final organiserRef = _db.collection('organisers').doc(event.organiserId);

    await _db.runTransaction((transaction) async {
      transaction.set(eventRef, event.toMap());
      transaction.update(organiserRef, {
        'totalEventsPosted': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    return eventRef.id;
  }

  Stream<List<EventModel>> myEventsStream(String organiserId) {
    return _db
        .collection('events')
        .where('organiserId', isEqualTo: organiserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<ApplicationModel>> applicationsStream(String organiserId) {
    return _db
        .collection('applications')
        .where('organiserId', isEqualTo: organiserId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ApplicationModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<int> getApplicationCount(String eventId) async {
    final snap = await _db
        .collection('applications')
        .where('eventId', isEqualTo: eventId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<void> respondToApplication(
    String applicationId,
    String status, {
    String? rejectionReason,
  }) async {
    final appRef = _db.collection('applications').doc(applicationId);

    await _db.runTransaction((transaction) async {
      final appDoc = await transaction.get(appRef);
      if (!appDoc.exists) return;

      transaction.update(appRef, {
        'status': status,
        'respondedAt': FieldValue.serverTimestamp(),
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      });

      if (status == 'accepted') {
        final organiserId = appDoc.data()?['organiserId'];
        if (organiserId != null) {
          final organiserRef = _db.collection('organisers').doc(organiserId);
          transaction.update(organiserRef, {
            'totalVolunteersHired': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }
}

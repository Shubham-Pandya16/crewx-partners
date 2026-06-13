import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> init() async {
    await _fcm.requestPermission();
    // TODO: Handle foreground notifications
  }

  Future<void> refreshToken(String uid) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _db.collection('organisers').doc(uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

extension DateTimeExt on DateTime {
  String get formatEventDate => DateFormat('EEE, d MMM yyyy · hh:mm a').format(this);
}

extension TimestampExt on Timestamp {
  String get formatEventDate => toDate().formatEventDate;
}

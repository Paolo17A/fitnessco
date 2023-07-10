import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> getThisUserData(
    String uid) async {
  final currentUser =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return currentUser;
}

Future updateThisUserData(String uid, Map<Object, Object?> data) {
  final updateData =
      FirebaseFirestore.instance.collection('users').doc(uid).update(data);
  return updateData;
}

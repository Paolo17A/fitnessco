import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String getCurrentUser() {
  return FirebaseAuth.instance.currentUser!.uid;
}

Future<Map<dynamic, dynamic>> getCurrentUserData() async {
  final currentUserData = await getThisUserData(getCurrentUser());
  return currentUserData.data()!;
}

Future updateCurrentUserData(Map<Object, Object?> dataMap) async {
  await updateThisUserData(getCurrentUser(), dataMap);
}

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

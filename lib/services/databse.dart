import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // collection reference
  final CollectionReference brewCollection =
      FirebaseFirestore.instance.collection('lost');

  Future<void> updateUserData(
      String company, String color, String modelname) async {
    return await brewCollection.doc(uid).set({
      'company': company,
      'color': color,
      'modelname': modelname,
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_services/user_firebase_services.dart';


class UserViewModel {
  final UsersFirebaseService _usersFirebaseService = UsersFirebaseService();

  Stream<QuerySnapshot> getUsers() async* {
    yield* _usersFirebaseService.getUsers();
  }

  void addUser({
    required String name,
    required String email,
    required String uid,
    required int colorValue,
  }) {
    _usersFirebaseService.addUser(
      name: name,
      email: email,
      uid: uid,
      colorValue: colorValue,
    );
  }
}
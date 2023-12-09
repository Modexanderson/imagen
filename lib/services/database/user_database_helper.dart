
import 'package:cloud_firestore/cloud_firestore.dart';

import '../authentification_service.dart';

class UserDatabaseHelper {
  static const String USERS_COLLECTION_NAME = "users";

  static const String DP_KEY = "display_picture";
  static const String CREDITS = 'credits';

  UserDatabaseHelper._privateConstructor({this.phone});
  static UserDatabaseHelper _instance =
      UserDatabaseHelper._privateConstructor();
  factory UserDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore? _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore!;
  }

  final String? phone;
  Future<void> createNewUser(String uid) async {
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).set({
      DP_KEY: null,
      CREDITS: 5,
    });
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
  try {
    return await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
  } catch (e) {
    // Handle exceptions (e.g., Firestore errors)
    print('Error fetching user data: $e');
    rethrow;
  }
}


  Future<bool> deductCreditsForUser(String uid, double amount) async {
    try {
      final userDocRef =
          firestore.collection(USERS_COLLECTION_NAME).doc(uid);

      // Get the current credits value
      final DocumentSnapshot userSnapshot = await userDocRef.get();
      final double currentCredits =
        (userSnapshot.data() as Map<String, dynamic>?)?[CREDITS] ?? 0;

      // Check if the user has enough credits
      if (currentCredits >= amount) {
        // Deduct the credits
        await userDocRef.update({
          CREDITS: currentCredits - amount,
        });
        return true;
      } else {
        // User doesn't have enough credits
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., Firestore errors)
      print('Error deducting credits: $e');
      return false;
    }
  }

  Future<void> deleteCurrentUserData() async {
    final uid = AuthentificationService().currentUser.uid;
    final docRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    
    // final ordersDoc = await ordersCollectionRef.get();
    // for (final orderDoc in ordersDoc.docs) {
    //   await ordersCollectionRef.doc(orderDoc.id).delete();
    // }
    await docRef.delete();
  }


  String getPathForCurrentUserDisplayPicture() {
    final String currentUserUid = AuthentificationService().currentUser.uid;
    return "user/display_picture/$currentUserUid";
  }

  Future<bool> uploadDisplayPictureForCurrentUser(String url) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {DP_KEY: url},
    );
    return true;
  }

  Future<bool> removeDisplayPictureForCurrentUser() async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {
        DP_KEY: FieldValue.delete(),
      },
    );
    return true;
  }

  Future<String> get displayPictureForCurrentUser async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    return userDocSnapshot.data()?['DP_KEY'] ??
        'https://cdn.vectorstock.com/i/1000x1000/62/59/default-avatar-photo-placeholder-profile-icon-vector-21666259.webp';
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/object_wrappers.dart';

import '../../api/purchase_api.dart';
import '../authentification_service.dart';

class UserDatabaseHelper {
  static const String USERS_COLLECTION_NAME = "users";

  static const String USER_EMAIL = "user_email";

  static const String CREDITS = 'credits';

  UserDatabaseHelper._privateConstructor(this.phone);
  static final UserDatabaseHelper _instance =
      UserDatabaseHelper._privateConstructor('');
  factory UserDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore? _firebaseFirestore;
  FirebaseFirestore get firestore {
    _firebaseFirestore ??= FirebaseFirestore.instance;
    return _firebaseFirestore!;
  }

   Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();

      return snapshot.exists;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking user existence: $e");
      }
      return false;
    }
  }

  Future<double> getInitialCreditValue() async {
    try {
      // Retrieve the document from Firestore
      final DocumentSnapshot snapshot =
        await firestore.collection('initial_credit_collection').doc('initial_credit_doc').get();

      // Check if the document exists and contains the 'credit' field
      if (snapshot.exists && snapshot.data() != null) {
        // Explicitly cast the data to Map<String, dynamic>
        Map<String, dynamic> data =
            snapshot.data() as Map<String, dynamic>;

        // Retrieve the credit value
        double initialCreditValue = (data['initialCreditValue'] ?? 0.0).toDouble();

        return initialCreditValue;
      } else {
        if (kDebugMode) {
          print('Document does not exist or credit field is missing.');
        }
        return 0.0; // or handle the default value appropriately
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving credit value: $e');
      }
      return 0.0; // or handle the default value appropriately
    }
}


  final String? phone;
  Future<void> createNewUser(String uid, String userEmail) async {
   // Retrieve the value from Firebase
  double initialCreditValue = await getInitialCreditValue();
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).set({
      USER_EMAIL: userEmail,
      CREDITS: initialCreditValue,
    });
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
  try {
    return await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
  } catch (e) {
    // Handle exceptions (e.g., Firestore errors)
    if (kDebugMode) {
      print('Error fetching user data: $e');
    }
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
      if (kDebugMode) {
        print('Error deducting credits: $e');
      }
      return false;
    }
  }

  Future<void> updateRevenueCatPayment(String uid, Package package) async {
    try {
      final userDocRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);

      // Get the current credits value
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final double currentCredits =
        (userSnapshot.data() as Map<String, dynamic>?)?[CREDITS] ?? 0;

    switch (package.offeringIdentifier) {
      case Coins.idCoins10:
      // Update the user's credits
        await userDocRef.update({
          CREDITS: currentCredits + 10});
          break;
      case Coins.idCoins5:
      // Update the user's credits
        await userDocRef.update({
          CREDITS: currentCredits + 5});
          break;
      default:
        break;
    }
    } catch (e) {
    // Handle exceptions (e.g., Firestore errors)
    if (kDebugMode) {
      print('Error updating user credits after payment: $e');
    }
  }
  }

  Future<void> updateCreditsAfterPayment(String uid, double amount) async {
  try {
    final userDocRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);

    // Get the current credits value
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final double currentCredits =
        (userSnapshot.data() as Map<String, dynamic>?)?[CREDITS] ?? 0;

    // Update the user's credits
    await userDocRef.update({
      CREDITS: currentCredits + amount,
    });
  } catch (e) {
    // Handle exceptions (e.g., Firestore errors)
    if (kDebugMode) {
      print('Error updating user credits after payment: $e');
    }
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

}

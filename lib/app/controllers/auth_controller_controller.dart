import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:waveclonefirebase/app/models/AccountModel.dart';
import 'package:waveclonefirebase/app/models/UserModel.dart';

class AuthControllerController extends GetxController {
  // Observable variable for handling count
  final count = 0.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Method to increment the count
  void increment() => count.value++;

  // Google Sign-In Method
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      print(
          "signed in successfully : ${userCredential.user?.displayName}  ${userCredential.user?.email}  ${userCredential.user?.photoURL}  ${userCredential.user?.uid}  ${userCredential.user!.phoneNumber} ");
      return userCredential.user;
    } catch (e) {
      print(e); // Handle any error during sign-in
      return null;
    }
  }

  // Facebook Sign-In Method
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile']);
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        print(
            "connected user : ${userCredential.user?.displayName}  ${userCredential.user?.email}  ${userCredential.user?.photoURL}  ${userCredential.user?.uid}  ${userCredential.user?.phoneNumber} ");
        return userCredential.user;
      } else {
        print('Facebook sign-in failed: ${result.message}');
        return null;
      }
    } catch (e) {
      print('Error signing in with Facebook: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        print('User signed in: ${user.email}');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found with this email.');
      } else if (e.code == 'wrong-password') {
        print('Incorrect password provided.');
      } else if (e.code == 'invalid-email') {
        print('The email address is badly formatted.');
      } else {
        print('An unknown error occurred: ${e.message}');
      }
      return null;
    } catch (e) {
      print('Error signing in with email/password: $e');
      return null;
    }
  }

  // Future<void> _saveUserToFirestore(User user) async {
  //   try {
  //     final DocumentReference userDoc =
  //         _firestore.collection('users').doc(user.uid);
  //     await userDoc.set({
  //       'uid': user.uid,
  //       'displayName': user.displayName,
  //       'email': user.email,
  //       'photoURL': user.photoURL,
  //       'phoneNumber': user.phoneNumber,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     print('Error saving user to Firestore: $e');
  //   }
  // }

  // Function to register a user with email and password
  Future<UserModel?> registerWithEmailPassword(
      String email,
      String password,
      String displayName,
      String telephone,
      String adresse,
      String idCardNumber,
      String status,
      String roleId,
      String accountId) async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Set the display name for the user
        await user.updateDisplayName(displayName);
        await user.reload();

        // Create a User model instance
        UserModel newUser = UserModel(
          id: user.uid,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          deletedAt: '',
          deleted: false,
          telephone: telephone,
          adresse: adresse,
          email: email,
          enabled: true, // Assuming enabled is true by default
          idCardNumber: idCardNumber,
          nom: displayName.split(' ')[
              0], // Assuming first name is the first part of the displayName
          password: password,
          prenom: displayName.split(' ').length > 1
              ? displayName.split(' ')[1]
              : '',
          qrCode: '', // Set to empty if not available
          status: status,
          roleId: roleId,
          accountId: accountId,
        );

        // Save user information to Firestore
        await _saveUserToFirestore(newUser);

        AccountModel accountModel = AccountModel(
          plafond: 1000000,
          solde: 0,
          type: "Standard",
          createdAt: DateTime.now().toIso8601String(),
          deleted: false,
          deletedAt: null,
          updatedAt: DateTime.now().toIso8601String(),
          userId: newUser.id,
          sommeDepot: 0,
          plafonnee: false,
        );

        await _saveUserToFirestore(accountModel);
        print("User registered successfully: ${user.email}  ${user.uid}  ${user.displayName}  ${user.phoneNumber}  ${user.photoURL}  ${user.emailVerified}");

        return newUser; // Return the User model object
      } else {
        print('User creation failed: User is null');
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      print('Error registering user: ${e.message}');
      return null;
    } catch (e) {
      // Catch any other errors
      print('Unexpected error registering user: $e');
      return null;
    }
  }

  // Helper function to save the user to Firestore
  Future<void> _saveUserToFirestore(dynamic user) async {
    try {
      // Create a user document in the 'users' collection
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      print('User data saved to Firestore');
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:waveclonefirebase/app/models/AccountModel.dart';
import 'package:waveclonefirebase/app/models/UserModel.dart';

class AuthControllerController extends GetxController {
  final count = 0.obs;
  final Rxn<UserModel> userData = Rxn<UserModel>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      print("signed in successfully : ${userCredential.user?.displayName}");

      QuerySnapshot querySnapshot = await firestore
          .collection("users")
          .where("email", isEqualTo: userCredential.user!.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final datas = querySnapshot.docs.first.data() as Map<String, dynamic>;
        userData.value = UserModel(
            deleted: datas["deleted"],
            telephone: datas["telephone"],
            adresse: datas["adresse"],
            email: datas["email"],
            idCardNumber: datas["idCardNumber"],
            nom: datas["nom"],
            password: datas["password"],
            prenom: datas["prenom"],
            qrCode: datas["qr_code"],
            status: datas["status"],
            roleId: datas["role_id"],
            accountId: datas["account_id"]);
      }

      Get.snackbar('Sign in', "signed-in successfully",
          backgroundColor: Colors.green);
      Get.toNamed("/acceuil");
      return userCredential.user;
    } catch (e) {
      print(e);
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
        print("connected user : ${userCredential.user?.displayName}");
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

  // Sign-in with email and password
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
        var _firestore = firestore.collection('users');

        QuerySnapshot querySnapshot =
            await _firestore.where("email", isEqualTo: user.email).get();

        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        print('User signed in: ${user.email}');
        Get.snackbar('Sign in', "signed-in successfully",
            backgroundColor: Colors.green);

        if (userData["role_id"] == "Client") {
          Get.toNamed("/acceuil");
        } else {
          Get.toNamed("/distributeur");
        }
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

  // Register user with email and password
  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    required String adresse,
    required String idCardNumber,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(prenom + " " + nom);
        await user.reload();

        final accountID = Uuid().v4();
        print(accountID);

        UserModel newUser = UserModel(
          id: user.uid,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          deletedAt: null,
          deleted: false,
          telephone: telephone,
          adresse: adresse,
          email: email,
          enabled: true,
          idCardNumber: idCardNumber,
          nom: nom,
          password: password,
          prenom: prenom,
          qrCode: telephone,
          status: "Actif",
          roleId: "Client",
          accountId: accountID,
        );

        await _saveUserToFirestore(newUser, "users");

        AccountModel accountModel = AccountModel(
          plafond: 1000000,
          solde: 0,
          type: "Standard",
          createdAt: DateTime.now().toIso8601String(),
          deleted: false,
          deletedAt: null,
          updatedAt: DateTime.now().toIso8601String(),
          userId: newUser.id!,
          sommeDepot: 0,
          plafonnee: false,
          id: accountID,
        );

        await _saveUserToFirestore(accountModel, "accounts");

        Get.snackbar('Registration', "Account registered successfully");
        Get.back();

        return newUser;
      } else {
        Get.snackbar('Registration', 'User creation failed: User is null');
        return null;
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration', 'Error registering user: ${e.message}');
      return null;
    } catch (e) {
      Get.snackbar('Registration', 'Unexpected error registering user: $e');
      return null;
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut(); // Sign out from Google as well

      userData.value = null; // Clear user data
      Get.snackbar('Sign out', "Signed out successfully", backgroundColor: Colors.red);
      Get.offAllNamed('/login'); // Navigate to the login page
    } catch (e) {
      print('Error signing out: $e');
      Get.snackbar('Sign out', 'Error signing out: $e');
    }
  }

  // Helper function to save the user to Firestore
  Future<void> _saveUserToFirestore(dynamic user, String collection) async {
    try {
      await firestore.collection(collection).doc(user.id).set(user.toJson());
      print('User data saved to Firestore');
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }
}

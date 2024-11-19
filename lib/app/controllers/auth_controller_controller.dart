import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthControllerController extends GetxController {
  // Observable variable for handling count
  final count = 0.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await auth.signInWithCredential(credential);
      print("signed in successfully : ${userCredential.user?.displayName}  ${userCredential.user?.email}  ${userCredential.user?.photoURL}  ${userCredential.user?.uid}  ${userCredential.user!.phoneNumber} ");
      return userCredential.user;
    } catch (e) {
      print(e); // Handle any error during sign-in
      return null;
    }
  }

  // Facebook Sign-In Method
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        print("connected user : ${userCredential.user?.displayName}  ${userCredential.user?.email}  ${userCredential.user?.photoURL}  ${userCredential.user?.uid}  ${userCredential.user?.phoneNumber} ");
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
}

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:waveclonefirebase/app/controllers/auth_controller_controller.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  final AuthControllerController authController = Get.put(AuthControllerController());
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Obx(() => isLoading.value
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignInButton(
                    Buttons.Google,
                    onPressed: () async {
                      isLoading.value = true;
                      final user = await authController.signInWithGoogle();
                      isLoading.value = false;
                      if (user != null) {
                        Get.toNamed('/home');
                      } else {
                        Get.snackbar('Error', 'Google Sign-in failed');
                      }
                    },
                  ),
                  SignInButton(
                    Buttons.Facebook,
                    onPressed: () async {
                      isLoading.value = true;
                      final user = await authController.signInWithFacebook();
                      isLoading.value = false;
                      if (user != null) {
                        Get.toNamed('/home');
                      } else {
                        Get.snackbar('Error', 'Facebook Sign-in failed');
                      }
                    },
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

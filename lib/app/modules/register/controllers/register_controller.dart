import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void submitForm() {
    if (formKey.currentState!.validate()) {
      // TODO: Implement actual registration logic
      final user = {
        'nom': nomController.text,
        'prenom': prenomController.text,
        'telephone': telephoneController.text,
        'email': emailController.text,
        'adresse': adresseController.text,
        'password': passwordController.text,
        'status': 'active',
        'roleId': 1,
        'qrCode': ''
      };
      
      print(user); // Replace with actual registration process
      Get.snackbar('Registration', 'User registration successful');
    }
  }

  @override
  void onClose() {
    nomController.dispose();
    prenomController.dispose();
    telephoneController.dispose();
    emailController.dispose();
    adresseController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
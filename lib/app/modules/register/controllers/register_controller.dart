import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waveclonefirebase/app/controllers/auth_controller_controller.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthControllerController authController = AuthControllerController();

  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void submitForm()async {
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
      
      authController.registerWithEmailPassword(email: emailController.text,password:  passwordController.text,prenom:  prenomController.text,nom: nomController.text,telephone:  telephoneController.text,adresse:  adresseController.text,idCardNumber: "1761200200327");
      print(user); // Replace with actual registration process
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
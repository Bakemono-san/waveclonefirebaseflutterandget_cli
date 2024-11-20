import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:waveclonefirebase/app/controllers/paiement_controller.dart';
import 'package:waveclonefirebase/app/controllers/transaction_controller_controller.dart';

import 'app/routes/app_pages.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(TransactionControllerController());
  Get.put(PaiementController());
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

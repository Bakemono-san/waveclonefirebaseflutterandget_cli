import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:waveclonefirebase/app/controllers/transaction_controller_controller.dart';
import 'package:waveclonefirebase/app/models/PaiementModel.dart';
import 'package:waveclonefirebase/app/models/TransactionModel.dart';

class PaiementController extends GetxController {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  TransactionControllerController transactionControllerController = Get.put(TransactionControllerController());

  // Store the single selected contact for sending payments
  Rx<Contact?> selectedContact = Rx<Contact?>(null);

  // Select a contact for the payment
  void selectContact(Contact contact) {
    selectedContact.value = contact;
  }

  // Send Plannification to Firestore for the selected contact
  void sendPlannification({required String phone, required String amount}) async {
  if (selectedContact.value == null) {
    print("No contact selected");
    return;
  }

  print("Sending Paiement to $phone for $amount");

  try {
    // Query for user information from Firestore
    

    transactionControllerController.sendTransaction(phone: phone, amount: amount, type: "paiement");

    
  } catch (e) {
    print("Error sending Plannification: $e");
    Get.snackbar(
      "Error",
      "An error occurred: $e",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

}

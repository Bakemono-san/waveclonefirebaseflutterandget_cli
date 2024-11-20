import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waveclonefirebase/app/widgets/homeWidget.dart';
import 'package:waveclonefirebase/app/widgets/plannificationWidget.dart';
import 'package:waveclonefirebase/app/widgets/transactionMultipleWidget.dart';
import 'package:waveclonefirebase/app/widgets/transactionWidget.dart';

class AcceuilController extends GetxController {
  var account = <String, dynamic>{}.obs; // Ensure the account data is typed
  var solde = 1.0.obs;
  var connectedUser = <String, dynamic>{}.obs; // Ensure the user data is typed

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch user data from Firestore based on the email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo: user.email)
            .get();

        // Check if the query returned any documents
        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

          // Fetch account data based on user_id
          QuerySnapshot accountSnapshot = await FirebaseFirestore.instance
              .collection("accounts")
              .where("id", isEqualTo: userData['account_id'])
              .get();

          // Check if the accountSnapshot returned any documents
          if (accountSnapshot.docs.isNotEmpty) {
            var accountData = accountSnapshot.docs.first.data() as Map<String, dynamic>;

            // Update the reactive variables
            account.value = accountData;
            connectedUser.value["nom"] = userData["nom"];
            connectedUser.value["prenom"] = userData["prenom"];
            connectedUser.value["qr_code"] = userData["qr_code"];
            connectedUser.value["telephone"] = userData["telephone"];

            // Set the 'solde' value from the account data
            solde.value = accountData['solde'] ?? 10.0; // Default to 0.0 if not found

            print("connected user data : $connectedUser");
            connectedUser.refresh();
          } else {
            print("No account data found for user.");
            Get.snackbar("Error", "No account data found for user", backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          print("No user data found.");
          Get.snackbar("Error", "No user data found", backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        print("Error fetching user data: $e");
        Get.snackbar("Error", "Failed to fetch user data", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      print("No user is logged in.");
      Get.snackbar("Error", "No user is logged in", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getUserData(); // Fetch the data when the controller is initialized
  }

  var currentIndex = 0.obs;

  List<Widget> get pages => [
        HomeWidget(balance: solde),
        TransactionWidget(),
        TransactionMultipleWidget(),
        PlannificationWidget(),
      ];

  // Update index
  void changePage(int index) {
    currentIndex.value = index;
  }
}

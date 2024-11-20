import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:waveclonefirebase/app/models/TransactionModel.dart';

class TransactionControllerController extends GetxController {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Change from List<TransactionModel> to RxList<TransactionModel>
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  // Send transaction to Firestore
  void sendTransaction({
    required String phone,
    required String amount,
    required String type,
  }) async {
    print("Sending transaction to $phone for $amount");

    user = FirebaseAuth.instance.currentUser;

    try {
      // Query for user information from Firestore
      print("Querying for user data : ${user?.email}");
      QuerySnapshot querySnapshot = await firestore
          .collection("users")
          .where("email", isEqualTo: user?.email ?? '')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("User data not found");
        Get.snackbar("transaction", "User data not found");
        return;
      }

      final connectedUser =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      // Check if the connected user has a telephone number
      if (connectedUser['telephone'] == null) {
        print("User telephone not found");
        return;
      }

      // Fetch user account by user_id
      QuerySnapshot userAccountSnapshot = await firestore
          .collection("accounts")
          .where("id", isEqualTo: connectedUser["account_id"])
          .get();

      if (userAccountSnapshot.docs.isEmpty) {
        print("Account data not found");
        Get.snackbar("transaction", "Account data not found");
        return;
      }

      var userAccount =
          userAccountSnapshot.docs.first.data() as Map<String, dynamic>;

      print("solde before transaction: ${userAccount['solde']}");

      // Check if the connected user has sufficient funds
      if (connectedUser["role_id"] != "Distributeur" &&
          (type == "Deposit" || type == "Withdraw")) {
        print("User is not a Distributeur");
        Get.snackbar("transaction", "vous ne pouvez pas faire cette action",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Query to find receiver by phone number
      QuerySnapshot receiverSnapshot = await firestore
          .collection("users")
          .where("telephone", isEqualTo: phone)
          .get();

      if (receiverSnapshot.docs.isEmpty) {
        print("Receiver user not found");
        Get.snackbar("transaction", "Ce numero n'est pas enregistré",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      var receiverUser =
          receiverSnapshot.docs.first.data() as Map<String, dynamic>;

      if (type == "Withdraw") {
        QuerySnapshot receiverAccountSnapshot = await firestore
            .collection("accounts")
            .where("id", isEqualTo: receiverUser["account_id"])
            .get();
        var receiverAccount =
            receiverAccountSnapshot.docs.first.data() as Map<String, dynamic>;

        // Ensure proper casting to double
        double receiverSolde = (receiverAccount["solde"] ?? 0).toDouble();

        if (receiverSolde < double.parse(amount)) {
          Get.snackbar("transaction", "Solde insuffisant",
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      } else {
        // Ensure sender has sufficient balance
        double senderSolde = (userAccount["solde"] ?? 0).toDouble();
        if (senderSolde < double.parse(amount)) {
          print("User solde insufficient");
          Get.snackbar("transaction", "User solde insufficient",
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      // Create the transaction object
      TransactionModel transaction = TransactionModel(
        id: Uuid().v4(),
        annulee: false,
        date: DateTime.now().toIso8601String(),
        montant: double.parse(amount),
        type: type,
        createdAt: DateTime.now().toIso8601String(),
        deleted: false,
        deletedAt: null,
        updatedAt: DateTime.now().toIso8601String(),
        receiverTelephone: phone,
        senderTelephone: connectedUser["telephone"],
      );

      // Add transaction to Firestore
      await firestore.collection("transactions").add(transaction.toJson());

      // Update sender's and receiver's balance
      if (type == "Withdraw") {
        await firestore
            .collection("accounts")
            .doc(receiverUser["account_id"])
            .update({
          "solde": FieldValue.increment(-transaction.montant),
        });

        await firestore
            .collection("users")
            .doc(connectedUser["account_id"])
            .update({
          "solde": FieldValue.increment(transaction.montant),
        });
      } else {
        await firestore
            .collection("users")
            .doc(connectedUser["account_id"])
            .update({
          "solde": FieldValue.increment(-transaction.montant),
        });

        await firestore
            .collection("accounts")
            .doc(receiverUser["account_id"])
            .update({
          "solde": FieldValue.increment(transaction.montant),
        });
      }

      print("Transaction saved to Firestore");
      Get.snackbar('Success', 'Transaction sent successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Error saving transaction to Firestore: $e');
      Get.snackbar('Error', 'Failed to send transaction',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Get transactions by phone number
  Future<void> getTransactionsByPhone(String phone) async {
    try {
      // Query transactions where sender or receiver matches the phone number
      QuerySnapshot senderQuery = await firestore
          .collection("transactions")
          .where("sender_telephone", isEqualTo: phone)
          .get();

      QuerySnapshot receiverQuery = await firestore
          .collection("transactions")
          .where("receiver_telephone", isEqualTo: phone)
          .get();

      // Combine the results
      List<QueryDocumentSnapshot> combinedDocs = []
        ..addAll(senderQuery.docs)
        ..addAll(receiverQuery.docs);

      // Convert documents to TransactionModel
      List<TransactionModel> newTransactions = combinedDocs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Handle 'date' field, check if it's a Timestamp or String
        String date;
        if (data['date'] is Timestamp) {
          date = (data['date'] as Timestamp).toDate().toIso8601String();
        } else {
          date = data['date'] as String;
        }

        // Ensure 'montant' is handled as a double
        double montant = (data['montant'] is double)
            ? data['montant']
            : (data['montant'] as int).toDouble();

        return TransactionModel(
          id: data['id'],
          senderTelephone: data['sender_telephone'],
          receiverTelephone: data['receiver_telephone'],
          montant: montant,
          type: data['type'],
          date: date,
          createdAt: (data['created_at'] is Timestamp)
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : data['created_at'],
          updatedAt: (data['updated_at'] is Timestamp)
              ? (data['updated_at'] as Timestamp).toDate().toIso8601String()
              : data['updated_at'],
          annulee: data['annulee'],
          deleted: data['deleted'],
          agentTelephone: data['agent_telephone'],
          deletedAt: (data['deleted_at'] is Timestamp)
              ? (data['deleted_at'] as Timestamp).toDate().toIso8601String()
              : data['deleted_at'],
        );
      }).toList();

      // Update the RxList reactively
      transactions.assignAll(newTransactions);

      // Optional: Sort transactions by date (if needed)
      transactions.sort((a, b) => DateTime.parse(b.date)
          .compareTo(DateTime.parse(a.date))); // Sorting by date descending
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  final count = 0.obs;

  @override
  void onInit() async {
    super.onInit();

    // Fetch user details
    if (user == null) {
      print("User not authenticated");
      return;
    }

    QuerySnapshot querySnapshot = await firestore
        .collection("users")
        .where("email", isEqualTo: user?.email ?? '')
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("User data not found");
      return;
    }

    final connectedUser =
        querySnapshot.docs.first.data() as Map<String, dynamic>;

    // Fetch transactions
    if (connectedUser["telephone"] != null) {
      await getTransactionsByPhone(connectedUser["telephone"]);
    } else {
      print("User telephone not found");
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}

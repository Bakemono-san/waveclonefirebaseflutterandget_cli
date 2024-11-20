import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:waveclonefirebase/app/models/PlannificationModel.dart';

class PlanningController extends GetxController {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Change from List<PlannificationModel> to RxList<PlannificationModel>
  List<Plannification> plannification = <Plannification>[].obs;

  // Send Plannification to Firestore
  void sendPlannification({required String phone, required String amount, required String periode}) async {
    print("Sending Plannification to $phone for $amount");
    try {
      // Query for user information from Firestore
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

      // Check if the connected user has a telephone number
      if (connectedUser['telephone'] == null) {
        print("User telephone not found");
        return;
      }

      // Create the Plannification object
      Plannification plannification = Plannification(
        id: Uuid().v4(),
        periode: periode,
        montant: double.parse(amount),
        createdAt: DateTime.now().toIso8601String(),
        deleted: false,
        deletedAt: null,
        updatedAt: DateTime.now().toIso8601String(),
        receiverTelephone: phone,
        senderTelephone: connectedUser["telephone"],
      );

      // Add Plannification to Firestore
      await firestore.collection("plannification").add(plannification.toJson());
      print("Plannification saved to Firestore");
      Get.snackbar('Success', 'Plannification saved successfully');
    } catch (e) {
      print('Error saving Plannification to Firestore: $e');
      Get.snackbar('Error', 'Failed to send Plannification');
    }
  }

  // Get plannification by phone number
  Future<void> getplannificationByPhone(String phone) async {
    try {
      // Query plannification where sender or receiver matches the phone number
      QuerySnapshot senderQuery = await firestore
          .collection("plannification")
          .where("senderTelephone", isEqualTo: phone)
          .get();

      QuerySnapshot receiverQuery = await firestore
          .collection("plannification")
          .where("receiverTelephone", isEqualTo: phone)
          .get();

      // Combine the results
      List<QueryDocumentSnapshot> combinedDocs = []
        ..addAll(senderQuery.docs)
        ..addAll(receiverQuery.docs);

      // Convert documents to PlannificationModel
      List<Plannification> newplannification = combinedDocs
          .map((doc) =>
              Plannification.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Update the RxList reactively
      plannification.assignAll(newplannification);

    } catch (e) {
      print("Error fetching plannification: $e");
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

  final connectedUser = querySnapshot.docs.first.data() as Map<String, dynamic>;

  // Fetch plannification
  if (connectedUser["telephone"] != null) {
    await getplannificationByPhone(connectedUser["telephone"]);
  } else {
    print("User telephone not found");
  }
}

}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waveclonefirebase/app/controllers/transaction_controller_controller.dart';

class DistributeurController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final accountNumberController = TextEditingController();
  final amountController = TextEditingController();
  late MobileScannerController mobileScannerController;

  final TransactionControllerController transactionController = Get.put(TransactionControllerController());
  
  final isScanning = false.obs;
  final totalDeposits = 0.obs;
  final totalWithdrawals = 0.obs;

  @override
  void onInit() {
    super.onInit();
    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  // QR Scanner Callback
  void onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        accountNumberController.text = code;
        isScanning.value = false;
        mobileScannerController.stop();
      }
    }
  }

  // Start QR scanning
  void startScanning() {
    isScanning.value = true;
    mobileScannerController.start();
  }

  // Process deposit/withdrawal transaction
  void processTransaction(String type) {
    if (!formKey.currentState!.validate()) return;

    transactionController.sendTransaction(phone: accountNumberController.text, amount: amountController.text, type: type);

    final amount = int.tryParse(amountController.text) ?? 0;

    if(type == 'Deposit') {
      totalDeposits.value += amount;
    }else{
      totalWithdrawals.value += amount;
    }

    // Check if the amount is valid
    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Clear form after transaction
    accountNumberController.clear();
    amountController.clear();
  }

  // Unblock account action
  void unblockAccount() {
    if (accountNumberController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please scan a QR code first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Success',
      'Account ${accountNumberController.text} has been unblocked',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    accountNumberController.dispose();
    amountController.dispose();
    mobileScannerController.dispose();
    super.dispose();
  }
}
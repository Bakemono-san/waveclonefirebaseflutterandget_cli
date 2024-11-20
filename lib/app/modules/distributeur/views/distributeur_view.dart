import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controllers/distributeur_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

class DistributeurView extends GetView<DistributeurController> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distributor Dashboard'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats Cards
              Row(
                children: [
                  _buildStatCard(
                    'Total Deposits',
                    '${controller.totalDeposits}',
                    Colors.green,
                  ),
                  SizedBox(width: 16),
                  _buildStatCard(
                    'Total Withdrawals',
                    '${controller.totalWithdrawals}',
                    Colors.orange,
                  ),
                ],
              ),
              SizedBox(height: 24),

              // QR Scanner Section
              Obx(
                () => controller.isScanning.value
                    ? Container(
                        height: 300,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: MobileScanner(
                                controller: controller.mobileScannerController,
                                onDetect: controller.onDetect,
                              ),
                            ),
                            // Custom overlay
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: controller.startScanning,
                        icon: Icon(Icons.qr_code_scanner),
                        label: Text('Scan QR Code'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
              ),

              SizedBox(height: 24),

              // Transaction Form
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Account Number Field
                         TextFormField(
                              controller: controller.accountNumberController,
                              decoration: InputDecoration(
                                labelText: 'Account Number',
                                border: OutlineInputBorder(),
                                // enabled: controller.accountNumberController.text
                                //     .isNotEmpty, // Enable after scan
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Please scan a QR code first'
                                  : null,
                            ),

                        SizedBox(height: 16),

                        // Amount Field
                        TextFormField(
                          controller: controller.amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter an amount' : null,
                        ),

                        SizedBox(height: 24),

                        // Transaction Type Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    controller.processTransaction('Deposit'),
                                icon: Icon(Icons.arrow_downward),
                                label: Text('Deposit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    controller.processTransaction('Withdraw'),
                                icon: Icon(Icons.arrow_upward),
                                label: Text('Withdraw'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Unblock Account Button
                        ElevatedButton.icon(
                          onPressed: controller.unblockAccount,
                          icon: Icon(Icons.lock_open),
                          label: Text('Unblock Account'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
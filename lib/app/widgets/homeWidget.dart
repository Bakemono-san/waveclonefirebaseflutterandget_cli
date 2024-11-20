import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:waveclonefirebase/app/controllers/transaction_controller_controller.dart';
import 'package:waveclonefirebase/app/models/TransactionModel.dart';

class HomeWidget extends StatelessWidget {
  final RxDouble balance;
  final TransactionControllerController transactionController =
      Get.put(TransactionControllerController());
  final RxBool isBalanceVisible = RxBool(true);

  HomeWidget({Key? key, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionController.onInit();
    });

    var format = NumberFormat.currency(symbol: "\$", decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
             transactionController.onInit();
          },
          child: CustomScrollView(
            slivers: [
              // SliverAppBar(
              //   floating: true,
              //   snap: true,
              //   backgroundColor: Colors.transparent,
              //   elevation: 0,
              //   actions: [
              //     IconButton(
              //       icon: Icon(Icons.notifications_outlined, color: Colors.black),
              //       onPressed: () {},
              //     )
              //   ],
              // ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30,),
                      _buildBalanceCard(format, context),
                      SizedBox(height: 20),
                      _buildRecentTransactionsSection(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(NumberFormat format, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade100.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 15,
          offset: Offset(0, 5),
        )
      ],
    ),
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Obx(() => IconButton(
                  icon: Icon(
                    isBalanceVisible.value ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue.shade600,
                  ),
                  onPressed: () {
                    isBalanceVisible.value = !isBalanceVisible.value;
                  },
                )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() => Text(
                    isBalanceVisible.value
                        ? format.format(balance.value)
                        : '*****',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  )),
            ),
            Obx(() {
              if (transactionController.transactions.isNotEmpty) {
                var transaction = transactionController.transactions[0];
                var phoneNumber = transaction.receiverTelephone;
                
                if (phoneNumber != null && phoneNumber.isNotEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                    ),
                    padding: EdgeInsets.all(8),
                    child: QrImageView(
                      data: phoneNumber,
                      size: 70.0,
                      backgroundColor: Colors.transparent,
                    ),
                  );
                }
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ],
    ),
  );
}
  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Obx(() {
          if (transactionController.transactions.isEmpty) {
            return _buildEmptyTransactionsView();
          }
          return _buildTransactionsList();
        }),
      ],
    );
  }

  Widget _buildEmptyTransactionsView() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactionController.transactions.length,
      itemBuilder: (context, index) {
        var transaction = transactionController.transactions[index];
        return _buildTransactionItem(
          icon: _getIconForTransactionType(transaction.type),
          title: transaction.type,
          subtitle: transaction.receiverTelephone ?? 'Unknown',
          amount: transaction.montant < 0
              ? '-\$${transaction.montant.abs()}'
              : '+\$${transaction.montant.abs()}',
          date: transaction.date,
        );
      },
    );
  }

  IconData _getIconForTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_cart;
      case 'transfer':
        return Icons.send;
      case 'bill':
        return Icons.receipt;
      case 'deposit':
        return Icons.add_circle;
      default:
        return Icons.payment;
    }
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String date,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(8),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              amount,
              style: TextStyle(
                color: amount.startsWith('+') ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final String date;

  Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class MobileBankingMainPage extends StatefulWidget {
  @override
  _MobileBankingMainPageState createState() => _MobileBankingMainPageState();
}

class _MobileBankingMainPageState extends State<MobileBankingMainPage> {
  bool _isBalanceHidden = false;
  final double _accountBalance = 12584.50;

  final List<Transaction> _transactions = [
    Transaction(
      title: 'Salary',
      subtitle: 'Monthly Income',
      amount: 5000.00,
      isIncome: true,
      date: 'Nov 15',
    ),
    Transaction(
      title: 'Grocery Store',
      subtitle: 'Supermarket',
      amount: 120.50,
      isIncome: false,
      date: 'Nov 10',
    ),
    Transaction(
      title: 'Electricity Bill',
      subtitle: 'Utility Payment',
      amount: 85.75,
      isIncome: false,
      date: 'Nov 05',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildBalanceSection(theme),
              SizedBox(height: 30),
              _buildQuickActions(),
              SizedBox(height: 30),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.account_balance_wallet, color: Colors.blue[600], size: 32),
        IconButton(
          icon: Icon(Icons.qr_code, color: Colors.blue[600], size: 32),
          onPressed: () {
            _showQRCodeDialog(context);
          },
          tooltip: 'Show QR Code',
        ),
      ],
    );
  }

  Widget _buildBalanceSection(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isBalanceHidden
                  ? '******'
                  : '\$${_accountBalance.toStringAsFixed(2)}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            IconButton(
              icon: Icon(
                _isBalanceHidden ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _isBalanceHidden = !_isBalanceHidden;
                });
              },
              tooltip: _isBalanceHidden ? 'Show Balance' : 'Hide Balance',
            ),
          ],
        ),
        Text(
          'Total Balance',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionButton(Icons.qr_code_scanner, 'Scan'),
        _buildQuickActionButton(Icons.payment, 'Pay'),
        _buildQuickActionButton(Icons.send, 'Transfer'),
        _buildQuickActionButton(Icons.more_horiz, 'More'),
      ],
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(icon, color: Colors.blue[600]),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full transactions page
              },
              child: Text(
                'See All',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Column(
          children: _transactions
              .map((transaction) => _buildTransactionItem(transaction))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transaction.isIncome
                      ? Colors.green[100]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  transaction.isIncome
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                  semanticLabel: transaction.isIncome ? 'Income' : 'Expense',
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    transaction.subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),
              Text(
                transaction.date,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 250.0,
            height: 250.0,
            child: QrImageView(
              data: 'YOUR_BANK_ACCOUNT_IDENTIFIER',
              version: QrVersions.auto,
              size: 250.0,
              gapless: false,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:waveclonefirebase/app/controllers/paiement_controller.dart';

class TransactionMultipleWidget extends StatelessWidget {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final PaiementController _paiementController = Get.put(PaiementController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildContactSelectionCard(),
              const SizedBox(height: 20),
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildSendButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSelectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Obx(() {
        final selectedContact = _paiementController.selectedContact.value;
        return selectedContact == null 
          ? _buildEmptyContactSelection()
          : _buildSelectedContactDisplay(selectedContact);
      }),
    );
  }

  Widget _buildEmptyContactSelection() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.person_add, color: Colors.blue.shade700),
      ),
      title: Text(
        'Select Contact',
        style: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.blue.shade700),
      onTap: _selectContact,
    );
  }

  Widget _buildSelectedContactDisplay(Contact contact) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.person, color: Colors.blue.shade700),
      ),
      title: Text(
        contact.displayName ?? 'Unknown',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        contact.phones?.isNotEmpty == true 
          ? contact.phones!.first.number 
          : 'No phone number',
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Colors.blue.shade700),
        onPressed: _selectContact,
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixIcon: Icon(Icons.attach_money, color: Colors.blue.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _sendPayment(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text('Send Payment', style: TextStyle(fontSize: 16)),
    );
  }

  Future<void> _selectContact() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await Navigator.push(
          Get.context!,
          MaterialPageRoute(builder: (context) => ContactSelectionPage()),
        );

        if (contact != null) {
          _paiementController.selectContact(contact);
        }
      } else {
        _showErrorSnackbar('Contact Permission', 'Cannot access contacts');
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to load contacts');
    }
  }

  void _sendPayment(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final amount = _amountController.text;
      final selectedContact = _paiementController.selectedContact.value;

      if (selectedContact != null) {
        _paiementController.sendPlannification(
          phone: selectedContact.phones!.first.number,
          amount: amount,
        );
        _amountController.clear();
      }
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }

  
}

class ContactSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Contact'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Contact>>(
        future: FlutterContacts.getContacts(withProperties: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final contact = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, color: Colors.blue.shade700),
                ),
                title: Text(contact.displayName ?? 'Unknown'),
                subtitle: Text(
                  contact.phones?.isNotEmpty == true 
                    ? contact.phones!.first.number 
                    : 'No phone number'
                ),
                onTap: () => Navigator.pop(context, contact),
              );
            },
          );
        },
      ),
    );
  }
}
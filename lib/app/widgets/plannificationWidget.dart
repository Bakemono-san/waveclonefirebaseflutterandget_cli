import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:waveclonefirebase/app/controllers/planning_controller.dart';

class PlannificationWidget extends StatefulWidget {
  const PlannificationWidget({Key? key}) : super(key: key);

  @override
  _PlannificationWidgetState createState() => _PlannificationWidgetState();
}

class _PlannificationWidgetState extends State<PlannificationWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _frequency = 'Daily';
  final PlanningController _transactionController = Get.put(PlanningController());

  @override
  void initState() {
    super.initState();
    _transactionController.onInit();
  }

  Future<void> _selectContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        _phoneController.text = contact.phones.first.number;
      }
    } else {
      _showErrorSnackbar('Contact Permission', 'Contact access denied');
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      margin: const EdgeInsets.all(12),
    );
  }

  void _schedulePlannification() {
    if (_formKey.currentState!.validate()) {
      _transactionController.sendPlannification(
        phone: _phoneController.text.trim(),
        amount: _amountController.text.trim(),
        periode: _frequency,
      );

      Get.snackbar(
        'Success',
        'Plannification Scheduled!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.check, color: Colors.white),
        margin: const EdgeInsets.all(12),
      );

      // Clear form after scheduling
      _phoneController.clear();
      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildSectionTitle('Create Plannification'),
                const SizedBox(height: 16),
                _buildContactTextField(),
                const SizedBox(height: 16),
                _buildAmountTextField(),
                const SizedBox(height: 16),
                _buildFrequencyDropdown(),
                const SizedBox(height: 24),
                _buildScheduleButton(),
                const SizedBox(height: 32),
                _buildSectionTitle('Existing Plannifications'),
                const SizedBox(height: 16),
                _buildPlannificationsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
    );
  }

  Widget _buildContactTextField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.contact_page),
                onPressed: _selectContact,
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountTextField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixIcon: Icon(Icons.monetization_on),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
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

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _frequency,
      decoration: const InputDecoration(
        labelText: 'Frequency',
        border: OutlineInputBorder(),
      ),
      items: ['Daily', 'Weekly', 'Monthly']
          .map((freq) => DropdownMenuItem(
                value: freq,
                child: Text(freq),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _frequency = value ?? 'Daily';
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a frequency';
        }
        return null;
      },
    );
  }

  Widget _buildScheduleButton() {
    return ElevatedButton.icon(
      onPressed: _schedulePlannification,
      icon: const Icon(Icons.schedule),
      label: const Text('Schedule Plannification'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildPlannificationsList() {
    return Obx(() {
      final plannings = _transactionController.plannification;

      if (plannings.isEmpty) {
        return const Center(
          child: Text(
            'No plannifications found.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: plannings.length,
        itemBuilder: (context, index) {
          final planning = plannings[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.shade100,
                child: Icon(Icons.phone, color: Colors.blueAccent.shade700),
              ),
              title: Text(
                planning.receiverTelephone ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Amount: ${planning.montant} - ${planning.periode}',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Icon(
                planning.deleted == true ? Icons.delete : Icons.check_circle,
                color: planning.deleted == true ? Colors.red : Colors.green,
              ),
            ),
          );
        },
      );
    });
  }
}
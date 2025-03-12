import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MedicationManagementPage extends StatefulWidget {
  const MedicationManagementPage({super.key});

  @override
  State<MedicationManagementPage> createState() => _MedicationManagementPageState();
}

class _MedicationManagementPageState extends State<MedicationManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  void _scheduleNotification(DateTime medicationTime, String medicationName) {
    final notificationTime = medicationTime.subtract(const Duration(minutes: 30));
    _firebaseMessaging.subscribeToTopic('medication_reminder');
    _firestore.collection('notifications').add({
      'title': 'Medication Reminder',
      'body': 'Take your medication: $medicationName in 30 minutes.',
      'time': notificationTime,
    });
  }

  void _showMedicationForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Medication Name')),
            TextField(controller: _dosageController, decoration: const InputDecoration(labelText: 'Dosage')),
            TextField(controller: _frequencyController, decoration: const InputDecoration(labelText: 'Frequency')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => _selectDate(context, true), child: Text(_startDate == null ? 'Select Start Date' : DateFormat.yMd().format(_startDate!))),
                TextButton(onPressed: () => _selectDate(context, false), child: Text(_endDate == null ? 'Select End Date' : DateFormat.yMd().format(_endDate!))),
              ],
            ),
            ElevatedButton(
              onPressed: () => _addOrUpdateMedication(),
              child: const Text('Add Medication'),
            ),
          ],
        ),
      ),
    );
  }

  void _addOrUpdateMedication({String? docId}) {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty || _frequencyController.text.isEmpty || _startDate == null || _endDate == null) {
      return;
    }

    final newMedication = {
      'name': _nameController.text,
      'dosage': _dosageController.text,
      'frequency': _frequencyController.text,
      'startDate': _startDate,
      'endDate': _endDate,
      'taken': false,
    };

    if (docId == null) {
      _firestore.collection('medications').add(newMedication).then((docRef) {
        _scheduleNotification(_startDate!, _nameController.text);
      });
    } else {
      _firestore.collection('medications').doc(docId).update(newMedication);
    }

    _clearFields();
    Navigator.pop(context);
  }

  void _deleteMedication(String docId) {
    _firestore.collection('medications').doc(docId).delete();
  }

  void _toggleTaken(String docId, bool currentStatus) {
    _firestore.collection('medications').doc(docId).update({'taken': !currentStatus});
  }

  void _clearFields() {
    _nameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _startDate = null;
    _endDate = null;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Medication Management')),
      body: StreamBuilder(
        stream: _firestore.collection('medications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final medications = snapshot.data!.docs;
          return medications.isEmpty
              ? const Center(child: Text('No medications added yet.'))
              : ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index].data() as Map<String, dynamic>;
              final docId = medications[index].id;
              return Card(
                child: ListTile(
                  title: Text(medication['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Dosage: ${medication['dosage']} \nFrequency: ${medication['frequency']}\nStart: ${DateFormat.yMd().format((medication['startDate'] as Timestamp).toDate())} - End: ${DateFormat.yMd().format((medication['endDate'] as Timestamp).toDate())}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteMedication(docId)),
                    ],
                  ),
                  leading: IconButton(
                    icon: Icon(medication['taken'] ? Icons.check_circle : Icons.circle_outlined, color: medication['taken'] ? Colors.green : Colors.grey),
                    onPressed: () => _toggleTaken(docId, medication['taken']),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMedicationForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
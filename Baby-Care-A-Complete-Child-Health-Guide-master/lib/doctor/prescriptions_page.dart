import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for the add prescription form
  final _patientNameController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _prescriptionDate;
  List<Map<String, dynamic>> _medicines = [];
  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _patientNameController.dispose();
    _doctorNameController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _medicineNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _patientNameController.clear();
    _doctorNameController.clear();
    _diagnosisController.clear();
    _notesController.clear();
    _medicineNameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _durationController.clear();
    setState(() {
      _prescriptionDate = null;
      _medicines = [];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _prescriptionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6200EE),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _prescriptionDate = picked);
    }
  }

  void _addMedicine() {
    if (_medicineNameController.text.isNotEmpty &&
        _dosageController.text.isNotEmpty &&
        _frequencyController.text.isNotEmpty &&
        _durationController.text.isNotEmpty) {
      setState(() {
        _medicines.add({
          'name': _medicineNameController.text,
          'dosage': _dosageController.text,
          'frequency': _frequencyController.text,
          'duration': _durationController.text,
        });
        _medicineNameController.clear();
        _dosageController.clear();
        _frequencyController.clear();
        _durationController.clear();
      });
    }
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
  }

  Future<void> _savePrescription() async {
    if (_formKey.currentState!.validate() &&
        _medicines.isNotEmpty &&
        _prescriptionDate != null) {
      try {
        setState(() => _isLoading = true);

        await _firestore.collection('prescriptions').add({
          'patientName': _patientNameController.text,
          'doctorName': _doctorNameController.text,
          'diagnosis': _diagnosisController.text,
          'notes': _notesController.text,
          'prescriptionDate': _prescriptionDate,
          'medicines': _medicines,
          'createdAt': DateTime.now(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prescription saved successfully'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving prescription: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please fill all required fields and add at least one medicine'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _deletePrescription(String id) async {
    try {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Prescription'),
          content:
              const Text('Are you sure you want to delete this prescription?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _firestore.collection('prescriptions').doc(id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prescription deleted successfully'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting prescription: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showAddPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medicine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _medicineNameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
              ),
              TextField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
              ),
              TextField(
                controller: _frequencyController,
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addMedicine();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddPrescriptionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Prescription',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6200EE),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _patientNameController,
                  decoration: InputDecoration(
                    labelText: 'Patient Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter patient name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _doctorNameController,
                  decoration: InputDecoration(
                    labelText: 'Doctor Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter doctor name'
                      : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Prescription Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _prescriptionDate == null
                          ? 'Select Date'
                          : DateFormat('MMM d, y').format(_prescriptionDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diagnosisController,
                  decoration: InputDecoration(
                    labelText: 'Diagnosis',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter diagnosis' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Medicines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showAddPrescriptionDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Medicine'),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _medicines[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(medicine['name']),
                        subtitle: Text(
                          '${medicine['dosage']} • ${medicine['frequency']} • ${medicine['duration']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _removeMedicine(index),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _savePrescription,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Prescription',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prescriptions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6200EE),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F5), Colors.white],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('prescriptions')
              .orderBy('prescriptionDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6200EE)),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No prescriptions yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a new prescription to get started',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final medicines =
                    List<Map<String, dynamic>>.from(data['medicines'] ?? []);
                final prescriptionDate =
                    (data['prescriptionDate'] as Timestamp).toDate();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['patientName'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6200EE),
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, y').format(prescriptionDate),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dr. ${data['doctorName'] ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Diagnosis:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          data['diagnosis'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Medicines:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medicines.length,
                          itemBuilder: (context, index) {
                            final medicine = medicines[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(
                                    child: Text(
                                      '${medicine['name']} - ${medicine['dosage']} (${medicine['frequency']}) for ${medicine['duration']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (data['notes']?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Notes:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            data['notes'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _deletePrescription(doc.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPrescriptionSheet,
        backgroundColor: const Color(0xFF6200EE),
        icon: const Icon(Icons.add),
        label: const Text('Add Prescription'),
      ),
    );
  }
}

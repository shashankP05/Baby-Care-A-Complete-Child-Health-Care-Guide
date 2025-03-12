import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'Male';
  String _bloodGroup = 'A+';

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
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
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _addPatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestore.collection('patients').add({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'dateOfBirth': _dateOfBirth?.toIso8601String(),
          'bloodGroup': _bloodGroup,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'medicalHistory': _medicalHistoryController.text,
          'allergies': _allergiesController.text,
          'registrationDate': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient added successfully'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          );
        }

        _resetForm();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding patient: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _ageController.clear();
    _phoneController.clear();
    _addressController.clear();
    _medicalHistoryController.clear();
    _allergiesController.clear();
    setState(() {
      _dateOfBirth = null;
      _gender = 'Male';
      _bloodGroup = 'A+';
    });
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF6200EE)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Patient',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6200EE),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        _nameController,
                        'Patient Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _ageController,
                              'Age',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter age';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age <= 0 || age > 150) {
                                  return 'Enter valid age';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _gender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _genders.map((String gender) {
                                return DropdownMenuItem(value: gender, child: Text(gender));
                              }).toList(),
                              onChanged: (String? newValue) => setState(() => _gender = newValue!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          child: Text(
                            _dateOfBirth == null
                                ? 'Select Date'
                                : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _bloodGroup,
                        decoration: InputDecoration(
                          labelText: 'Blood Group',
                          labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _bloodGroups.map((String group) {
                          return DropdownMenuItem(value: group, child: Text(group));
                        }).toList(),
                        onChanged: (String? newValue) => setState(() => _bloodGroup = newValue!),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _phoneController,
                        'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Enter valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_addressController, 'Address', maxLines: 2),
                      const SizedBox(height: 16),
                      _buildTextField(_medicalHistoryController, 'Medical History', maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField(_allergiesController, 'Allergies', maxLines: 2),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFF6200EE),
                            elevation: 2,
                          ),
                          onPressed: _isLoading ? null : _addPatient,
                          child: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                              : const Text(
                            'Add Patient',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PediatricConsultationPage extends StatefulWidget {
  const PediatricConsultationPage({Key? key}) : super(key: key);

  @override
  _PediatricConsultationPageState createState() =>
      _PediatricConsultationPageState();
}

class _PediatricConsultationPageState extends State<PediatricConsultationPage> {
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _concernController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedDoctor;
  TimeOfDay? _selectedTime;
  String _selectedConsultationType = 'In-Person';
  bool _isEmergency = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<String> _doctorNames = [];

  // Theme colors
  final Color primaryColor = const Color(0xFF8BC34A);
  final Color secondaryColor = const Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      setState(() {
        _doctorNames = querySnapshot.docs
            .map((doc) => doc['name'] as String)
            .toList();
      });
    } catch (e) {
      print("Error fetching doctors: $e");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildConsultationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consultation Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'In-Person',
              label: Text('In-Person'),
              icon: Icon(Icons.person),
            ),
            ButtonSegment(
              value: 'Video',
              label: Text('Video'),
              icon: Icon(Icons.video_call),
            ),
          ],
          selected: {_selectedConsultationType},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selectedConsultationType = newSelection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return primaryColor;
                }
                return Colors.transparent;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyToggle() {
    return SwitchListTile(
      title: Text(
        'Emergency Consultation',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _isEmergency ? Colors.red : primaryColor,
        ),
      ),
      subtitle: Text(
        'Toggle for urgent medical attention',
        style: TextStyle(fontSize: 14),
      ),
      value: _isEmergency,
      onChanged: (bool value) {
        setState(() {
          _isEmergency = value;
        });
      },
      activeColor: Colors.red,
      activeTrackColor: Colors.red.withOpacity(0.5),
    );
  }

  Widget _buildDoctorDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDoctor,
      decoration: InputDecoration(
        labelText: 'Select Doctor',
        prefixIcon: Icon(Icons.person),
      ),
      items: _doctorNames.map((String doctor) {
        return DropdownMenuItem<String>(
          value: doctor,
          child: Text(doctor),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDoctor = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a doctor';
        }
        return null;
      },
    );
  }

  Widget _buildAppointmentForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _childNameController,
            decoration: InputDecoration(
              labelText: 'Child Name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your child\'s name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _concernController,
            decoration: InputDecoration(
              labelText: 'Concern/Reason',
              prefixIcon: Icon(Icons.medical_services),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe your concern';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDoctorDropdown(),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2022),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                  _scheduleController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: _scheduleController,
                decoration: InputDecoration(
                  labelText: 'Appointment Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _selectTime(context),
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(
                  text: _selectedTime != null ? _selectedTime!.format(context) : '',
                ),
                decoration: InputDecoration(
                  labelText: 'Appointment Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildConsultationTypeSelector(),
          const SizedBox(height: 16),
          _buildEmergencyToggle(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              primary: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: TextStyle(fontSize: 16),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Submit Appointment'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Add appointment to a separate collection
      await FirebaseFirestore.instance.collection('appointments').add({
        'child_name': _childNameController.text,
        'phone': _phoneController.text,
        'concern': _concernController.text,
        'schedule_date': _selectedDate,
        'schedule_time': _selectedTime?.format(context),
        'doctor': _selectedDoctor,
        'consultation_type': _selectedConsultationType,
        'is_emergency': _isEmergency,
        'created_at': DateTime.now(),
      });

      setState(() {
        _isLoading = false;
      });

      // Show confirmation message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Appointment Submitted'),
            content: Text('Your appointment request has been successfully submitted.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle any errors here
      print("Error submitting appointment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Pediatric Consultation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildAppointmentForm(),
          ],
        ),
      ),
    );
  }
}
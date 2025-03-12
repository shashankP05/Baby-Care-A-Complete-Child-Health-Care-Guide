import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAppointmentPage extends StatefulWidget {
  @override
  _AddAppointmentPageState createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _status = "Pending";

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (_nameController.text.isEmpty || _dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    await FirebaseFirestore.instance.collection('appointments').add({
      "name": _nameController.text,
      "date": _dateController.text,
      "time": _timeController.text,
      "status": _status,
    });

    Navigator.pop(context); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Appointment'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Patient Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(labelText: "Select Date"),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _timeController,
              readOnly: true,
              decoration: InputDecoration(labelText: "Select Time"),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _status,
              items: ["Pending", "Confirmed", "Canceled"].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value.toString();
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAppointment,
              child: Text("Save Appointment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

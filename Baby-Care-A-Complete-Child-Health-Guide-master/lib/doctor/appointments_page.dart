import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final CollectionReference _appointmentsRef =
  FirebaseFirestore.instance.collection('appointments');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildAppointmentList()),
          _buildScheduleButton(),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _appointmentsRef.orderBy('schedule_date', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Appointments Found'));
        }

        final appointments = snapshot.data!.docs;
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var appointment = appointments[index].data() as Map<String, dynamic>;
            return _buildAppointmentCard(appointments[index].id, appointment);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(String id, Map<String, dynamic> appointment) {
    Color statusColor = appointment["is_emergency"] ? Colors.red : Colors.blue;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
              appointment["is_emergency"] ? Icons.emergency : Icons.calendar_today,
              color: Colors.white
          ),
        ),
        title: Text(
            appointment["child_name"],
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${appointment["doctor"]}'),
            Text('Concern: ${appointment["concern"]}'),
            Text('${DateFormat.yMMMd().format((appointment["schedule_date"] as Timestamp).toDate())} at ${appointment["schedule_time"]}'),
            Text('Type: ${appointment["consultation_type"]}'),
            Text('Phone: ${appointment["phone"]}'),
          ],
        ),
        isThreeLine: true,
        trailing: appointment["is_emergency"]
            ? Chip(
          label: Text('EMERGENCY'),
          backgroundColor: Colors.red[100],
          labelStyle: TextStyle(color: Colors.red),
        )
            : null,
        onLongPress: () => _confirmDeleteAppointment(id),
      ),
    );
  }

  Widget _buildScheduleButton() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _showAddAppointmentDialog,
          child: Text("Schedule New Appointment"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showAddAppointmentDialog() {
    TextEditingController childNameController = TextEditingController();
    TextEditingController doctorController = TextEditingController();
    TextEditingController concernController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String consultationType = "In-Person";
    bool isEmergency = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Appointment"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: childNameController,
                    decoration: InputDecoration(labelText: "Child Name")
                ),
                TextField(
                    controller: doctorController,
                    decoration: InputDecoration(labelText: "Doctor Name")
                ),
                TextField(
                    controller: concernController,
                    decoration: InputDecoration(labelText: "Concern")
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(selectedDate == null
                      ? "Pick Date"
                      : DateFormat.yMMMd().format(selectedDate!)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text(selectedTime == null
                      ? "Pick Time"
                      : selectedTime!.format(context)),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: consultationType,
                  items: ["In-Person", "Video Call", "Phone Call"].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    consultationType = value.toString();
                  },
                  decoration: InputDecoration(labelText: "Consultation Type"),
                ),
                SwitchListTile(
                  title: Text("Emergency"),
                  value: isEmergency,
                  onChanged: (bool value) {
                    setState(() {
                      isEmergency = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () async {
                if (childNameController.text.isNotEmpty &&
                    doctorController.text.isNotEmpty &&
                    concernController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null) {
                  await _addAppointment(
                    childNameController.text,
                    doctorController.text,
                    concernController.text,
                    phoneController.text,
                    selectedDate!,
                    selectedTime!,
                    consultationType,
                    isEmergency,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAppointment(
      String childName,
      String doctor,
      String concern,
      String phone,
      DateTime date,
      TimeOfDay time,
      String consultationType,
      bool isEmergency,
      ) async {
    DateTime scheduleDate = DateTime(date.year, date.month, date.day);

    await _appointmentsRef.add({
      "child_name": childName,
      "doctor": doctor,
      "concern": concern,
      "phone": phone,
      "schedule_date": Timestamp.fromDate(scheduleDate),
      "schedule_time": "${time.format(context)}",
      "consultation_type": consultationType,
      "is_emergency": isEmergency,
      "created_at": Timestamp.now(),
    });
  }

  void _confirmDeleteAppointment(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Appointment"),
          content: Text("Are you sure you want to delete this appointment?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () async {
                await _appointmentsRef.doc(id).delete();
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TodaysPatientsPage extends StatefulWidget {
  @override
  _TodaysPatientsPageState createState() => _TodaysPatientsPageState();
}

class _TodaysPatientsPageState extends State<TodaysPatientsPage> {
  final CollectionReference _patientsRef =
  FirebaseFirestore.instance.collection('patients');
  late String _todayDate;

  @override
  void initState() {
    super.initState();
    _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Patients'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "All Patients",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildPatientsList()),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _patientsRef.snapshots(), // Removed the where clause
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Patients Found'));
        }

        final patients = snapshot.data!.docs;
        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            var patient = patients[index].data() as Map<String, dynamic>;
            return _buildPatientCard(patients[index].id, patient);
          },
        );
      },
    );
  }

  Widget _buildPatientCard(String id, Map<String, dynamic> patient) {
    Color statusColor = patient["status"] == "Completed" ? Colors.green : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(patient["name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Age: ${patient["age"]}\nAppointment Time: ${patient["appointment_time"]}'),
        trailing: IconButton(
          icon: Icon(Icons.check, color: Colors.green),
          onPressed: () => _markAsCompleted(id),
        ),
      ),
    );
  }

  Future<void> _markAsCompleted(String id) async {
    await _patientsRef.doc(id).update({"status": "Completed"});
  }
}
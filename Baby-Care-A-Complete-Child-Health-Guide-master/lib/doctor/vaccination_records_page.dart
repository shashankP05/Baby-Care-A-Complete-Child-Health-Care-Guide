import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationRecordsPage extends StatefulWidget {
  @override
  _VaccinationRecordsPageState createState() => _VaccinationRecordsPageState();
}

class _VaccinationRecordsPageState extends State<VaccinationRecordsPage> {
  final CollectionReference _vaccinationRecordsRef =
  FirebaseFirestore.instance.collection('vaccination_records');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vaccination Records'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildVaccinationList()),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildVaccinationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _vaccinationRecordsRef.orderBy('date', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Vaccination Records Found'));
        }

        final records = snapshot.data!.docs;
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            var record = records[index].data() as Map<String, dynamic>;
            return _buildRecordCard(records[index].id, record);
          },
        );
      },
    );
  }

  Widget _buildRecordCard(String id, Map<String, dynamic> record) {
    Color statusColor = record["status"] == "Completed" ? Colors.green : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(Icons.vaccines, color: Colors.white),
        ),
        title: Text(record["child_name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Vaccine: ${record["vaccine_name"]}\nDate: ${record["date"]}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () => _markAsCompleted(id),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRecord(id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showAddRecordDialog,
        child: Text("Add New Record"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showAddRecordDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController vaccineController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    String status = "Pending";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Vaccination Record"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Child Name")),
              TextField(controller: vaccineController, decoration: InputDecoration(labelText: "Vaccine Name")),
              TextField(controller: dateController, decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)")),
              DropdownButtonFormField(
                value: status,
                items: ["Pending", "Completed"].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  status = value.toString();
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _addRecord(nameController.text, vaccineController.text, dateController.text, status);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addRecord(String childName, String vaccineName, String date, String status) async {
    if (childName.isNotEmpty && vaccineName.isNotEmpty && date.isNotEmpty) {
      await _vaccinationRecordsRef.add({
        "child_name": childName,
        "vaccine_name": vaccineName,
        "date": date,
        "status": status,
      });
    }
  }

  Future<void> _markAsCompleted(String id) async {
    await _vaccinationRecordsRef.doc(id).update({"status": "Completed"});
  }

  Future<void> _deleteRecord(String id) async {
    await _vaccinationRecordsRef.doc(id).delete();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRecordsPage extends StatefulWidget {
  @override
  _PatientRecordsPageState createState() => _PatientRecordsPageState();
}

class _PatientRecordsPageState extends State<PatientRecordsPage> {
  final CollectionReference _patientRecordsRef =
  FirebaseFirestore.instance.collection('patient_records');

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Records'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildPatientList()),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search Patient...",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildPatientList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _patientRecordsRef.orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Patient Records Found'));
        }

        final records = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data["name"].toLowerCase().contains(_searchQuery);
        }).toList();

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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.person, color: Colors.blueAccent),
        title: Text(record["name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Age: ${record["age"]} • Condition: ${record["condition"]}\nLast Visit: ${record["last_visit"]}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteRecord(id),
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
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showAddRecordDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController conditionController = TextEditingController();
    TextEditingController lastVisitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Patient Record"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Patient Name")),
              TextField(controller: ageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Age")),
              TextField(controller: conditionController, decoration: InputDecoration(labelText: "Medical Condition")),
              TextField(controller: lastVisitController, decoration: InputDecoration(labelText: "Last Visit (YYYY-MM-DD)")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _addRecord(nameController.text, ageController.text, conditionController.text, lastVisitController.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addRecord(String name, String age, String condition, String lastVisit) async {
    if (name.isNotEmpty && age.isNotEmpty && condition.isNotEmpty && lastVisit.isNotEmpty) {
      await _patientRecordsRef.add({
        "name": name,
        "age": int.parse(age),
        "condition": condition,
        "last_visit": lastVisit,
      });
    }
  }

  Future<void> _deleteRecord(String id) async {
    await _patientRecordsRef.doc(id).delete();
  }
}

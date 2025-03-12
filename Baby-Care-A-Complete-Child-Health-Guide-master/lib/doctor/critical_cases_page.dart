import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CriticalCasesPage extends StatefulWidget {
  @override
  _CriticalCasesPageState createState() => _CriticalCasesPageState();
}

class _CriticalCasesPageState extends State<CriticalCasesPage> {
  final CollectionReference _criticalCasesRef =
  FirebaseFirestore.instance.collection('critical_cases');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Critical Cases'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: _buildCriticalCasesList(),
    );
  }

  Widget _buildCriticalCasesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _criticalCasesRef.orderBy('urgency_level', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Critical Cases Found'));
        }

        final cases = snapshot.data!.docs;
        return ListView.builder(
          itemCount: cases.length,
          itemBuilder: (context, index) {
            var caseData = cases[index].data() as Map<String, dynamic>;
            return _buildCaseCard(cases[index].id, caseData);
          },
        );
      },
    );
  }

  Widget _buildCaseCard(String id, Map<String, dynamic> caseData) {
    Color urgencyColor;
    switch (caseData["urgency_level"]) {
      case "High":
        urgencyColor = Colors.red;
        break;
      case "Medium":
        urgencyColor = Colors.orange;
        break;
      case "Low":
        urgencyColor = Colors.yellow;
        break;
      default:
        urgencyColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: urgencyColor,
          child: Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(caseData["patient_name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Condition: ${caseData["condition"]}\nUrgency: ${caseData["urgency_level"]}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.call, color: Colors.green),
              onPressed: () => _callEmergency(caseData["emergency_contact"]),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCase(id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCase(String id) async {
    await _criticalCasesRef.doc(id).delete();
  }

  void _callEmergency(String contactNumber) {
    // Implement phone call functionality if needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $contactNumber...')),
    );
  }
}

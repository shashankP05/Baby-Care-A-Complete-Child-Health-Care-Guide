import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedCasesPage extends StatefulWidget {
  @override
  _CompletedCasesPageState createState() => _CompletedCasesPageState();
}

class _CompletedCasesPageState extends State<CompletedCasesPage> {
  final CollectionReference _completedCasesRef =
  FirebaseFirestore.instance.collection('completed_cases');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Cases'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _buildCompletedCasesList(),
    );
  }

  Widget _buildCompletedCasesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _completedCasesRef.orderBy('completion_date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Completed Cases Found'));
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green),
        title: Text(caseData["patient_name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Completed on: ${caseData["completion_date"]}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteCase(id),
        ),
      ),
    );
  }

  Future<void> _deleteCase(String id) async {
    await _completedCasesRef.doc(id).delete();
  }
}

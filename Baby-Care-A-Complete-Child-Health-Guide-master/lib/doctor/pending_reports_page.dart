import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingReportsPage extends StatefulWidget {
  @override
  _PendingReportsPageState createState() => _PendingReportsPageState();
}

class _PendingReportsPageState extends State<PendingReportsPage> {
  final CollectionReference _pendingReportsRef =
  FirebaseFirestore.instance.collection('pending_reports');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Reports'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: _buildPendingReportsList(),
    );
  }

  Widget _buildPendingReportsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pendingReportsRef.orderBy('submission_date', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Pending Reports Found'));
        }

        final reports = snapshot.data!.docs;
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            var report = reports[index].data() as Map<String, dynamic>;
            return _buildReportCard(reports[index].id, report);
          },
        );
      },
    );
  }

  Widget _buildReportCard(String id, Map<String, dynamic> report) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.insert_drive_file, color: Colors.orangeAccent),
        title: Text(report["patient_name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Report: ${report["report_type"]}\nSubmission: ${report["submission_date"]}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () => _markAsCompleted(id),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteReport(id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsCompleted(String id) async {
    await _pendingReportsRef.doc(id).update({"status": "Completed"});
  }

  Future<void> _deleteReport(String id) async {
    await _pendingReportsRef.doc(id).delete();
  }
}

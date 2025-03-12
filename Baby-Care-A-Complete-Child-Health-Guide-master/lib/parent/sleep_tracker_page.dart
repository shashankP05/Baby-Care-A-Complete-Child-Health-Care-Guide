import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({Key? key}) : super(key: key);

  @override
  _SleepTrackerPageState createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  final List<Map<String, dynamic>> _sleepLog = [];
  final _bedtimeController = TextEditingController();
  final _wakeTimeController = TextEditingController();
  final _notesController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchSleepData();
  }

  // Fetch sleep data from Firebase Firestore
  Future<void> _fetchSleepData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('sleepLogs')
            .where('userId', isEqualTo: user.uid)
            .get();

        setState(() {
          _sleepLog.clear();
          for (var doc in snapshot.docs) {
            _sleepLog.add({
              'date': doc['date'],
              'bedtime': doc['bedtime'],
              'waketime': doc['waketime'],
              'notes': doc['notes'],
              'duration': doc['duration'],
            });
          }
        });
      }
    } catch (e) {
      print("Error fetching sleep data: $e");
    }
  }

  // Add new sleep log to Firebase Firestore
  Future<void> _addSleepLog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Sleep Log'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _bedtimeController,
                  decoration: const InputDecoration(labelText: 'Bedtime'),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? bedtime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (bedtime != null) {
                      final now = DateTime.now();
                      final dateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        bedtime.hour,
                        bedtime.minute,
                      );
                      _bedtimeController.text = DateFormat('HH:mm').format(dateTime);
                    }
                  },
                ),
                TextField(
                  controller: _wakeTimeController,
                  decoration: const InputDecoration(labelText: 'Wake-up Time'),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? wakeTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (wakeTime != null) {
                      final now = DateTime.now();
                      final dateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        wakeTime.hour,
                        wakeTime.minute,
                      );
                      _wakeTimeController.text = DateFormat('HH:mm').format(dateTime);
                    }
                  },
                ),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final bedtime = _bedtimeController.text;
                final waketime = _wakeTimeController.text;
                final notes = _notesController.text;

                final bedtimeDate = DateFormat('HH:mm').parse(bedtime);
                final wakeTimeDate = DateFormat('HH:mm').parse(waketime);
                final duration = wakeTimeDate
                    .difference(bedtimeDate)
                    .inMinutes
                    .abs() /
                    60;

                final user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('sleepLogs').add({
                    'userId': user.uid,
                    'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    'bedtime': bedtime,
                    'waketime': waketime,
                    'notes': notes,
                    'duration': duration,
                  });

                  _bedtimeController.clear();
                  _wakeTimeController.clear();
                  _notesController.clear();

                  _fetchSleepData(); // Refresh sleep data after adding
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete sleep log
  Future<void> _deleteSleepLog(String docId) async {
    try {
      await _firestore.collection('sleepLogs').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep log deleted successfully')),
      );
      _fetchSleepData(); // Refresh after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting log')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Patterns Tracker')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSleepLogSection(),
              const SizedBox(height: 20),
              _buildSleepAnalytics(),
              const SizedBox(height: 20),
              _buildSleepTrendsVisualization(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSleepLog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildSleepLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep Log',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sleepLog.length,
          itemBuilder: (context, index) {
            final log = _sleepLog[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.nights_stay, color: Colors.blue),
                title: Text(
                  'Date: ${log['date']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Bedtime: ${log['bedtime']}\nWake-up: ${log['waketime']}\nNotes: ${log['notes']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSleepLog(log['id']),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSleepAnalytics() {
    if (_sleepLog.isEmpty) {
      return const Text('No sleep data available to analyze.');
    }

    final totalSleep = _sleepLog.fold<double>(
      0,
          (sum, log) => sum + log['duration'],
    );
    final averageSleep = totalSleep / _sleepLog.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep Analytics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text('Total Sleep Recorded: ${totalSleep.toStringAsFixed(1)} hrs'),
        Text('Average Sleep Duration: ${averageSleep.toStringAsFixed(1)} hrs'),
      ],
    );
  }

  Widget _buildSleepTrendsVisualization() {
    if (_sleepLog.isEmpty) {
      return const Text('No sleep data available to visualize.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep Trends',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            title: ChartTitle(text: 'Sleep Duration Over Time'),
            series: <CartesianSeries>[
              LineSeries<Map<String, dynamic>, String>(
                dataSource: _sleepLog,
                xValueMapper: (log, _) => log['date'],
                yValueMapper: (log, _) => log['duration'],
                name: 'Sleep Duration (hrs)',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

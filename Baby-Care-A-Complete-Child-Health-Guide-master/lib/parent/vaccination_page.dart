import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class VaccinationPage extends StatefulWidget {
  const VaccinationPage({super.key});

  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  DateTime _dob = DateTime.now();
  List<Map<String, dynamic>> vaccinations = [];
  final _vaccinationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _hasLoadedData = false;

  final Map<String, Map<String, dynamic>> mandatoryVaccines = {
    'Birth': {
      'BCG': 'Prevents Tuberculosis',
      'OPV-0': 'Oral Polio Vaccine',
      'Hep B1': 'Hepatitis B first dose'
    },
    '6 Weeks': {
      'DTwP/DTaP-1': 'Diphtheria, Tetanus, Pertussis',
      'IPV-1': 'Inactivated Polio Vaccine',
      'Hep B2': 'Hepatitis B second dose',
      'Hib-1': 'Haemophilus Influenzae type b',
      'PCV-1': 'Pneumococcal Conjugate Vaccine',
      'Rota-1': 'Rotavirus vaccine'
    },
    '10 Weeks': {
      'DTwP/DTaP-2': 'Second dose',
      'IPV-2': 'Second dose',
      'Hib-2': 'Second dose',
      'PCV-2': 'Second dose',
      'Rota-2': 'Second dose'
    }
  };

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadUserData();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Handle notification tapped logic here
      },
    );
  }

  Future<void> _loadUserData() async {
    if (_hasLoadedData) return;
    setState(() => _isLoading = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('dob')) {
        setState(() {
          _dob = DateTime.parse(userDoc.data()!['dob']);
          _hasLoadedData = true;
        });
        await _loadVaccinations();
      }
    } catch (e) {
      if (!_hasLoadedData) {
        _showSnackBar('Error loading data');
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadVaccinations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vaccination_schedule')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('scheduledDate', descending: false)
        .get();

    setState(() {
      vaccinations = snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    });
  }

  Future<void> _scheduleNotification(String title, DateTime scheduleDate) async {
    final scheduledNotificationDateTime = scheduleDate.subtract(const Duration(days: 1));

    if (scheduledNotificationDateTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        vaccinations.length,
        'Vaccination Reminder',
        'Tomorrow: $title',
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'vaccination_channel',
            'Vaccination Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void _suggestMandatoryVaccinations() {
    final age = DateTime.now().difference(_dob).inDays;

    if (age <= 1) {
      _suggestVaccinesForAge('Birth');
    } else if (age >= 42 && age < 70) {
      _suggestVaccinesForAge('6 Weeks');
    } else if (age >= 70) {
      _suggestVaccinesForAge('10 Weeks');
    }
  }

  void _suggestVaccinesForAge(String ageGroup) {
    final vaccines = mandatoryVaccines[ageGroup]!;
    vaccines.forEach((name, description) {
      if (!vaccinations.any((v) => v['name'] == name)) {
        DateTime suggestedDate;
        switch (ageGroup) {
          case 'Birth':
            suggestedDate = _dob;
            break;
          case '6 Weeks':
            suggestedDate = _dob.add(const Duration(days: 42));
            break;
          case '10 Weeks':
            suggestedDate = _dob.add(const Duration(days: 70));
            break;
          default:
            suggestedDate = DateTime.now();
        }
        _addVaccination(name, description, true, suggestedDate);
      }
    });
  }

  Future<void> _addVaccination(String name, String description, bool isMandatory, [DateTime? scheduledDate]) async {
    try {
      final vaccination = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'name': name,
        'description': description,
        'scheduledDate': (scheduledDate ?? _selectedDate).toIso8601String(),
        'isMandatory': isMandatory,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('vaccination_schedule')
          .add(vaccination);

      setState(() {
        vaccinations.add({...vaccination, 'id': docRef.id});
      });

      await _scheduleNotification(name, scheduledDate ?? _selectedDate);
      _showSnackBar('Vaccination scheduled successfully');
    } catch (e) {
      _showSnackBar('Error scheduling vaccination');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _dob) {
      setState(() => _dob = picked);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'dob': picked.toIso8601String()}, SetOptions(merge: true));

      _suggestMandatoryVaccinations();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  void _showVaccinationOptions(Map<String, dynamic> vaccination) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Mark as Complete'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance
                      .collection('vaccination_schedule')
                      .doc(vaccination['id'])
                      .update({'status': 'completed'});
                  await _loadVaccinations();
                  _showSnackBar('Vaccination marked as complete');
                } catch (e) {
                  _showSnackBar('Error updating vaccination status');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editVaccination(vaccination);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance
                      .collection('vaccination_schedule')
                      .doc(vaccination['id'])
                      .delete();
                  await _loadVaccinations();
                  _showSnackBar('Vaccination deleted successfully');
                } catch (e) {
                  _showSnackBar('Error deleting vaccination');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editVaccination(Map<String, dynamic> vaccination) async {
    _vaccinationController.text = vaccination['name'];
    _descriptionController.text = vaccination['description'] ?? '';
    setState(() {
      _selectedDate = DateTime.parse(vaccination['scheduledDate']);
    });

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Vaccination'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vaccinationController,
                decoration: const InputDecoration(
                  labelText: 'Vaccination Name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Schedule Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (_vaccinationController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('vaccination_schedule')
                      .doc(vaccination['id'])
                      .update({
                    'name': _vaccinationController.text,
                    'description': _descriptionController.text,
                    'scheduledDate': _selectedDate.toIso8601String(),
                    'updatedAt': DateTime.now().toIso8601String(),
                  });

                  await flutterLocalNotificationsPlugin.cancel(vaccinations.indexWhere((v) => v['id'] == vaccination['id']));
                  await _scheduleNotification(_vaccinationController.text, _selectedDate);

                  await _loadVaccinations();
                  _showSnackBar('Vaccination updated successfully');
                } catch (e) {
                  _showSnackBar('Error updating vaccination');
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddVaccinationDialog() async {
    _vaccinationController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Vaccination'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vaccinationController,
                decoration: const InputDecoration(
                  labelText: 'Vaccination Name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Schedule Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_vaccinationController.text.isNotEmpty) {
                _addVaccination(
                  _vaccinationController.text,
                  _descriptionController.text,
                  false,
                );
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Vaccination Schedule'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDOB(context),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
            children: [
        Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text(
          'Date of Birth:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          DateFormat('MMM dd, yyyy').format(_dob),
          style: Theme.of(context).textTheme.titleMedium,
        ),
          ],
        ),
        ),
              Expanded(
                child: ListView.builder(
                  itemCount: vaccinations.length,
                  itemBuilder: (context, index) {
                    final vaccination = vaccinations[index];
                    final scheduledDate = DateTime.parse(vaccination['scheduledDate']);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          vaccination['isMandatory'] == true
                              ? Icons.warning
                              : Icons.event,
                          color: vaccination['isMandatory'] == true
                              ? Colors.red
                              : Colors.blue,
                        ),
                        title: Text(vaccination['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vaccination['description'] ?? ''),
                            Text(
                              'Scheduled for: ${DateFormat('MMM dd, yyyy').format(scheduledDate)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Status: ${vaccination['status']}',
                              style: TextStyle(
                                color: vaccination['status'] == 'completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showVaccinationOptions(vaccination),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVaccinationDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _vaccinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class UpcomingVaccinationsPage extends StatefulWidget {
  const UpcomingVaccinationsPage({super.key});

  @override
  _UpcomingVaccinationsPageState createState() => _UpcomingVaccinationsPageState();
}

class _UpcomingVaccinationsPageState extends State<UpcomingVaccinationsPage> {
  List<Map<String, dynamic>> upcomingVaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingVaccinations();
  }

  Future<void> _loadUpcomingVaccinations() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final snapshot = await FirebaseFirestore.instance
          .collection('vaccination_schedule')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('status', isEqualTo: 'pending')
          .orderBy('scheduledDate')
          .get();

      setState(() {
        upcomingVaccinations = snapshot.docs.map((doc) => {
          ...doc.data(),
          'id': doc.id,
          'isUpcoming': DateTime.parse(doc.data()['scheduledDate'])
              .isBefore(now.add(const Duration(days: 7))),
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading upcoming vaccinations')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Vaccinations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : upcomingVaccinations.isEmpty
          ? const Center(
        child: Text('No upcoming vaccinations scheduled'),
      )
          : ListView.builder(
        itemCount: upcomingVaccinations.length,
        itemBuilder: (context, index) {
          final vaccination = upcomingVaccinations[index];
          final scheduledDate = DateTime.parse(vaccination['scheduledDate']);
          final isToday = scheduledDate.day == DateTime.now().day;
          final isTomorrow = scheduledDate.day == DateTime.now().add(const Duration(days: 1)).day;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: vaccination['isUpcoming'] ? Colors.blue.shade50 : null,
            child: ListTile(
              leading: Icon(
                vaccination['isMandatory'] == true
                    ? Icons.warning
                    : Icons.event,
                color: vaccination['isMandatory'] == true
                    ? Colors.red
                    : Colors.blue,
              ),
              title: Text(
                vaccination['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vaccination['description'] ?? ''),
                  Text(
                    'Scheduled for: ${isToday ? "Today" : isTomorrow ? "Tomorrow" : DateFormat('MMM dd, yyyy').format(scheduledDate)}',
                    style: TextStyle(
                      color: vaccination['isUpcoming']
                          ? Colors.red
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUpcomingVaccinations,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
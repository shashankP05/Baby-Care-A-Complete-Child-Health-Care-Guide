// doctor_homepage.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'appointments_page.dart';
import 'add_patient_page.dart';
import 'lab_reports_page.dart';
import 'prescriptions_page.dart';
import 'emergency_page.dart';
import 'patient_records_page.dart';
import 'growth_charts_page.dart';
import 'vaccination_records_page.dart';
import 'medical_guidelines_page.dart';
import 'drug_database_page.dart';
import 'research_papers_page.dart';
import 'clinical_tools_page.dart';
import 'notifications_page.dart';
import 'add_appointment_page.dart';
import 'todays_patients_page.dart';
import 'pending_reports_page.dart';
import 'critical_cases_page.dart';
import 'completed_cases_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class HomePage extends StatefulWidget {
  final String name;
  const HomePage({super.key, required this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'patientName': 'Sarah Johnson',
      'age': '5',
      'time': '09:30 AM',
      'type': 'Regular Checkup',
      'status': 'Confirmed'
    },
    {
      'patientName': 'Mike Peters',
      'age': '3',
      'time': '10:45 AM',
      'type': 'Vaccination',
      'status': 'Pending'
    },
    {
      'patientName': 'Emma Davis',
      'age': '7',
      'time': '02:15 PM',
      'type': 'Follow-up',
      'status': 'Confirmed'
    },
  ];

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStats(),
              const SizedBox(height: 20),
              _buildSectionTitle('Today\'s Schedule'),
              _buildAppointmentsList(),
              const SizedBox(height: 20),
              _buildSectionTitle('Quick Actions'),
              _buildQuickActions(),
              const SizedBox(height: 20),
              // _buildSectionTitle('Patient Management'),
              // _buildPatientManagement(),
              const SizedBox(height: 20),
              _buildSectionTitle('Medical Resources'),
              _buildMedicalResources(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToPage(context,  AddAppointmentPage()),
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              widget.name[0],
              style: const TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dr. ${widget.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Pediatrician',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Patients', '12', Icons.people, Colors.blue,
             TodaysPatientsPage()),
        _buildStatCard('Appointments', '5', Icons.description, Colors.orange,
            AppointmentsPage()),
        // _buildStatCard('Critical Cases', '2', Icons.warning, Colors.red,
        //      CriticalCasesPage()),
        // _buildStatCard('Completed', '8', Icons.check_circle, Colors.green,
        //      CompletedCasesPage()),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => _navigateToPage(context, page),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .orderBy('schedule_date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No upcoming appointments.'));
        }

        final appointments = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        final emergencyAppointments = appointments.where((appt) => appt['is_emergency'] == true).toList();
        final nonEmergencyAppointments = appointments.where((appt) => appt['is_emergency'] != true).toList();

        List<Map<String, dynamic>> displayedAppointments = [];
        if (emergencyAppointments.isNotEmpty) {
          displayedAppointments.add(emergencyAppointments.first);
        }
        if (displayedAppointments.length < 2 && nonEmergencyAppointments.isNotEmpty) {
          displayedAppointments.add(nonEmergencyAppointments.first);
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedAppointments.length,
          itemBuilder: (context, index) {
            final appointment = displayedAppointments[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: appointment['is_emergency'] ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  child: Icon(
                    appointment['is_emergency'] ? Icons.warning : Icons.calendar_today,
                    color: appointment['is_emergency'] ? Colors.red : Colors.blue,
                  ),
                ),
                title: Text(
                  appointment['child_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doctor: ${appointment['doctor']}'),
                    Text('Concern: ${appointment['concern']}'),
                    Text('${DateFormat.yMMMd().format((appointment['schedule_date'] as Timestamp).toDate())} at ${appointment['schedule_time']}'),
                    Text('Type: ${appointment['consultation_type']}'),
                  ],
                ),
                trailing: appointment['is_emergency']
                    ? Chip(
                  label: Text('EMERGENCY', style: TextStyle(color: Colors.red)),
                  backgroundColor: Colors.red[100],
                )
                    : Chip(
                  label: Text('Upcoming', style: TextStyle(color: Colors.blue)),
                  backgroundColor: Colors.blue[100],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionButton('Add Patient', Icons.person_add, Colors.blue,
             AddPatientPage()),
        _buildActionButton('Vaccination Records', Icons.vaccines, Colors.teal,
            VaccinationRecordsPage()),
        _buildActionButton('Prescriptions', Icons.medical_services, Colors.green,
             PrescriptionsPage()),
        _buildActionButton(
            'Emergency', Icons.emergency, Colors.red,  EmergencyPage()),
      ],
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, Widget page) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToPage(context, page),
        icon: Icon(icon, color: Colors.white),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPatientManagement() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // _buildManagementTile(
          //   'Patient Records',
          //   Icons.folder,
          //   Colors.blue,
          //   'Access and manage patient histories',
          //    PatientRecordsPage(),
          // ),
          // _buildManagementTile(
          //   'Growth Charts',
          //   Icons.show_chart,
          //   Colors.green,
          //   'Track patient growth metrics',
          //    GrowthChartsPage(),
          // ),
          // _buildManagementTile(
          //   'Vaccination Records',
          //   Icons.vaccines,
          //   Colors.orange,
          //   'Manage immunization schedules',
          //    VaccinationRecordsPage(),
         // ),
        ],
      ),
    );
  }

  Widget _buildManagementTile(String title, IconData icon, Color color,
      String subtitle, Widget page) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _navigateToPage(context, page),
    );
  }

  Widget _buildMedicalResources() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildResourceCard(
          'Medical Guidelines',
          Icons.book,
          Colors.purple,
          'Latest treatment protocols',
           MedicalGuidelinesPage(),
        ),
        _buildResourceCard(
          'Drug Database',
          Icons.medication,
          Colors.teal,
          'Comprehensive medicine info',
           DrugDatabasePage(),
        ),
        _buildResourceCard(
          'Research Papers',
          Icons.article,
          Colors.indigo,
          'Recent medical studies',
           ResearchPapersPage(),
        ),
        _buildResourceCard(
          'Clinical Tools',
          Icons.calculate,
          Colors.brown,
          'Medical calculators & tools',
           ClinicalToolsPage(),
        ),
      ],
    );
  }

  Widget _buildResourceCard(String title, IconData icon, Color color,
      String description, Widget page) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToPage(context, page),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
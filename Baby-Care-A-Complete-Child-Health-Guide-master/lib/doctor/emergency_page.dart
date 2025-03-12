import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.report),
            onPressed: () {
              // Navigate to Emergency Case Reporting Page
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEmergencyAlertCard(context),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildEmergencyContactCard(
                      'Hospital Reception', '0123456789', Icons.local_hospital),
                  _buildEmergencyContactCard(
                      'Ambulance Service', '102', Icons.local_taxi),
                  _buildEmergencyContactCard(
                      'Blood Bank', '9876543210', Icons.bloodtype),
                  _buildEmergencyContactCard(
                      'Medical Supplier', '8765432109', Icons.medical_services),
                  _buildEmergencyContactCard(
                      'Pharmacy', '7654321098', Icons.local_pharmacy),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add functionality to report emergency cases
        },
        backgroundColor: Colors.redAccent,
        icon: Icon(Icons.warning, color: Colors.white),
        label: Text('Report Emergency'),
      ),
    );
  }

  Widget _buildEmergencyContactCard(String name, String number, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(number),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(number),
            ),
            IconButton(
              icon: Icon(Icons.message, color: Colors.blue),
              onPressed: () => _sendSMS(number),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyAlertCard(BuildContext context) {
    return Card(
      color: Colors.redAccent.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
            Expanded(
              child: Text(
                'Emergency Alert! Quick access to critical contacts.',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to emergency response actions
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: Text('Respond', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  // Function to make a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  // Function to send an SMS
  void _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }
}

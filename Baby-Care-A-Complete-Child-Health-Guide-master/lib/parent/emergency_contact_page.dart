import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class EmergencyContact {
  final String name;
  final String number;
  final String role;
  final IconData icon;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.role,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'role': role,
      'icon': icon.codePoint,
    };
  }
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    // Define a map to convert string values to Icons
    Map<String, IconData> iconMap = {
      'call': Icons.call,
      'message': Icons.message,
      'email': Icons.email,
      // Add other icons as needed
    };

    return EmergencyContact(
      name: map['name'],
      number: map['number'],
      role: map['role'],
      icon: iconMap[map['icon']] ?? Icons.error, // Default to error icon if not found
    );
  }

}

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final List<EmergencyContact> emergencyContacts = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final QuerySnapshot snapshot = await _firestore.collection('emergencyContacts').get();
    setState(() {
      emergencyContacts.addAll(snapshot.docs.map((doc) => EmergencyContact.fromMap(doc.data() as Map<String, dynamic>)));
    });
  }

  Future<void> _addContactFromContactBook() async {
    final Contact? contact = await ContactsService.openDeviceContactPicker();
    if (contact != null) {
      final newContact = EmergencyContact(
        name: contact.displayName ?? 'Unknown',
        number: contact.phones?.isNotEmpty == true ? contact.phones!.first.value ?? '' : '',
        role: 'Family',
        icon: Icons.person,
      );

      await _firestore.collection('emergencyContacts').add(newContact.toMap());
      setState(() {
        emergencyContacts.add(newContact);
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmergencyButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(contact.icon, color: Colors.red, size: 24),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              contact.role,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contact.number,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: Colors.red),
          onPressed: () => _makePhoneCall(contact.number),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Emergency Information'),
                  content: const Text(
                    'This page provides quick access to emergency services. '
                        'In case of a serious emergency, immediately dial 108. '
                        'Make sure to stay calm and provide clear information about your emergency.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'In case of emergency, please dial 108 immediately',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildEmergencyButton(
                      title: 'Call\nAmbulance',
                      icon: Icons.local_hospital,
                      color: Colors.red,
                      onPressed: () => _makePhoneCall('108'),
                    ),
                    _buildEmergencyButton(
                      title: 'Call\nPolice',
                      icon: Icons.local_police,
                      color: Colors.blue,
                      onPressed: () => _makePhoneCall('100'),
                    ),
                    _buildEmergencyButton(
                      title: 'Fire\nDepartment',
                      icon: Icons.fire_truck,
                      color: Colors.orange,
                      onPressed: () => _makePhoneCall('112'),
                    ),
                    _buildEmergencyButton(
                      title: 'Poison\nControl',
                      icon: Icons.warning,
                      color: Colors.purple,
                      onPressed: () => _makePhoneCall('1800 116 117'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...emergencyContacts.map(_buildContactCard),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContactFromContactBook,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
      ),
    );
  }
}
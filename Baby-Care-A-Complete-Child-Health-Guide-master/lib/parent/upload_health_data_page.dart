import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadHealthDataPage extends StatefulWidget {
  const UploadHealthDataPage({super.key});

  @override
  State<UploadHealthDataPage> createState() => _UploadHealthDataPageState();
}

class _UploadHealthDataPageState extends State<UploadHealthDataPage> {
  final ImagePicker _picker = ImagePicker();
  File? _medicalReport;
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isSortedAsc = true; // Flag to track sorting order

  // Pick a medical report
  Future<void> _pickMedicalReport() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _medicalReport = File(image.path);
      });
    }
  }

  // Add new health record
  void _addHealthRecord() {
    if (_medicalReport != null) {
      setState(() {
        final newRecord = {
          'report': _medicalReport,
          'timestamp': DateTime.now(),
        };
        _records.add(newRecord);
        _filteredRecords.add(newRecord);
      });
      _medicalReport = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health record added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a report!')),
      );
    }
  }

  // Filter records based on search query
  void _filterRecords(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRecords = _records
          .where((record) => (record['report']?.path.split('/').last ?? '')
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  // Sorting records based on date
  void _sortRecords() {
    setState(() {
      _filteredRecords.sort((a, b) {
        if (_isSortedAsc) {
          return a['timestamp'].compareTo(b['timestamp']);
        } else {
          return b['timestamp'].compareTo(a['timestamp']);
        }
      });
      _isSortedAsc = !_isSortedAsc; // Toggle sorting order
    });
  }

  // Show modal dialog to add a health record
  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Health Record'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickMedicalReport,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Medical Report'),
                ),
                if (_medicalReport != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected file: ${_medicalReport!.path.split('/').last}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _addHealthRecord();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Record'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Health Data'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch(
                context: context,
                delegate: HealthRecordSearchDelegate(records: _filteredRecords),
              );
              if (query != null) {
                _filterRecords(query);
              }
            },
          ),
          IconButton(
            icon: Icon(_isSortedAsc ? Icons.sort : Icons.sort_outlined),
            onPressed: _sortRecords,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Removed the button for adding new record inside the page
                    const SizedBox(height: 16),
                    if (_filteredRecords.isEmpty)
                      const Text('No records available.')
                    else
                      Column(
                        children: _filteredRecords.map((record) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(Icons.file_present),
                              title: Text('Report: ${record['report']?.path.split('/').last}'),
                              subtitle: Text('Date: ${record['timestamp']}'),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add New Health Record',
      ),
    );
  }
}

class HealthRecordSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, dynamic>> records;

  HealthRecordSearchDelegate({required this.records});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search and return null
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = records
        .where((record) =>
        (record['report']?.path.split('/').last ?? '')
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results.map((record) {
        return ListTile(
          title: Text('Report: ${record['report']?.path.split('/').last}'),
          subtitle: Text('Date: ${record['timestamp']}'),
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

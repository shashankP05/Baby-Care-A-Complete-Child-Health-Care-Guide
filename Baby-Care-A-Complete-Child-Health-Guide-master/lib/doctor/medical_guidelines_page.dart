import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalGuidelinesPage extends StatefulWidget {
  @override
  _MedicalGuidelinesPageState createState() => _MedicalGuidelinesPageState();
}

class _MedicalGuidelinesPageState extends State<MedicalGuidelinesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<DocumentSnapshot> _guidelines = [];
  List<DocumentSnapshot> _filteredGuidelines = [];

  @override
  void initState() {
    super.initState();
    _fetchGuidelines();
  }

  void _fetchGuidelines() {
    FirebaseFirestore.instance.collection('guidelines').snapshots().listen((snapshot) {
      if (mounted) {
        setState(() {
          _guidelines = snapshot.docs;
          _filteredGuidelines = List.from(_guidelines);
        });
      }
    });
  }

  void _filterGuidelines(String query) {
    setState(() {
      _filteredGuidelines = _guidelines.where((doc) {
        String title = doc['title'].toString().toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _addGuideline() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty) {
      await FirebaseFirestore.instance.collection('guidelines').add({
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear form fields
      _titleController.clear();
      _descriptionController.clear();

      // Close the dialog safely
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showAddGuidelineDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents accidental closure
      builder: (context) => AlertDialog(
        title: Text('Add Medical Guideline'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addGuideline,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Guidelines'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            Expanded(
              child: _filteredGuidelines.isEmpty
                  ? Center(child: Text('No guidelines available'))
                  : ListView.builder(
                itemCount: _filteredGuidelines.length,
                itemBuilder: (context, index) {
                  var doc = _filteredGuidelines[index];
                  return _buildGuidelineCard(doc);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGuidelineDialog,
        backgroundColor: Colors.blueAccent,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Guideline'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterGuidelines,
      decoration: InputDecoration(
        hintText: "Search guidelines...",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildGuidelineCard(DocumentSnapshot doc) {
    String title = doc['title'];
    String description = doc['description'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        leading: Icon(Icons.menu_book, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(description, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}

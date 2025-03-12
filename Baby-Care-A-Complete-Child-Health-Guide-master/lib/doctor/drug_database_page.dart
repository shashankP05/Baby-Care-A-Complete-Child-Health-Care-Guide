import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DrugDatabasePage extends StatefulWidget {
  @override
  _DrugDatabasePageState createState() => _DrugDatabasePageState();
}

class _DrugDatabasePageState extends State<DrugDatabasePage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _drugs = [];
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _fetchDrugs(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.fda.gov/drug/label.json?search=$query&limit=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _drugs = data['results'] ?? [];
        });
      } else {
        setState(() {
          _hasError = true;
          _drugs = [];
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _drugs = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drug Database'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _hasError
                  ? Center(child: Text('Error fetching data. Try again.'))
                  : _drugs.isEmpty
                  ? Center(child: Text('No drugs found. Try a different search.'))
                  : ListView.builder(
                itemCount: _drugs.length,
                itemBuilder: (context, index) {
                  return _buildDrugCard(_drugs[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onSubmitted: _fetchDrugs,
      decoration: InputDecoration(
        hintText: "Search for a drug...",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDrugCard(dynamic drug) {
    String name = drug['openfda']?['brand_name']?.join(', ') ?? 'Unknown Drug';
    String manufacturer = drug['openfda']?['manufacturer_name']?.join(', ') ?? 'Unknown Manufacturer';
    String purpose = drug['purpose'] != null ? drug['purpose'][0] : 'No information available';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        leading: Icon(Icons.medication, color: Colors.teal),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(manufacturer),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Purpose: $purpose", style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}

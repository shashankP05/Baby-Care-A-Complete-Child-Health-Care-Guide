import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResearchPapersPage extends StatefulWidget {
  @override
  _ResearchPapersPageState createState() => _ResearchPapersPageState();
}

class _ResearchPapersPageState extends State<ResearchPapersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _papers = [];
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _fetchResearchPapers(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.openalex.org/works?search=$query&per-page=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _papers = data['results'] ?? [];
        });
      } else {
        setState(() {
          _hasError = true;
          _papers = [];
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _papers = [];
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
        title: Text('Research Papers'),
        backgroundColor: Colors.deepPurple,
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
                  : _papers.isEmpty
                  ? Center(child: Text('No papers found. Try a different search.'))
                  : ListView.builder(
                itemCount: _papers.length,
                itemBuilder: (context, index) {
                  return _buildPaperCard(_papers[index]);
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
      onSubmitted: _fetchResearchPapers,
      decoration: InputDecoration(
        hintText: "Search for research papers...",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPaperCard(dynamic paper) {
    String title = paper['title'] ?? 'Unknown Title';
    String authors = (paper['authorships'] as List?)?.map((a) => a['author']['display_name']).join(', ') ?? 'Unknown Authors';
    String abstract = paper['abstract_inverted_index'] != null ? paper['abstract_inverted_index'].keys.join(' ') : 'No abstract available';
    String url = paper['doi'] != null ? 'https://doi.org/${paper['doi']}' : '#';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        leading: Icon(Icons.article, color: Colors.deepPurple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(authors),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(abstract, style: TextStyle(color: Colors.grey.shade700)),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Open paper link
                },
                icon: Icon(Icons.open_in_browser, color: Colors.deepPurple),
                label: Text('Read Paper'),
              ),
              IconButton(
                icon: Icon(Icons.share, color: Colors.deepPurple),
                onPressed: () {
                  // Share research paper link
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

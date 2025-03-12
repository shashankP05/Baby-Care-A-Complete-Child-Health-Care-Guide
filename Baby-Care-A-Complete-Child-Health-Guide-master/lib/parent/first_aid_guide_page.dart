import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'emergency_contact_page.dart';
import 'package:http/http.dart' as http; // Import http for API calls
import 'dart:convert'; // For JSON decoding

class FirstAidGuidePage extends StatefulWidget {
  const FirstAidGuidePage({Key? key}) : super(key: key);

  @override
  _FirstAidGuidePageState createState() => _FirstAidGuidePageState();
}

class _FirstAidGuidePageState extends State<FirstAidGuidePage> {
  final List<Map<String, dynamic>> _firstAidTopics = [
    {
      'icon': Icons.local_fire_department,
      'title': 'Burns',
      'content': '1. Cool the burn under running water for at least 10 minutes.\n'
          '2. Cover the burn with a sterile, non-stick bandage.\n'
          '3. Avoid applying creams or popping blisters.',
      'resources': [
        'https://www.webmd.com/first-aid/guide/burns',
        'https://www.youtube.com/watch?v=kpqWzXBcNNI'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.cut,
      'title': 'Cuts and Wounds',
      'content': '1. Wash the wound with clean water to remove dirt.\n'
          '2. Apply pressure to stop bleeding.\n'
          '3. Cover with a sterile bandage.',
      'resources': [
        'https://www.mayoclinic.org/first-aid/first-aid-cuts-and-scrapes/faq-20383779',
        'https://www.youtube.com/watch?v=JppzZqBKTzY'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.warning,
      'title': 'Choking',
      'content': '1. Encourage the person to cough if possible.\n'
          '2. Perform back blows and abdominal thrusts if needed.\n'
          '3. Seek emergency help if the airway remains blocked.',
      'resources': [
        'https://www.redcross.org/first-aid/choking.html',
        'https://www.youtube.com/watch?v=1ASGybCm7os'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.thermostat,
      'title': 'Fever',
      'content': '1. Keep the person hydrated.\n'
          '2. Administer fever-reducing medication as recommended.\n'
          '3. Seek medical help if the fever persists or is very high.',
      'resources': [
        'https://www.cdc.gov/flu/treatment/index.html',
        'https://www.youtube.com/watch?v=xwPclGsA7vQ'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.airline_seat_recline_normal,
      'title': 'Head Injuries',
      'content': '1. Ensure the person remains still.\n'
          '2. Apply a cold pack to reduce swelling.\n'
          '3. Seek immediate medical attention.',
      'resources': [
        'https://www.mayoclinic.org/first-aid/first-aid-head-injuries/faq-20383780',
        'https://www.youtube.com/watch?v=mttz3dOtF54'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.access_alarm,
      'title': 'Heart Attack',
      'content': '1. Call emergency services immediately.\n'
          '2. Keep the person calm and help them rest.\n'
          '3. If trained, perform CPR.',
      'resources': [
        'https://www.heart.org/en/health-topics/heart-attack',
        'https://www.youtube.com/watch?v=G4dZFL94Eo8'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.ac_unit,
      'title': 'Hypothermia',
      'content': '1. Move the person to a warm environment.\n'
          '2. Remove wet clothing and wrap them in blankets.\n'
          '3. Seek medical attention if symptoms persist.',
      'resources': [
        'https://www.cdc.gov/disasters/winter/duringstorm/hypothermia.html',
        'https://www.youtube.com/watch?v=Fb9pAHv6KcM'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.face,
      'title': 'Allergic Reaction',
      'content': '1. Administer antihistamines or an epinephrine injection.\n'
          '2. Seek medical help if necessary.\n'
          '3. Keep the person calm and monitor breathing.',
      'resources': [
        'https://www.webmd.com/allergies/first-aid-for-allergic-reactions',
        'https://www.youtube.com/watch?v=w7aw1ih-TLo'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.child_care,
      'title': 'Poisoning',
      'content': '1. Call poison control immediately.\n'
          '2. Do not induce vomiting unless directed.\n'
          '3. Provide the substance details if possible.',
      'resources': [
        'https://www.poison.org/articles/first-aid-for-poisoning',
        'https://www.youtube.com/watch?v=s3p8tP0g7gY'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.warning,
      'title': 'Severe Bleeding',
      'content': '1. Apply direct pressure to the wound.\n'
          '2. Raise the leg if possible.\n'
          '3. Seek immediate medical help.',
      'resources': [
        'https://www.redcross.org/first-aid/bleeding.html',
        'https://www.youtube.com/watch?v=1sbPswfkjMo'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.fastfood,
      'title': 'Food Allergies',
      'content': '1. Avoid known allergens.\n'
          '2. Use an epinephrine auto-injector if necessary.\n'
          '3. Seek medical help if breathing is affected.',
      'resources': [
        'https://www.cdc.gov/foodborneburden/2011-foodborne-estimates.html',
        'https://www.youtube.com/watch?v=IHjPbkkFwWw'
      ],
      'favorite': false,
    },
    {
      'icon': Icons.accessibility_new,
      'title': 'Heatstroke',
      'content': '1. Move the person to a cooler place.\n'
          '2. Apply cold packs to the body.\n'
          '3. Seek immediate medical help.',
      'resources': [
        'https://www.cdc.gov/niosh/topics/heatstress/',
        'https://www.youtube.com/watch?v=8PssI-QWc80'
      ],
      'favorite': false,
    },
  ];

  String _searchQuery = '';
  String _wikipediaSearchResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Aid Guide'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          ..._firstAidTopics
              .where((topic) =>
              topic['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
              .map((topic) => _FirstAidTile(
            icon: topic['icon'],
            title: topic['title'],
            content: topic['content'],
            resources: topic['resources'],
            favorite: topic['favorite'],
            onFavoriteToggle: () {
              setState(() {
                topic['favorite'] = !topic['favorite'];
              });
            },
          ))
              .toList(),
          if (_wikipediaSearchResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ' Search Result:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _wikipediaSearchResult,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _navigateToEmergencyContactPage(),
        child: const Icon(Icons.phone),
      ),
    );
  }

  void _navigateToEmergencyContactPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyPage()),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Topics'),
          content: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(hintText: 'Enter a topic name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _searchWikipedia(_searchQuery);
              },
              child: const Text('Search '),
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchWikipedia(String query) async {
    if (query.isEmpty) return;

    final encodedQuery = Uri.encodeComponent(query); // Encode query for spaces
    final url =
        'https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=$encodedQuery';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final searchResults = data['query']['search'];

      if (searchResults.isNotEmpty) {
        final snippet = searchResults[0]['snippet'];
        // Remove HTML tags from the snippet
        final cleanSnippet = snippet.replaceAll(RegExp(r'<[^>]*>'), '');
        setState(() {
          _wikipediaSearchResult = cleanSnippet;
        });
      } else {
        setState(() {
          _wikipediaSearchResult = 'No results found.';
        });
      }
    } else {
      setState(() {
        _wikipediaSearchResult = 'Failed to load data.';
      });
    }
  }
}

class _FirstAidTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final List<String> resources;
  final bool favorite;
  final VoidCallback onFavoriteToggle;

  const _FirstAidTile({
    required this.icon,
    required this.title,
    required this.content,
    required this.resources,
    required this.favorite,
    required this.onFavoriteToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.green),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                color: favorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Helpful Resources:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                for (var resource in resources)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: GestureDetector(
                      onTap: () => _openLink(context, resource),
                      child: Text(
                        resource,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openLink(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the link: $url';
    }
  }
}
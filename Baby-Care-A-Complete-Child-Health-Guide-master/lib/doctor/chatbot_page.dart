import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final String _apiKey = 'Your-Gemini-API-Key';

  // Function to get user name from Firebase
  Future<String> _getUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return 'Doctor'; // Default name if not logged in
    }

    // Fetch the user's name from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    if (userDoc.exists) {
      return userDoc['name'] ?? 'Doctor'; // Return the user's name or 'Doctor' if name is missing
    } else {
      return 'Doctor'; // Return default name if user data not found
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;
    setState(() {
      _messages.add('Doctor: $userMessage');
    });

    String botResponse = await _getChatbotResponse(userMessage);
    setState(() {
      _messages.add('Assistant: $botResponse');
      _controller.clear();
    });
  }

  Future<String> _getChatbotResponse(String question) async {
    final response = await http.post(
      Uri.parse('https://your-chatbot-api-endpoint.com'),
      headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
      body: json.encode({'query': question}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['response'] ?? 'I couldn’t process that request.';
    } else {
      return 'Error connecting to the chatbot service.';
    }
  }

  @override
  void initState() {
    super.initState();
    // Removed navigation to HomePage from here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Doctor AI Assistant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSuggestedQuestions(),
                    const SizedBox(height: 24),
                    _buildConversation(),
                  ],
                ),
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Questions:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          'What are the best treatments for common illnesses?',
          'How can I differentiate between viral and bacterial infections?',
          'What are the latest medical guidelines for pediatrics?',
        ].map((question) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(
              question,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ))
      ],
    );
  }

  Widget _buildConversation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _messages.map((msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: msg.startsWith('Doctor:')
                ? Colors.deepPurple.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg,
            style: TextStyle(
              fontSize: 16,
              color: msg.startsWith('Doctor:')
                  ? Colors.deepPurple.shade800
                  : Colors.black87,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

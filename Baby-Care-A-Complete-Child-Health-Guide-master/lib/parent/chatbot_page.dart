import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'community_page.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final String _apiKey = 'Your-Gemini-API-Key';

  // List of health-related keywords to validate questions
  final List<String> _healthKeywords = [
    'health',
    'medical',
    'doctor',
    'hospital',
    'symptom',
    'treatment',
    'medicine',
    'disease',
    'condition',
    'pain',
    'vaccine',
    'vaccination',
    'fever',
    'cold',
    'flu',
    'cough',
    'allergy',
    'diet',
    'nutrition',
    'growth',
    'development',
    'milestone',
    'pediatrician',
    'emergency',
    'infection',
    'injury',
    'care',
    'wellness',
    'prescription',
    'medication',
    'asthma',
    'bronchitis',
    'pneumonia',
    'diarrhea',
    'dehydration',
    'malnutrition',
    'anemia',
    'measles',
    'mumps',
    'chickenpox',
    'rubella',
    'whooping cough',
    'ear infection',
    'tonsillitis',
    'hand-foot-mouth disease',
    'RSV',
    'eczema',
    'rickets',
    'jaundice',
    'colic',
    'autism',
    'ADHD',
    'congenital disorders',
    'neonatal care',
    'newborn screening',
    'premature birth',
    'SIDS',
    'childhood obesity',
    'dental care',
    'oral health',
    'mental health',
    'behavioral health',
    'speech delay',
    'immunization',
    'dermatitis',
    'scabies',
    'ringworm',
    'tuberculosis',
    'HIV/AIDS',
    'cystic fibrosis',
    'growth hormone',
    'lead poisoning',
    'thyroid disorder',
    'retinopathy',
    'gastroenteritis',
    'stomach virus',
    'eczema',
    'psoriasis',
    'seborrheic dermatitis',
    'uticaria',
    'allergic rhinitis',
    'sickle cell anemia',
    'hemophilia',
    'epilepsy',
    'seizures',
    'cerebral palsy',
    'hydrocephalus',
    'spina bifida',
    'palsy',
    'muscular dystrophy',
    'down syndrome',
    'genetic disorders',
    'neuroblastoma',
    'leukemia',
    'lymphoma',
    'brain tumor',
    'osteogenesis imperfecta',
    'scoliosis',
    'arthritis',
    'juvenile arthritis',
    'cavities',
    'tooth decay',
    'childbirth',
    'postpartum care',
    'breastfeeding',
    'infant care',
    'pediatric surgery',
    'pediatric oncology',
    'pediatric cardiology',
    'pediatric nephrology',
    'pediatric pulmonology',
    'pediatric dermatology',
    'child development',
    'behavioral therapy',
    'speech therapy',
    'occupational therapy',
    'physical therapy',
    'sensory processing disorder',
    'hyperactivity',
    'depression',
    'anxiety',
    'mental disorders',
    'child abuse',
    'autism spectrum',
    'sensorial issues',
    'sleep disorder',
    'sleep apnea',
    'night terrors',
    'teething',
    'tooth eruption',
    'swelling',
    'bruising',
    'bacterial infection',
    'viral infection',
    'fungal infection',
    'parasitic infection',
    'wound care',
    'burns',
    'fractures',
    'lacerations',
    'sprains',
    'strains',
    'dislocations',
    'muscle injuries',
    'head injury',
    'contusions',
    'concussion',
    'allergic reaction',
    'anaphylaxis',
    'respiratory distress',
    'asthma attack',
    'allergy test',
    'vaccination schedule',
    'polio vaccine',
    'tetanus',
    'hepatitis B',
    'measles mumps rubella',
    'diphtheria',
    'pertussis',
    'rotavirus',
    'HPV',
    'flu shot',
    'herpes simplex',
    'oral thrush',
    'sinusitis',
    'pediatric checkup',
    'well-child visit',
    'preventive care',
    'early intervention',
    'milestone tracking',
    'baby registry',
    'child health insurance',
    'healthcare provider',
    'urgent care',
    'pediatric clinic',
    'primary care',
    'caregiver',
    'parenting',
    'family health',
    'prevention',
    'well-baby',
    'health education',
    'first aid',
    'emergency response',
    'childcare center',
    'nursery',
    'home care',
    'child protection',
    'health monitoring',
    'genetic testing',
    'immunization records',
    'growth monitoring',
    'birth defects',
    'adoption health',
    'teen health',
    'adolescent care',
    'puberty',
    'self-care',
    'healthy habits',
    'sanitation',
    'hygiene',
    'handwashing',
    'personal care',
    'fitness',
    'exercise',
    'outdoor activity',
    'sports injury',
    'self-esteem',
    'self-care',
    'mental well-being',
    'psychosocial health',
    'special needs',
    'nurturing',
    'rest',
    'parental support',
    'child safety',
    'baby-proofing',
    'sleep hygiene',
    'peaceful parenting'
  ];

  bool _isHealthRelated(String question) {
    question = question.toLowerCase();
    return _healthKeywords
        .any((keyword) => question.contains(keyword.toLowerCase()));
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;

    // Check if the question is health-related
    if (!_isHealthRelated(userMessage)) {
      setState(() {
        _messages.add('User: $userMessage');
        _messages.add(
            'Bot: I can only answer questions related to health and healthcare. Please ask a health-related question.');
        _controller.clear();
      });
      return;
    }

    setState(() {
      _messages.add('User: $userMessage');
    });

    String botResponse = await _getChatbotResponse(userMessage);
    setState(() {
      _messages.add('Bot: $botResponse');
      _controller.clear();
    });
  }

  Future<String> _getChatbotResponse(String question) async {
    final response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent'),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': _apiKey,
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    '''You are a healthcare assistant specializing in child health. 
Only provide information related to health, medical conditions, and healthcare. 
If the question is not related to health or healthcare, politely decline to answer and remind the user to ask health-related questions only.

User question: $question'''
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'Sorry, I couldn\'t process that health-related question. Please try rephrasing it.';
      }
    } else {
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
      return 'Sorry, there was an error processing your health-related question.';
    }
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
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Child Health Assistant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.05),
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
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildSuggestedQuestions(),
                    const SizedBox(height: 24),
                    _buildNavigateButton(context),
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

  // Rest of the widget building methods remain the same, but update the suggested questions
  Widget _buildSuggestedQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Health Questions:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          'What vaccinations does my child need at 6 months?',
          'What are the signs of dehydration in children?',
          'How can I tell if my child has a fever?',
        ]
            .map((question) => Padding(
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
            .toList(),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Welcome to the Child Health Assistant!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'I\'m here to answer your questions about child health, medical concerns, and healthcare guidance.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Other widget methods remain the same
  Widget _buildConversation() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _messages
            .map((msg) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.startsWith('User:')
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg,
                      style: TextStyle(
                        fontSize: 16,
                        color: msg.startsWith('User:')
                            ? Colors.blue.shade800
                            : Colors.black87,
                      ),
                    ),
                  ),
                ))
            .toList(),
      );

  Widget _buildChatInput() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask a health-related question...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      );
  Widget _buildNavigateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommunityPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'View Health Resources',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

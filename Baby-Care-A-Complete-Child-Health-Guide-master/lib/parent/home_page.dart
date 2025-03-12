import 'package:flutter/material.dart';
import 'dart:async';
import 'notifications_page.dart';
import 'disease_detection_page.dart';
import 'vaccination_page.dart';
import 'cognitive_games_page.dart';
import 'growth_tracking_page.dart';
import 'sleep_tracker_page.dart';
import 'behavioral_tips_page.dart';
import 'first_aid_guide_page.dart';
import 'parental_guidance_page.dart';
import 'upload_health_data_page.dart';
import 'pediatric_consultation_page.dart';
import 'medication_management_page.dart';
import 'emergency_contact_page.dart';

class HomePage extends StatefulWidget {
  final String name;

  const HomePage({super.key, required this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  int _currentTipIndex = 0;
  final List<String> _healthTips = [
    "Stay hydrated by drinking at least 8 glasses of water daily.",
    "Ensure your child gets 8-10 hours of sleep each night.",
    "Encourage outdoor activities for physical well-being.",
    "Limit screen time to protect eye health.",
    "Eat a balanced diet rich in fruits and vegetables.",
    "Encourage handwashing to prevent infections.",
    "Teach proper brushing and flossing habits.",
    "Limit sugary snacks to protect dental health.",
    "Ensure vaccinations are up to date.",
    "Encourage deep breathing exercises for stress relief.",
    "Provide a healthy breakfast every morning.",
    "Teach the importance of good posture.",
    "Ensure a quiet and dark sleeping environment.",
    "Encourage drinking milk for strong bones.",
    "Teach kids to cover their mouths when coughing or sneezing.",
    "Ensure they wear helmets while cycling.",
    "Encourage participation in sports or physical activities.",
    "Reduce processed food intake.",
    "Teach kids to identify and express their emotions.",
    "Limit caffeine consumption in children.",
    "Encourage daily reading to boost brain development.",
    "Teach kids to listen to their body's hunger and fullness cues.",
    "Avoid skipping meals to maintain energy levels.",
    "Encourage sharing of feelings to reduce stress.",
    "Promote family meals for better nutrition and bonding.",
    "Encourage spending time in nature for mental health.",
    "Provide whole grains instead of refined grains.",
    "Ensure your child gets regular health check-ups.",
    "Avoid exposing children to secondhand smoke.",
    "Encourage mindful eating habits.",
    "Teach children the importance of gratitude.",
    "Promote healthy snacking with nuts and fruits.",
    "Reduce salt intake to maintain heart health.",
    "Encourage limiting sugary drinks like soda.",
    "Teach proper sun protection with sunscreen and hats.",
    "Model healthy behaviors for children to follow.",
    "Encourage wearing seat belts in vehicles.",
    "Teach children to avoid junk food marketing traps.",
    "Provide nutritious homemade meals as often as possible.",
    "Encourage stretching exercises in the morning.",
    "Limit fast food consumption for overall health.",
    "Promote good hygiene habits like nail trimming.",
    "Encourage deep breathing and relaxation techniques.",
    "Provide enough fiber-rich foods to aid digestion.",
    "Ensure your child maintains a proper sleep schedule.",
    "Encourage proper hydration with water instead of juices.",
    "Teach kids how to manage their emotions healthily.",
    "Provide dairy or dairy alternatives for calcium intake.",
    "Encourage laughter and play for stress relief.",
    "Limit TV and mobile use before bedtime.",
    "Promote kindness and positive social interactions.",
    "Avoid giving processed meats like sausages and hot dogs.",
    "Encourage regular stretching exercises.",
    "Promote proper handwashing after playing outside.",
    "Encourage the use of ergonomic school bags.",
    "Teach children about food allergies and how to be cautious.",
    "Avoid excessive use of antibacterial products.",
    "Promote the importance of dental check-ups.",
    "Ensure children take breaks from studying or screen time.",
    "Encourage walking or cycling instead of short car rides.",
    "Promote healthy fats like those from nuts and avocados.",
    "Teach children to recognize and respond to bullying.",
    "Encourage daily meditation or quiet time.",
    "Ensure children’s shoes fit properly for foot health.",
    "Limit ultra-processed foods in the diet.",
    "Encourage participation in community activities.",
    "Teach kids to avoid sharing personal hygiene items.",
    "Ensure children wear appropriate clothing for the weather.",
    "Teach the importance of staying hydrated during exercise.",
    "Promote healthy bedtime routines for better sleep.",
    "Encourage social interactions for emotional well-being.",
    "Provide protein-rich meals for muscle development.",
    "Limit energy drinks and excessive sugar intake.",
    "Encourage active hobbies like dancing and sports.",
    "Teach kids how to properly clean their ears.",
    "Ensure children have regular eye check-ups.",
    "Teach kids how to recognize symptoms of illness early.",
    "Encourage journaling to express emotions.",
    "Ensure good air circulation at home for respiratory health.",
    "Promote healthy weight management through activity.",
    "Avoid excessive punishment; promote positive discipline.",
    "Encourage creativity through art and music.",
    "Provide iron-rich foods for proper growth and energy.",
    "Teach kids the importance of personal space and boundaries.",
    "Encourage healthy sibling relationships and cooperation.",
    "Ensure proper foot hygiene to prevent infections.",
    "Encourage children to eat slowly and chew properly",
    "Teach kids the importance of washing hands before meals",
    "Promote regular stretching to improve flexibility",
    "Encourage kids to drink water instead of sugary drinks",
    "Ensure children take breaks from screens to rest their eyes",
    "Teach kids to always wear a seatbelt in the car",
    "Provide a variety of protein sources in their diet",
    "Encourage kids to eat a rainbow of fruits and vegetables",
    "Limit fried and greasy foods for better digestion",
    "Teach kids to listen to their bodies when they are full",
    "Promote good oral hygiene by brushing twice a day",
    "Encourage outdoor play for better physical and mental health",
    "Ensure children get enough iron to prevent anemia",
    "Promote deep breathing exercises to reduce stress",
    "Encourage kids to express their feelings openly",
    "Teach the importance of personal space and respecting others",
    "Provide nutrient-rich homemade snacks instead of processed ones",
    "Ensure kids get enough fiber for good digestion",
    "Teach children how to safely use kitchen utensils",
    "Encourage kids to read books instead of excessive screen time",
    "Promote spending quality time with family",
    "Ensure children wash their hands after playing with pets",
    "Encourage good posture while sitting and standing",
    "Teach kids to recognize signs of dehydration",
    "Ensure kids wear appropriate clothing for the weather",
    "Limit junk food intake to avoid obesity",
    "Encourage kids to engage in creative activities",
    "Teach kids to avoid touching their faces with unclean hands",
    "Promote getting fresh air daily",
    "Ensure children sleep in a comfortable and dark environment",
    "Encourage drinking milk or calcium-rich alternatives",
    "Teach kids to be kind and compassionate",
    "Promote healthy portion sizes to avoid overeating",
    "Encourage washing fruits and vegetables before eating",
    "Ensure children eat a healthy breakfast daily",
    "Teach kids to avoid energy drinks and excessive caffeine",
    "Encourage participation in team sports for social skills",
    "Promote the habit of eating together as a family",
    "Teach kids about the importance of self-care",
    "Encourage mindfulness practices for relaxation",
    "Ensure children get regular check-ups with a pediatrician",
    "Teach kids to avoid smoking and alcohol when they grow older",
    "Promote sun safety with hats and sunscreen",
    "Encourage daily movement through play and exercise",
    "Teach kids to listen to their bodies when they feel unwell",
    "Ensure kids take breaks while studying to prevent fatigue",
    "Promote making healthy food choices from a young age",
    "Encourage laughter and play for mental well-being",
    "Teach children to avoid talking to strangers online",
    "Ensure kids understand basic safety rules in public places",
    "Encourage good sleep habits by setting a bedtime routine",
    "Teach kids the importance of empathy and helping others",
    "Promote regular hydration, especially in hot weather",
    "Encourage eating nuts and seeds for good nutrition",
    "Ensure kids have a balanced diet with essential vitamins",
    "Teach children how to respond to emergencies",
    "Promote daily stretching to prevent stiffness",
    "Encourage kids to avoid excessive sugar consumption",
    "Teach proper hygiene when coughing or sneezing",
    "Ensure children eat enough protein for growth and development",
    "Encourage trying new healthy foods",
    "Teach children to avoid excessive fast food consumption",
    "Promote a positive mindset for overall well-being",
    "Ensure children have access to clean and safe drinking water",
    "Teach kids to balance school, play, and rest",
    "Encourage walking or biking instead of short car rides",
    "Teach children to clean their toys regularly",
    "Promote family bonding through activities and discussions",
    "Encourage kids to get involved in hobbies they enjoy",
    "Ensure proper ventilation in bedrooms for better sleep",
    "Teach kids to recognize their emotions and express them healthily",
    "Encourage proper dental care, including flossing",
    "Promote staying active with fun activities",
    "Ensure kids understand the importance of regular health check-ups",
    "Teach children to say no to peer pressure",
    "Encourage making healthy choices when dining out",
    "Ensure kids wear comfortable and supportive shoes",
    "Promote a positive attitude towards challenges",
    "Encourage healthy snacking habits",
    "Teach kids the importance of washing their hands after using the bathroom",
    "Ensure proper hydration during sports and physical activities",
    "Encourage children to respect their bodies and others",
    "Teach kids to avoid excessive use of electronic devices",
    "Promote eating whole grains instead of refined grains",
    "Ensure kids maintain good hygiene habits",
    "Encourage social interactions and friendships",
    "Teach kids about the importance of reducing waste and recycling",
    "Promote having a gratitude journal to boost positivity",
    "Ensure children wear protective gear during sports",
    "Encourage taking deep breaths when feeling stressed",
    "Teach kids the importance of keeping their surroundings clean",
    "Promote relaxation techniques like meditation or listening to music",
    "Encourage limiting artificial food colorings and preservatives",
    "Ensure kids have a clutter-free study area",
    "Teach children to recognize symptoms of illness early",
    "Promote playing outside for physical and emotional benefits",
    "Encourage kids to help with household chores",
    "Teach kids to avoid skipping meals for better energy levels",
    "Ensure children consume enough omega-3s for brain health",
    "Promote journaling or storytelling for self-expression",
    "Encourage teaching kids about the importance of a healthy lifestyle",
    "Teach children to recognize harmful chemicals in products.",
    "Provide adequate vitamin D from sunlight exposure.",
    "Encourage washing fruits and vegetables before eating.",
    "Limit highly processed snacks like chips and candies.",
    "Promote gardening as a way to connect with nature.",
    "Teach deep breathing techniques for relaxation.",
    "Encourage playing musical instruments for brain development.",
    "Ensure children maintain a regular vaccination schedule.",
    "Teach fire safety and emergency preparedness.",
    "Promote the importance of kindness and gratitude.",
    "Encourage proper hydration before, during, and after playtime.",
    "Ensure proper sitting posture while studying or using gadgets.",
    "Provide lean meats and plant-based proteins in meals.",
    "Encourage keeping nails short to prevent bacteria buildup.",
    "Teach the importance of self-care and hygiene habits.",
    "Promote a calm and positive home environment.",
    "Encourage children to avoid overeating and eat mindfully.",
    "Limit exposure to loud noises to protect hearing.",
    "Promote the importance of keeping personal spaces clean.",
    "Encourage making homemade meals instead of fast food.",
    "Teach children about healthy portion sizes.",
    "Provide a variety of fruits and vegetables daily.",
    "Encourage proper food chewing to aid digestion.",
    "Ensure children have time for unstructured play.",
    "Teach children how to say ‘no’ to peer pressure.",
    "Encourage eating a variety of colors in meals.",
    "Teach the importance of getting enough rest.",
    "Encourage drinking water after waking up.",
    "Ensure children get their daily dose of fresh air.",
    "Encourage limiting digital device use before bedtime.",
    "Promote positive affirmations for self-confidence.",
    "Teach the importance of balanced nutrition.",
    "Encourage regular breaks while studying or working.",
    "Promote good skin care habits, including sunscreen use.",
    "Ensure children eat a variety of protein sources.",
    "Teach children to be aware of their emotions and express them.",
    "Promote kindness and respect in daily interactions.",
    "Encourage children to ask for help when needed.",
    "Teach children basic first aid skills.",
    "Encourage trying new healthy foods regularly.",
    "Teach children to listen to their bodies and rest when needed.",
    "Promote creative expression through play and hobbies.",
    "Encourage children to participate in family activities.",
    "Teach children how to handle disappointment positively.",
    "Promote good hygiene when handling food.",
    "Encourage children to spend time away from screens.",
    "Teach children the importance of patience and resilience.",
    "Promote a positive attitude towards learning new things.",
    "Encourage storytelling and imaginative play.",
    "Teach the importance of expressing gratitude daily.",
    "Promote a clutter-free and organized environment.",
    "Encourage small acts of kindness and helping others.",
    "Teach children to identify and manage stress.",
    "Ensure children get proper exposure to sunlight for vitamin D.",
    "Encourage drinking herbal teas instead of sugary drinks.",
    "Teach children about the benefits of stretching daily.",
    "Promote healthy social habits and friendships.",
    "Encourage children to have a healthy relationship with food.",
    "Teach children how to properly wash and dry their hands.",
    "Promote nature walks and outdoor adventures.",
  ];

  @override
  void initState() {
    super.initState();
    _startHealthTipRotation();
  }

  void _startHealthTipRotation() {
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _healthTips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF64B5F6),
                const Color(0xFF1976D2)
              ], // Sky Blue to Deep Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Text(
                'Hi, ${widget.name}👋',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthTipsCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Health & Wellness'),
              _buildFeatureGrid([
                _buildFeatureTile('Disease Detection', Icons.medical_services,
                    Colors.red, const DiseaseDetectionPage()),
                _buildFeatureTile('Pediatric Consultaion', Icons.event_available, Colors.blue,
                    const PediatricConsultationPage()),
                _buildFeatureTile('Cognitive Games', Icons.videogame_asset,
                    Colors.orange, const CognitiveGamesPage()),
                _buildFeatureTile('Growth Tracking', Icons.trending_up,
                    Colors.green, const GrowthTrackingPage()),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('Daily Support'),
              _buildScrollableFeatureList([
                _buildFeatureTile('Sleep Patterns', Icons.nights_stay,
                    Colors.indigo, const SleepTrackerPage()),
                _buildFeatureTile('Behavioral Support', Icons.psychology,
                    Colors.purple, const BehavioralTipsPage()),
                _buildFeatureTile('First Aid Guide', Icons.healing, Colors.pink,
                    const FirstAidGuidePage()),
                _buildFeatureTile('Parental Guidance', Icons.menu_book,
                    Colors.teal, const ParentalGuidancePage()),
                // _buildFeatureTile('Upload Health Data', Icons.cloud_upload,
                //     Colors.deepPurple, const UploadHealthDataPage()),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('Medical Assistance'),
              _buildMedicalAssistanceButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTipsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.health_and_safety, color: Colors.blue, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _healthTips[_currentTipIndex],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(List<Widget> tiles) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }

  Widget _buildScrollableFeatureList(List<Widget> tiles) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tiles,
      ),
    );
  }

  Widget _buildMedicalAssistanceButtons() {
    return Column(
      children: [
        _buildAssistanceButton(
          'Vaccination',
          const Color(0xFF64B5F6), // Soft Blue (Trust & Healthcare)
          const VaccinationPage(),
        ),
        _buildAssistanceButton(
          'Medication Management',
          const Color(0xFF9575CD), // Purple (Medical Precision)
          const MedicationManagementPage(),
        ),
        _buildAssistanceButton(
          'Emergency Contact',
          const Color(0xFFFF7043), // Deep Orange (Urgency & Attention)
          const EmergencyPage(),
        ),
      ],
    );
  }

  Widget _buildAssistanceButton(String title, Color color, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
      String title, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

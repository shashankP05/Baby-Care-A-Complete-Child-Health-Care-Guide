import 'package:flutter/material.dart';

class ParentalGuidancePage extends StatefulWidget {
  const ParentalGuidancePage({super.key});

  @override
  State<ParentalGuidancePage> createState() => _ParentalGuidancePageState();
}

class _ParentalGuidancePageState extends State<ParentalGuidancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text(
          'Parenting Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildDevelopmentStages(),
              const SizedBox(height: 20),
              _buildHealthAndNutrition(),
              const SizedBox(height: 20),
              _buildEducationGuidance(),
              const SizedBox(height: 20),
              _buildEmotionalSupport(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Parents!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find expert guidance on child development, health, education, and emotional well-being. Together, let\'s give your child the best possible start in life.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentStages() {
    return Card(
      child: ExpansionTile(
        title: const Text(
          'Child Development Stages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          _buildDevelopmentStageItem(
            'Infants (0-12 months)',
            '• Support physical development with tummy time\n'
                '• Engage in face-to-face interaction\n'
                '• Create a safe exploration environment\n'
                '• Establish consistent sleep routines\n'
                '• Respond promptly to crying',
          ),
          _buildDevelopmentStageItem(
            'Toddlers (1-3 years)',
            '• Encourage independent walking\n'
                '• Introduce simple problem-solving toys\n'
                '• Begin basic language development activities\n'
                '• Establish toilet training when ready\n'
                '• Create opportunities for social interaction',
          ),
          _buildDevelopmentStageItem(
            'Preschoolers (3-5 years)',
            '• Support imaginative play\n'
                '• Develop fine motor skills through art\n'
                '• Practice basic numbers and letters\n'
                '• Encourage sharing and turn-taking\n'
                '• Build emotional vocabulary',
          ),
          _buildDevelopmentStageItem(
            'School Age (6-12 years)',
            '• Support academic learning\n'
                '• Encourage physical activities and sports\n'
                '• Teach responsibility through chores\n'
                '• Build social skills and friendships\n'
                '• Develop problem-solving abilities',
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentStageItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _showDetailedGuidance(context, title, content);
            },
            child: const Text('View Detailed Guide'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAndNutrition() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health & Nutrition',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthTip(
              'Balanced Nutrition',
              Icons.restaurant_menu,
              'Create balanced meals with proteins, whole grains, fruits, and vegetables',
                  () => _showNutritionGuide(context),
            ),
            _buildHealthTip(
              'Physical Activity',
              Icons.directions_run,
              'Ensure 60 minutes of active play daily',
                  () => _showActivityGuide(context),
            ),
            _buildHealthTip(
              'Sleep Schedule',
              Icons.bedtime,
              'Maintain consistent sleep routines for better health',
                  () => _showSleepGuide(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTip(
      String title,
      IconData icon,
      String description,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationGuidance() {
    return Card(
      child: ExpansionTile(
        title: const Text(
          'Educational Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEducationItem(
                  'Learning Styles',
                  'Understand and support your child\'s unique learning style',
                      () => _showLearningStylesGuide(context),
                ),
                _buildEducationItem(
                  'Homework Help',
                  'Tips for creating an effective study environment',
                      () => _showHomeworkGuide(context),
                ),
                _buildEducationItem(
                  'Reading Support',
                  'Strategies to encourage reading habits',
                      () => _showReadingGuide(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
      String title,
      String description,
      VoidCallback onTap,
      ) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildEmotionalSupport() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emotional Well-being',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmotionalItem(
              'Building Confidence',
              'Support your child\'s self-esteem development',
                  () => _showConfidenceGuide(context),
            ),
            _buildEmotionalItem(
              'Managing Emotions',
              'Help your child understand and express feelings',
                  () => _showEmotionsGuide(context),
            ),
            _buildEmotionalItem(
              'Social Skills',
              'Develop strong interpersonal abilities',
                  () => _showSocialSkillsGuide(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalItem(
      String title,
      String description,
      VoidCallback onTap,
      ) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  void _showPopupGuide(BuildContext context, String title, String content, {List<Map<String, String>>? videoLinks}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (videoLinks != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Recommended Videos:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...videoLinks.map((video) => ListTile(
                            leading: const Icon(Icons.play_circle_fill, color: Colors.red),
                            title: Text(video['title']!),
                            onTap: () {
                              // Here you would implement the video opening logic
                              // For now, we'll show a message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening video: ${video['title']}'),
                                ),
                              );
                            },
                          )),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetailedGuidance(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showNutritionGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Nutrition Guidelines',
      '• Include proteins in every meal\n'
          '• Serve colorful fruits and vegetables\n'
          '• Choose whole grains over refined grains\n'
          '• Limit sugary snacks and drinks\n'
          '• Make mealtimes a family activity\n'
          '• Teach portion control\n'
          '• Encourage water consumption\n'
          '• Include calcium-rich foods for bone health',
    );
  }

  void _showActivityGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Physical Activity Guide',
      '• Encourage outdoor play daily\n'
          '• Join sports or physical activities\n'
          '• Make exercise a family activity\n'
          '• Balance screen time with active time\n'
          '• Create active games and challenges\n'
          '• Focus on fun rather than competition\n'
          '• Include both cardio and strength activities',
    );
  }

  void _showSleepGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Sleep Guidelines',
      '• Set consistent bedtimes\n'
          '• Create a calming bedtime routine\n'
          '• Limit screen time before bed\n'
          '• Ensure the bedroom is quiet and dark\n'
          '• Address bedtime fears and anxiety\n'
          '• Maintain sleep schedule on weekends\n'
          '• Monitor signs of sleep deprivation',
    );
  }

  void _showLearningStylesGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Understanding Learning Styles',
      '• Visual learners: Use diagrams and pictures\n'
          '• Auditory learners: Encourage discussion\n'
          '• Kinesthetic learners: Hands-on activities\n'
          '• Observe how your child learns best\n'
          '• Adapt teaching methods accordingly\n'
          '• Mix different learning approaches\n'
          '• Communicate with teachers about style',
    );
  }

  void _showHomeworkGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Homework Support Tips',
      '• Create a dedicated study space\n'
          '• Set regular homework time\n'
          '• Remove distractions\n'
          '• Break tasks into manageable chunks\n'
          '• Offer help when needed\n'
          '• Maintain communication with teachers\n'
          '• Celebrate completed assignments',
    );
  }

  void _showReadingGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Reading Development',
      '• Read together daily\n'
          '• Let children choose books\n'
          '• Make reading fun and interactive\n'
          '• Create a reading-friendly environment\n'
          '• Use reading apps and tools\n'
          '• Visit libraries regularly\n'
          '• Discuss stories together',
    );
  }

  void _showConfidenceGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Building Confidence',
      '• Praise effort over results\n'
          '• Set achievable goals\n'
          '• Encourage problem-solving\n'
          '• Celebrate small victories\n'
          '• Teach positive self-talk\n'
          '• Allow safe risk-taking\n'
          '• Show unconditional love',
    );
  }

  void _showEmotionsGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Managing Emotions',
      '• Validate their feelings\n'
          '• Teach emotional vocabulary\n'
          '• Model emotional regulation\n'
          '• Create a safe space for expression\n'
          '• Use feelings charts\n'
          '• Practice calming techniques\n'
          '• Discuss emotional situations\n'
          '• Help identify triggers\n'
          '• Encourage healthy coping strategies\n'
          '• Maintain open communication',
    );
  }

  void _showSocialSkillsGuide(BuildContext context) {
    _showPopupGuide(
      context,
      'Developing Social Skills',
      '• Arrange playdates\n'
          '• Practice sharing and turn-taking\n'
          '• Teach conflict resolution\n'
          '• Role-play social situations\n'
          '• Encourage empathy\n'
          '• Build listening skills\n'
          '• Discuss body language\n'
          '• Practice good manners\n'
          '• Support group activities\n'
          '• Address social anxiety',
    );
  }
}

class DetailedGuideDialog extends StatelessWidget {
  final String title;
  final String content;

  const DetailedGuideDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
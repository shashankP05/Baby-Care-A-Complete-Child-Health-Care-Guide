import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BehavioralTipsPage extends StatefulWidget {
  const BehavioralTipsPage({super.key});

  @override
  _BehavioralTipsPageState createState() => _BehavioralTipsPageState();
}

class _BehavioralTipsPageState extends State<BehavioralTipsPage> {
  List<Map<String, String>> tips = [
    {
      "title": "Positive Reinforcement",
      "content":
      "Use positive reinforcement like praise or rewards to encourage good behavior. Reinforcing the right actions motivates children to repeat them. Instead of punishing mistakes, focus on celebrating achievements. Over time, this builds confidence and trust in your child.",
      "link":
      "https://www.psychologytoday.com/us/blog/saving-normal/201702/why-positive-reinforcement-is-more-effective-than-punishment"
    },
    {
      "title": "Consistency in Discipline",
      "content":
      "Consistency is key when it comes to disciplining children. Always follow through with set expectations and rules. Inconsistencies can confuse children and make them feel insecure. A consistent approach helps them understand boundaries and encourages better behavior.",
      "link":
      "https://www.verywellfamily.com/how-consistency-in-discipline-helps-your-child-4083515"
    },
    {
      "title": "Modeling Behavior",
      "content":
      "Children often imitate the behavior they see at home. Be a positive role model by demonstrating good manners, patience, and empathy. Children will replicate the behaviors they observe in their caregivers. This helps them understand social expectations and develop emotional intelligence.",
      "link":
      "https://www.psychologytoday.com/us/blog/making-ideas-happen/201406/the-best-way-to-raise-a-child"
    },
    {
      "title": "Setting Clear Boundaries",
      "content":
      "Setting clear boundaries is essential in helping children understand what’s acceptable behavior. Be clear about rules and follow through with consequences when they are broken. Children thrive in environments where expectations are clear and consistent. This teaches respect and self-control.",
      "link":
      "https://www.psychologytoday.com/us/blog/raising-healthy-children/201610/7-tips-setting-boundaries-children"
    },
    {
      "title": "Active Listening",
      "content":
      "Active listening involves giving your full attention when your child speaks. Respond thoughtfully and show empathy for their feelings. This helps your child feel heard and validated. Active listening strengthens your connection with your child and helps with resolving conflicts.",
      "link":
      "https://www.psychologytoday.com/us/blog/parenting-the-new-style/201604/the-art-of-listening-to-your-child"
    },
    {
      "title": "Promote Emotional Expression",
      "content":
      "Encourage your child to express their emotions in a healthy way. Teach them that it’s okay to be sad, angry, or frustrated. When children learn to express themselves, they develop emotional resilience. Open discussions about feelings help prevent emotional buildup and lead to better problem-solving.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201601/encouraging-emotional-expression-in-children"
    },
    {
      "title": "Praise Effort, Not Just Results",
      "content":
      "Praise your child's effort rather than only their results. This encourages a growth mindset where they learn that hard work is valuable, not just success. Focusing on effort can increase their motivation and build perseverance. Acknowledging effort helps children tackle challenges with resilience.",
      "link":
      "https://www.psychologytoday.com/us/blog/finding-fulfillment/201805/praising-effort-vs-innate-talent"
    },
    {
      "title": "Create a Safe Environment",
      "content":
      "Creating a safe, supportive environment is essential for your child’s development. Ensure they feel secure enough to explore and learn without fear. Children who feel safe are more likely to engage with their surroundings positively. This promotes healthy emotional and social growth.",
      "link":
      "https://www.psychologytoday.com/us/blog/family-confidential/201608/creating-a-safe-space-for-your-child"
    },
    {
      "title": "Time for Play",
      "content":
      "Play is essential for a child's development. It fosters creativity, builds social skills, and helps with emotional regulation. Ensure that your child has ample time for unstructured play. Play allows children to explore their interests and develop vital life skills.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-playful-parent/201502/why-play-is-important-for-kids"
    },
    {
      "title": "Respecting Their Autonomy",
      "content":
      "Allow children to make choices and take responsibility for their decisions. This fosters independence and self-confidence. Giving them autonomy within boundaries teaches them accountability. The ability to make decisions helps children feel more in control of their lives.",
      "link":
      "https://www.psychologytoday.com/us/blog/family-confidential/201608/7-ways-to-support-your-childs-independence"
    },
    {
      "title": "Encourage Problem-Solving",
      "content":
      "Encourage your child to think critically and solve problems on their own. Offer guidance when needed, but allow them to work through challenges independently. Problem-solving skills help children develop resilience and adapt to life's difficulties. This boosts their confidence and ability to think for themselves.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201706/how-to-encourage-problem-solving-skills-in-your-child"
    },
    {
      "title": "Reinforce Good Manners",
      "content":
      "Reinforce good manners through repetition and positive reinforcement. Teach your child to say 'please' and 'thank you' and model these behaviors yourself. Good manners are vital for social interaction and help children build positive relationships. Consistent practice encourages respect for others.",
      "link":
      "https://www.psychologytoday.com/us/blog/parenting-the-new-style/201702/teaching-good-manners-to-children"
    },
    {
      "title": "Understanding Their Needs",
      "content":
      "Understanding and acknowledging your child's emotional, physical, and developmental needs is crucial. When parents are attuned to their child’s needs, it promotes emotional well-being. Regularly check in with them to understand their world. Meeting their needs helps foster trust and a secure attachment.",
      "link":
      "https://www.psychologytoday.com/us/blog/raising-healthy-children/201709/meeting-your-childs-emotional-needs"
    },
    {
      "title": "Encourage Social Interaction",
      "content":
      "Encourage your child to interact with peers and engage in group activities. Social interactions teach children empathy, communication skills, and conflict resolution. Positive peer relationships promote emotional well-being and social confidence. Help them navigate social challenges by offering guidance and support.",
      "link":
      "https://www.psychologytoday.com/us/blog/parenting-the-new-style/201706/why-socialization-is-so-important-for-children"
    },
    {
      "title": "Mindful Parenting",
      "content":
      "Practice mindful parenting by being present with your child and focusing on the moment. This helps reduce stress and improves your ability to respond calmly. Being mindful allows you to better understand your child's needs and feelings. Mindful parenting strengthens the bond between you and your child.",
      "link":
      "https://www.psychologytoday.com/us/blog/parenting-the-new-style/201606/how-to-practice-mindful-parenting"
    },
    {
      "title": "Limit Screen Time",
      "content":
      "Limit your child's screen time to encourage other forms of learning and play. Excessive screen time can interfere with sleep, physical activity, and social interaction. Set clear boundaries around technology usage. Engaging in physical activity and creative play promotes better cognitive and emotional development.",
      "link":
      "https://www.verywellfamily.com/why-limiting-screen-time-is-important-for-kids-4173231"
    },
    {
      "title": "Foster a Growth Mindset",
      "content":
      "Help your child develop a growth mindset by emphasizing effort over inherent ability. Encourage them to see challenges as opportunities for growth. A growth mindset builds resilience and motivates children to keep trying, even when they face setbacks. This encourages a love for learning and self-improvement.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201506/growth-mindset-and-kids"
    },
    {
      "title": "Teach Accountability",
      "content":
      "Teach your child to take responsibility for their actions. Hold them accountable for mistakes while offering support and guidance for improvement. Teaching accountability fosters self-discipline and independence. It encourages children to learn from their experiences and make better choices in the future.",
      "link":
      "https://www.psychologytoday.com/us/blog/family-confidential/201704/10-ways-to-teach-kids-accountability"
    },
    {
      "title": "Spend Quality Time Together",
      "content":
      "Spend quality one-on-one time with your child to strengthen your bond. This time can be spent doing simple activities like reading, playing, or talking. Quality time fosters emotional connections and creates positive memories. It also gives you an opportunity to learn about your child’s thoughts and feelings.",
      "link":
      "https://www.psychologytoday.com/us/blog/raising-healthy-children/201801/10-ways-to-spend-more-quality-time-with-your-child"
    },
    {
      "title": "Model Healthy Coping Skills",
      "content":
      "Model healthy coping skills to help your child manage stress and emotions. Demonstrate techniques like deep breathing, positive self-talk, or taking breaks. Children learn how to cope by observing the adults around them. Helping them build healthy coping skills gives them tools to handle life's challenges.",
      "link":
      "https://www.psychologytoday.com/us/blog/parenting-the-new-style/201810/how-to-teach-your-kid-to-cope-with-stress"
    },
    {
      "title": "Use Time-Outs Effectively",
      "content":
      "Use time-outs as a tool for helping children calm down and reflect on their behavior. A time-out should be brief and not used as a punishment, but rather a chance for the child to reset. It helps children learn to regulate their emotions and behavior. Ensure that time-outs are followed by a discussion about what went wrong.",
      "link":
      "https://www.psychologytoday.com/us/blog/parenting-the-new-style/201607/using-time-outs-effectively-with-your-child"
    },
    {
      "title": "Encourage Responsibility",
      "content":
      "Encourage your child to take on age-appropriate responsibilities at home. This helps them build self-reliance and a sense of accomplishment. Tasks like tidying up or taking care of a pet teach valuable life skills. Acknowledging their effort boosts their confidence and work ethic.",
      "link":
      "https://www.psychologytoday.com/us/blog/raising-healthy-children/201708/teaching-your-child-responsibility"
    },
    {
      "title": "Praise Specific Behaviors",
      "content":
      "Praise specific actions rather than giving general compliments. For example, saying 'Great job for sharing your toy!' focuses on the behavior rather than a broad 'Good job!' This helps children understand which behaviors to repeat. It also reinforces their self-esteem and positive actions.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-power-prime/201311/why-praising-behavior-works-better-than-praising-personality"
    },
    {
      "title": "Create Routines",
      "content":
      "Establishing routines provides children with a sense of security and predictability. It helps them know what to expect and reduces anxiety. Consistent routines, like bedtime and mealtime, can improve behavior. This consistency also fosters independence as children learn to follow schedules.",
      "link":
      "https://www.psychologytoday.com/us/articles/201502/the-benefits-of-daily-routines-for-kids"
    },
    {
      "title": "Be Patient",
      "content":
      "Patience is crucial when dealing with children's behavior. Children are still learning how to navigate their emotions and actions. Practicing patience helps you remain calm and empathetic when challenges arise. It also sets an example for your child to handle frustration constructively.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201907/why-patience-is-important-with-children"
    },
    {
      "title": "Encourage a Growth Mindset",
      "content":
      "Foster a growth mindset by praising your child’s efforts to improve, not just their results. Teach them that mistakes are opportunities to learn. Encouraging perseverance and hard work over innate talent helps them tackle challenges with confidence. A growth mindset prepares them to approach life’s difficulties with resilience.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201907/why-patience-is-important-with-children"
    },
    {
      "title": "Give Choices",
      "content":
      "Offering choices helps children feel empowered and in control. Allow them to choose between two options, like which outfit to wear or what book to read. Giving them control over decisions builds their independence and reduces power struggles. It teaches children to make thoughtful choices.",
      "link":
      "https://www.psychologytoday.com/us/blog/mom-answers/201311/why-giving-your-kids-choices-is-important"
    },
    {
      "title": "Avoid Comparisons",
      "content":
      "Avoid comparing your child to other children. Every child develops at their own pace, and comparisons can negatively impact their self-esteem. Instead, celebrate your child’s unique qualities and strengths. This helps them build confidence and reduces the pressure to conform.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-power-prime/201506/why-you-should-stop-comparing-your-kids-to-others"
    },
    {
      "title": "Set Realistic Expectations",
      "content":
      "Set age-appropriate and realistic expectations for your child. Understanding their capabilities helps you provide support without overwhelming them. Unrealistic expectations can lead to frustration and disappointment. Tailor your goals to their developmental stage to foster success and confidence.",
      "link":
      "https://www.psychologytoday.com/us/blog/family-confidential/201509/setting-realistic-expectations-for-your-child"
    },
    {
      "title": "Be Supportive During Mistakes",
      "content":
      "Be supportive and understanding when your child makes mistakes. Help them view errors as learning experiences rather than failures. A child who feels safe to make mistakes is more likely to develop resilience and problem-solving skills. Offering encouragement fosters a healthy mindset toward challenges.",
      "link":
      "https://www.psychologytoday.com/us/blog/family-confidential/201708/supporting-your-child-through-their-mistakes"
    },
    {
      "title": "Be Flexible",
      "content":
      "Flexibility in parenting allows you to adapt to your child's needs and circumstances. Life is unpredictable, and being flexible helps maintain calm during stressful situations. Adjusting rules or routines as necessary can prevent power struggles and reduce stress. This also teaches your child adaptability.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201606/the-benefits-of-flexibility-in-parenting"
    },
    {
      "title": "Promote Healthy Sleep Habits",
      "content":
      "Good sleep habits are essential for a child's well-being. Ensure your child has a consistent bedtime routine and gets enough sleep each night. Proper rest is linked to better mood regulation, learning, and behavior. Establishing good sleep habits early on helps children function better during the day.",
      "link":
      "https://www.psychologytoday.com/us/articles/201502/the-benefits-of-daily-routines-for-kids"
    },
    {
      "title": "Use Positive Language",
      "content":
      "Use positive, solution-focused language when addressing your child's behavior. Instead of saying, 'Don't run,' try, 'Please walk.' Positive language is more encouraging and helps children understand what they should do. It fosters a supportive environment for behavioral change.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201506/positive-language-helps-you-raise-happy-kids"
    },
    {
      "title": "Encourage Creativity",
      "content":
      "Encourage your child’s creativity through activities like drawing, building, or storytelling. Creative activities help children develop problem-solving skills and imagination. They provide opportunities for self-expression and emotional growth. Encourage open-ended play to let your child’s creativity flourish.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201502/why-play-is-important-for-kids"
    },
    {
      "title": "Limit Multitasking",
      "content":
      "Limit multitasking when interacting with your child. Focus your attention solely on them to strengthen your connection. Children benefit from undivided attention, which helps them feel valued and heard. This practice also sets an example of mindful presence for your child.",
      "link":
      "https://www.psychologytoday.com/us/blog/family-confidential/201701/why-multitasking-with-kids-is-hurting-your-relationship"
    },
    {
      "title": "Promote Healthy Eating Habits",
      "content":
      "Encourage healthy eating habits by introducing a variety of nutritious foods. Children are more likely to develop a positive relationship with food when they see it modeled. Healthy eating boosts energy, mood, and cognitive function. Foster a love of good food by making mealtime enjoyable.",
      "link":
      "https://www.psychologytoday.com/us/articles/201501/encouraging-healthy-eating-habits-in-kids"
    },
    {
      "title": "Teach Conflict Resolution",
      "content":
      "Teach your child how to resolve conflicts peacefully by using words instead of actions. Encourage them to express their feelings calmly and listen to others. Children who learn conflict resolution skills are more likely to form healthy relationships. These skills also help reduce aggression and foster empathy.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201703/teaching-your-child-to-resolve-conflict"
    },
    {
      "title": "Foster a Positive Self-Image",
      "content":
      "Encourage a positive self-image by helping your child recognize their unique strengths and qualities. Praise their efforts and encourage them to be proud of their achievements. A strong sense of self-worth helps children navigate challenges with confidence. It also leads to healthier emotional development.",
      "link":
      "https://www.psychologytoday.com/us/articles/201502/raising-a-confident-child"
    },
    {
      "title": "Encourage Teamwork",
      "content":
      "Encourage your child to work with others through group activities and games. Teamwork teaches children how to cooperate, share, and compromise. These experiences help them develop social skills and empathy. Teamwork also builds a sense of belonging and achievement within a group.",
      "link":
      "https://www.psychologytoday.com/us/articles/201501/teaching-kids-the-value-of-teamwork"
    },
    {
      "title": "Foster a Love of Learning",
      "content":
      "Cultivate a love of learning by encouraging curiosity and exploration. Provide books, games, and activities that spark your child’s interest. Celebrate their progress and make learning fun. When children enjoy learning, they are more likely to be motivated and engaged in their education.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201907/why-patience-is-important-with-children"
    },
    {
      "title": "Model Empathy",
      "content":
      "Model empathy by showing care for others’ feelings. When your child sees you showing kindness and concern for others, they are more likely to mimic these behaviors. Empathy helps children develop strong social connections and emotional intelligence. It's crucial for fostering understanding and compassion in relationships.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201801/why-empathy-is-vital-to-child-development"
    },
    {
      "title": "Encourage Independent Play",
      "content":
      "Encourage independent play to help your child develop problem-solving and creativity skills. Independent play allows children to use their imagination and explore their own ideas. It also fosters a sense of independence and self-sufficiency. While it’s important to be involved, moments of independent play are key for growth.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201504/why-independence-play-is-important"
    },
    {
      "title": "Avoid Over-Scheduling",
      "content":
      "Avoid over-scheduling your child’s time with activities. Balance between structured activities and downtime is essential for their emotional and physical well-being. Over-scheduling can lead to stress and burnout for both children and parents. Allowing free time gives children the chance to recharge and explore their own interests.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201806/why-kids-need-down-time"
    },
    {
      "title": "Support Emotional Expression",
      "content":
      "Support your child in expressing their emotions by validating how they feel. Instead of dismissing their emotions, acknowledge them and provide a safe space for expression. This helps children develop emotional intelligence and resilience. It also improves their ability to cope with difficult emotions in the future.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201901/how-to-help-your-child-express-their-feelings"
    },
    {
      "title": "Encourage Reading",
      "content":
      "Encourage reading from an early age to foster language skills and imagination. Reading enhances cognitive development and can be a fun bonding activity. The more your child reads, the better they’ll do in school and social interactions. Make reading enjoyable by choosing books that align with their interests.",
      "link":
      "https://www.psychologytoday.com/us/articles/201507/reading-to-your-child-the-benefits"
    },
    {
      "title": "Limit Screen Time",
      "content":
      "Limit screen time to ensure your child engages in a variety of activities. Excessive screen time can hinder social development, disrupt sleep, and impact academic performance. Set clear boundaries around screen use and encourage activities like outdoor play and reading. Balance is key to a healthy lifestyle.",
      "link":
      "https://www.psychologytoday.com/us/articles/201805/why-limiting-screen-time-is-good-for-your-child"
    },
    {
      "title": "Set Boundaries with Love",
      "content":
      "Set boundaries with love to guide your child’s behavior in a respectful manner. Boundaries are crucial for teaching children what is acceptable and what isn’t. By setting clear, consistent limits, you provide structure while showing that you care. Boundaries help children feel secure and teach responsibility.",
      "link":
      "https://www.psychologytoday.com/us/blog/urban-survival/201603/setting-boundaries-with-your-child"
    },
    {
      "title": "Show Unconditional Love",
      "content":
      "Show your child unconditional love to help them develop a sense of security. Children need to know that your love is not based on their behavior or achievements. Unconditional love builds self-esteem and emotional resilience. It fosters a secure attachment and deepens the bond between you and your child.",
      "link":
      "https://www.psychologytoday.com/us/blog/family-confidential/201702/the-power-of-unconditional-love"
    },
    {
      "title": "Teach Time Management",
      "content":
      "Teach your child time management skills by helping them organize their tasks. Break down big tasks into smaller steps to make them feel more manageable. Time management helps children become more responsible and less overwhelmed. It also teaches them how to prioritize and be mindful of deadlines.",
      "link":
      "https://www.psychologytoday.com/us/articles/201507/teaching-time-management-to-kids"
    },
    {
      "title": "Encourage Gratitude",
      "content":
      "Encourage your child to express gratitude by making it a regular practice. Whether through saying 'thank you' or keeping a gratitude journal, teaching gratitude promotes a positive outlook on life. Children who practice gratitude tend to be happier, more empathetic, and less materialistic. It also strengthens their emotional well-being.",
      "link":
      "https://www.psychologytoday.com/us/blog/the-importance-play/201511/teaching-kids-gratitude"
    }
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  Map<String, bool> likedStatus = {};

  @override
  void initState() {
    super.initState();
    _loadLikedStatus();
  }

  Future<void> _loadLikedStatus() async {
    if (userId == null) return;

    for (var tip in tips) {
      final QuerySnapshot snapshot = await _firestore
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .where('tipTitle', isEqualTo: tip['title'])
          .get();

      if (mounted) {
        setState(() {
          likedStatus[tip['title']!] = snapshot.docs.isNotEmpty;
        });
      }
    }
  }

  void shareTip(String title, String content) {
    Share.share('$title\n\n$content');
  }

  Future<void> toggleLike(Map<String, String> tip) async {
    if (userId == null) return;

    final String tipTitle = tip['title']!;
    final bool currentLikeStatus = likedStatus[tipTitle] ?? false;
    final CollectionReference likesRef = _firestore.collection('likes');

    try {
      // Update UI immediately
      setState(() {
        likedStatus[tipTitle] = !currentLikeStatus;
      });

      if (!currentLikeStatus) {
        // Like the tip
        await likesRef.add({
          'userId': userId,
          'tipTitle': tipTitle,
          'tipContent': tip['content'],
          'timestamp': FieldValue.serverTimestamp(), // Ensures timestamp exists
        });
      } else {
        // Unlike the tip
        final QuerySnapshot snapshot = await likesRef
            .where('userId', isEqualTo: userId)
            .where('tipTitle', isEqualTo: tipTitle)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      // Revert UI if operation fails
      setState(() {
        likedStatus[tipTitle] = currentLikeStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like status')),
      );
    }
  }

  Widget buildTipCard(Map<String, String> tip) {
    final bool isLiked = likedStatus[tip['title']] ?? false;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip['title']!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tip['content']!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => toggleLike(tip),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => shareTip(tip['title']!, tip['content']!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavioral Support Tips'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedTipsPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: tips.map((tip) => buildTipCard(tip)).toList(),
        ),
      ),
    );
  }
}

class LikedTipsPage extends StatelessWidget {
  final String? userId;

  const LikedTipsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Liked Tips')),
        body: const Center(child: Text('Please log in to view liked tips')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Liked Tips')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('likes')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Firestore error: ${snapshot.error}');
            return const Center(child: Text('Something went wrong, please try again later.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No liked tips yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['tipTitle'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(doc['tipContent'] ?? ''),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

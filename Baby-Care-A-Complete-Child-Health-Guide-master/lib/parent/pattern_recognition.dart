import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class PatternRecognitionGame extends StatefulWidget {
  const PatternRecognitionGame({super.key});

  @override
  State<PatternRecognitionGame> createState() => _PatternRecognitionGameState();
}

class _PatternRecognitionGameState extends State<PatternRecognitionGame> {
  final Random _random = Random();
  late List<PatternItem> pattern;
  late List<PatternItem> choices;
  int score = 0;
  int level = 1;
  bool isCorrect = false;
  bool showResult = false;
  Timer? resultTimer;
  int patternLength = 4;

  // Define possible shapes, colors, and numbers
  final List<IconData> shapes = [
    Icons.circle,
    Icons.square,
    Icons.star,
    Icons.favorite,
    Icons.pets,
  ];

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    generateNewPattern();
  }

  void generateNewPattern() {
    // Generate pattern based on current level
    pattern = [];
    int patternType = _random.nextInt(3); // 0: shape, 1: color, 2: both

    // Create base pattern items
    List<PatternItem> baseItems = [];
    for (int i = 0; i < 3; i++) {
      baseItems.add(PatternItem(
        shape: shapes[_random.nextInt(shapes.length)],
        color: colors[_random.nextInt(colors.length)],
      ));
    }

    // Generate pattern using base items
    for (int i = 0; i < patternLength; i++) {
      pattern.add(baseItems[i % baseItems.length]);
    }

    // Generate choices including the correct answer
    PatternItem correctAnswer = baseItems[pattern.length % baseItems.length];
    choices = [correctAnswer];

    // Add incorrect choices
    while (choices.length < 4) {
      PatternItem newChoice = PatternItem(
        shape: shapes[_random.nextInt(shapes.length)],
        color: colors[_random.nextInt(colors.length)],
      );
      if (!choices.contains(newChoice)) {
        choices.add(newChoice);
      }
    }
    choices.shuffle();
  }

  void checkAnswer(PatternItem selectedItem) {
    if (showResult) return;

    PatternItem correctAnswer = pattern[pattern.length % (pattern.length - 1)];
    bool correct = selectedItem == correctAnswer;

    setState(() {
      isCorrect = correct;
      showResult = true;
    });

    resultTimer?.cancel();
    resultTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        showResult = false;
        if (correct) {
          score += 10;
          if (score % 30 == 0) {
            level++;
            patternLength = min(patternLength + 1, 8);
          }
        }
        generateNewPattern();
      });
    });
  }

  @override
  void dispose() {
    resultTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pattern Recognition",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Level: $level',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Score: $score',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'What comes next in the pattern?',
              style: TextStyle(fontSize: 18),
            ),
          ),
          // Pattern display
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pattern.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    pattern[index].shape,
                    color: pattern[index].color,
                    size: 50,
                  ),
                );
              },
            ),
          ),
          // Question mark
          const Icon(
            Icons.help_outline,
            size: 50,
            color: Colors.grey,
          ),
          // Choices grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => checkAnswer(choices[index]),
                    child: Card(
                      elevation: 4,
                      color: showResult
                          ? (choices[index] == pattern[pattern.length % (pattern.length - 1)])
                          ? Colors.green.shade100
                          : Colors.red.shade100
                          : Colors.white,
                      child: Center(
                        child: Icon(
                          choices[index].shape,
                          color: choices[index].color,
                          size: 60,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (showResult)
            Text(
              isCorrect ? '✨ Correct! ✨' : '❌ Try Again!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PatternItem {
  final IconData shape;
  final Color color;

  PatternItem({required this.shape, required this.color});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PatternItem &&
              runtimeType == other.runtimeType &&
              shape == other.shape &&
              color == other.color;

  @override
  int get hashCode => shape.hashCode ^ color.hashCode;
}
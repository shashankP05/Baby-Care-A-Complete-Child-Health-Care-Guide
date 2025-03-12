import 'package:flutter/material.dart';
import 'dart:math';

class MathChallengesGame extends StatefulWidget {
  const MathChallengesGame({super.key});

  @override
  State<MathChallengesGame> createState() => _MathChallengesGameState();
}

class _MathChallengesGameState extends State<MathChallengesGame> {
  int score = 0;
  int currentLevel = 1;
  int timeLeft = 30;
  bool isPlaying = false;
  String currentQuestion = '';
  int correctAnswer = 0;
  List<int> options = [];
  int questionsAnswered = 0;
  int correctAnswers = 0;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    generateNewQuestion();
  }

  void startGame() {
    setState(() {
      score = 0;
      currentLevel = 1;
      timeLeft = 30;
      isPlaying = true;
      questionsAnswered = 0;
      correctAnswers = 0;
      generateNewQuestion();
    });
    startTimer();
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          isPlaying = false;
          showGameOverDialog();
        }
      });
      return timeLeft > 0 && isPlaying;
    });
  }

  void generateNewQuestion() {
    int num1, num2;
    String operator;

    switch (currentLevel) {
      case 1: // Simple addition within 20
        num1 = random.nextInt(10) + 1;
        num2 = random.nextInt(10) + 1;
        operator = '+';
        correctAnswer = num1 + num2;
        break;
      case 2: // Addition and subtraction within 50
        num1 = random.nextInt(30) + 10;
        num2 = random.nextInt(20) + 1;
        operator = random.nextBool() ? '+' : '-';
        correctAnswer = operator == '+' ? num1 + num2 : num1 - num2;
        break;
      case 3: // Multiplication tables up to 10
        num1 = random.nextInt(10) + 1;
        num2 = random.nextInt(10) + 1;
        operator = '×';
        correctAnswer = num1 * num2;
        break;
      default: // Mixed operations
        num1 = random.nextInt(20) + 1;
        num2 = random.nextInt(20) + 1;
        int opChoice = random.nextInt(3);
        operator = ['+', '-', '×'][opChoice];
        correctAnswer = operator == '+'
            ? num1 + num2
            : operator == '-'
            ? num1 - num2
            : num1 * num2;
    }

    currentQuestion = '$num1 $operator $num2 = ?';
    generateOptions();
  }

  void generateOptions() {
    options = [correctAnswer];

    while (options.length < 4) {
      int offset = random.nextInt(10) + 1;
      int newOption = correctAnswer + (random.nextBool() ? offset : -offset);

      if (!options.contains(newOption) && newOption >= 0) {
        options.add(newOption);
      }
    }

    options.shuffle();
  }

  void checkAnswer(int selectedAnswer) {
    if (!isPlaying) return;

    setState(() {
      questionsAnswered++;

      if (selectedAnswer == correctAnswer) {
        correctAnswers++;
        score += (currentLevel * 10);

        // Level progression
        if (correctAnswers % 5 == 0 && currentLevel < 4) {
          currentLevel++;
          timeLeft += 15; // Bonus time for level up
          showLevelUpDialog();
        }
      }

      generateNewQuestion();
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over! 🎮',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score: $score',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text('Correct Answers: $correctAnswers/$questionsAnswered',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Highest Level Reached: $currentLevel',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('Play Again',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  void showLevelUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Level Up! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You\'ve reached Level $currentLevel!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text('Bonus: +15 seconds',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Challenge!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: Column(
          children: [
            // Game stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Score',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('$score',
                        style: const TextStyle(fontSize: 24, color: Colors.blue),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Level',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('$currentLevel',
                        style: const TextStyle(fontSize: 24, color: Colors.green),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('$timeLeft',
                        style: TextStyle(
                          fontSize: 24,
                          color: timeLeft <= 10 ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Question area
            if (!isPlaying)
              Center(
                child: ElevatedButton(
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Start Game',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      currentQuestion,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Answer options
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: options.map((option) =>
                        SizedBox(
                          width: 150,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: () => checkAnswer(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              option.toString(),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                    ).toList(),
                  ),
                ],
              ),

            const Spacer(),

            // Instructions or level info
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                isPlaying
                    ? getLevelDescription(currentLevel)
                    : 'Press Start to begin the challenge!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Level 1: Simple addition within 20';
      case 2:
        return 'Level 2: Addition and subtraction within 50';
      case 3:
        return 'Level 3: Multiplication tables up to 10';
      default:
        return 'Level 4: Mixed operations challenge';
    }
  }
}
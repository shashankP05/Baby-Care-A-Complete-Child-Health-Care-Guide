import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class WordAssociationGame extends StatefulWidget {
  const WordAssociationGame({super.key});

  @override
  State<WordAssociationGame> createState() => _WordAssociationGameState();
}

class _WordAssociationGameState extends State<WordAssociationGame> {
  int score = 0;
  int level = 1;
  int timeLeft = 60;
  Timer? gameTimer;
  bool isPlaying = false;
  String currentWord = '';
  List<String> currentChoices = [];
  String correctAnswer = '';
  bool showResult = false;
  bool isCorrect = false;
  Timer? resultTimer;

  // Word pairs for the game (moved to a static map)
  static final Map<String, List<String>> wordPairs = {
    'dog': ['puppy', 'cat', 'bone', 'leash'],
    'sun': ['moon', 'star', 'sky', 'light'],
    'tree': ['leaf', 'branch', 'forest', 'wood'],
    'book': ['read', 'page', 'story', 'library'],
    'car': ['drive', 'wheel', 'road', 'garage'],
    'fish': ['swim', 'water', 'ocean', 'fins'],
    'bird': ['fly', 'nest', 'wing', 'feather'],
    'rain': ['cloud', 'storm', 'umbrella', 'wet'],
    'shoe': ['foot', 'sock', 'walk', 'laces'],
    'apple': ['fruit', 'tree', 'pie', 'seed'],
    'house': ['home', 'room', 'door', 'roof'],
    'pencil': ['write', 'paper', 'draw', 'eraser'],
  };

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    score = 0;
    level = 1;
    timeLeft = 60;
    isPlaying = true;
    startTimer();
    generateNewQuestion();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            endGame();
          }
        });
      }
    });
  }

  void generateNewQuestion() {
    final words = wordPairs.keys.toList();
    currentWord = words[Random().nextInt(words.length)];
    final associatedWords = wordPairs[currentWord]!;
    correctAnswer = associatedWords[0];

    currentChoices = [correctAnswer];
    final allWords = wordPairs.values.expand((i) => i).toList();
    while (currentChoices.length < 4) {
      String randomWord = allWords[Random().nextInt(allWords.length)];
      if (!currentChoices.contains(randomWord) &&
          !wordPairs[currentWord]!.contains(randomWord)) {
        currentChoices.add(randomWord);
      }
    }
    currentChoices.shuffle();
  }

  void checkAnswer(String selected) {
    if (!isPlaying || showResult) return;

    bool correct = selected == correctAnswer;
    setState(() {
      isCorrect = correct;
      showResult = true;
      if (correct) {
        score += 10;
        if (score % 30 == 0) {
          level++;
        }
      }
    });

    resultTimer?.cancel();
    resultTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          showResult = false;
          generateNewQuestion();
        });
      }
    });
  }

  void endGame() {
    gameTimer?.cancel();
    isPlaying = false;
    showGameOverDialog();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Final Score: $score\nLevel Reached: $level',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Text(
                'Would you like to play again?',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  startNewGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    resultTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Word Association",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
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
                Text(
                  'Time: $timeLeft',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: timeLeft <= 10 ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Find a word related to:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              currentWord.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: currentChoices.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () => checkAnswer(currentChoices[index]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showResult
                          ? (currentChoices[index] == correctAnswer
                          ? Colors.green
                          : Colors.red)
                          : Colors.purple[100],
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Text(
                      currentChoices[index].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            if (showResult)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isCorrect ? 'Great job!' : 'Try again!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
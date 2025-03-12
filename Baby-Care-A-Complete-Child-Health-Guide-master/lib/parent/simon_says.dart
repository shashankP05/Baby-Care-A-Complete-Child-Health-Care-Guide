import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SimonSaysGame extends StatefulWidget {
  const SimonSaysGame({super.key});

  @override
  State<SimonSaysGame> createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<SimonSaysGame> {
  // Enhanced color scheme with deeper, more vibrant colors
  final List<Color> gameColors = [
    const Color(0xFFD32F2F),  // Deep Red
    const Color(0xFF388E3C),  // Deep Green
    const Color(0xFF1976D2),  // Deep Blue
    const Color(0xFFFBC02D),  // Deep Yellow
  ];

  // Darker versions for inactive state
  final List<Color> inactiveColors = [
    const Color(0xFF8B1C1C),  // Darker Red
    const Color(0xFF1B5E20),  // Darker Green
    const Color(0xFF0D47A1),  // Darker Blue
    const Color(0xFFF57F17),  // Darker Yellow
  ];

  List<int> sequence = [];
  List<int> playerSequence = [];
  int score = 0;
  int highScore = 0;
  bool isPlaying = false;
  bool isShowingSequence = false;
  int activeIndex = -1;
  bool canPlayerInput = false;
  Timer? sequenceTimer;
  double difficulty = 1.0;  // New difficulty multiplier

  @override
  void dispose() {
    sequenceTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      sequence.clear();
      playerSequence.clear();
      score = 0;
      difficulty = 1.0;
      isPlaying = true;
      addNewColor();
    });
  }

  void addNewColor() {
    setState(() {
      sequence.add(Random().nextInt(4));
      showSequence();
    });
  }

  void showSequence() {
    int currentIndex = 0;
    setState(() {
      isShowingSequence = true;
      canPlayerInput = false;
    });

    // Sequence speed increases with difficulty
    double speedMultiplier = max(0.3, 1.0 - (difficulty * 0.05));

    sequenceTimer = Timer.periodic(Duration(milliseconds: (800 * speedMultiplier).toInt()), (timer) {
      if (currentIndex < sequence.length) {
        setState(() {
          activeIndex = sequence[currentIndex];
        });

        Future.delayed(Duration(milliseconds: (400 * speedMultiplier).toInt()), () {
          setState(() {
            activeIndex = -1;
          });
        });

        currentIndex++;
      } else {
        timer.cancel();
        setState(() {
          isShowingSequence = false;
          canPlayerInput = true;
          playerSequence.clear();
        });
      }
    });
  }

  void onColorPressed(int colorIndex) {
    if (!canPlayerInput) return;

    setState(() {
      playerSequence.add(colorIndex);
      activeIndex = colorIndex;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        activeIndex = -1;
      });
    });

    if (playerSequence.length == sequence.length) {
      checkSequence();
    }
  }

  void checkSequence() {
    bool isCorrect = true;
    for (int i = 0; i < sequence.length; i++) {
      if (sequence[i] != playerSequence[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() {
        score++;
        difficulty += 0.2;  // Increase difficulty
        if (score > highScore) {
          highScore = score;
        }
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        addNewColor();
      });
    } else {
      gameOver();
    }
  }

  void gameOver() {
    setState(() {
      isPlaying = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,  // Dark background
        title: const Text('Game Over! 🎮',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text('High Score: $highScore',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text('Sequence Length: ${sequence.length}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('Play Again',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
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
        title: const Text('Simon Says',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,  // Darker app bar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,  // Dark blue-grey
              Colors.white,  // Lighter blue-grey
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Score display with enhanced styling
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreContainer('Score', score, Colors.red),
                    _buildScoreContainer('High Score', highScore, Colors.red),
                  ],
                ),
              ),

              const Spacer(),

              // Game buttons
              if (!isPlaying)
                Center(
                  child: ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFF388E3C),  // Deep green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Start Game',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    children: List.generate(4, (index) {
                      return GestureDetector(
                        onTapDown: (_) => onColorPressed(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: activeIndex == index
                                ? gameColors[index]
                                : inactiveColors[index],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: gameColors[index].withOpacity(0.5),
                                blurRadius: activeIndex == index ? 15 : 5,
                                spreadRadius: activeIndex == index ? 3 : 0,
                              ),
                            ],
                            border: Border.all(
                              color: gameColors[index],
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

              const Spacer(),

              // Game status with enhanced styling
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isPlaying
                      ? isShowingSequence
                      ? 'Watch carefully...'
                      : 'Your turn! Repeat the pattern'
                      : 'Ready to test your memory?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreContainer(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text('$value',
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:math';

class FindDifferenceGame extends StatefulWidget {
  const FindDifferenceGame({super.key});

  @override
  State<FindDifferenceGame> createState() => _FindDifferenceGameState();
}

class _FindDifferenceGameState extends State<FindDifferenceGame> {
  int score = 0;
  int timeLeft = 60;
  bool gameStarted = false;
  Set<int> foundDifferences = {};
  late List<Difference> differences;

  @override
  void initState() {
    super.initState();
    initializeDifferences();
  }

  void initializeDifferences() {
    // Randomly generate 5 differences with double values
    differences = List.generate(5, (index) {
      return Difference(
        x: Random().nextDouble() * 300,
        y: Random().nextDouble() * 400,
        radius: 20.0,  // Explicitly using double
      );
    });
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      score = 0;
      timeLeft = 60;
      foundDifferences.clear();
      initializeDifferences();
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
          gameStarted = false;
          showGameOverDialog();
        }
      });
      return timeLeft > 0 && gameStarted;
    });
  }

  void checkDifference(Offset tapPosition, bool isRightImage) {
    if (!gameStarted) return;

    for (int i = 0; i < differences.length; i++) {
      if (foundDifferences.contains(i)) continue;

      final difference = differences[i];
      final dx = tapPosition.dx - difference.x;
      final dy = tapPosition.dy - difference.y;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance <= difference.radius) {
        setState(() {
          foundDifferences.add(i);
          score += 10;

          if (foundDifferences.length == differences.length) {
            gameStarted = false;
            showWinDialog();
          }
        });
        return;
      }
    }

    // Wrong tap penalty
    setState(() {
      if (score > 0) score -= 5;
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up! 🕒',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score: $score',
              style: const TextStyle(fontSize: 20),
            ),
            Text('Differences Found: ${foundDifferences.length}/5',
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

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You found all differences!',
              style: TextStyle(fontSize: 20),
            ),
            Text('Score: $score',
              style: const TextStyle(fontSize: 18),
            ),
            Text('Time Left: $timeLeft seconds',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find the Differences!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Game stats bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Score: $score',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('Time: $timeLeft',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('Found: ${foundDifferences.length}/5',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Game area
          if (!gameStarted)
            Center(
              child: ElevatedButton(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text('Start Game',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  // Left image
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (details) => checkDifference(details.localPosition, false),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          color: Colors.grey[200],
                        ),
                        child: CustomPaint(
                          painter: ImagePainter(
                            differences: differences,
                            foundDifferences: foundDifferences,
                            isRightImage: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Right image
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (details) => checkDifference(details.localPosition, true),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          color: Colors.grey[200],
                        ),
                        child: CustomPaint(
                          painter: ImagePainter(
                            differences: differences,
                            foundDifferences: foundDifferences,
                            isRightImage: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              gameStarted
                  ? 'Tap on the differences between the images!'
                  : 'Press Start to begin the game',
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class Difference {
  final double x;
  final double y;
  final double radius;

  Difference({required this.x, required this.y, required this.radius});
}

class ImagePainter extends CustomPainter {
  final List<Difference> differences;
  final Set<int> foundDifferences;
  final bool isRightImage;

  ImagePainter({
    required this.differences,
    required this.foundDifferences,
    required this.isRightImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw base shapes
    paint.color = Colors.blue[100]!;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        50.0,  // Using double
        paint
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width / 4,
          size.height / 4,
          50.0,  // Using double
          50.0   // Using double
      ),
      paint,
    );

    // Draw differences
    for (int i = 0; i < differences.length; i++) {
      final difference = differences[i];
      if (isRightImage || foundDifferences.contains(i)) {
        paint.color = Colors.red;
        canvas.drawCircle(
          Offset(difference.x, difference.y),
          difference.radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
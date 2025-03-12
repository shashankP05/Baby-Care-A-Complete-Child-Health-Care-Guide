import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
class PuzzleSolverGame extends StatefulWidget {
  const PuzzleSolverGame({super.key});

  @override
  State<PuzzleSolverGame> createState() => _PuzzleSolverGameState();
}

class _PuzzleSolverGameState extends State<PuzzleSolverGame> {
  late List<int> tiles;
  late int emptyTileIndex;
  int moveCount = 0;
  late Stopwatch stopwatch;
  Timer? timer;
  String timeElapsed = '00:00';
  bool isGameComplete = false;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    initializeGame();
  }

  void initializeGame() {
    // Create solved puzzle
    tiles = List.generate(16, (index) => index);
    // Shuffle puzzle ensuring it's solvable
    do {
      tiles.shuffle();
    } while (!isSolvable(tiles));

    emptyTileIndex = tiles.indexOf(0);
    moveCount = 0;
    isGameComplete = false;
    stopwatch.reset();
    stopwatch.start();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final minutes = (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
          timeElapsed = '$minutes:$seconds';
        });
      }
    });
  }

  bool isSolvable(List<int> puzzle) {
    int inversions = 0;
    for (int i = 0; i < puzzle.length - 1; i++) {
      for (int j = i + 1; j < puzzle.length; j++) {
        if (puzzle[i] != 0 && puzzle[j] != 0 && puzzle[i] > puzzle[j]) {
          inversions++;
        }
      }
    }

    // For a 4x4 puzzle, if the empty tile is on an even row counting from bottom
    // and number of inversions is odd, the puzzle is solvable
    int emptyTileRow = (puzzle.indexOf(0) ~/ 4);
    int bottomRow = 3;
    bool isEmptyTileRowEvenFromBottom = ((bottomRow - emptyTileRow) % 2 == 0);

    return (isEmptyTileRowEvenFromBottom && inversions.isOdd) ||
        (!isEmptyTileRowEvenFromBottom && inversions.isEven);
  }

  bool canMoveTile(int index) {
    // Check if tile is adjacent to empty tile
    if (index == emptyTileIndex - 1 && index ~/ 4 == emptyTileIndex ~/ 4 ||  // Left
        index == emptyTileIndex + 1 && index ~/ 4 == emptyTileIndex ~/ 4 ||  // Right
        index == emptyTileIndex - 4 ||  // Above
        index == emptyTileIndex + 4) {  // Below
      return true;
    }
    return false;
  }

  void moveTile(int index) {
    if (!canMoveTile(index) || isGameComplete) return;

    setState(() {
      // Swap tiles
      final temp = tiles[index];
      tiles[index] = tiles[emptyTileIndex];
      tiles[emptyTileIndex] = temp;
      emptyTileIndex = index;
      moveCount++;

      // Check if puzzle is solved
      bool isSolved = true;
      for (int i = 0; i < tiles.length - 1; i++) {
        if (tiles[i] != i + 1) {
          isSolved = false;
          break;
        }
      }
      if (isSolved && tiles.last == 0) {
        isGameComplete = true;
        stopwatch.stop();
        timer?.cancel();
        showWinDialog();
      }
    });
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 Congratulations! 🎉',
              textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You solved the puzzle in:\n$moveCount moves\n$timeElapsed',
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
                  initializeGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Color getTileColor(int value) {
    if (value == 0) return Colors.white;
    // Create a gradient of colors based on tile value
    return Colors.blue[100 + (value * 40 % 400)] ?? Colors.blue;
  }

  @override
  void dispose() {
    stopwatch.stop();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Puzzle Solver",
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
                  'Moves: $moveCount',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: $timeElapsed',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => moveTile(index),
                      child: Card(
                        elevation: tiles[index] != 0 ? 4 : 0,
                        color: getTileColor(tiles[index]),
                        child: Center(
                          child: tiles[index] != 0
                              ? Text(
                            '${tiles[index]}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  initializeGame();
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'New Game',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class MazeSolverGame extends StatefulWidget {
  const MazeSolverGame({super.key});

  @override
  State<MazeSolverGame> createState() => _MazeSolverGameState();
}

class _MazeSolverGameState extends State<MazeSolverGame> {
  static const int rows = 8;
  static const int cols = 8;

  // Player position
  int playerRow = 0;
  int playerCol = 0;

  // Goal position
  final int goalRow = rows - 1;
  final int goalCol = cols - 1;

  // Walls in the maze
  final Set<String> walls = {
    '0,1', '1,1', '2,1', '3,1',
    '1,3', '2,3', '3,3', '4,3',
    '5,1', '5,2', '5,3', '5,4',
    '3,5', '4,5', '5,5', '6,5',
  };

  int moves = 0;
  bool gameCompleted = false;

  void movePlayer(DragUpdateDetails details) {
    if (gameCompleted) return;

    const sensitivity = 10.0;
    if (details.delta.dx.abs() > details.delta.dy.abs()) {
      // Horizontal movement
      if (details.delta.dx > sensitivity) {
        tryMove(0, 1); // Right
      } else if (details.delta.dx < -sensitivity) {
        tryMove(0, -1); // Left
      }
    } else {
      // Vertical movement
      if (details.delta.dy > sensitivity) {
        tryMove(1, 0); // Down
      } else if (details.delta.dy < -sensitivity) {
        tryMove(-1, 0); // Up
      }
    }
  }

  void tryMove(int rowDelta, int colDelta) {
    final newRow = playerRow + rowDelta;
    final newCol = playerCol + colDelta;

    // Check boundaries
    if (newRow < 0 || newRow >= rows || newCol < 0 || newCol >= cols) {
      return;
    }

    // Check walls
    if (walls.contains('$newRow,$newCol')) {
      return;
    }

    setState(() {
      playerRow = newRow;
      playerCol = newCol;
      moves++;

      // Check if player reached the goal
      if (playerRow == goalRow && playerCol == goalCol) {
        gameCompleted = true;
        showWinDialog();
      }
    });
  }

  void resetGame() {
    setState(() {
      playerRow = 0;
      playerCol = 0;
      moves = 0;
      gameCompleted = false;
    });
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
            const Text('You solved the maze!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Moves taken: $moves',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Play Again',
              style: TextStyle(fontSize: 16),
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
        title: const Text('Maze Adventure!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moves: $moves',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: movePlayer,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rows,
                      ),
                      itemCount: rows * cols,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final row = index ~/ cols;
                        final col = index % cols;
                        final isWall = walls.contains('$row,$col');
                        final isPlayer = row == playerRow && col == playerCol;
                        final isGoal = row == goalRow && col == goalCol;

                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isWall
                                ? Colors.grey[800]
                                : isPlayer
                                ? Colors.blue
                                : isGoal
                                ? Colors.green
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: isPlayer
                              ? const Icon(Icons.emoji_people,
                              color: Colors.white)
                              : isGoal
                              ? const Icon(Icons.star,
                              color: Colors.yellow)
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Swipe to move the player to the star!',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
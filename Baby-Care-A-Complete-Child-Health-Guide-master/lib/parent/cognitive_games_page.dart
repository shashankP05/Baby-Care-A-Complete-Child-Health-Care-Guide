import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'memory_match.dart';
import 'puzzle_solver.dart';
import 'pattern_recognition.dart';
import 'word_association.dart';
import 'sorting_game.dart';
import 'maze_solver.dart';
import 'find_difference.dart';
import 'math_challenges.dart';
import 'simon_says.dart';
import 'story_building.dart';

class CognitiveGamesPage extends StatelessWidget {
  const CognitiveGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cognitive Games"),
        backgroundColor:
            Colors.lightBlue.shade100, // Light color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildGameCard(context, "Memory Match", Colors.blue,
                const MemoryMatchGame(), FontAwesomeIcons.brain),
            _buildGameCard(context, "Puzzle Solver", Colors.green,
                const PuzzleSolverGame(), FontAwesomeIcons.puzzlePiece),
            _buildGameCard(context, "Pattern Recognition", Colors.orange,
                const PatternRecognitionGame(), FontAwesomeIcons.shapes),
            _buildGameCard(context, "Word Association", Colors.red,
                const WordAssociationGame(), FontAwesomeIcons.bookOpen),
            _buildGameCard(context, "Sorting Game", Colors.purple,
                const SortingGame(), FontAwesomeIcons.layerGroup),
            _buildGameCard(context, "Maze Solver", Colors.teal,
                const MazeSolverGame(), FontAwesomeIcons.route),
            _buildGameCard(context, "Find the Difference", Colors.brown,
                const FindDifferenceGame(), FontAwesomeIcons.eye),
            _buildGameCard(context, "Math Challenges", Colors.pink,
                const MathChallengesGame(), FontAwesomeIcons.calculator),
            _buildGameCard(context, "Simon Says", Colors.amber,
                const SimonSaysGame(), FontAwesomeIcons.handPointUp),
            _buildGameCard(context, "Story Building", Colors.indigo,
                const StoryBuildingGame(), FontAwesomeIcons.penFancy),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, Color color,
      Widget page, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        color: color,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  // Game state variables
  List<String> cardContent = [];
  List<bool> cardFlips = [];
  int? firstCardIndex;
  int? secondCardIndex;
  int pairsFound = 0;
  int attempts = 0;
  bool isProcessing = false;
  Timer? flipBackTimer;

  // Emoji pairs for cards - child-friendly themes
  final List<String> emojis = [
    '🐶', '🐱', '🐰', '🐼', '🐨', '🦁',
    '🐸', '🦊', '🐮', '🐷', '🐔', '🦄'
  ];

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    // Create pairs of emojis
    cardContent = [...emojis, ...emojis];
    // Shuffle the cards
    cardContent.shuffle(Random());
    // Initialize all cards as face down
    cardFlips = List.generate(cardContent.length, (index) => false);
    // Reset game state
    firstCardIndex = null;
    secondCardIndex = null;
    pairsFound = 0;
    attempts = 0;
  }

  void onCardTap(int index) {
    // Prevent tapping while processing or if card is already flipped
    if (isProcessing || cardFlips[index]) return;

    setState(() {
      // Flip the card
      cardFlips[index] = true;

      // First card of the pair
      if (firstCardIndex == null) {
        firstCardIndex = index;
      }
      // Second card of the pair
      else if (secondCardIndex == null && firstCardIndex != index) {
        secondCardIndex = index;
        attempts++;
        isProcessing = true;

        // Check if cards match
        if (cardContent[firstCardIndex!] == cardContent[secondCardIndex!]) {
          pairsFound++;
          // Reset for next pair
          firstCardIndex = null;
          secondCardIndex = null;
          isProcessing = false;

          // Check if game is complete
          if (pairsFound == emojis.length) {
            showWinDialog();
          }
        } else {
          // Flip cards back after delay
          flipBackTimer?.cancel();
          flipBackTimer = Timer(const Duration(milliseconds: 1000), () {
            setState(() {
              cardFlips[firstCardIndex!] = false;
              cardFlips[secondCardIndex!] = false;
              firstCardIndex = null;
              secondCardIndex = null;
              isProcessing = false;
            });
          });
        }
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
                'You won in $attempts attempts!',
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

  @override
  void dispose() {
    flipBackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Memory Match",
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
                  'Matches: $pairsFound/${emojis.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Attempts: $attempts',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: cardContent.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onCardTap(index),
                    child: Card(
                      elevation: 4,
                      color: cardFlips[index] ? Colors.white : Colors.blue,
                      child: Center(
                        child: cardFlips[index]
                            ? Text(
                          cardContent[index],
                          style: const TextStyle(fontSize: 32),
                        )
                            : const Icon(
                          Icons.star,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
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
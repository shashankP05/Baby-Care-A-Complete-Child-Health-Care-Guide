import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SortingGame extends StatefulWidget {
  const SortingGame({super.key});

  @override
  State<SortingGame> createState() => _SortingGameState();
}

class _SortingGameState extends State<SortingGame> {
  int score = 0;
  int level = 1;
  int timeLeft = 60;
  Timer? gameTimer;
  bool isPlaying = false;
  List<ItemData> items = [];
  List<String> categories = [];
  Map<String, List<ItemData>> sortedItems = {};
  bool showResult = false;
  bool isCorrect = false;

  // Game items data
  static final Map<String, List<ItemData>> gameData = {
    'Colors': [
      ItemData('Red Ball', '🔴', 'Red'),
      ItemData('Blue Star', '🔵', 'Blue'),
      ItemData('Yellow Sun', '⭐', 'Yellow'),
      ItemData('Red Heart', '❤️', 'Red'),
      ItemData('Blue Diamond', '💎', 'Blue'),
      ItemData('Yellow Moon', '🌙', 'Yellow'),
    ],
    'Shapes': [
      ItemData('Circle', '⭕', 'Round'),
      ItemData('Square', '⬛', 'Square'),
      ItemData('Triangle', '🔺', 'Triangle'),
      ItemData('Heart', '❤️', 'Round'),
      ItemData('Diamond', '💎', 'Square'),
      ItemData('Star', '⭐', 'Triangle'),
    ],
    'Animals': [
      ItemData('Dog', '🐕', 'Land'),
      ItemData('Fish', '🐠', 'Water'),
      ItemData('Bird', '🦜', 'Air'),
      ItemData('Cat', '🐈', 'Land'),
      ItemData('Dolphin', '🐬', 'Water'),
      ItemData('Eagle', '🦅', 'Air'),
    ],
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
    setupLevel();
    startTimer();
  }

  void setupLevel() {
    // Select a random category
    final categories = gameData.keys.toList();
    final selectedCategory = categories[Random().nextInt(categories.length)];

    // Get items for the category
    items = List.from(gameData[selectedCategory]!)..shuffle();

    // Set up categories based on the items
    this.categories = items.map((item) => item.category).toSet().toList();

    // Initialize sorted items
    sortedItems = Map.fromIterable(
      this.categories,
      key: (item) => item.toString(),
      value: (item) => <ItemData>[],
    );
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

  void checkSorting() {
    bool allSorted = true;
    for (var category in categories) {
      for (var item in sortedItems[category]!) {
        if (item.category != category) {
          allSorted = false;
          break;
        }
      }
    }

    if (allSorted && items.isEmpty) {
      setState(() {
        score += 10;
        if (score % 30 == 0) {
          level++;
        }
        isCorrect = true;
        showResult = true;
      });

      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showResult = false;
            setupLevel();
          });
        }
      });
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sorting Game",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
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
          ),
          Expanded(
            flex: 1,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8.0),
              children: items.map((item) => DragItem(item: item)).toList(),
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: categories.length,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return DropZone(
                  category: categories[index],
                  items: sortedItems[categories[index]]!,
                  onAccept: (ItemData item) {
                    setState(() {
                      items.remove(item);
                      sortedItems[categories[index]]!.add(item);
                      checkSorting();
                    });
                  },
                );
              },
            ),
          ),
          if (showResult)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isCorrect ? 'Perfect Sorting!' : 'Keep Trying!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ItemData {
  final String name;
  final String emoji;
  final String category;

  ItemData(this.name, this.emoji, this.category);
}

class DragItem extends StatelessWidget {
  final ItemData item;

  const DragItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Draggable<ItemData>(
      data: item,
      feedback: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          item.emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
      childWhenDragging: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          item.emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            Text(
              item.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class DropZone extends StatelessWidget {
  final String category;
  final List<ItemData> items;
  final Function(ItemData) onAccept;

  const DropZone({
    super.key,
    required this.category,
    required this.items,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ItemData>(
      onWillAccept: (data) => true,
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: items.map((item) => Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
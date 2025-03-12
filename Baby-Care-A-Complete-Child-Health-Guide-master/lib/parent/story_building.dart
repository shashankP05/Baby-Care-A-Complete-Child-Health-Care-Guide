import 'package:flutter/material.dart';

class StoryBuildingGame extends StatefulWidget {
  const StoryBuildingGame({super.key});

  @override
  State<StoryBuildingGame> createState() => _StoryBuildingGameState();
}

class _StoryBuildingGameState extends State<StoryBuildingGame> {
  final List<String> _storyParts = [];
  final TextEditingController _controller = TextEditingController();
  final List<String> _prompts = [
    'Once upon a time...',
    'Suddenly...',
    'But then...',
    'Because of that...',
    'Finally...',
  ];
  int _currentPromptIndex = 0;

  void _addStoryPart() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _storyParts.add(_controller.text);
        _controller.clear();
        if (_currentPromptIndex < _prompts.length - 1) {
          _currentPromptIndex++;
        }
      });
    }
  }

  void _resetStory() {
    setState(() {
      _storyParts.clear();
      _currentPromptIndex = 0;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Building Adventure'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetStory,
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _storyParts.isEmpty
                  ? const Center(
                child: Text(
                  'Start building your story!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
                  : ListView.builder(
                itemCount: _storyParts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _storyParts[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_currentPromptIndex < _prompts.length)
              Card(
                color: Colors.yellow.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _prompts[_currentPromptIndex],
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add to your story...',
                labelText: 'Your story part',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _currentPromptIndex < _prompts.length ? _addStoryPart : null,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add to Story', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(primary: Colors.green),
            ),
            if (_storyParts.isNotEmpty && _currentPromptIndex >= _prompts.length)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Story complete! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AutismDetectionPage extends StatefulWidget {
  @override
  _AutismDetectionPageState createState() => _AutismDetectionPageState();
}

class _AutismDetectionPageState extends State<AutismDetectionPage> {
  final TextEditingController _ageController = TextEditingController();
  String? _selectedSex;
  String? _selectedEthnicity;
  String? _selectedJaundice;
  String? _selectedFamilyASD;
  String? _selectedWhoCompleted;
  Map<String, int> _answers = {};

  String _result = "";
  double _probability = 0.0;
  int _qchatScore = 0;
  bool _isLoading = false;

  final List<String> _yesNoOptions = ["yes", "no"];
  final List<String> _sexOptions = ["m", "f"];
  final List<String> _ethnicityOptions = [
    "asian", "middle eastern", "black", "Hispanic", "White European",
    "south asian", "Native Indian", "others"
  ];
  final List<String> _whoCompletedOptions = [
    "family member", "Health Care Professional", "Self"
  ];

  Future<void> _detectAutism() async {
    setState(() {
      _isLoading = true;
    });

    final int ageMonths = int.tryParse(_ageController.text) ?? 0;
    if (ageMonths == 0 || _selectedSex == null || _selectedEthnicity == null ||
        _selectedJaundice == null || _selectedFamilyASD == null ||
        _selectedWhoCompleted == null || _answers.length < 10) {
      setState(() {
        _result = "Please complete all fields.";
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> requestData = {
      "A1": _answers["A1"] ?? 0,
      "A2": _answers["A2"] ?? 0,
      "A3": _answers["A3"] ?? 0,
      "A4": _answers["A4"] ?? 0,
      "A5": _answers["A5"] ?? 0,
      "A6": _answers["A6"] ?? 0,
      "A7": _answers["A7"] ?? 0,
      "A8": _answers["A8"] ?? 0,
      "A9": _answers["A9"] ?? 0,
      "A10": _answers["A10"] ?? 0,
      "Age_Mons": ageMonths,
      "Sex": _selectedSex,
      "Ethnicity": _selectedEthnicity,
      "Jaundice": _selectedJaundice,
      "Family_mem_with_ASD": _selectedFamilyASD,
      "Who_completed_the_test": _selectedWhoCompleted
    };

    try {
      final response = await http.post(
        Uri.parse("http://192.168.4.28:8080/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _qchatScore = responseData["qchat_score"];
          _probability = responseData["probability"];
          // Update the result message based on the Q-CHAT-10 score
          _result = _qchatScore > 5
              ? "Based on the assessment, there is a chance of autism. Please consult with a healthcare professional for a thorough evaluation."
              : "Based on the assessment, there are no significant indicators of autism. However, if you have concerns, please consult with a healthcare professional.";
        });
      } else {
        setState(() {
          _result = "Error: Unable to get results. Try again.";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Failed to connect to the server.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildDropdown(String title, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: title, border: OutlineInputBorder()),
      value: selectedValue,
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildQuestion(String question, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<int>(
                title: Text("Yes"),
                value: 1,
                groupValue: _answers[key],
                onChanged: (value) {
                  setState(() {
                    _answers[key] = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                title: Text("No"),
                value: 0,
                groupValue: _answers[key],
                onChanged: (value) {
                  setState(() {
                    _answers[key] = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Autism Detection")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: "Child's Age (in months)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _buildDropdown("Sex", _sexOptions, _selectedSex, (value) => setState(() => _selectedSex = value)),
            SizedBox(height: 10),
            _buildDropdown("Ethnicity", _ethnicityOptions, _selectedEthnicity, (value) => setState(() => _selectedEthnicity = value)),
            SizedBox(height: 10),
            _buildDropdown("Jaundice at birth?", _yesNoOptions, _selectedJaundice, (value) => setState(() => _selectedJaundice = value)),
            SizedBox(height: 10),
            _buildDropdown("Family member with ASD?", _yesNoOptions, _selectedFamilyASD, (value) => setState(() => _selectedFamilyASD = value)),
            SizedBox(height: 10),
            _buildDropdown("Who completed the test?", _whoCompletedOptions, _selectedWhoCompleted, (value) => setState(() => _selectedWhoCompleted = value)),
            SizedBox(height: 20),

            // Autism Screening Questions
            _buildQuestion("Does your child look at you when you call their name?", "A1"),
            _buildQuestion("Does your child make eye contact with you?", "A2"),
            _buildQuestion("When your child plays alone, does he/she line objects up?", "A3"),
            _buildQuestion("Can your child point to indicate that they want something?", "A4"),
            _buildQuestion("Can your child point to share interest with you?", "A5"),
            _buildQuestion("Does your child pretend play?", "A6"),
            _buildQuestion("Does your child follow where you're looking?", "A7"),
            _buildQuestion("Is your child's behavior normal compared to other children?", "A8"),
            _buildQuestion("Does your child engage in repetitive activities?", "A9"),
            _buildQuestion("Does your child look at what you're looking at?", "A10"),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _detectAutism,
              child: _isLoading ? CircularProgressIndicator() : Text("Detect"),
            ),
            SizedBox(height: 20),

            if (_result.isNotEmpty)
              Card(
                color: Colors.blue[100],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Q-CHAT-10 Score: $_qchatScore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Probability: ${(_probability * 100).toStringAsFixed(2)}%", style: TextStyle(fontSize: 18, color: Colors.red)),
                      Text(_result, style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
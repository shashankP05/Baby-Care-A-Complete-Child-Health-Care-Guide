import 'package:flutter/material.dart';
import 'dart:math';

class ClinicalToolsPage extends StatefulWidget {
  @override
  _ClinicalToolsPageState createState() => _ClinicalToolsPageState();
}

class _ClinicalToolsPageState extends State<ClinicalToolsPage> {
  // BMI variables
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double? _bmiResult;
  String _bmiCategory = '';

  // Drug Dosage variables
  final TextEditingController _drugWeightController = TextEditingController();
  final TextEditingController _drugConcentrationController = TextEditingController();
  double? _drugDosage;

  // Heart Rate variables
  final TextEditingController _heartRateController = TextEditingController();
  String _heartRateCategory = '';

  // Calorie Calculator variables
  final TextEditingController _caloriesWeightController = TextEditingController();
  final TextEditingController _caloriesAgeController = TextEditingController();
  final TextEditingController _caloriesActivityController = TextEditingController();
  double? _calorieResult;

  // Ideal Body Weight variables
  final TextEditingController _ibwWeightController = TextEditingController();
  final TextEditingController _ibwHeightController = TextEditingController();
  double? _idealBodyWeight;

  // Blood Pressure variables
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  String _bloodPressureCategory = '';

  // Pregnancy Due Date variables
  final TextEditingController _lmpController = TextEditingController();
  String _dueDate = '';

  // Blood Sugar variables
  final TextEditingController _bloodSugarController = TextEditingController();
  String _bloodSugarCategory = '';

  // BMI calculation
  void _calculateBMI() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      double bmi = weight / pow(height / 100, 2);
      setState(() {
        _bmiResult = bmi;
        _bmiCategory = _getBMICategory(bmi);
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 18.5 && bmi < 24.9) return 'Normal Weight';
    if (bmi >= 25 && bmi < 29.9) return 'Overweight';
    return 'Obese';
  }

  // Drug Dosage calculation
  void _calculateDrugDosage() {
    double weight = double.tryParse(_drugWeightController.text) ?? 0;
    double concentration = double.tryParse(_drugConcentrationController.text) ?? 0;

    if (weight > 0 && concentration > 0) {
      double dosage = weight * concentration;
      setState(() {
        _drugDosage = dosage;
      });
    }
  }

  // Heart Rate Category
  void _calculateHeartRateCategory() {
    double heartRate = double.tryParse(_heartRateController.text) ?? 0;

    if (heartRate < 60) {
      setState(() {
        _heartRateCategory = 'Low Heart Rate';
      });
    } else if (heartRate >= 60 && heartRate <= 100) {
      setState(() {
        _heartRateCategory = 'Normal Heart Rate';
      });
    } else {
      setState(() {
        _heartRateCategory = 'High Heart Rate';
      });
    }
  }

  // Calorie Calculation
  void _calculateCalories() {
    double weight = double.tryParse(_caloriesWeightController.text) ?? 0;
    int age = int.tryParse(_caloriesAgeController.text) ?? 0;
    double activityLevel = double.tryParse(_caloriesActivityController.text) ?? 0;

    if (weight > 0 && age > 0 && activityLevel > 0) {
      double calories = (10 * weight) + (6.25 * 170) - (5 * age) + 5;
      setState(() {
        _calorieResult = calories * activityLevel;
      });
    }
  }

  // Ideal Body Weight Calculation
  void _calculateIdealBodyWeight() {
    double height = double.tryParse(_ibwHeightController.text) ?? 0;
    double weight = double.tryParse(_ibwWeightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      double idealWeight = (height - 100) - ((height - 150) / 4);
      setState(() {
        _idealBodyWeight = idealWeight;
      });
    }
  }

  // Blood Pressure Category
  void _calculateBloodPressureCategory() {
    int systolic = int.tryParse(_systolicController.text) ?? 0;
    int diastolic = int.tryParse(_diastolicController.text) ?? 0;

    if (systolic < 120 && diastolic < 80) {
      setState(() {
        _bloodPressureCategory = 'Normal';
      });
    } else if (systolic < 130 && diastolic < 80) {
      setState(() {
        _bloodPressureCategory = 'Elevated';
      });
    } else if (systolic < 140 || diastolic < 90) {
      setState(() {
        _bloodPressureCategory = 'Hypertension Stage 1';
      });
    } else {
      setState(() {
        _bloodPressureCategory = 'Hypertension Stage 2';
      });
    }
  }

  // Pregnancy Due Date Calculation
  void _calculateDueDate() {
    DateTime lmp = DateTime.tryParse(_lmpController.text) ?? DateTime.now();
    DateTime dueDate = lmp.add(Duration(days: 280));

    setState(() {
      _dueDate = '${dueDate.year}-${dueDate.month}-${dueDate.day}';
    });
  }

  // Blood Sugar Category
  void _calculateBloodSugarCategory() {
    int bloodSugar = int.tryParse(_bloodSugarController.text) ?? 0;

    if (bloodSugar < 100) {
      setState(() {
        _bloodSugarCategory = 'Normal';
      });
    } else if (bloodSugar >= 100 && bloodSugar < 126) {
      setState(() {
        _bloodSugarCategory = 'Prediabetic';
      });
    } else {
      setState(() {
        _bloodSugarCategory = 'Diabetic';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clinical Tools'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildToolCard(
              title: "BMI Calculator",
              icon: Icons.fitness_center,
              child: _buildBMICalculator(),
            ),
            _buildToolCard(
              title: "Drug Dosage Calculator",
              icon: Icons.medication,
              child: _buildDrugDosageCalculator(),
            ),
            _buildToolCard(
              title: "Heart Rate Category",
              icon: Icons.heart_broken,
              child: _buildHeartRateCalculator(),
            ),
            _buildToolCard(
              title: "Calorie Calculator",
              icon: Icons.restaurant_menu,
              child: _buildCalorieCalculator(),
            ),
            _buildToolCard(
              title: "Ideal Body Weight Calculator",
              icon: Icons.account_balance,
              child: _buildIdealBodyWeightCalculator(),
            ),
            _buildToolCard(
              title: "Blood Pressure Category",
              icon: Icons.local_hospital,
              child: _buildBloodPressureCategory(),
            ),
            _buildToolCard(
              title: "Pregnancy Due Date Calculator",
              icon: Icons.calendar_today,
              child: _buildPregnancyDueDate(),
            ),
            _buildToolCard(
              title: "Blood Sugar Category",
              icon: Icons.bloodtype,
              child: _buildBloodSugarCategory(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the tool cards
  Widget _buildToolCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(padding: EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }

  // Function for BMI calculator
  Widget _buildBMICalculator() {
    return Column(
      children: [
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Weight (kg)'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _heightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Height (cm)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateBMI,
          child: Text("Calculate BMI"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_bmiResult != null) ...[
          SizedBox(height: 10),
          Text("BMI: ${_bmiResult!.toStringAsFixed(1)}"),
          Text("Category: $_bmiCategory", style: TextStyle(fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }

  // Function for Drug Dosage calculator
  Widget _buildDrugDosageCalculator() {
    return Column(
      children: [
        TextField(
          controller: _drugWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Patient Weight (kg)'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _drugConcentrationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Drug Concentration (mg/kg)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateDrugDosage,
          child: Text("Calculate Dosage"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_drugDosage != null) ...[
          SizedBox(height: 10),
          Text("Recommended Dosage: ${_drugDosage!.toStringAsFixed(1)} mg"),
        ]
      ],
    );
  }

  // Function for Heart Rate category
  Widget _buildHeartRateCalculator() {
    return Column(
      children: [
        TextField(
          controller: _heartRateController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Heart Rate (bpm)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateHeartRateCategory,
          child: Text("Check Heart Rate Category"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_heartRateCategory.isNotEmpty) ...[
          SizedBox(height: 10),
          Text("Heart Rate: $_heartRateCategory", style: TextStyle(fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }

  // Function for Calorie calculator
  Widget _buildCalorieCalculator() {
    return Column(
      children: [
        TextField(
          controller: _caloriesWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Weight (kg)'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _caloriesAgeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Age (years)'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _caloriesActivityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Activity Level (1-3)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateCalories,
          child: Text("Calculate Calories"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_calorieResult != null) ...[
          SizedBox(height: 10),
          Text("Recommended Daily Calories: ${_calorieResult!.toStringAsFixed(0)}"),
        ]
      ],
    );
  }

  // Function for Ideal Body Weight calculator
  Widget _buildIdealBodyWeightCalculator() {
    return Column(
      children: [
        TextField(
          controller: _ibwHeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Height (cm)'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _ibwWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Weight (kg)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateIdealBodyWeight,
          child: Text("Calculate Ideal Body Weight"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_idealBodyWeight != null) ...[
          SizedBox(height: 10),
          Text("Ideal Body Weight: ${_idealBodyWeight!.toStringAsFixed(1)} kg"),
        ]
      ],
    );
  }

  // Function for Blood Pressure category
  Widget _buildBloodPressureCategory() {
    return Column(
      children: [
        TextField(
          controller: _systolicController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Systolic BP'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _diastolicController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Diastolic BP'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateBloodPressureCategory,
          child: Text("Check Blood Pressure"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_bloodPressureCategory.isNotEmpty) ...[
          SizedBox(height: 10),
          Text("Blood Pressure: $_bloodPressureCategory", style: TextStyle(fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }

  // Function for Pregnancy Due Date calculator
  Widget _buildPregnancyDueDate() {
    return Column(
      children: [
        TextField(
          controller: _lmpController,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(labelText: 'Last Menstrual Period (LMP)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateDueDate,
          child: Text("Calculate Due Date"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_dueDate.isNotEmpty) ...[
          SizedBox(height: 10),
          Text("Due Date: $_dueDate", style: TextStyle(fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }

  // Function for Blood Sugar category
  Widget _buildBloodSugarCategory() {
    return Column(
      children: [
        TextField(
          controller: _bloodSugarController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Blood Sugar (mg/dL)'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _calculateBloodSugarCategory,
          child: Text("Check Blood Sugar Category"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        if (_bloodSugarCategory.isNotEmpty) ...[
          SizedBox(height: 10),
          Text("Blood Sugar: $_bloodSugarCategory", style: TextStyle(fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GrowthChartsPage extends StatefulWidget {
  @override
  _GrowthChartsPageState createState() => _GrowthChartsPageState();
}

class _GrowthChartsPageState extends State<GrowthChartsPage> {
  final CollectionReference _growthDataRef =
  FirebaseFirestore.instance.collection('growth_data');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Growth Charts'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _buildGrowthChart(),
    );
  }

  Widget _buildGrowthChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _growthDataRef.orderBy('age_months').snapshots(), // No need to specify ascending since it's default
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Growth Data Available'));
        }

        final growthData = snapshot.data!.docs;
        List<FlSpot> heightSpots = [];
        List<FlSpot> weightSpots = [];

        for (var doc in growthData) {
          var data = doc.data() as Map<String, dynamic>;
          double age = data["age_months"].toDouble();
          double height = data["height_cm"].toDouble();
          double weight = data["weight_kg"].toDouble();

          heightSpots.add(FlSpot(age, height));
          weightSpots.add(FlSpot(age, weight));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildGrowthCard(heightSpots, weightSpots),
              SizedBox(height: 20),
              Expanded(child: _buildLineChart(heightSpots, weightSpots)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrowthCard(List<FlSpot> heightSpots, List<FlSpot> weightSpots) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Growth Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            Text("Latest Height: ${heightSpots.isNotEmpty ? heightSpots.last.y.toStringAsFixed(1) + " cm" : "N/A"}"),
            Text("Latest Weight: ${weightSpots.isNotEmpty ? weightSpots.last.y.toStringAsFixed(1) + " kg" : "N/A"}"),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> heightSpots, List<FlSpot> weightSpots) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 20),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: heightSpots,
            isCurved: true,
            barWidth: 4,
            color: Colors.blue,
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: weightSpots,
            isCurved: true,
            barWidth: 4,
            color: Colors.green,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

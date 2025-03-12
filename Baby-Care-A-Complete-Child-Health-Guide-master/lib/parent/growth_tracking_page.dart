import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GrowthTrackingPage extends StatefulWidget {
  const GrowthTrackingPage({super.key});

  @override
  GrowthTrackingPageState createState() => GrowthTrackingPageState();
}

class GrowthTrackingPageState extends State<GrowthTrackingPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  List<Map<String, dynamic>> _growthData = [];
  bool _isLoading = true;

  bool get _isWeightView => _tabController.index == 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _fetchGrowthData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchGrowthData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('growth_data')
            .orderBy('date', descending: true)
            .get();

        setState(() {
          _growthData = snapshot.docs
              .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
              .toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to fetch data: ${e.toString()}');
    }
    setState(() => _isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.height), text: 'Height'),
            Tab(icon: Icon(Icons.monitor_weight), text: 'Weight'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(isWeight: false),
            _buildTabContent(isWeight: true),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGrowthDataDialog,
        label: const Text('Add Data'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabContent({required bool isWeight}) {
    return _growthData.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
      onRefresh: _fetchGrowthData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatsCard(isWeight),
              const SizedBox(height: 16),
              _buildGrowthChart(isWeight),
              const SizedBox(height: 16),
              _buildGrowthDataList(isWeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isWeight) {
    final values = _growthData.map((d) => isWeight ? d['weight'] : d['height']).toList();
    if (values.isEmpty) return const SizedBox();

    final current = values.first;
    final previous = values.length > 1 ? values[1] : current;
    final difference = current - previous;
    final unit = isWeight ? 'kg' : 'cm';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current: $current $unit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  difference >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: difference >= 0 ? Colors.green : Colors.red,
                ),
                Text(
                  '${difference.abs().toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    color: difference >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data recorded yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showAddGrowthDataDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Record'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(bool isWeight) {
    if (_growthData.length < 2) return const SizedBox();

    final data = _growthData.reversed.toList();
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= data.length || value.toInt() < 0) {
                        return const SizedBox();
                      }
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          DateFormat('MMM d').format(DateTime.parse(data[value.toInt()]['date'])),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toStringAsFixed(1));
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      isWeight ? entry.value['weight'] : entry.value['height'],
                    );
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthDataList(bool isWeight) {
    return Card(
      elevation: 4,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _growthData.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final data = _growthData[index];
          return Dismissible(
            key: Key(data['id']),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Record'),
                  content: const Text('Are you sure you want to delete this record?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) => _deleteGrowthData(data['id']),
            child: ListTile(
              title: Text(
                DateFormat('MMMM d, yyyy').format(DateTime.parse(data['date'])),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${isWeight ? "Weight" : "Height"}: ${isWeight ? data['weight'] : data['height']} ${isWeight ? "kg" : "cm"}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditGrowthDataDialog(data),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddGrowthDataDialog() {
    _showGrowthDataDialog();
  }

  void _showEditGrowthDataDialog(Map<String, dynamic> data) {
    _showGrowthDataDialog(existingData: data);
  }

  void _showGrowthDataDialog({Map<String, dynamic>? existingData}) {
    final isEditing = existingData != null;
    String date = isEditing
        ? existingData['date']
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    double height = isEditing ? existingData['height'] : 0;
    double weight = isEditing ? existingData['weight'] : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isEditing ? "Edit" : "Add"} Growth Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              initialValue: date,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(date),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  date = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height),
              ),
              keyboardType: TextInputType.number,
              initialValue: height > 0 ? height.toString() : '',
              onChanged: (value) => height = double.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: TextInputType.number,
              initialValue: weight > 0 ? weight.toString() : '',
              onChanged: (value) => weight = double.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (date.isNotEmpty && (height > 0 || weight > 0)) {
                if (isEditing) {
                  _updateGrowthData(existingData['id'], date, height, weight);
                } else {
                  _addGrowthData(date, height, weight);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addGrowthData(String date, double height, double weight) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).collection('growth_data').add({
          'date': date,
          'height': height,
          'weight': weight,
        });
        _fetchGrowthData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add data: ${e.toString()}');
    }
  }

  Future<void> _updateGrowthData(String docId, String date, double height, double weight) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).collection('growth_data').doc(docId).update({
          'date': date,
          'height': height,
          'weight': weight,
        });
        _fetchGrowthData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update data: ${e.toString()}');
    }
  }

  Future<void> _deleteGrowthData(String docId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).collection('growth_data').doc(docId).delete();
        await _fetchGrowthData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete data: ${e.toString()}');
    }
  }
}

class GrowthMetric {
  final double value;
  final String date;
  final String unit;

  GrowthMetric({required this.value, required this.date, required this.unit});

  String get formattedValue => '${value.toStringAsFixed(1)} $unit';
  DateTime get dateTime => DateTime.parse(date);
}

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
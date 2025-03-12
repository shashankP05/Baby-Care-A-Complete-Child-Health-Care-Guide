  import 'package:flutter/material.dart';
  import 'down_syndrome_detection.dart';
  import 'autism_detection.dart';

  class DiseaseDetectionPage extends StatelessWidget {
    const DiseaseDetectionPage({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Health Screening",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF5F7FA),
                const Color(0xFFC3CFE2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Screening Type",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDetectionCard(
                          context,
                          title: 'Down Syndrome Screening',
                          description: 'Early detection through facial analysis',
                          icon: Icons.favorite_border,
                          color: const Color(0xFF3498DB),
                          page:  DownSyndromeDetectionPage(),
                        ),
                        const SizedBox(height: 20),
                        _buildDetectionCard(
                          context,
                          title: 'Autism Screening',
                          description: 'Behavioral pattern analysis',
                          icon: Icons.psychology,
                          color: const Color(0xFF9B59B6),
                          page:  AutismDetectionPage(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildDetectionCard(
        BuildContext context, {
          required String title,
          required String description,
          required IconData icon,
          required Color color,
          required Widget page,
        }) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
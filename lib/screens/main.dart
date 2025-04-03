import 'package:flutter/material.dart';

Color customRed = Color(0xFF961818);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top-left half-circle
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: customRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: customRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom-right half-circle
          // Positioned(
          //   bottom: -50,
          //   right: -50,
          //   child: Container(
          //     width: 150,
          //     height: 150,
          //     decoration: BoxDecoration(
          //       color: customRed,
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 49),
                Text(
                  "Heyyy Food Bestie!",
                  style: TextStyle(fontSize: 28, color: customRed),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shania",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: customRed),
                          ),
                          Text(
                            "Shamuyarona",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: customRed),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/food1.jpg',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Your Details",
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: customRed),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildInfoCard(
                          "Semester Balance", "Spring 2025", "GHC 9000", 'assets/food2.jpg'),
                      _buildInfoCard(
                          "Daily Limit", "Spring 2025", "GHC 100", 'assets/food3.jpg'),
                      _buildInfoCard(
                          "Day's Balance", "Spring 2025", "GHC 90", 'assets/food4.jpg'),
                      _buildInfoCard(
                          "Meal Plan Type", "Spring 2025", "100 Limit", 'assets/food6.jpg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, String value, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: customRed,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
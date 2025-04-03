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

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: customRed),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
      ),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
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
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
                ],
              ),
            ),
          ),

          // Red Circles Background
          // Positioned(
          //   top: -50,
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
          // Positioned(
          //   bottom: -50,
          //   left: -50,
          //   child: Container(
          //     width: 150,
          //     height: 150,
          //     decoration: BoxDecoration(
          //       color: customRed,
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),

          // Sidebar Overlay
          if (_isSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),

          // Sidebar
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isSidebarOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: SideBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, String value, String imagePath) {
    return Container(
      padding: EdgeInsets.all(10), // Fixed: Moved padding here
      decoration: BoxDecoration(
        color: customRed,
        borderRadius: BorderRadius.circular(20),
      ),
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

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: customRed,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "FEATURES",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            _buildMenuItem("Account", Icons.person),
            _buildMenuItem("Pin Change", Icons.lock),
            _buildMenuItem("Eating Goals", Icons.restaurant),
            _buildMenuItem("Meal Usage & Insights", Icons.insights),
            _buildMenuItem("Share", Icons.share),
          ],
        ),
      ),
    );
  }

Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

}
import 'package:flutter/material.dart';
import "eating_goals.dart";
import "../services/api_services.dart";

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
  double? balance;
  String? firstname;
  String? lastname;
  String? funder;
  double? dailyLimit;
  String? cardType;
  String? status;

  Map<String, dynamic>? mealData;

  @override
  void initState() {
    super.initState();
    fetchBalance();
    fetchMealPlanData();
  }

  void fetchBalance() async {
    double newBalance = await ApiService().getCurrentBalance("83092025");
    setState(() {
      balance = newBalance;
    });
  }

  void fetchMealPlanData() async {
    try {
      Map<String, dynamic> data =
          await ApiService().getMealPlanData("83092025");

      setState(() {
        mealData = data;
        balance = data['current_balance'];
        funder = data['funder'] ?? "N/A";
        firstname = data['firstname'];
        lastname = data['lastname'];
        dailyLimit = data['daily_spending_limit'];
        cardType = data['card_type'];
        status = data['subscriber_status'];

        // You can extract more fields from the JSON if needed, e.g.:
        // dailyLimit = data['daily_limit'];
        // mealPlanType = data['meal_plan'];
      });
    } catch (e) {
      print("Error fetching meal plan data: $e");
      // Optionally: show a snackbar or error UI
    }
  }

  Future<void> _toggleSidebar() async {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: customRed),
          onPressed: _toggleSidebar,
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
                              "$firstname",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: customRed),
                            ),
                            Text(
                              "$lastname",
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
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: customRed),
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
                          "Today Balance",
                          "$cardType",
                          "GHC ${balance?.toStringAsFixed(2)}",
                          'assets/food2.jpg'),
                      _buildInfoCard("Daily Limit", "$status",
                          "GHC ${dailyLimit}", 'assets/food3.jpg'),
                    ],
                  ),
                ],
              ),
            ),
          ),

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

  Widget _buildInfoCard(
      String title, String subtitle, String value, String imagePath) {
    return Container(
      padding: EdgeInsets.all(10),
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
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
            _buildMenuItem(
              "Account",
              Icons.person,
              () {
                // Navigate to another page if needed
              },
            ),
            _buildMenuItem(
              "Pin Change",
              Icons.lock,
              () {
                // Navigate to another page if needed
              },
            ),
            _buildMenuItem(
              "Eating Goals",
              Icons.restaurant,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyCLPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              "Meal Usage & Insights",
              Icons.insights,
              () {
                // Navigate to another page
              },
            ),
            _buildMenuItem(
              "Share",
              Icons.share,
              () {
                // Handle share logic
              },
            ),
            _buildMenuItem(
              "Logout",
              Icons.logout,
              () {
                // Handle logout
              },
            ),
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
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

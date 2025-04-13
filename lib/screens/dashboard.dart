import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "eating_goals.dart";
import "../services/api_services.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ashesi_meal_plan/screens/cafeteria.dart';
import 'package:ashesi_meal_plan/screens/meals.dart';
import 'package:ashesi_meal_plan/routes/app_routes.dart';
import "package:ashesi_meal_plan/push_notifications/firebase_api.dart";

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
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isSidebarOpen = false;
  double? balance;
  String? firstname;
  String? lastname;
  String? funder;
  double? dailyLimit;
  String? cardType;
  String? status;
  double? amount;
  String? mealPlanName;
  String? userId;

  Map<String, dynamic>? mealData;

  @override
  void initState() {
    super.initState();
    fetchBalance();
    fetchMealPlanData();
  }

  void fetchBalance() async {
    userId = await _secureStorage.read(key: 'userId');
    double newBalance = await ApiService().getCurrentBalance(userId ?? "0");
    setState(() {
      balance = newBalance;
    });
    await FirebaseApi().scheduleNotifs(
      id: int.parse(userId ?? "234567890"), // or any unique ID
      title: "Have you Spent All Your Money?",
      body: "Get a treat now",
      hour: 23,
      minute: 0,
    );
    print("I've set your reminder");
  }

  Future<void> changePin() async {
    try {
      userId = await _secureStorage.read(key: 'userId');
      Map<String, dynamic> data =
          await ApiService().changeMealPlanPin("$userId");

      if (!mounted) return;
      setState(() {
        firstname = data['firstname'];
        lastname = data['lastname'];
        userId = userId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'You have successfully changed your pin, $firstname $lastname!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something wrong happened: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void fetchMealPlanData() async {
    try {
      userId = await _secureStorage.read(key: 'userId');
      Map<String, dynamic> data = await ApiService().getMealPlanData("$userId");

      setState(() {
        mealData = data;
        balance = data['current_balance'].toDouble();
        funder = data['funder'];
        firstname = data['firstname'];
        lastname = data['lastname'];
        userId = userId;
        dailyLimit = data['daily_spending_limit'].toDouble();
        cardType = data['card_type'];
        status = data['subscriber_status'];
        amount = data['amount'].toDouble();
        mealPlanName = data['meal_plan_name'];
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something wrong happened: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
                              "${firstname ?? "loading...."}",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: customRed),
                            ),
                            Text(
                              "${lastname ?? "loading...."}",
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
                          'assets/food5.jpg',
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
                          "Semester Balance",
                          "${funder ?? "loading...."}r",
                          "GHC ${amount ?? 0.0}",
                          'assets/food1.jpg'),
                      _buildInfoCard(
                          "Today Balance",
                          "$cardType",
                          "GHC ${balance?.toStringAsFixed(2) ?? 0.0}",
                          'assets/food2.jpg'),
                      _buildInfoCard("Daily Limit", "$status",
                          "GHC ${dailyLimit ?? 0.0}", 'assets/food3.jpg'),
                      _buildInfoCard(
                          "Meal Plan Type",
                          "   ",
                          " ${mealPlanName ?? "loading...."}",
                          'assets/food4.jpg'),
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
            child: SideBar(onChangePin: changePin, userId: userId ?? "00"),
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
  final Future<void> Function() onChangePin;
  final String userId;

  const SideBar({Key? key, required this.onChangePin, required this.userId})
      : super(key: key);

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
              "Cafeteria",
              Icons.fastfood,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CafeteriaPage()),
                );
              },
            ),
            _buildMenuItem(
              "Pin Change",
              Icons.lock,
              () async {
                await onChangePin();
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => MealInsightsPage(),
                //   ),
                // );
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
                Get.offAllNamed(AppRoutes.signIn); // Handle logout
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

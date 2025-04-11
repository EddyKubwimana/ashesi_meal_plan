//DUMMY CODE FOR MEAL INSIGHTS AND USAGE PAGE

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_services.dart';


Color customRed = Color(0xFF961818);
Color lightBackground = Color(0xFFF5F5F5);

class MealInsightsPage extends StatefulWidget {
  const MealInsightsPage({super.key});

  @override
  State<MealInsightsPage> createState() => _MealInsightsPageState();
}

class _MealInsightsPageState extends State<MealInsightsPage> {
  List<MealData> weeklyUsage = [];
  List<MealData> monthlyUsage = [];
  List<MealTypeData> mealTypeDistribution = [];
  double averageDailySpending = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealInsights();
  }

  Future<void> _loadMealInsights() async {
    // Simulate API call - replace with actual API calls
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      // Sample data - replace with real data from API
      weeklyUsage = [
        MealData('Mon', 45),
        MealData('Tue', 60),
        MealData('Wed', 52),
        MealData('Thu', 70),
        MealData('Fri', 65),
        MealData('Sat', 40),
        MealData('Sun', 35),
      ];

      monthlyUsage = [
        MealData('Week 1', 280),
        MealData('Week 2', 310),
        MealData('Week 3', 295),
        MealData('Week 4', 330),
      ];

      mealTypeDistribution = [
        MealTypeData('Breakfast', 35, customRed),
        MealTypeData('Lunch', 45, Color(0xFFE53935)),
        MealTypeData('Dinner', 20, Color(0xFFEF9A9A)),
      ];

      averageDailySpending = 58.50;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: customRed,
        title: const Text(
          'Meal Usage & Insights',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: customRed))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Weekly Meal Spending'),
                  SizedBox(height: 8),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                    ),],
                    ),
                    padding: EdgeInsets.all(12),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <CartesianSeries>[
                        ColumnSeries<MealData, String>(
                          dataSource: weeklyUsage,
                          xValueMapper: (MealData data, _) => data.day,
                          yValueMapper: (MealData data, _) => data.amount,
                          color: customRed,
                          width: 0.6,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    )],
                        tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('Monthly Overview'),
                  SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                    ),],
                    ),
                    padding: EdgeInsets.all(12),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <CartesianSeries>[
                        LineSeries<MealData, String>(
                          dataSource: monthlyUsage,
                          xValueMapper: (MealData data, _) => data.day,
                          yValueMapper: (MealData data, _) => data.amount,
                          color: customRed,
                          width: 2,
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            borderWidth: 2,
                            borderColor: customRed,
                            color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Average Daily',
                          'GHC ${averageDailySpending.toStringAsFixed(2)}',
                          Icons.trending_up,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Remaining Balance',
                          'GHC 420.50',
                          Icons.account_balance_wallet,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('Meal Type Distribution'),
                  SizedBox(height: 8),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                    ),],
                    ),
                    padding: EdgeInsets.all(12),
                    child: SfCircularChart(
                      series: <CircularSeries>[
                        PieSeries<MealTypeData, String>(
                          dataSource: mealTypeDistribution,
                          xValueMapper: (MealTypeData data, _) => data.mealType,
                          yValueMapper: (MealTypeData data, _) => data.percentage,
                          pointColorMapper: (MealTypeData data, _) => data.color,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside),
                          explode: true,
                          explodeIndex: 0,
                          explodeOffset: '10%',
                        ),
                      ],
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('Recent Transactions'),
                  SizedBox(height: 8),
                  ..._buildRecentTransactions(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: customRed,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
      ),],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: customRed, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecentTransactions() {
    final transactions = [
      {'location': 'Main Cafeteria', 'amount': 12.50, 'time': 'Today, 12:45 PM'},
      {'location': 'Coffee Shop', 'amount': 8.00, 'time': 'Today, 9:30 AM'},
      {'location': 'Main Cafeteria', 'amount': 15.00, 'time': 'Yesterday, 6:15 PM'},
      {'location': 'Sandwich Bar', 'amount': 10.50, 'time': 'Yesterday, 1:00 PM'},
    ];

    return transactions.map((transaction) => Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
       ), ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: customRed.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.restaurant, color: customRed),
        ),
        title: Text(
          transaction['location'] as String,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          transaction['time'] as String,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '-GHC ${transaction['amount']}',
          style: TextStyle(
            color: customRed,
            fontWeight: FontWeight.bold,
            fontSize: 16),
        ),
      ),
    )).toList();
  }
}

class MealData {
  final String day;
  final double amount;

  MealData(this.day, this.amount);
}

class MealTypeData {
  final String mealType;
  final double percentage;
  final Color color;

  MealTypeData(this.mealType, this.percentage, this.color);
}
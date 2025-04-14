import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// Color constants
const Color customRed = Color(0xFF961818);
const Color lightBackground = Color(0xFFF5F5F5);
const Color accentColor = Color(0xFF4285F4);

class MealInsightsPage extends StatefulWidget {
  const MealInsightsPage({super.key});

  @override
  State<MealInsightsPage> createState() => _MealInsightsPageState();
}

class _MealInsightsPageState extends State<MealInsightsPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  List<dynamic> transactions = [];
  bool isLoading = true;
  String? errorMessage;
  String viewMode = 'week'; // 'week' or 'month'
  String chartView = 'spending'; // 'spending', 'categories', or 'locations'

  // Processed data
  late List<MealData> weeklyUsage;
  late List<MealData> monthlyUsage;
  late List<MealTypeData> mealTypeDistribution;
  late List<CategorySpending> categorySpending;
  late double averageDailySpending;
  late List<dynamic> recentTransactions;
  late Map<String, double> locationSpending;

  @override
  void initState() {
    super.initState();
    _fetchMealPlanHistory();
  }

  Future<void> _fetchMealPlanHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found in secure storage');
      }

      final dateFormat = DateFormat('yyyy-MM-dd');
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final response = await _dio.get(
        'https://api.mplan.ashesi.edu.gh/api/getSubscriberHistory/$userId/${dateFormat.format(startDate)}/${dateFormat.format(endDate)}',
      );

      if (response.statusCode == 200) {
        setState(() {
          transactions = response.data as List;
          _processTransactionData();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      debugPrint('Error fetching meal history: $e');
    }
  }

  List<MealData> _calculateWeeklySpending() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyTransactions = transactions.where((t) {
      final date = DateTime.parse(t['date']);
      return date.isAfter(weekAgo);
    }).toList();

    final groupedByDay = groupBy(weeklyTransactions, (t) {
      final date = DateTime.parse(t['date']);
      return DateFormat('EEE').format(date);
    });

    return groupedByDay.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, item) {
        return sum + (item['cost'] * item['quantity']);
      });
      return MealData(entry.key, total);
    }).toList();
  }

  List<MealData> _calculateMonthlySpending() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final monthlyTransactions = transactions.where((t) {
      final date = DateTime.parse(t['date']);
      return date.isAfter(monthAgo);
    }).toList();

    final groupedByWeek = groupBy(monthlyTransactions, (t) {
      final date = DateTime.parse(t['date']);
      final weekNumber = (date.difference(monthAgo).inDays / 7).floor();
      return 'Week ${weekNumber + 1}';
    });

    return groupedByWeek.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, item) {
        return sum + (item['cost'] * item['quantity']);
      });
      return MealData(entry.key, total);
    }).toList();
  }

  List<MealTypeData> _calculateMealTypeDistribution() {
    final mealTypes = {
      2: 'Lunch',
      3: 'Dinner',
      4: 'Snacks',
      9: 'Breakfast',
      10: 'Beverages'
    };

    final groupedByCategory = groupBy(transactions, (t) => t['category_id']);

    final totalSpending = transactions.fold(0.0, (sum, item) {
      return sum + (item['cost'] * item['quantity']);
    });

    if (totalSpending == 0) return [];

    return groupedByCategory.entries.map((entry) {
      final categoryTotal = entry.value.fold(0.0, (sum, item) {
        return sum + (item['cost'] * item['quantity']);
      });
      final percentage = (categoryTotal / totalSpending * 100);

      return MealTypeData(
        mealTypes[entry.key] ?? 'Category ${entry.key}',
        percentage,
        _getCategoryColor(entry.key),
      );
    }).toList();
  }

  Map<String, double> _calculateLocationSpending() {
    final groupedByLocation = groupBy(
        transactions, (t) => t['transaction_point'] ?? 'Unknown Location');

    return groupedByLocation.map((location, transactions) {
      final total = transactions.fold(0.0, (sum, item) {
        return sum + (item['cost'] * item['quantity']);
      });
      return MapEntry(location, total);
    });
  }

  Color _getCategoryColor(int categoryId) {
    final colors = [
      customRed,
      const Color(0xFFE53935),
      const Color(0xFFEF9A9A),
      const Color(0xFFC62828),
      const Color(0xFFF44336),
    ];
    return colors[categoryId % colors.length];
  }

  double _calculateAverageDailySpending() {
    final groupedByDay = groupBy(transactions, (t) {
      final date = DateTime.parse(t['date']);
      return DateTime(date.year, date.month, date.day);
    });

    final dailyTotals = groupedByDay.values.map((transactions) {
      return transactions.fold(0.0, (sum, item) {
        return sum + (item['cost'] * item['quantity']);
      });
    }).toList();

    return dailyTotals.isEmpty
        ? 0
        : dailyTotals.reduce((a, b) => a + b) / dailyTotals.length;
  }

  List<CategorySpending> _calculateCategorySpending() {
    final groupedByCategory = groupBy(transactions, (t) => t['category_id']);

    return groupedByCategory.entries.map((entry) {
      final categoryTotal = entry.value.fold(0.0, (sum, item) {
        return sum + (item['cost'] * item['quantity']);
      });

      return CategorySpending(
        'Category ${entry.key}',
        categoryTotal,
        _getCategoryColor(entry.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  void _processTransactionData() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    recentTransactions = transactions.where((t) {
      final date = DateTime.parse(t['date']);
      return date.isAfter(sevenDaysAgo);
    }).toList()
      ..sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    weeklyUsage = _calculateWeeklySpending();
    monthlyUsage = _calculateMonthlySpending();
    mealTypeDistribution = _calculateMealTypeDistribution();
    categorySpending = _calculateCategorySpending();
    averageDailySpending = _calculateAverageDailySpending();
    locationSpending = _calculateLocationSpending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: customRed,
        title: const Text('Meal Insights & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMealPlanHistory,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: customRed));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMealPlanHistory,
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: customRed),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
      return const Center(child: Text('No transaction data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 20),

          // View Mode Selector
          _buildViewModeSelector(),
          const SizedBox(height: 20),

          // Chart Type Selector
          _buildChartTypeSelector(),
          const SizedBox(height: 20),

          // Main Chart Visualization
          _buildMainChart(),
          const SizedBox(height: 20),

          // Meal Type Distribution
          _buildMealTypeChart(),
          const SizedBox(height: 20),

          // Recent Transactions
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Avg Daily',
            'GHS ${averageDailySpending.toStringAsFixed(2)}',
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Total This ${viewMode == 'week' ? 'Week' : 'Month'}',
            'GHS ${(viewMode == 'week' ? weeklyUsage : monthlyUsage).fold(0.0, (sum, item) => sum + item.amount).toStringAsFixed(2)}',
            Icons.account_balance_wallet,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: customRed, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return ToggleButtons(
      isSelected: [viewMode == 'week', viewMode == 'month'],
      onPressed: (index) {
        setState(() {
          viewMode = index == 0 ? 'week' : 'month';
        });
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: customRed,
      color: customRed,
      constraints: const BoxConstraints(
        minHeight: 40,
        minWidth: 100,
      ),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Weekly View'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Monthly View'),
        ),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    return ToggleButtons(
      isSelected: [chartView == 'spending', chartView == 'locations'],
      onPressed: (index) {
        setState(() {
          chartView = ['spending', 'locations'][index];
        });
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: accentColor,
      color: accentColor,
      constraints: const BoxConstraints(
        minHeight: 40,
      ),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('Spending'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('Locations'),
        ),
      ],
    );
  }

  Widget _buildMainChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: _getChartForCurrentView(),
    );
  }

  Widget _getChartForCurrentView() {
    switch (chartView) {
      case 'categories':
        return SfCircularChart(
          title: ChartTitle(text: 'Spending by Category'),
          legend: Legend(isVisible: true),
          series: <CircularSeries>[
            PieSeries<CategorySpending, String>(
              dataSource: categorySpending,
              xValueMapper: (CategorySpending data, _) => data.category,
              yValueMapper: (CategorySpending data, _) => data.amount,
              pointColorMapper: (CategorySpending data, _) => data.color,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
      case 'locations':
        return SfCartesianChart(
          title: ChartTitle(text: 'Spending by Location'),
          primaryXAxis: CategoryAxis(),
          series: <ChartSeries>[
            BarSeries<MapEntry<String, double>, String>(
              dataSource: locationSpending.entries.toList(),
              xValueMapper: (entry, _) => entry.key,
              yValueMapper: (entry, _) => entry.value,
              color: accentColor,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
      case 'spending':
      default:
        return SfCartesianChart(
          title: ChartTitle(text: 'Meal Spending Pattern'),
          primaryXAxis: CategoryAxis(),
          series: <ChartSeries>[
            ColumnSeries<MealData, String>(
              dataSource: viewMode == 'week' ? weeklyUsage : monthlyUsage,
              xValueMapper: (MealData data, _) => data.day,
              yValueMapper: (MealData data, _) => data.amount,
              color: customRed,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        );
    }
  }

  Widget _buildMealTypeChart() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SfCircularChart(
        title: ChartTitle(text: 'Meal Type Distribution'),
        series: <CircularSeries>[
          DoughnutSeries<MealTypeData, String>(
            dataSource: mealTypeDistribution,
            xValueMapper: (MealTypeData data, _) => data.category,
            yValueMapper: (MealTypeData data, _) => data.percent,
            pointColorMapper: (MealTypeData data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...recentTransactions.take(5).map((transaction) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                  transaction['name'] ?? 'Unknown Item',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${transaction['transaction_point']}\n${DateFormat('MMM d, y • h:mm a').format(DateTime.parse(transaction['date']))}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Text(
                  'GHS ${(transaction['cost'] * transaction['quantity']).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: customRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class MealData {
  final String day;
  final double amount;
  MealData(this.day, this.amount);
}

class MealTypeData {
  final String category;
  final double percent;
  final Color color;
  MealTypeData(this.category, this.percent, this.color);
}

class CategorySpending {
  final String category;
  final double amount;
  final Color color;
  CategorySpending(this.category, this.amount, this.color);
}

import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:flutter/material.dart';

class MealListPage extends StatelessWidget {
  final String cafeteriaName;
  final Map<String, dynamic> mealsData;

  MealListPage({
    Key? key,
    required this.cafeteriaName,
    required this.mealsData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '$cafeteriaName Meals',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: mealsData.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fastfood_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No meals found for this cafeteria',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: mealsData.keys.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final day = mealsData.keys.elementAt(index);
                  final dayMeals = mealsData[day];
                  return _buildDaySection(day, dayMeals);
                },
              ),
      ),
    );
  }

  Widget _buildDaySection(String day, Map<String, dynamic> dayMeals) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildMealTypeSection('Breakfast', dayMeals['Breakfast']),
            const SizedBox(height: 12),
            _buildMealTypeSection('Lunch', dayMeals['Lunch']),
            const SizedBox(height: 12),
            _buildMealTypeSection('Dinner', dayMeals['Dinner']),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeSection(String mealType, List<dynamic> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getMealTypeIcon(mealType),
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              mealType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        meals.isNotEmpty
            ? Column(
                children: [
                  ...meals.map((meal) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4, right: 8),
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                meal,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No meals available',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
      ],
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.wb_sunny_outlined;
      case 'Lunch':
        return Icons.lunch_dining_outlined;
      case 'Dinner':
        return Icons.nightlight_round_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }
}

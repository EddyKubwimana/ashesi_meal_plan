import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:flutter/material.dart';

class MealListPage extends StatelessWidget {
  final String cafeteriaName;
  final Map<String, dynamic> mealsData;

  // Removed 'const' from the constructor
  MealListPage({
    Key? key,
    required this.cafeteriaName,
    required this.mealsData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$cafeteriaName Meals'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: mealsData.isEmpty
            ? const Center(
                child: Text(
                  'No meals found for this cafeteria.',
                  style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: mealsData.keys.length,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildMealTypeSection('Breakfast', dayMeals['Breakfast']),
          _buildMealTypeSection('Lunch', dayMeals['Lunch']),
          _buildMealTypeSection('Dinner',
              dayMeals['Dinner']), // Fixed typo: 'MeaType' to 'MealType'
        ],
      ),
    );
  }

  // Fixed formatting: Removed newline between '_buildMealType' and 'Section'
  Widget _buildMealTypeSection(String mealType, List<dynamic> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealType,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        meals.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children: [
                        Text(
                          meals[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                      ],
                    ),
                  );
                },
              )
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  'No meals available.',
                  style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
              ),
      ],
    );
  }
}

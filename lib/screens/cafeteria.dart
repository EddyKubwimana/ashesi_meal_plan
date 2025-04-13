import 'dart:convert';

import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'MealListPage.dart';

class CafeteriaPage extends StatelessWidget {
  const CafeteriaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeterias'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            CafeteriaCard(
              name: 'HallMark',
              imagePath: 'assets/food5.jpg',
              description: 'Located near the the Patrick Nutor Building',
            ),
            CafeteriaCard(
              name: 'Arknor',
              imagePath: 'assets/food6.jpg',
              description: 'Located below the Hive & Writing Centre',
            ),
            CafeteriaCard(
              name: 'Munchies',
              imagePath: 'assets/food1.jpg',
              description: 'Located near the Walter Sisulu Student Hostel',
            ),
          ],
        ),
      ),
    );
  }
}

class CafeteriaCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final String description;

  const CafeteriaCard({
    Key? key,
    required this.name,
    required this.imagePath,
    required this.description,
  }) : super(key: key);

  // Map cafeteria names to their IDs based on the database
  static const Map<String, String> _cafeteriaIdMap = {
    'Munchies': '1',
    'Arknor': '2', // Corrected spelling to match database ("Akonnor")
    'HallMark': '3',
  };

  // Function to fetch meals from the API
  Future<Map<String, dynamic>> fetchMeals(String cafeteriaName) async {
    final cafeteriaId =
        _cafeteriaIdMap[cafeteriaName == 'Arknor' ? 'Akonnor' : cafeteriaName];
    if (cafeteriaId == null) {
      throw Exception('Cafeteria ID not found for $cafeteriaName');
    }

    final response = await http.post(
      Uri.parse('https://titans2026.pythonanywhere.com/api/view_meals'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'cafeteria-id': cafeteriaId},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load meals: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          try {
            // Fetch meals when the card is tapped
            final mealsData = await fetchMeals(name);
            // Navigate to the new MealListPage with the fetched data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealListPage(
                  cafeteriaName: name,
                  mealsData: mealsData['data'],
                ),
              ),
            );
          } catch (e) {
            // Show an error message if the API call fails
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading meals: $e')),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

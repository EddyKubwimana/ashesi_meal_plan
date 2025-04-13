import 'package:flutter/material.dart';
import "../push_notifications/firebase_api.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "edit_eating_goal.dart";
import "package:ashesi_meal_plan/main.dart" as main;

Color customRed = Color(0xFF961818);
Color lightBackground = Color(0xFFF5F5F5);

class MyCLPage extends StatefulWidget {
  const MyCLPage({super.key});
  @override
  State<MyCLPage> createState() => _MyCLPageState();
}

class _MyCLPageState extends State<MyCLPage> {
  late SharedPreferences prefs;
  Map<int, List<String>> goals = {};
  final TextEditingController myController = TextEditingController();
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      counter = int.tryParse(prefs.getString("counter") ?? "0") ?? 0;
      goals = _getStoredGoals();
      prefs.getKeys().forEach((key) {
          print('Key: $key, Value: ${prefs.get(key)}');
        });
    });
  }

  Map<int, List<String>> _getStoredGoals() {
    Map<int, List<String>> tempGoals = {};
    prefs.getKeys().forEach((key) {
      if (key != 'counter') {
        int index = int.tryParse(key) ?? -1;
        if (index != -1) {
          tempGoals[index] = prefs.getStringList(key) ?? [];
        }
      }
    });
    return tempGoals;
  }

  void _del(int index) async {
    await main.localNotifications.cancel(index);
    await prefs.remove(index.toString());
    _loadGoals();

  }

  Future<void> _sendRequest() async {
    String prompt = myController.text.trim();
    if (prompt.isEmpty) return;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: customRed,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
      initialEntryMode: TimePickerEntryMode.input,
      helpText: "Set a Reminder Time",
    );

<<<<<<< HEAD
    if (selectedTime == null) return;
=======
    if (selectedTime == null) return; // User canceled
    
    String formattedTime = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
>>>>>>> 17b39edc1526ca6195c5f637d683a25d2cb9219e

    List<String> goalEntry = [prompt, formattedTime]; 

    setState(() {
      goals[counter] = goalEntry;
      counter++;
    });

    await prefs.setStringList(counter.toString(), goalEntry);
    await prefs.setString("counter", counter.toString());

    myController.clear();
    int hour = selectedTime.hour;
    int minute = selectedTime.minute;
    await FirebaseApi().scheduleNotifs(
<<<<<<< HEAD
      id: counter,
=======
      id: counter, // or any unique ID
>>>>>>> 17b39edc1526ca6195c5f637d683a25d2cb9219e
      title: "Eating Goal",
      body: prompt,
      hour: hour,
      minute: minute,
    );
    _loadGoals();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: customRed,
        title: const Text(
          "Eating Goals",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 50, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          "No Goals Added Yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Add your first eating goal below!",
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      int key = goals.keys.elementAt(index);
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            goals[key]![0], // Goal text
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            "Reminder at ${goals[key]![1]}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: customRed),
                                onPressed: () async {
                                  bool? updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditGoalPage(goalIndex: key),
                                    ),
                                  );
                                  if (updated == true) {
                                    _loadGoals(); // Reload goals after editing
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: customRed),
                                onPressed: () {
                                  _del(key);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: myController,
                      style: TextStyle(color: customRed), 
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: InputBorder.none,
                        hintText: 'Add an eating goal...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: customRed),
                          onPressed: _sendRequest,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
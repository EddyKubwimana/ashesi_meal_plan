import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "edit_eating_goal.dart";
Color customRed = Color(0xFF961818);

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
      counter = prefs.getInt('counter') ?? 0;
      goals = _getStoredGoals();
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
    setState(() {
      goals.remove(index);
    });
    await prefs.remove(index.toString());
  }

  Future<void> _sendRequest() async {
    String prompt = myController.text.trim();
    if (prompt.isEmpty) return;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialEntryMode: TimePickerEntryMode.input,
      helpText: "Set a Reminder Time",
    );

    if (selectedTime == null) return; // User canceled

    String formattedTime = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

    List<String> goalEntry = [prompt, formattedTime]; 

    setState(() {
      goals[counter] = goalEntry;
      counter++;
    });

    await prefs.setStringList(counter.toString(), goalEntry);
    await prefs.setInt('counter', counter);
    myController.clear();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Eating Goals"),
      ),
      body: goals.isEmpty
          ? const Center(child: Text("No Goals Added"))
          : ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                int key = goals.keys.elementAt(index);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      goals[key]![0], // Goal text
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(goals[key]![1], selectionColor: Colors.white,), // Selected time
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            bool? updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditGoalPage(goalIndex: index),
                              ),
                            );

                            if (updated == true) {
                              _loadGoals(); // Reloads goals if the user made changes
                            }
                          },

                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: myController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Add an Eating Goal',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendRequest,
        child: const Icon(Icons.add),
      ),
    );
  }
}

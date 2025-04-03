import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditGoalPage extends StatefulWidget {
  final int goalIndex;
  const EditGoalPage({super.key, required this.goalIndex});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  late SharedPreferences prefs;
  final TextEditingController goalController = TextEditingController();
  String selectedTime = "00:00"; // Default time

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? goalData = prefs.getStringList(widget.goalIndex.toString());

    if (goalData != null && goalData.length == 2) {
      setState(() {
        goalController.text = goalData[0];
        selectedTime = goalData[1];
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
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

    if (pickedTime != null) {
      setState(() {
        selectedTime = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveGoal() async {
    String updatedGoal = goalController.text.trim();
    if (updatedGoal.isEmpty) return;

    await prefs.setStringList(widget.goalIndex.toString(), [updatedGoal, selectedTime]);
    Navigator.pop(context, true); // Return to the main page
  }

  @override
  void dispose() {
    goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Eating Goal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: goalController,
              decoration: const InputDecoration(
                labelText: "Edit Goal",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text("Reminder Time: $selectedTime"),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: _pickTime,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}

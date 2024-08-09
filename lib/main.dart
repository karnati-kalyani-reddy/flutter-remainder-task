import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReminderProvider(),
      child: MaterialApp(
        title: 'Reminder App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ReminderScreen(),
      ),
    );
  }
}

class ReminderProvider with ChangeNotifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ReminderProvider() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Reminder', title, platformChannelSpecifics,
        payload: 'item x');
  }
}

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  String? _selectedDay;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedActivity;
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> _activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedDay,
              hint: Text('Select Day'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDay = newValue;
                });
              },
              items: _days.map<DropdownMenuItem<String>>((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                DatePicker.showTimePicker(context, showTitleActions: true,
                    onConfirm: (time) {
                  setState(() {
                    _selectedTime =
                        TimeOfDay(hour: time.hour, minute: time.minute);
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Text('Select Time'),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedActivity,
              hint: Text('Select Activity'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedActivity = newValue;
                });
              },
              items:
                  _activities.map<DropdownMenuItem<String>>((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedDay != null && _selectedActivity != null) {
                  _scheduleNotification();
                }
              },
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleNotification() {
    final now = DateTime.now();
    final reminderTime = DateTime(
        now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    if (reminderTime.isBefore(now)) {
      reminderTime.add(Duration(days: 1));
    }

    final notificationProvider =
        Provider.of<ReminderProvider>(context, listen: false);
    notificationProvider
        .showNotification('$_selectedActivity at $_selectedTime');
  }
}

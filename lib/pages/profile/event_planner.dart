import 'package:flutter/material.dart';
import 'schedule_event_screen.dart'; // Import the schedule screen

class EventPlanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Planner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScheduleEventScreen()),
                );
              },
              child: Text('Schedule an Event'),
            ),
            // Other buttons or widgets
          ],
        ),
      ),
    );
  }
}

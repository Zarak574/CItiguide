import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:rolebase/pages/profile/edit_event_screen.dart';
import 'package:table_calendar/table_calendar.dart'; // Import the calendar package
import 'schedule_event_screen.dart'; // Import your schedule event screen

class EventsListScreen extends StatefulWidget {
  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _scheduledEvents;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scheduledEvents = _fetchScheduledEvents();
  }

  Future<List<Map<String, dynamic>>> _fetchScheduledEvents() async {
  final userId = _auth.currentUser?.uid;

  if (userId == null) {
    throw Exception('User not logged in');
  }

  final querySnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('schedules')
      .orderBy('date')
      .get();

  return querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id, // Add document ID to the data
      ...data,
    };
  }).toList();
}


  void _refreshEvents() {
    setState(() {
      _scheduledEvents = _fetchScheduledEvents();
    });
  }

  Future<void> _editEvent(String eventId, Map<String, dynamic> event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleEventScreen(
          eventId: eventId,
          initialDateTime: (event['date'] as Timestamp).toDate(),
          initialTime: event['time'],
          initialNote: event['note'],
        ),
      ),
    );
    if (result == true) {
      _refreshEvents(); 
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(26.0),
                bottomRight: Radius.circular(26.0),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 8.0, 
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TableCalendar(
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _refreshEvents(); 
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  headerStyle: const HeaderStyle(
                    headerMargin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF56C6D3),
                    ),
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                    weekendStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: Color(0xFF56C6D3), // Color for today's date
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                    defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                    weekendDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF56C6D3), // Color for selected date
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
  child: Container(
    padding: const EdgeInsets.all(16.0),
    color: Theme.of(context).colorScheme.background,
    child: FutureBuilder<List<Map<String, dynamic>>>(
      future: _scheduledEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No scheduled events found.'));
        } else {
          final events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final dateTime = (event['date'] as Timestamp?)?.toDate();
              final formattedDate = dateTime != null ? DateFormat('yyyy-MM-dd').format(dateTime) : 'No date provided';
              final formattedDateTime = dateTime != null ? '$formattedDate ${event['time'] ?? 'No time provided'}' : 'No date/time provided';

              // Alternate border colors
              Color borderColor = index.isEven ? const Color(0xFFFF8340) : const Color(0xFF56C6D3);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border(
                    left: BorderSide(
                      color: borderColor,
                      width: 8.0, // Width of the left border
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['note'] ?? 'No note provided',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            formattedDateTime,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add Edit and Delete buttons
                   IconButton(
                      icon: Icon(Icons.edit, color: Color(0xFF56C6D3)),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditScheduleScreen(
                              eventId: event['id'] ?? '',  // Pass the event ID
                              eventData: event,  // Pass the event data
                            ),
                          ),
                        );
                        if (result == true) {
                          _refreshEvents(); // Refresh the events list after editing
                        }
                      },
                    ),
                  IconButton(
  icon: Icon(Icons.delete, color: Color(0xFFFF8340),),
  onPressed: () {
    if (event['id'] != null) {
      _showDeleteConfirmationDialog(event['id']);
    } else {
      print('Error: Event ID is null');
    }
  },
)


                  ],
                ),
              );
            },
          );
        }
      },
    ),
  ),
),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScheduleEventScreen()),
          );
          if (result == true) {
            _refreshEvents(); 
          }
        },
        child: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: const Color(0xFFFF8340),
      ),
    );
  }

 void _showDeleteConfirmationDialog(String eventId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _deleteEvent(eventId); // Delete the event
            },
            child: Text('Delete', style: TextStyle(color: Color(0xFFFF8340),),),
          ),
        ],
      );
    },
  );
}



Future<void> _deleteEvent(String eventId) async {
  if (eventId == null || eventId.isEmpty) {
    print('Error: Event ID is null or empty');
    return;
  }

  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print('Error: User not logged in');
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('schedules')
        .doc(eventId)
        .delete();

    _refreshEvents(); // Refresh the events list after deletion
  } catch (e) {
    print('Error deleting event: $e');
  }
}



}

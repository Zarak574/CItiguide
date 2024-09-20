
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EditEventScreen extends StatefulWidget {
//   final Map<String, dynamic> eventData;

//   EditEventScreen({Key? key, required this.eventData}) : super(key: key);

//   @override
//   _EditEventScreenState createState() => _EditEventScreenState();
// }

// class _EditEventScreenState extends State<EditEventScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late TextEditingController _noteController;
//   late TextEditingController _timeController;

//   @override
//   void initState() {
//     super.initState();
//     _noteController = TextEditingController(text: widget.eventData['note']);
//     _timeController = TextEditingController(text: widget.eventData['time']);
//   }

//   @override
//   void dispose() {
//     _noteController.dispose();
//     _timeController.dispose();
//     super.dispose();
//   }

//   Future<void> _updateEvent() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId != null) {
//         await _firestore
//             .collection('users')
//             .doc(userId)
//             .collection('schedules')
//             .doc(widget.eventData['id'])
//             .update({
//           'note': _noteController.text,
//           'time': _timeController.text,
//         });
//         Navigator.pop(context, true); // Return true to indicate success
//       }
//     } catch (e) {
//       print('Error updating event: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Event'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             TextField(
//               controller: _noteController,
//               decoration: InputDecoration(labelText: 'Note'),
//             ),
//             TextField(
//               controller: _timeController,
//               decoration: InputDecoration(labelText: 'Time'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _updateEvent,
//               child: Text('Update Event'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditScheduleScreen extends StatefulWidget {
  final String eventId;

  EditScheduleScreen({required this.eventId, required Map<String, dynamic> eventData});

  @override
  _EditScheduleScreenState createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final docSnapshot = await _firestore.collection('users').doc(userId).collection('schedules').doc(widget.eventId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
        _timeController.text = data['time'] ?? '';
        _noteController.text = data['note'] ?? '';
      });
    } else {
      // Handle case where the document does not exist
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_dateController.text.isNotEmpty ? _dateController.text : DateFormat('yyyy-MM-dd').format(DateTime.now())),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(_timeController.text.isNotEmpty ? _timeController.text : DateFormat('HH:mm').format(DateTime.now())),
      ),
    );
    if (selectedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      setState(() {
        _timeController.text = DateFormat('HH:mm').format(selectedDateTime);
      });
    }
  }

  Future<void> _updateSchedule() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final date = DateTime.parse(_dateController.text);
    final time = _timeController.text;
    final note = _noteController.text;

    await _firestore.collection('users').doc(userId).collection('schedules').doc(widget.eventId).update({
      'date': Timestamp.fromDate(date),
      'day': DateFormat('EEEE').format(date),
      'time': time,
      'note': note,
    });

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final userId = _auth.currentUser?.uid;
              if (userId == null) {
                throw Exception('User not logged in');
              }

              await _firestore.collection('users').doc(userId).collection('schedules').doc(widget.eventId).delete();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.secondary,
                filled: true,
                labelText: 'Date',
                labelStyle: TextStyle(color: Color(0xFF56C6D3), fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () => _selectDate(context),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.secondary,
                filled: true,
                labelText: 'Time',
                labelStyle: TextStyle(color: Color(0xFF56C6D3), fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () => _selectTime(context),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.secondary,
                filled: true,
                labelText: 'Note',
                labelStyle: TextStyle(color: Color(0xFF56C6D3), fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8340),
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Update Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

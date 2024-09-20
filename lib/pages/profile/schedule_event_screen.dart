import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ScheduleEventScreen extends StatefulWidget {
  final String? eventId;
  final DateTime? initialDateTime;
  final String? initialTime;
  final String? initialNote;

  ScheduleEventScreen({this.eventId, this.initialDateTime, this.initialTime, this.initialNote});

  @override
  _ScheduleEventScreenState createState() => _ScheduleEventScreenState();
}

class _ScheduleEventScreenState extends State<ScheduleEventScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.initialDateTime != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(widget.initialDateTime!);
      _timeController.text = widget.initialTime ?? '';
      _noteController.text = widget.initialNote ?? '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null && selectedDate != widget.initialDateTime) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.initialDateTime ?? DateTime.now()),
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

  Future<void> _saveSchedule() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final date = DateTime.parse(_dateController.text);
    final time = _timeController.text;
    final note = _noteController.text;

    if (widget.eventId == null) {
      // Add new event
      await _firestore.collection('users').doc(userId).collection('schedules').add({
        'date': Timestamp.fromDate(date),
        'day': DateFormat('EEEE').format(date),
        'time': time,
        'note': note,
      });
    } else {
      // Update existing event
      await _firestore.collection('users').doc(userId).collection('schedules').doc(widget.eventId).update({
        'date': Timestamp.fromDate(date),
        'day': DateFormat('EEEE').format(date),
        'time': time,
        'note': note,
      });
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Add Event' : 'Edit Event'),
        actions: [
          if (widget.eventId != null)
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
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8340),
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                widget.eventId == null ? 'Save Schedule' : 'Update Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

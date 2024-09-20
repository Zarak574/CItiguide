// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class CityDetailsPage extends StatefulWidget {
//   final String city;

//   CityDetailsPage({required this.city});

//   @override
//   _CityDetailsPageState createState() => _CityDetailsPageState();
// }

// class _CityDetailsPageState extends State<CityDetailsPage> {
//   List<String> landmarks = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchLandmarks(widget.city);
//   }

//   Future<void> fetchLandmarks(String city) async {
//     final apiKey = 'AIzaSyDhG3hgTnf0v-0WGjp5YZlLDrrx7_LPRjU';
//     final query = 'landmark in $city';
//     final url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List<String> fetchedLandmarks = [];

//         for (var place in data['results']) {
//           fetchedLandmarks.add(place['name']);
//         }

//         setState(() {
//           landmarks = fetchedLandmarks;
//         });
//       } else {
//         throw Exception('Failed to load landmarks');
//       }
//     } catch (e) {
//       print('Error fetching landmarks: $e');
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Failed to fetch landmarks. Please check your internet connection and API key.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Landmarks in ${widget.city}'),
//       ),
//       body: ListView.builder(
//         itemCount: landmarks.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(landmarks[index]),
//           );
//         },
//       ),
//     );
//   }
// }

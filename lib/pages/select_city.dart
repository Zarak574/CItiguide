// import 'package:flutter/material.dart';
// import 'package:rolebase/pages/fetch_place.dart';

// class CitySelectionPage extends StatefulWidget {
//   @override
//   _CitySelectionPageState createState() => _CitySelectionPageState();
// }

// class _CitySelectionPageState extends State<CitySelectionPage> {
//   String selectedCity = ''; // State variable to hold selected city
//   List<String> cities = ['New York', 'London', 'Paris', 'Tokyo']; // List of cities

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select City'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             DropdownButtonFormField<String>(
//               value: selectedCity.isNotEmpty ? selectedCity : null,
//               hint: Text('Select a city'), // Placeholder text
//               onChanged: (String? value) {
//                 setState(() {
//                   selectedCity = value!;
//                 });
//               },
//               items: cities.map((String city) {
//                 return DropdownMenuItem<String>(
//                   value: city,
//                   child: Text(city),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () {
//                 if (selectedCity.isNotEmpty) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CityDetailsPage(city: selectedCity),
//                     ),
//                   );
//                 } else {
//                   // Handle case where no city is selected
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: Text('Error'),
//                       content: Text('Please select a city.'),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           child: Text('OK'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//               },
//               child: Text('Show Details'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

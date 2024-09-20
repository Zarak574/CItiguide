

import 'package:flutter/material.dart';
import 'package:rolebase/pages/place_details.dart';

class SearchBox extends StatefulWidget {
  final Function(String) onSearchTextChanged;
  final List<Map<String, dynamic>> suggestions;

  SearchBox({required this.onSearchTextChanged, required this.suggestions, required TextEditingController controller});

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  void navigateToDetailScreen(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetails(record: record),
      ),
    );
  }

  @override
 Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child:  Stack(
          children: [
          TextField(
          onChanged: widget.onSearchTextChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 8,),
            hintText: 'Search by name, city, or category',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.inversePrimary,  
            ),
            prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0), 
                  child: Icon(
                    Icons.search,
                    color: Color(0xFFFF8340),
                  ),
                ),
            // filled: true, 
            // fillColor: Theme.of(context).colorScheme.primary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Color(0xFFFF8340),),
            ),
            enabledBorder: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: const Color(0xFFFF8340)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFFFF8340),),
            ),
          ),
        ),
        Positioned(
              left: 35,
              top: 12,
              bottom: 12,
              child: Container(
                width: 1,
                color: Color(0xFFFF8340),
              ),
            ),
          ],
      ),
      ),
      SizedBox(height: 10),
    ],
  );
}
}

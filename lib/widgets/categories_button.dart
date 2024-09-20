import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rolebase/pages/all_places.dart';
import 'package:rolebase/pages/categories/accommodation.dart';
import 'package:rolebase/pages/categories/adventure.dart';
import 'package:rolebase/pages/categories/beach.dart';
import 'package:rolebase/pages/categories/culture.dart';
import 'package:rolebase/pages/categories/desert.dart';
import 'package:rolebase/pages/categories/dining.dart';
import 'package:rolebase/pages/categories/forest.dart';
import 'package:rolebase/pages/categories/heritage.dart';
import 'package:rolebase/pages/categories/mountain.dart';
import 'package:rolebase/pages/categories/others.dart';
import 'package:rolebase/pages/categories/religious.dart';
import 'package:rolebase/pages/categories/souvenir.dart';

class CategoriesButton extends StatefulWidget {
  const CategoriesButton({Key? key}) : super(key: key);

  @override
  _CategoriesButtonState createState() => _CategoriesButtonState();
}

class _CategoriesButtonState extends State<CategoriesButton> {
  List<String> categories = [];
  final databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      var snapshot = await databaseReference.child('records').once();
      
      if (snapshot.snapshot.value != null) {
        DataSnapshot dataSnapshot = snapshot.snapshot;
        Map<dynamic, dynamic>? values = dataSnapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<String> categoryNames = [];

          values.forEach((key, value) {
            if (value['category'] != null) {
              String category = value['category'].toString().trim().toLowerCase();
              if (!categoryNames.contains(category)) {
                categoryNames.add(category);
              }
            }
          });

          categoryNames.sort();

          setState(() {
            categories = categoryNames;
          });
        }
      } else {
        print('No records found.');
      }
    } catch (error) {
      print('Error fetching records: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return _buildTouristPlaceButton(
              category: category,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _getCategoryPage(category),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTouristPlaceButton({
    required String category,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 35,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: Center(
          child: Text(
            category[0].toUpperCase() + category.substring(1),
            style: const TextStyle(
              color: Color(0xFFFF8340),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCategoryPage(String category) {
    switch (category) {
      case 'mountains':
        return MountainPage();
      case 'beaches':
        return BeachPage();
      case 'forest':
        return ForestPage();
      case 'other':
        return OthersPage();
      case 'deserts':
        return DesertPage();
      case 'heritage':
        return HeritagePage();
      case 'adventure':
        return AdventurePage();
      case 'culture':
        return CulturePage();
      case 'dining':
        return DiningPage();
      case 'accommodation':
        return AccommodationPage();
      case 'souvenirs':
        return SouvenirPage();
      case 'religious':
        return ReligiousPage();
      default:
        return AllPlaces();
    }
  }
}

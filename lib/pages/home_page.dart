import 'package:flutter/material.dart';
import 'package:rolebase/pages/all_places.dart';
import 'package:rolebase/pages/categories/others.dart';
import 'package:rolebase/pages/place_details.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/custom_card.dart';
import 'package:rolebase/widgets/heading.dart';
import 'package:rolebase/widgets/my_drawer.dart';
import 'package:rolebase/widgets/famous_destinations.dart';
import 'package:rolebase/widgets/recommended_places.dart';
import 'package:rolebase/widgets/search_box.dart';
import 'package:rolebase/widgets/categories_button.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  static String routeName = "/home";
  HomePage({Key? key,}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
   int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('records');
  List<Map<String, dynamic>> allRecords = [];
  List<Map<String, dynamic>> suggestions = [];
  List<Map<String, dynamic>> records = [];
  List<Map<String, dynamic>> displayedRecords = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      var snapshot = await databaseReference.once();

      if (snapshot.snapshot.value != null) {
        DataSnapshot dataSnapshot = snapshot.snapshot;
        Map<dynamic, dynamic>? values =
            dataSnapshot.value as Map<dynamic, dynamic>?;

         List<Map<String, dynamic>> fetchedRecords = [];

        values?.forEach((key, value) {
          fetchedRecords.add({
            'key': key,
            'name': value['name'],
            'location': value['location'],
            'category': value['category'],
            'city': value['city'],
            'description': value['description'],
            'imageUrl': value['imageUrl'],
            'latitude': value['latitude'],
            'longitude': value['longitude'],
          });
        });

        setState(() {
          allRecords = fetchedRecords;
        });
      } else {
        print('No records found.');
      }
    } catch (error) {
      print('Error fetching records: $error');
    }
  }

  void filterSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        suggestions.clear();
      });
    } else {
      setState(() {
        suggestions = allRecords.where((record) {
          return record['name'].toLowerCase().contains(query.toLowerCase()) ||
              record['location'].toLowerCase().contains(query.toLowerCase()) ||
              record['city'].toLowerCase().contains(query.toLowerCase()) ||
              record['category'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void navigateToDetailScreen(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetails(record: record),
      ),
    );
  }

  void searchRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedRecords = allRecords;
      } else {
        displayedRecords = allRecords.where((record) {
          return record['name'].toLowerCase().contains(query.toLowerCase()) ||
              record['location'].toLowerCase().contains(query.toLowerCase()) ||
              record['city'].toLowerCase().contains(query.toLowerCase()) ||
              record['category'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body:  
       Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                  const CustomCard(),
                  const SizedBox(height: 10),
                  SearchBox(
                      onSearchTextChanged: filterSuggestions,
                      controller: _searchController, suggestions: suggestions,
                    ),
                  if (suggestions.isNotEmpty)
                    Container(
                      height: 150, 
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                       child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> suggestion = suggestions[index];
                          
                          return InkWell(
                            onTap: () {
                              navigateToDetailScreen(suggestion);
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              suggestion['name'],
                                              style: const TextStyle(
                                                fontSize: 14, 
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  suggestion['city'],
                                                  style: const TextStyle(
                                                    fontSize: 12, 
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                const Text(
                                                  ', ', 
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  suggestion['category'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 3,),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 10),
              const HeadingWidget(title: 'Categories'),
              const SizedBox(height: 10),
              const CategoriesButton(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const HeadingWidget(title: 'Recommendation'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OthersPage()),
                      );
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(color: Color(0xFF0B91A0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RecommendedPlaces(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 
                   const HeadingWidget(title: 'Famous Landmarks'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllPlaces()),
                      );
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(color: Color(0xFF0B91A0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
               FamousDestinations(),
            ],
          ),
          ),
          ),
         bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
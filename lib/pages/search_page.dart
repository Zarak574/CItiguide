import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rolebase/pages/place_details.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/my_drawer.dart';
import 'package:rolebase/widgets/search_box.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
   int _currentIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('records');
  List<Map<String, dynamic>> allRecords = [];
  List<Map<String, dynamic>> suggestions = [];
  List<Map<String, dynamic>> displayedRecords = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRecords();
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

  Future<void> fetchRecords() async {
    try {
      var snapshot = await databaseReference.once();
      if (snapshot.snapshot.value != null) {
        DataSnapshot dataSnapshot = snapshot.snapshot;
        Map<dynamic, dynamic>? values = dataSnapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<Map<String, dynamic>> fetchedRecords = [];
          values.forEach((key, value) {
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
            displayedRecords = fetchedRecords; 
          });
        }
      } else {
        print('No records found.');
      }
    } catch (error) {
      print('Error fetching records: $error');
    }
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
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left:8, right: 8, top: 10),
            child: SearchBox(
              onSearchTextChanged: filterSuggestions,
              controller: _searchController,
              suggestions: suggestions,
            ),
          ),
          const SizedBox(height: 10,),
          if (suggestions.isNotEmpty)
            Container(
              height: 450,
              padding: const EdgeInsets.symmetric(vertical: 10), 
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> suggestion = suggestions[index];
                  return InkWell(
                    onTap: () {
                      navigateToDetailScreen(suggestion);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16), 
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary, 
                        borderRadius: BorderRadius.circular(8), 
                       
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0), 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.inversePrimary
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        suggestion['city'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.inversePrimary
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ', ',
                                        style: TextStyle(
                                          fontSize: 16,
                                         color: Theme.of(context).colorScheme.inversePrimary
                                        ),
                                      ),
                                      Text(
                                        suggestion['category'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.inversePrimary
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
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

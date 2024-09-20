import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rolebase/pages/place_details.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/heading.dart';
import 'package:rolebase/widgets/my_drawer.dart';


class CityRecordPage extends StatefulWidget {
  final String city;

  const CityRecordPage({Key? key, required this.city}) : super(key: key);

  @override
  _CityRecordPageState createState() => _CityRecordPageState();
}

class _CityRecordPageState extends State<CityRecordPage> {
  
     int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  User? user;
  Set<String> bookmarkedPlaces = Set<String>();
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('records');
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchCityRecords(widget.city);
  }

  Future<void> fetchCityRecords(String city) async {
    try {
      var snapshot = await _databaseReference.once();

      if (snapshot.snapshot.value != null) {
        DataSnapshot dataSnapshot = snapshot.snapshot;
        Map<dynamic, dynamic>? values =
            dataSnapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<Map<String, dynamic>> fetchedCityRecords = [];

          values.forEach((key, value) {
            if (value['city'] == city) {
              fetchedCityRecords.add({
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
            }
          });

          setState(() {
            records = fetchedCityRecords;
          });
        }
      } else {
        print('No records found.');
      }
    } catch (error) {
      print('Error fetching records: $error');
    }
  }

  Future<void> fetchBookmarkedPlaces() async {
    if (user == null) return;

    final userId = user!.uid;
    final bookmarksRef = FirebaseDatabase.instance.ref().child('users').child(userId).child('bookmarks');

    try {
      final snapshot = await bookmarksRef.get();
      if (snapshot.exists) {
        final bookmarks = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          bookmarkedPlaces = bookmarks.keys.cast<String>().toSet();
        });
      }
    } catch (error) {
      print('Error fetching bookmarks: $error');
    }
  }

  Future<void> toggleBookmark(Map<String, dynamic> place) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to bookmark places.')),
      );
      return;
    }

    final userId = user!.uid;
    final bookmarkRef = FirebaseDatabase.instance.ref().child('users').child(userId).child('bookmarks').child(place['key']);

    try {
      final snapshot = await bookmarkRef.get();
      if (snapshot.exists) {
        await bookmarkRef.remove();
        setState(() {
          bookmarkedPlaces.remove(place['key']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from bookmarks.')),
        );
      } else {
        await bookmarkRef.set({
          'name': place['name'],
          'location': place['location'],
          'imageUrl': place['imageUrl'],
          'rating': place['rating'],
        });
        setState(() {
          bookmarkedPlaces.add(place['key']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to bookmarks.')),
        );
      }
    } catch (error) {
      print('Error toggling bookmark: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to toggle bookmark.')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           const Padding(
            padding: EdgeInsets.all(16.0),
            child: HeadingWidget(
              title: 'Filtered By City',
            ),
          ),
          Expanded(
            child: GridView.builder( 
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two items per row
                crossAxisSpacing: 8.0, // Space between columns
                mainAxisSpacing: 8.0, // Space between rows
                childAspectRatio: 0.75, // Aspect ratio of the child
              ),
              itemCount: records.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> record = records[index];
                // String description = record['description'];
                // String trimmedDescription =
                //     description.length > 100 ? description.substring(0, 100) + '...' : description;
                 final isBookmarked = bookmarkedPlaces.contains(record['key']);
                return GestureDetector(
                  onTap: () {
                    navigateToDetailScreen(record);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0), // Margin around each card
                    padding: const EdgeInsets.all(8.0), // Padding inside each card
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 120, // Fixed height for the image
                                child: record['imageUrl'] != null
                                    ? Image.network(
                                        record['imageUrl'],
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        color: Colors.grey,
                                      ),
                              ),
                           Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record['name'],
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.inversePrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4), 
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Color(0xFFB75019),
                                              size: 16,
                                            ),
                                            Text(
                                              record['city'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).colorScheme.inversePrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4), 
                                    Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow.shade700,
                                              size: 16,
                                            ),
                                            Text(
                                              record['rating'].toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).colorScheme.inversePrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 0, // Increased space from bottom
                            right: 0, // Increased space from right
                            child: IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: const Color(0xFF56C6D3),
                                size: 24, // Adjusted icon size
                              ),
                              onPressed: () => toggleBookmark(record),
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

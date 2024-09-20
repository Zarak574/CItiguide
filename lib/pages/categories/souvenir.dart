import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rolebase/pages/place_details.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/heading.dart';
import 'package:rolebase/widgets/my_drawer.dart';

class SouvenirPage extends StatefulWidget {
  @override
  _SouvenirPageState createState() => _SouvenirPageState();
}

class _SouvenirPageState extends State<SouvenirPage> {
  
     int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  List<Map<String, dynamic>> records = [];
  User? user;
  Set<String> bookmarkedPlaces = Set<String>();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchMountainRecords();
  }

  Future<void> fetchMountainRecords() async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('records');
      final snapshot = await dbRef.orderByChild('category').equalTo('Souvenirs').once();

      if (snapshot.snapshot.value != null) {
        final values = snapshot.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          records = values.entries.map((entry) {
            final value = entry.value as Map<dynamic, dynamic>;
            return {
              'key': entry.key,
              'name': value['name'],
              'location': value['location'],
              'category': value['category'],
              'city': value['city'],
              'description': value['description'],
              'latitude': value['latitude'],
              'longitude': value['longitude'],
              'imageUrl': value['imageUrl'],
              'rating': value['rating'] ?? 4.4,
            };
          }).toList();
        });
        fetchBookmarkedPlaces();
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
              title: 'Shopping for Souvenirs',
            ),
          ),
          Expanded(
            child: GridView.builder( 
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0, 
                mainAxisSpacing: 8.0, 
                childAspectRatio: 0.75,
              ),
              itemCount: records.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> record = records[index];
                final isBookmarked = bookmarkedPlaces.contains(record['key']);
                return GestureDetector(
                  onTap: () {
                    navigateToDetailScreen(record);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0), 
                    padding: const EdgeInsets.all(8.0), 
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
                                height: 120,
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
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: const Color(0xFF56C6D3),
                                size: 24, 
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

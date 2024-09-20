import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rolebase/pages/place_details.dart';

class FamousDeserts extends StatefulWidget {
  @override
  _FamousDestinationsState createState() => _FamousDestinationsState();
}

class _FamousDestinationsState extends State<FamousDeserts> {
  List<Map<String, dynamic>> FamousDeserts = [];
  User? user;
  Set<String> bookmarkedPlaces = Set<String>();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchFamousDestinations();
  }

  Future<void> fetchFamousDestinations() async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('records');
      final snapshot = await dbRef.orderByChild('category').equalTo('Deserts').once();

      if (snapshot.snapshot.value != null) {
        final values = snapshot.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          FamousDeserts = values.entries.map((entry) {
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
         // Fetch bookmarks after fetching recommended places
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
        SnackBar(content: Text('You need to be logged in to bookmark places.')),
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
          SnackBar(content: Text('Removed from bookmarks.')),
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
          SnackBar(content: Text('Added to bookmarks.')),
        );
      }
    } catch (error) {
      print('Error toggling bookmark: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle bookmark.')),
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
    return Container(
      height: 235,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: FamousDeserts.length,
        itemBuilder: (context, index) {
          final place = FamousDeserts[index];
          final isBookmarked = bookmarkedPlaces.contains(place['key']);
          return SizedBox(
            width: 220,
            child: Card(
              color: Theme.of(context).colorScheme.secondary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => navigateToDetailScreen(place),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              place['imageUrl'],
                              width: double.maxFinite,
                              fit: BoxFit.cover,
                              height: 150,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  place['name'],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow.shade700,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    place['rating'].toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFFB75019),
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                place['location'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: IconButton(
                       icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Color(0xFF56C6D3) :Color(0xFF56C6D3),
                          size: 30,
                        ),
                        onPressed: () => toggleBookmark(place),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(right: 10),
        ),
      ),
    );
  }
}

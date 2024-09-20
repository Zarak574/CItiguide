import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rolebase/pages/place_details.dart';

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> bookmarks = [];
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      fetchBookmarks();
    }
  }

  Future<void> fetchBookmarks() async {
    try {
      final userId = user!.uid;
      final bookmarksRef = FirebaseDatabase.instance.ref().child('users').child(userId).child('bookmarks');
      final snapshot = await bookmarksRef.once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          bookmarks = values.entries.map((entry) {
            final value = entry.value;
            return {
              'key': entry.key,
              'name': value['name'],
              'location': value['location'],
              'imageUrl': value['imageUrl'],
              'rating': value['rating'],
            };
          }).toList();
        });
      } else {
        print('No bookmarks found.');
      }
    } catch (error) {
      print('Error fetching bookmarks: $error');
    }
  }

  Future<void> removeBookmark(String key) async {
    if (user == null) return;

    final userId = user!.uid;
    final bookmarkRef = FirebaseDatabase.instance.ref().child('users').child(userId).child('bookmarks').child(key);

    try {
      await bookmarkRef.remove();
      setState(() {
        bookmarks.removeWhere((bookmark) => bookmark['key'] == key);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed.')),
      );
    } catch (error) {
      print('Error removing bookmark: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove bookmark.')),
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
      appBar: AppBar(
        title: const Text('Saved'),
      ),
      body: bookmarks.isEmpty
          ? const Center(child: Text('No bookmarks found.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.90, // Adjusted to fit two cards in a row with reduced height
              ),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final place = bookmarks[index];
                return Card(
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
                          padding: const EdgeInsets.all(8), // Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  place['imageUrl'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  height: 100, // Reduced height
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                place['name'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  fontSize: 14, // Slightly reduced font size
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow.shade700,
                                    size: 12, // Reduced size
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
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFB75019),
                                    size: 14, // Reduced size
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
                          bottom: 2, // Adjusted position
                          right: 2, // Adjusted position
                          child: IconButton(
                            icon: const Icon(
                              Icons.bookmark,
                              color: Color(0xFF56C6D3),
                              size: 25,
                            ),
                            onPressed: () => removeBookmark(place['key']),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
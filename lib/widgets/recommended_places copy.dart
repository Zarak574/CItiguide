import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rolebase/pages/place_details.dart';

class RecommendedPlaces extends StatefulWidget {
  const RecommendedPlaces({Key? key}) : super(key: key);

  @override
  State<RecommendedPlaces> createState() => _RecommendedPlacesState();
}

class _RecommendedPlacesState extends State<RecommendedPlaces> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> records = [];

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
        List<Map<String, dynamic>> fetchedRecords = [];
        values.forEach((key, value) {
          print('Fetched record: $key -> $value'); // Debug print
          if (value['category'] == 'Others') {
            fetchedRecords.add({
              'key': key,
              'name': value['name'],
              'location': value['location'],
              'category': value['category'],
              'city': value['city'],
              'description': value['description'],
              'latitude': value['latitude'],
              'longitude': value['longitude'],
              'imageUrl': value['imageUrl'],
            });
          }
        });
        print('Fetched records: $records');
        setState(() {
          records = fetchedRecords;
        });
      } else {
        print('No valid data found.');
      }
    } else {
      print('No records found.');
    }
  } catch (error) {
    print('Error fetching records: $error');
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

Widget buildOtherRecords() {
  return Container(
    height: 235, 
    child: ListView.separated(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return SizedBox(
          width: 220,
          
          child: Card(
            color: Theme.of(context).colorScheme.secondary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                navigateToDetailScreen(records[index]);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        records[index]['imageUrl'],
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
                            records[index]['name'],
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
                              "4.4",
                              style: TextStyle(
                                 color: Theme.of(context).colorScheme.inversePrimary,
                                fontSize: 12,
                              ),
                            )
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
                          records[index]['city'],
                          style: TextStyle(
                             color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          records[index]['category'],
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
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(right: 10),
      ),
      itemCount: records.length > 4 ? 4 : records.length, 
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return buildOtherRecords();
  }
}


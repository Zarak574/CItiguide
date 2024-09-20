
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rolebase/pages/place_details.dart';

class FamousDestinations extends StatefulWidget {
  const FamousDestinations({super.key});

  @override
  State<FamousDestinations> createState() => _FamousDestinationsState();
}

class _FamousDestinationsState extends State<FamousDestinations> {

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
          if (value['category'] == 'Beaches' || value['category'] == 'Mountains') {
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

        setState(() {
          records = fetchedRecords;
        });
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

 @override
Widget build(BuildContext context) {
  return Column(
    children: List.generate(records.length > 4 ? 4 : records.length, (index) {
      Map<String, dynamic> record = records[index];
       String description = record['description'];
      String trimmedDescription =
      description.substring(0, description.length ~/ 4);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          height: 135,
          width: double.maxFinite,
          child: Card(
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0.4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                navigateToDetailScreen(record);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(12),
                    //   child: record['imageUrl'] != null
                    //       ? Image.network(
                    //           record['imageUrl'],
                    //           height: double.maxFinite,
                    //           width: 130,
                    //           fit: BoxFit.cover,
                    //         )
                    //       : Container(
                    //           height: double.maxFinite,
                    //           width: 130,
                    //           color: Colors.grey,
                    //         ),
                    // ),
                  ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          record['imageUrl'],
                          height: double.infinity,
                          width: 130,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            print('Stack trace: $stackTrace');
                            return Container(
                              height: double.infinity,
                              width: 130,
                              color: Colors.grey,
                              child: Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['name'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                        children: [
                          Icon(
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
                        ],
                      ),
                          const SizedBox(height: 5),
                          Text(
          trimmedDescription,
          maxLines: 2, // Show at most 2 lines
          overflow: TextOverflow.ellipsis,
        ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow.shade700,
                                size: 14,
                              ),
                              Text(
                                "4.5",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }),
  );
}

}

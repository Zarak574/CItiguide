import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rolebase/pages/account/profile/edit_record_screen.dart';
import 'package:rolebase/pages/account/profile/insertplace.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/my_drawer.dart';

class AllRecordsDisplay extends StatefulWidget {
  @override
  _AllRecordsDisplayState createState() => _AllRecordsDisplayState();
}

class _AllRecordsDisplayState extends State<AllRecordsDisplay> {
  
    int _currentIndex = 3;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
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
            fetchedRecords.add({
              'key': key,
              'name': value['name'],
              'location': value['location'],
              'category': value['category'],
              'city': value['city'],
              'description': value['description'],
              'imageUrl': value['imageUrl'],
            });
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

  void navigateToEditScreen(Map<String, dynamic> record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditRecordScreen(record: record)),
    );
  }

  void navigateToInsert() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InsertRecordForm()),
    ).then((_) {
      fetchRecords();
    });
  }

  Future<void> deleteRecord(String recordKey) async {
    try {
      await databaseReference.child('records').child(recordKey).remove();
      print('Record deleted successfully');
      fetchRecords();
    } catch (error) {
      print('Error deleting record: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       drawer: MyDrawer(),
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: navigateToInsert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF56C6D3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Insert', style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
          Expanded(
          child: ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> record = records[index];
            return Padding(
              padding: const EdgeInsets.all( 8.0), 
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary, 
                  borderRadius: BorderRadius.circular(12), 
                ),
                child: ListTile(
                  title: Text(record['name']),
                  titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                  subtitle: Text(record['location']),
                  leading: record['imageUrl'] != null
                      ? Image.network(
                          record['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey, 
                        ),
                  onTap: () {
                    navigateToEditScreen(record);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: const Color(0xFF56C6D3),
                        onPressed: () {
                          navigateToEditScreen(record);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: const Color(0xFFFF8340),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text('Delete Record', style: TextStyle(color: Color(0xFF56C6D3),),),
                                content: const Text('Are you sure you want to delete this record?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF56C6D3),),),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteRecord(record['key']);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete', style: TextStyle(color:Color(0xFFFF8340),)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
        ]
      ),
bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      )
    );
  }
}

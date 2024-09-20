import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rolebase/pages/categories/beach.dart';
import 'package:rolebase/pages/categories/city.dart';
import 'package:rolebase/pages/categories/desert.dart';
import 'package:rolebase/pages/categories/forest.dart';
import 'package:rolebase/pages/categories/mountain.dart';
import 'package:rolebase/pages/categories/others.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/famous_beaches.dart';
import 'package:rolebase/widgets/famous_deserts.dart';
import 'package:rolebase/widgets/famous_forests.dart';
import 'package:rolebase/widgets/famous_mountains.dart';
import 'package:rolebase/widgets/famous_others.dart';
import 'package:rolebase/widgets/heading.dart';
import 'package:rolebase/widgets/my_drawer.dart';

class AllPlaces extends StatefulWidget {
  static String routeName = "/home";
  const AllPlaces({Key? key}) : super(key: key);

  @override
  State<AllPlaces> createState() => _AllPlacesState();
}

class _AllPlacesState extends State<AllPlaces> {

   int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    fetchCities();
  }


  Future<void> fetchCities() async {
  try {
    DatabaseEvent snapshot = await _databaseReference.child('city').once();
    List<String> cityList = [];
    if (snapshot.snapshot.value != null) {
      List<dynamic> cityData = snapshot.snapshot.value as List<dynamic>;
      cityData.forEach((city) {
  if (city != null) {
    cityList.add(city.toString());
  }
});
    } else {
      print('No cities found.');
    }
    setState(() {
      cities = cityList;
    });
  } catch (error) {
    print('Error fetching cities: $error');
  }
}


  void navigateToCityRecordPage(String city) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CityRecordPage(city: city)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          const SizedBox(height: 10),
           Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), 
            color: Color(0xFFFFF3E0),
          ),
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    title: Text('Filter by City',
                      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: cities.map((city) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                             decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background, // Background color for each tile
                                borderRadius: BorderRadius.circular(12), 
                              ),
                            child: ListTile(
                              tileColor: Theme.of(context).colorScheme.background,
                              title: Text(city),
                              onTap: () {
                                Navigator.of(context).pop();
                                navigateToCityRecordPage(city);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, 
              elevation: 0, 
            ),
            child: const Text(
              'Filter',
              style: TextStyle(color: Color(0xFFFF8340),), 
            ),
          ),
        ),
      ],
    ),
    
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const HeadingWidget(title: 'Mountains'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MountainPage()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF56C6D3),
                  ),
                ),
              )
            ],
          ),
          FamousMountains(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const HeadingWidget(title: 'Beaches'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BeachPage()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(color: Color(0xFF0B91A0)),
                ),
              )
            ],
          ),
          FamousBeaches(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const HeadingWidget(title: 'Forests'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForestPage()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(color: Color(0xFF0B91A0)),
                ),
              )
            ],
          ),
          FamousForests(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const HeadingWidget(title: 'Deserts'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DesertPage()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(color: Color(0xFF0B91A0)),
                ),
              )
            ],
          ),
          FamousDeserts(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const HeadingWidget(title: 'Historical Sites'),
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
              )
            ],
          ),
          FamousOthers(),
        ],
      ),
     bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

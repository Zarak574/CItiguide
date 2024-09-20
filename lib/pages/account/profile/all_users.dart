import 'package:flutter/material.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/heading.dart';
import 'package:rolebase/widgets/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  int _currentIndex = 3;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: HeadingWidget(title: "All Users"),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.background,
              ),
              margin: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  final userData = userList[index];
                  final userName = userData['username'] ?? 'No username';
                  final userEmail = userData['email'] ?? 'No email';
                  final profilePictureUrl = userData['profile_picture'] ?? ''; 

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profilePictureUrl.isNotEmpty
                            ? NetworkImage(profilePictureUrl)
                            : const AssetImage('./images/placeholder.jpg'),
                      ),
                      title: Text(userName),
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      
                      subtitle: Text(userEmail),
                      subtitleTextStyle: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      onTap: () {
                        // Handle user tap
                      },
                    ),
                  );
                },
              ),
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

  Future<void> fetchAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isNotEqualTo: 'admin@gmail.com') 
          .get();

      if (querySnapshot.docs.isNotEmpty) {
      
        final users = querySnapshot.docs.map((doc) {
          final userData = doc.data() as Map<String, dynamic>;
          return {
            'username': userData['username'] ?? 'No username',
            'email': userData['email'] ?? 'No email',
            'profile_picture': userData['profile_picture'] ?? '', 
          };
        }).toList();

        setState(() {
          userList = users;
        });
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }
}

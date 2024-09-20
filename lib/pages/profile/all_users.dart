import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rolebase/widgets/custom_icon_button.dart';
import 'package:rolebase/widgets/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  late List<Map<String, dynamic>> userList = [];

@override
void initState() {
  super.initState();
  fetchAllUsers(); // Fetch all users initially
}

 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const MyDrawer(),
//       appBar: AppBar(
//         surfaceTintColor: Color(0xFFD4EFFF),
//         backgroundColor: Colors.white,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 8, right: 10),
//               child: Image.asset(
//                 "./images/logo.png",
//                 width: 140,
//               ),
//             ),
//           ],
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: CustomIconButton(
//               icon: Icon(Ionicons.search_outline),
//             ),
//           ),
//         ],
//       ),
//      body: ListView.builder(
//   itemCount: userList.length,
//   itemBuilder: (context, index) {
//     final userData = userList[index];

//     // Extract user information
//     final userName = userData['username'] ?? 'No username';
//     final userEmail = userData['email'] ?? 'No email';
//     final profilePictureUrl = userData['profilePicture'] ?? ''; // Assuming profile picture is stored as a URL

//     return ListTile(
//       leading: CircleAvatar(
//         // Display profile picture if available, else show a placeholder
//         backgroundImage: profilePictureUrl.isNotEmpty
//             ? NetworkImage(profilePictureUrl)
//             : AssetImage('./images/placeholder.jpg'),
//       ),
//       title: Text(userName),
//       subtitle: Text(userEmail),
//       onTap: () {
//         // Handle onTap event if needed
//       },
//     );
//   },
// ),
//     );
//   }


@override
Widget build(BuildContext context) {
  return Scaffold(
    drawer: const MyDrawer(),
    appBar: AppBar(
      surfaceTintColor: Color(0xFFD4EFFF),
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Image.asset(
              "./images/logo.png",
              width: 140,
            ),
          ),
        ],
      ),
      // actions: const [
      //   Padding(
      //     padding: EdgeInsets.all(8.0),
      //     child: CustomIconButton(
      //       icon: Icon(Ionicons.search_outline),
      //     ),
      //   ),
      // ],
    ),
    body:  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20 ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "All Users",
            style: TextStyle(
              color: Color(0xFFB75019),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0, ),
          child: Divider(
            color: Color(0xFF0B91A0),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            margin: EdgeInsets.all(5),
            child: ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final userData = userList[index];
                final userName = userData['username'] ?? 'No username';
                final userEmail = userData['email'] ?? 'No email';
                final profilePictureUrl = userData['profilePictureURL'] ?? ''; 

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  // padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : AssetImage('./images/placeholder.jpg'),
                    ),
                    title: Text(userName),
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF0B91A0),
                    ),
                    subtitle: Text(userEmail),
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
  );
}

//  Future<void> fetchAllUsers() async {
//     try {
//       QuerySnapshot querySnapshot =
//           await FirebaseFirestore.instance.collection('users').get();

//       if (querySnapshot.docs.isNotEmpty) {
//         setState(() {
//           userList = querySnapshot.docs
//               .map((doc) => doc.data() as Map<String, dynamic>)
//               .toList();
//         });
//       }
//     } catch (error) {
//       print('Error fetching users: $error');
//     }
//   }

 Future<void> fetchAllUsers() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        userList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        
        fetchUsersWithProfilePicture(); 
      });
    }
  } catch (error) {
    print('Error fetching users: $error');
  }
}

Future<void> fetchUsersWithProfilePicture() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('profilePictureURL', isNotEqualTo: '')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> usersWithProfilePicture = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        // Update userList with users having profile pictures
        userList = usersWithProfilePicture;
      });
    }
  } catch (error) {
    print('Error fetching users with profile picture: $error');
  }
}


}

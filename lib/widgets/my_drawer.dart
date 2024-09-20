import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rolebase/pages/all_places.dart';
import 'package:rolebase/pages/account/posts/community.dart';
import 'package:rolebase/pages/home_page.dart';
import 'package:rolebase/pages/login/login.dart';
import 'package:rolebase/pages/account/profile/admin_profile.dart';
import 'package:rolebase/pages/account/event_planner/events_list_screen.dart';
import 'package:rolebase/pages/account/profile/user_profile.dart';
import 'package:rolebase/pages/search_page.dart';
import 'package:rolebase/pages/settings_page.dart';
import 'package:rolebase/widgets/my_drawer_tile.dart';


class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
    Widget build(BuildContext context) {
   return Drawer(
  backgroundColor: Theme.of(context).colorScheme.background,
  child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _isLoggedIn(user)) {
        return buildDrawerForLoggedInUser(context, user);
      } else {
        return buildDrawerForGuest(context);
      }
    },
  ),
);
  }

  bool _isLoggedIn(User user) {
    return user.uid.isNotEmpty; 
  }



  Widget buildDrawerForLoggedInUser(BuildContext context, User user) {
    String? userId = user.uid;
    return Column(
      children: [
        const SizedBox(height: 30),
        MyDrawerTile(
          text: "H O M E",
          icon: Icons.home,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        MyDrawerTile(
          text: "A L L  A T T R A C T I O N S",
          icon: Icons.attractions_rounded,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPlaces()),
            );
          },
        ),
        MyDrawerTile(
          text: "S E A R C H",
          icon: Icons.search_rounded,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
        ),
        MyDrawerTile(
          text: "A C C O U N T",
          icon: Icons.person,
          onTap: () {
            if (user.email == "admin@gmail.com") {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminProfile()),
              );
            } else {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            }
          },
        ),
           MyDrawerTile(
          text: "C O M M U N I T Y", 
          icon: Icons.forum, 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  CommunityPage(),
            ),
            );
          },
          ),
           MyDrawerTile(
          text: "P L A N N E R", 
          icon: Icons.calendar_month_outlined, 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  EventsListScreen(),
            ),
            );
          },
          ),
        const SizedBox(height: 25),
      ],
    );
  }

 Widget buildDrawerForGuest(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        MyDrawerTile(
          text: "H O M E",
          icon: Icons.home,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        MyDrawerTile(
          text: "A L L  A T T R A C T I O N S",
          icon: Icons.place,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPlaces()),
            );
          },
        ),
        MyDrawerTile(
          text: "S E A R C H",
          icon: Icons.search_rounded,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
        ),
        MyDrawerTile(
          text: "L O G I N",
          icon: Icons.person,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
         MyDrawerTile(
          text: "S E T T I N G S", 
          icon: Icons.settings, 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage(),
            ),
            );
          },
          ),
          
        const SizedBox(height: 25),
      ],
    );
  }

}

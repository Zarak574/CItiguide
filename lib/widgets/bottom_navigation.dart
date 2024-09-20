// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const CustomBottomNavBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);

//     Future<String?> _getUserProfileImageUrl(String uid) async {
//     try {
//       final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       if (doc.exists) {
//         return doc.data()?['profile_picture'];
//       }
//     } catch (e) {
//       print("Error fetching profile image URL: $e");
//     }
//     return null;
//   }

//   Future<User?> _getCurrentUser() async {
//     return FirebaseAuth.instance.currentUser;
//   }

//   @override
//   // Widget build(BuildContext context) {
//     // final user = FirebaseAuth.instance.currentUser;

//   //   return Container(
//   //     child: Column(
//   //       mainAxisSize: MainAxisSize.min,
//   //       children: [
//   //         Container(
//   //           height: 4,
//   //           decoration: BoxDecoration(
//   //             color: Theme.of(context).colorScheme.secondary,
//   //           ),
//   //         ),
//   //         SizedBox(
//   //           height: 60,
//   //           child: BottomNavigationBar(
//   //             type: BottomNavigationBarType.fixed, 
//   //             currentIndex: currentIndex,
//   //             onTap: (index) {
//   //               if (index == 0) {
//   //                 Navigator.pushReplacementNamed(context, '/home');
//   //               } else if (index == 1) {
//   //                 Navigator.pushReplacementNamed(context, '/allplaces');
//   //               } else if (index == 2) {
//   //                 Navigator.pushReplacementNamed(context, '/search');
//   //               } else if (index == 3) {
//   //                 if (user == null) {
//   //                   Navigator.pushReplacementNamed(context, '/login');
//   //                 } else { 
//   //                   Navigator.pushReplacementNamed(context, '/profile');
//   //                 }
//   //               }
//   //               onTap(index); 
//   //             },
//   //             items: const [
//   //               BottomNavigationBarItem(
//   //                 icon: Icon(Icons.home_filled, size: 24), 
//   //                 label: '', 
//   //               ),
//   //               BottomNavigationBarItem(
//   //                 icon: Icon(Icons.attractions_rounded, size: 24), 
//   //                 label: '', 
//   //               ),
//   //               BottomNavigationBarItem(
//   //                 icon: Icon(Icons.search_rounded, size: 24), 
//   //                 label: '', 
//   //               ),
//   //               BottomNavigationBarItem(
//   //                 icon: Icon(Icons.person, size: 24), 
//   //                 label: '', 
//   //               ),
//   //             ],
//   //             backgroundColor: Theme.of(context).colorScheme.background, 
//   //             elevation: 0, 
//   //             selectedItemColor: Color(0xFF56C6D3), 
//   //             unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//  Widget build(BuildContext context) {
//     return FutureBuilder<User?>(
//       future: _getCurrentUser(),
//       builder: (context, userSnapshot) {
//         if (userSnapshot.connectionState == ConnectionState.waiting) {
//           // Display progress indicator while waiting for user data
//           return Center(child: CircularProgressIndicator());
//         } else if (userSnapshot.hasError || !userSnapshot.hasData) {
//           // Error or no user data available
//           return SizedBox(
//             height: 65,
//             child: BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               currentIndex: currentIndex,
//               onTap: (index) {
//                 if (index == 0) {
//                   Navigator.pushReplacementNamed(context, '/home');
//                 } else if (index == 1) {
//                   Navigator.pushReplacementNamed(context, '/allplaces');
//                 } else if (index == 2) {
//                   Navigator.pushReplacementNamed(context, '/search');
//                 } else if (index == 3) {
//                   Navigator.pushReplacementNamed(context, '/login');
//                 }
//                 onTap(index);
//               },
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home_filled, size: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.attractions_rounded, size: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.search_rounded, size: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person, size: 24), // Default icon if user is not logged in
//                   label: '',
//                 ),
//               ],
//               backgroundColor: Theme.of(context).colorScheme.background,
//               elevation: 0,
//               selectedItemColor: Color(0xFF56C6D3),
//               unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
//             ),
//           );
//         } else {
//           final user = userSnapshot.data!;
//           return SizedBox(
//             height: 68,
//             child: BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               currentIndex: currentIndex,
//               onTap: (index) {
//                 if (index == 0) {
//                   Navigator.pushReplacementNamed(context, '/home');
//                 } else if (index == 1) {
//                   Navigator.pushReplacementNamed(context, '/allplaces');
//                 } else if (index == 2) {
//                   Navigator.pushReplacementNamed(context, '/search');
//                 } else if (index == 3) {
//                   Navigator.pushReplacementNamed(context, '/profile');
//                 }
//                 onTap(index);
//               },
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home_filled, size: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.attractions_rounded, size: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.search_rounded, size: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: FutureBuilder<String?>(
//                     future: _getUserProfileImageUrl(user.uid),
//                     builder: (context, imageSnapshot) {
//                       if (imageSnapshot.connectionState == ConnectionState.waiting) {
//                         return CircularProgressIndicator();
//                       } else if (imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data!.isEmpty) {
//                         return CircleAvatar(
//                           backgroundImage: AssetImage('./images/placeholder.jpg'),
//                           radius: 10,
//                         );
//                       } else {
//                         return CircleAvatar(
//                           backgroundImage: NetworkImage(imageSnapshot.data!),
//                           radius: 10,
//                         );
//                       }
//                     },
//                   ),
//                   label: '',
//                 ),
//               ],
//               backgroundColor: Theme.of(context).colorScheme.background,
//               elevation: 0,
//               selectedItemColor: Color(0xFF56C6D3),
//               unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
//             ),
//           );
//         }
//       },
//     );
//   }

  
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  Future<String?> _getUserProfileImageUrl(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['profile_picture'];
      }
    } catch (e) {
      print("Error fetching profile image URL: $e");
    }
    return null;
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          // Display progress indicator while waiting for user data
          return SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (userSnapshot.hasError || !userSnapshot.hasData) {
          // Error or no user data available
          return SizedBox(
            height: 60,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/allplaces');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/search');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
                onTap(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled, size: 24),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.attractions_rounded, size: 24),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded, size: 24),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 24), // Default icon
                  label: '',
                ),
              ],
              backgroundColor: Theme.of(context).colorScheme.background,
              elevation: 0,
              selectedItemColor: Color(0xFF56C6D3),
              unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          );
        } else {
          final user = userSnapshot.data!;
          return FutureBuilder<String?>(
            future: _getUserProfileImageUrl(user.uid),
            builder: (context, imageSnapshot) {
              return SizedBox(
                height: 60,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: currentIndex,
                  onTap: (index) {
                    if (index == 0) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else if (index == 1) {
                      Navigator.pushReplacementNamed(context, '/allplaces');
                    } else if (index == 2) {
                      Navigator.pushReplacementNamed(context, '/search');
                    } else if (index == 3) {
                      Navigator.pushReplacementNamed(context, '/profile');
                    }
                    onTap(index);
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_filled, size: 24),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.attractions_rounded, size: 24),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search_rounded, size: 24),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: CircleAvatar(
                        backgroundImage: imageSnapshot.connectionState == ConnectionState.waiting
                            ? AssetImage('./images/placeholder.jpg')
                            : imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data!.isEmpty
                                ? AssetImage('./images/placeholder.jpg')
                                : NetworkImage(imageSnapshot.data!) as ImageProvider,
                        radius: 12,
                      ),
                      label: '',
                    ),
                  ],
                  backgroundColor: Theme.of(context).colorScheme.background,
                  elevation: 0,
                  selectedItemColor: Color(0xFF56C6D3),
                  unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
                ),
              );
            },
          );
        }
      },
    );
  }
}

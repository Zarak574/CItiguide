// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:rolebase/pages/login/second.dart';

// class SquareTile extends StatefulWidget {
//   final String imagePath;
//   const SquareTile({
//     super.key,
//     required this.imagePath,
//   });

//   @override
//   State<SquareTile> createState() => _SquareTileState();
// }

// class _SquareTileState extends State<SquareTile> {
//   GoogleSignInAccount? _userObj;
//   GoogleSignIn _googleSignIn = GoogleSignIn();
//   String url = "";
//   String name = "";
//   String email = "";

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.white),
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.grey[200],
//       ),
//       child: MaterialButton(
//         minWidth: 20,
//         onPressed: () { 
//           _googleSignIn.signIn().then((userData) {
//               setState(() {
//                 _userObj = userData;
//                 url = _userObj!.photoUrl.toString();
//                 name = _userObj!.displayName.toString();
//                 email = _userObj!.email;
//               });
//               if (userData != null) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => (second(
//                       url: url,
//                       name: name,
//                       email: email,
//                     )),
//                   ),
//                 );
//               }
//             }).catchError((e) {
//               print(e);
//             });
//          },
//         child: Image.asset(
//           widget.imagePath,
//           height: 40,
//         ),
//       ),
//     );
//   }
// }
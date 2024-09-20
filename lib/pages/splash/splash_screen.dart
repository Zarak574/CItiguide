// import 'package:flutter/material.dart';
// import 'package:rolebase/pages/splash/size_config.dart';
// import 'package:rolebase/pages/splash/splash_content.dart';
// import 'dart:async';

// class SplashScreen extends StatefulWidget {
//   static String routeName = "/splash";
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   late PageController _controller;
//   late Timer _timer;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = PageController();
//     _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
//       if (_currentPage < contents.length - 1) {
//         _currentPage++;
//         _controller.animateToPage(
//           _currentPage,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _timer.cancel();
//     super.dispose();
//   }

//   List<Color> colors = const [
//     Color(0xFFF0F9FF),
//     Color(0xFFFFF6F1),
//     Color(0xFFF0F9FF)
//   ];

//   Widget _buildDots({
//     int? index,
//   }) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.all(
//           Radius.circular(50),
//         ),
//         color: Color(0xFF0B91A0),
//       ),
//       margin: const EdgeInsets.only(right: 5),
//       height: 10,
//       width: _currentPage == index ? 20 : 10,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     double width = SizeConfig.screenW!;
//     double height = SizeConfig.screenH!;

//     return Scaffold(
//       backgroundColor: colors[_currentPage],
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               flex: 3,
//               child: PageView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 controller: _controller,
//                 onPageChanged: (value) => setState(() => _currentPage = value),
//                 itemCount: contents.length,
//                 itemBuilder: (context, i) {
//                   return Padding(
//                     padding: const EdgeInsets.all(40.0),
//                     child: Column(
//                       children: [
//                         Image.asset(
//                           contents[i].image,
//                           height: SizeConfig.blockV! * 35,
//                         ),
//                         SizedBox(
//                           height: (height >= 840) ? 60 : 30,
//                         ),
//                         Text(
//                           contents[i].title,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: "Mulish",
//                             fontWeight: FontWeight.w600,
//                             fontSize: (width <= 550) ? 30 : 35,
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Text(
//                           contents[i].desc,
//                           style: TextStyle(
//                             fontFamily: "Mulish",
//                             fontWeight: FontWeight.w300,
//                             fontSize: (width <= 550) ? 17 : 25,
//                           ),
//                           textAlign: TextAlign.center,
//                         )
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Expanded(
//               flex: 1,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       contents.length,
//                       (int index) => _buildDots(
//                         index: index,
//                       ),
//                     ),
//                   ),
//                   _currentPage + 1 == contents.length
//                       ? Padding(
//                           padding: const EdgeInsets.all(30),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.pushNamed(context, '/home');
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFFB75019),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               padding: (width <= 550)
//                                   ? const EdgeInsets.symmetric(
//                                       horizontal: 100, vertical: 20)
//                                   : EdgeInsets.symmetric(
//                                       horizontal: width * 0.2, vertical: 25),
//                               textStyle: TextStyle(
//                                 fontSize: (width <= 550) ? 13 : 17,
//                               ),
//                             ),
//                             child: const Text(
//                               "START",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         )
//                       : Padding(
//                           padding: const EdgeInsets.all(30),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               TextButton(
//                                 onPressed: () {
//                                   _controller.jumpToPage(2);
//                                 },
//                                 style: TextButton.styleFrom(
//                                   elevation: 0,
//                                   textStyle: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: (width <= 550) ? 13 : 17,
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "SKIP",
//                                   style: TextStyle(color: Color(0xFF0B91A0)),
//                                 ),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   _controller.nextPage(
//                                     duration: const Duration(milliseconds: 200),
//                                     curve: Curves.easeIn,
//                                   );
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xFFB75019),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(50),
//                                   ),
//                                   elevation: 0,
//                                   padding: (width <= 550)
//                                       ? const EdgeInsets.symmetric(
//                                           horizontal: 30, vertical: 20)
//                                       : const EdgeInsets.symmetric(
//                                           horizontal: 30, vertical: 25),
//                                   textStyle: TextStyle(
//                                     fontSize: (width <= 550) ? 13 : 17,
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "NEXT",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:rolebase/pages/splash/size_config.dart';
import 'package:rolebase/pages/splash/splash_content.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _controller;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
     _controller = PageController();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < contents.length - 1) {
        _currentPage++;
        _controller.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel(); 
      }
    });
  }

   @override
  void dispose() {
    _timer.cancel(); 
    super.dispose();
  }

  List colors = const [
    Color(0xFFF0F9FF),
    // Color(0xffDAD3C8),
    Color(0xFFFFF6F1),
    // Color(0xffFFE5DE),
    // Color(0xffDCF6E6),
    Color(0xFFF0F9FF)
  ];

  AnimatedContainer _buildDots({
    int? index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        color: 
        // Color(0xFF000000),
        Color(0xFF0B91A0),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenW!;
    double height = SizeConfig.screenH!;

    return Scaffold(
      backgroundColor: colors[_currentPage],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: contents.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          contents[i].image,
                          height: SizeConfig.blockV! * 35,
                        ),
                        SizedBox(
                          height: (height >= 840) ? 60 : 30,
                        ),
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w600,
                            fontSize: (width <= 550) ? 30 : 35,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          contents[i].desc,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w300,
                            fontSize: (width <= 550) ? 17 : 25,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (int index) => _buildDots(
                        index: index,
                      ),
                    ),
                  ),
                  _currentPage + 1 == contents.length
                      ? Padding(
                          padding: const EdgeInsets.all(30),
                          child: ElevatedButton(
                            onPressed: () {
                                 Navigator.pushNamed(context, '/home');
                            },
                             child: const Text(
                              "START",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: 
                              // Colors.black,
                              Color(0xFFB75019),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: (width <= 550)
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 100, vertical: 20)
                                  : EdgeInsets.symmetric(
                                      horizontal: width * 0.2, vertical: 25),
                              textStyle:
                                  TextStyle(
                                    fontSize: (width <= 550) ? 13 : 17),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _controller.jumpToPage(2);
                                },
                                child: const Text(
                                  "SKIP",
                                  style: TextStyle(color: 
                                  Color(0xFF0B91A0),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: (width <= 550) ? 13 : 17,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: const Text(
                                  "NEXT",
                                  style: TextStyle(color: Colors.white),
                                  ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: 
                                  Color(0xFFB75019),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 0,
                                  padding: (width <= 550)
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 20)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 25),
                                  textStyle: TextStyle(
                                      fontSize: (width <= 550) ? 13 : 17),
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
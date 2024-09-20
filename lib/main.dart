import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rolebase/firebase_options.dart';
import 'package:rolebase/pages/splash/splash_screen.dart';
import 'package:rolebase/routes.dart';
import 'package:provider/provider.dart';
import 'package:rolebase/themes/theme_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}



class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 
  @override
 Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CITIGUIDE',
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}

// darkOrange = Color(0xFFFF8340),
// Color(0xFFB75019),
// lightOrange = Color(0xFFFFF6F1),
// green = Color(0xFF56C6D3),
// Color(0xFF0B91A0),
// blue = Color(0xFFF0F9FF)
// cream = Color(0xFFFFF3E0), 
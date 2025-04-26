import 'package:cityprint/BusinessPage.dart';
import 'package:cityprint/BusinessSettingsPage.dart';
import 'package:cityprint/HomePage.dart';
import 'package:cityprint/LoginScreen.dart';
import 'package:cityprint/RoleSelectionScreen.dart';
import 'package:cityprint/SignupScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Import the generated firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/roleselection': (context) => RoleSelectionScreen(),
        '/home': (context) => HomePage(),
        '/business': (context) => BusinessPage(),
        '/BusinessSettings': (context) => BusinessSettingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}





// 2. Signup Screen


// 3. Home Page (User)


// 4. Business Page (Seller)


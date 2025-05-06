import 'package:cityprint/BusinessPage.dart';
import 'package:cityprint/BusinessSettingsPage.dart';
import 'package:cityprint/HomePage.dart';
import 'package:cityprint/LoginScreen.dart';
import 'package:cityprint/RoleSelectionScreen.dart';
import 'package:cityprint/SignupScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://unhzfqogrjlhdbraxarj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVuaHpmcW9ncmpsaGRicmF4YXJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzMTUwOTcsImV4cCI6MjA2MTg5MTA5N30.wX_KicRkVLHqZxsm5SNhOmmU-M9gVj8C9jElVBSEFFQ',
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
        'signupBusiness': (context) => SignupBusinessScreen(),
        '/home': (context) => HomePage(),
        '/business': (context) => BusinessPage(),
        '/BusinessSettings': (context) => BusinessSettingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

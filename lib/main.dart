import 'package:flutter/material.dart';
import 'package:reenk/uygulama_anonim.dart';
import 'welcome.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'uygulamam.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Nunito"),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => Uygulamam(),
        '/anonim': (context) => Uygulamam_a()
      },
    );
  }
}

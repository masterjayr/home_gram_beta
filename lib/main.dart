import 'package:flutter/material.dart';
import 'package:home_gram_beta/screens/Registration_Screen.dart';
import 'package:home_gram_beta/screens/add_home_screen.dart';
import 'package:home_gram_beta/screens/home_screen.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/screens/profile_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/services/user.dart';
import 'package:home_gram_beta/ui/const.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: themeColor),
      home: HomeScreen(auth: Auth(),),
      routes: <String, WidgetBuilder>{
        '/profile' : (BuildContext context) => ProfileScreen(user: UserActivity(),),
        '/home' : (BuildContext context)=> HomeScreen(auth: Auth(),),
        '/login' : (BuildContext context) => LoginScreen(auth: Auth(),)
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
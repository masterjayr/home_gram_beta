import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_gram_beta/screens/Registration_Screen.dart';
import 'package:home_gram_beta/screens/about_screen.dart';
import 'package:home_gram_beta/screens/add_home_screen.dart';
import 'package:home_gram_beta/screens/home_screen.dart';
import 'package:home_gram_beta/screens/introduction_screen.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/screens/my_homes_screen.dart';
import 'package:home_gram_beta/screens/profile_screen.dart';
import 'package:home_gram_beta/screens/search_home_screen.dart';
import 'package:home_gram_beta/screens/settings_screen.dart';
import 'package:home_gram_beta/screens/splash_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/services/user.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';
import 'package:home_gram_beta/services/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'package:home_gram_beta/screens/all_homes_screen.dart';

void main(){
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<ConnectivityStatus>(
          builder: (context) => ConnectivityService().connectionController,
          child: MaterialApp(
        theme: ThemeData(primaryColor: themeColor,
          textTheme: TextTheme(
            body1: GoogleFonts.nunito(fontSize: 15)
          )
        ),
        home: SearchHomeScreen(),
        routes: <String, WidgetBuilder>{
          '/profile' : (BuildContext context) => ProfileScreen(user: UserActivity(),),
          '/home' : (BuildContext context)=> HomeScreen(auth: Auth(),),
          '/login' : (BuildContext context) => LoginScreen(auth: Auth(),),
          '/addHome' : (BuildContext context) => AddHomeScreen(user: UserActivity(),),
           '/myHomes' : (BuildContext context) => MyHomeScreen(),
          '/about' : (BuildContext context) => AboutScreen(),
          '/settings' : (BuildContext context) => SettingsScreen(),
          '/allHomes' : (BuildContext context) => AllHomesScreen()
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
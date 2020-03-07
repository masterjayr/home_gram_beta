import 'package:flutter/material.dart';
import 'package:home_gram_beta/screens/home_screen.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/widgets/loader.dart';


class RootScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = Auth();
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if(snapshot.connectionState == ConnectionState.active){
          final bool isLoggedIn = snapshot.hasData;
          return isLoggedIn ? HomeScreen(auth: auth,) : LoginScreen(auth: auth,);
        }
        return _buildWaitingScreen();
      },
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        child: Loader()
      ),
    );
  }
}
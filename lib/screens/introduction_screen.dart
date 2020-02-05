import 'package:flutter/material.dart';
import 'package:home_gram_beta/screens/Registration_Screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatelessWidget {
  final pageDecoration = PageDecoration(
    titleTextStyle:
        PageDecoration().titleTextStyle.copyWith(color: Colors.black),
    bodyTextStyle:
        PageDecoration().titleTextStyle.copyWith(color: Colors.black),
  );
  List<PageViewModel> getPages() {
    return [
      PageViewModel(
          image: Image.asset(
            'assets/welcomeaboard.png',
            fit: BoxFit.cover,
          ),
          title: '',
          body: 'Welcome to HomeGram, The Home to finding a new home',
          footer: Text(
            'HOMEGRAM',
            style: TextStyle(color: Colors.blueGrey),
          ),
          decoration: pageDecoration),
      PageViewModel(
          image: Image.asset(
            'assets/homegramservice.png',
            fit: BoxFit.cover,
          ),
          title: 'We are home agents, Just smarter',
          body:
              'Homegram serves as an agent in automatically locating a house in a location closest to yours or any location of your choice',
          footer: Text(
            'HOMEGRAM',
            style: TextStyle(color: Colors.blueGrey),
          ),
          decoration: pageDecoration),
      PageViewModel(
          image: Image.asset(
            'assets/onboarding1.png',
            fit: BoxFit.cover,
          ),
          title: '',
          body:
              'We walk you through the path we create, Taking care of all your home needs',
          footer: Text(
            'HOMEGRAM',
            style: TextStyle(color: Colors.blueGrey, ),
          ),
          decoration: pageDecoration),
      PageViewModel(
          image: Image.asset(
            'assets/letsgo.png',
            fit: BoxFit.fill,
          ),
          title: '',
          body: 'On God We\'ll give you the best experience. Let\'s go!',
          footer: Text(
            'HOMEGRAM',
            style: TextStyle(color: Colors.blueGrey),
          ),
          decoration: pageDecoration)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      body: SafeArea(
        child: IntroductionScreen(
          done: Text(
            'Get Started',
            style: TextStyle(color: Colors.black),
          ),
          globalBackgroundColor: Colors.yellow.shade50,
          pages: getPages(),
          onDone: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RegistrationScreen(auth: Auth())));
          },
          onSkip: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RegistrationScreen(auth: Auth())));
          },
          showSkipButton: true,
          skip: Text('Skip'),
          next: const Icon(Icons.navigate_next),
          dotsDecorator: DotsDecorator(
              size: const Size.square(10.0),
              activeSize: const Size(20.0, 10.0),
              activeColor: primaryColor,
              color: Colors.black26,
              spacing: const EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0))),
        ),
      ),
    );
  }
}

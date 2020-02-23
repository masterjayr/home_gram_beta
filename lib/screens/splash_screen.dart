import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    var estimatedPrice;
  _getInitialDetails() async{
    var url = 'https://home-gram-api.herokuapp.com/predict_home_price';
    var response = await http.post(url, body: {'location': 'bauchi ring road, jos', 'noOfRooms': '3'});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() {
      var data = json.decode(response.body);
      print(data.runtimeType);
      estimatedPrice = data['estimated_price'];
    });
  }
  

  @override
  void initState() {
    super.initState();
    _getInitialDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Model Page'),),
      body: Center(child: Text('Estimated Price: $estimatedPrice'),),
    );
  }
}
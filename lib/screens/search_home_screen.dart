import 'package:flutter/material.dart';

class SearchHomeScreen extends StatefulWidget {
  @override
  _SearchHomeScreenState createState() => _SearchHomeScreenState();
}

class _SearchHomeScreenState extends State<SearchHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            
          ],
        )
      )
    );
  }
}
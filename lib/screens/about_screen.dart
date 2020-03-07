import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
                actions: <Widget>[
                  IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                    Navigator.of(context).pop();
                  })
                ],
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/house_image.jpg',
                    fit: BoxFit.cover,
                  ),
                  centerTitle: true,
                  title: FittedBox(
                    child: Text(
                      'About',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  collapseMode: CollapseMode.parallax,
                ),
                pinned: true,
                floating: true,
              )
        ],
      ),
    );
  }
}
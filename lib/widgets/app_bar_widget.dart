
import 'package:flutter/material.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class MyAppBar {
  static AppBar customAppBar(GlobalKey<ScaffoldState> key, String title) {
    return AppBar(
      backgroundColor: themeColor,
      elevation: 1.0,
      leading: InkWell(
        onTap: () {
          key.currentState.openDrawer();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 3),
          child: Container(
            width: 30,
            height: 25,
            decoration: BoxDecoration(
                color: themeColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(
              MaterialCommunityIcons.menu,
              size: 45,
              color: Colors.black,
            ),
          ),
        ),
      ),
      title: Center(child: Text('$title')),
    );
  }
}
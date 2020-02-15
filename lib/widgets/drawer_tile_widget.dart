import 'package:flutter/material.dart';

class DrawerTiles extends StatelessWidget {
  DrawerTiles(
    this.title,
    this.icon,
    this.isSelected,
    this.onPressed,
  );
  final String title;
  final IconData icon;
  final bool isSelected;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('$title'),
      leading: Icon(icon),
      onTap: onPressed,
      selected: isSelected ? true : false,
    );
  }
}
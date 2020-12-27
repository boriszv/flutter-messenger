import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {

  final int selectedIndex;
  final Function indexChanged;

  AppBottomNav(this.selectedIndex, this.indexChanged);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: indexChanged,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Container()),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 26), title: Container()),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Container()),
        ]);
  }
}

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sighttrack_app/screens/home.dart';
import 'package:sighttrack_app/screens/profile.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int selectedIndex = 0;
  static const List<Widget> widgetOptions = <Widget>[
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: Container(
        color: Colors.teal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.teal,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.all(16),
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],
          ),
        ),
      ),
    );

    // GNav(
    //   rippleColor: Colors.grey[300]!,
    //   hoverColor: Colors.grey[100]!,
    //   gap: 8,
    //   activeColor: Colors.redAccent,
    //   iconSize: 24,
    //   color: Colors.black,
    //   tabs: [
    //     GButton(icon: Icons.home, text: 'Home'),
    //     GButton(icon: Icons.person, text: 'Profile'),
    //   ],
  }
}

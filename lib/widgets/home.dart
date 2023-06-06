import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

import '../screens/pick_up.dart';
import '../screens/profile.dart';
import '../screens/report.dart';
import '../screens/smart_bin.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _list = [
    const SmartBin(),
    const PickUp(),
    const Report(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 245, 242, 253),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 3,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: const Color.fromRGBO(96, 125, 139, 1),
        unselectedLabelStyle: const TextStyle(color: Colors.blueGrey),
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Smart Bins',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.electric_scooter,
                size: 30,
              ),
              label: 'Pick Up'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.report,
                size: 30,
              ),
              label: 'Report'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              label: 'Profile'),
        ],
      ),
      body: _list[_selectedIndex],
    );
  }
}

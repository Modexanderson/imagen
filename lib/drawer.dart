import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Drawer build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'AI Image Generator',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to the home page
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Navigate to the settings page
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to the about page
            },
          ),
        ],
      ),
    );
  }
}

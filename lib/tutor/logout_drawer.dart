import 'package:flutter/material.dart';
import 'package:firebase_quizzapp/tutor/tutor_main_screen.dart';

class LogoutDrawer extends StatelessWidget {
  const LogoutDrawer({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.of(context).pop(); // Close drawer
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TutorMainScreen(
                      tutorName: 'Tutor Name', // Pass actual name if available
                      tutorId: null,            // Pass actual id if available
                      initialIndex: 3,          // Profile tab
                    ),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

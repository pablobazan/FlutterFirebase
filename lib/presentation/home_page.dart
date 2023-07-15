import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      /**
     * Send email verification
     */
      FirebaseAuth.instance.currentUser?.sendEmailVerification();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Firebase'),
      ),
      body: Center(
        child: OutlinedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Logout')),
      ),
    );
  }
}

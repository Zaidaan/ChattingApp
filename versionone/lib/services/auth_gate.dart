import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:versionone/pages/home_page.dart';
import 'package:versionone/services/auth.dart';
import 'package:versionone/main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // is logged in
          if (snapshot.hasData) {
            return const HomePage();
          }

          // in not logged in
          else {
            return const CheckAuth();
          }
        },
      ),
    );
  }
}

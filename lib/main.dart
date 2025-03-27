// Platform  Firebase App Id
// android   1:1006035679554:android:9d96c690595921e37d70db

import 'package:flutter/material.dart';
import 'package:posex/pages/HomePage.dart';
import 'package:posex/pages/pre_excercise.dart';
import 'package:posex/pages/profile.dart';
import 'package:posex/pages/sign_in.dart';
import 'package:posex/pages/sign_up.dart';
import 'package:posex/pages/verify_email.dart';
import 'package:posex/constants/routes.dart';
import 'package:posex/pages/viedo_corrector.dart';
import 'package:posex/services/auth/auth_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Jersey25'),
      home: StartPage(),
      routes: {
        homeRoute: (context) => Homepage(),
        profileRoute: (context) => Profile(),
        signInRoute: (context) => SignIn(),
        signUpRoute: (context) => SignUp(),
        verifyRoute: (context) => VerifyEmailView(),
        preExcerciseRoute: (context) => PreExcercise(),
        videoRoute: (context) => VideoCorrector(),
      },
    );
  }
}


class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthServices.firebase().initialise(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthServices.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return Homepage();
              } else {
                return VerifyEmailView();
              }
            } else {
              return const SignIn();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}


Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('LOGOUT'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}

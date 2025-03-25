// Platform  Firebase App Id
// android   1:1006035679554:android:9d96c690595921e37d70db

import 'package:flutter/material.dart';
import 'package:posex/pages/HomePage.dart';
import 'package:posex/pages/profile.dart';
import 'package:posex/pages/sign_in.dart';
import 'package:posex/pages/sign_up.dart';
import 'package:posex/pages/verify_email.dart';
import 'package:posex/routes.dart';

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
      home: VerifyEmailView(),
      routes: {
        homeRoute: (context) => Homepage(),
        profileRoute: (context) => Profile(),
        signInRoute: (context) => SignIn(),
        signUpRoute: (context) => SignUp(),
        verifyRoute: (context) => VerifyEmailView(),
      },
    );
  }
}

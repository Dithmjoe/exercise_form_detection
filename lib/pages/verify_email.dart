// ignore_for_file: use_build_context_synchronously

import 'package:posex/pages/sign_in.dart';
import 'package:posex/routes.dart';
import 'package:posex/services/auth/auth_services.dart';
import 'package:flutter/material.dart';

const backgroundBlack = Color(0xFF323232);
const reddishBlack = Color(0xFF190909);
const white = Color(0xFFFFFFFF);

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlack,
      appBar: AppBar(
        backgroundColor: backgroundBlack,
        title: Text('Verify email', style: TextStyle(color: white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "We've sent a verification email to your mail. please check your mail",
              style: TextStyle(color: white),
            ),
            SizedBox(height: 25,),
            Text(
              "If you haven't recived an email click the button below",
              style: TextStyle(color: white),
            ),
            TextButton(
              onPressed: () async {
                await AuthServices.firebase().sendEmailVerification();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(oliveGold),
                foregroundColor: WidgetStatePropertyAll(white),
              ),
              child: Text('verify email', style: TextStyle(color: white)),
            ),
            SizedBox(height: 50,),
            TextButton(
              onPressed: () async {
                await AuthServices.firebase().logOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(signInRoute, (context) => false);
              },
              style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(white),
                            foregroundColor: WidgetStatePropertyAll(reddishBlack),
                          ),
              child: Text('<= go to Sign In', style: TextStyle(color: reddishBlack)),
            ),
          ],
        ),
      ),
    );
  }
}

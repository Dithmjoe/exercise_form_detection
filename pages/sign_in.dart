// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:posex/constants/routes.dart';
import 'package:posex/services/auth/auth_exceptions.dart';
import 'package:posex/services/auth/auth_services.dart';
import 'package:posex/utils/show_error.dart';

import '../constants/colors.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: backgroundBlack,
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 162),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Welcome Back,',
                style: TextStyle(
                  fontFamily: 'jockeyOne',
                  fontSize: 36,
                  color: white,
                ),
              ),
            ),
            SizedBox(height: 43),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                height: 399,
                width: 325,
                decoration: BoxDecoration(color: reddishBlack),
                child: Padding(
                  padding: const EdgeInsets.only(left: 28, right: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Email:',
                        style: TextStyle(
                          color: white,
                          fontFamily: 'jockeyOne',
                          fontSize: 20,
                        ),
                      ),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: 'johncena@gmail.com',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: backgroundBlack,
                              width: 3.0,
                            ),
                          ),
                        ),
                        style: TextStyle(color: white),
                      ), //email
                      SizedBox(height: 28),
                      Text(
                        'Password:',
                        style: TextStyle(
                          color: white,
                          fontFamily: 'jockeyOne',
                          fontSize: 20,
                        ),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "better not have forgotten that",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: backgroundBlack,
                              width: 3.0,
                            ),
                          ),
                        ),
                        style: TextStyle(color: white),
                      ),
                      SizedBox(height: 48),
                      SizedBox(
                        height: 54,
                        width: 263,
                        child: TextButton(
                          onPressed: () async {
                            try {
              final email = _email.text;
              final password = _password.text;
              await AuthServices.firebase().login(email: email, password: password);
              final user = AuthServices.firebase().currentUser;
              if (user?.isEmailVerified ?? false) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(homeRoute, (_) => false);
              }else{
                Navigator.of(context).pushNamed(verifyRoute);
              }
            } on InvalidCredentialsAuthError catch (_) {
              await showErrorDialog(context, "in-valid credentials");
              // devtools.log('Invalid credentials');
            } on GenericAuthError catch (_) {
              await showErrorDialog(context, "Authentication Error");
            }catch (e) {
              await showErrorDialog(context, e.toString());
              // devtools.log(e.runtimeType.toString());
            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(oliveGold),
                            foregroundColor: WidgetStatePropertyAll(white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              0,
                            ), //TODO: remove this useless padding element later please you fuaking doofus
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: 'Jersy25',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(signUpRoute, (route) => false);
                          },
                          child: Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(color: shadedWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

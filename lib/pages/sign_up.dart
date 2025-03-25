import 'package:flutter/material.dart';
import 'package:posex/routes.dart';

const backgroundBlack = Color(0xFF323232);
const oliveGold = Color(0xFFB5B25C);
const reddishBlack = Color(0xFF190909);
const white = Color(0xFFFFFFFF);
const shadedWhite = Color(0xFFB2AAAD);

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
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
            SizedBox(height: 112),
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
                height: 500,
                width: 325,
                decoration: BoxDecoration(color: reddishBlack),
                child: Padding(
                  padding: const EdgeInsets.only(left: 28, right: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          textLabel(width: 105, height: 47, labelText: 'First Name:', hintText: 'John', controller: _firstName),
                          SizedBox(width: 50,),
                          textLabel(width: 112, height: 47, labelText: 'Last Name:', hintText: 'Cena', controller: _lastName),
                        ],
                      ),
                      SizedBox(height: 28,),
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
                          hintText: "Enter your password here",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: backgroundBlack,
                              width: 3.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 48),
                      SizedBox(
                        height: 54,
                        width: 263,
                        child: TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(oliveGold),
                            foregroundColor: WidgetStatePropertyAll(white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              0,
                            ), //TODO: remove this useless padding element later please you fuaking doofus
                            child: Text(
                              'Sign Up',
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
                            Navigator.of(context).pushNamedAndRemoveUntil(signInRoute, (context) => false);
                          },
                          child: Text(
                            "Already have an account? Sign In",
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

  Column textLabel({
    required double width,
    required double height,
    required String labelText,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(color: white, fontFamily: 'jockeyOne', fontSize: 20),
        ),
        SizedBox(
          width: width,
          height: height,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(5.0, 30.0, 0.0, 0.0),
              hintText: hintText,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: backgroundBlack, width: 3.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

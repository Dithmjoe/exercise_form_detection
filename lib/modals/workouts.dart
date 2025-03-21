// import 'package:flutter/material.dart';

// ignore_for_file: non_constant_identifier_names

// ignore: camel_case_types
class workouts{
  String name;
  String image_path;

  workouts({
    required this.name,
    required this.image_path
  });

  static List<workouts> getworkouts() {
    List<workouts> returnee = [];

    returnee.add(
      workouts(name: 'Pushup', image_path: 'assets/images/pushup.jpeg')
    );

    returnee.add(
      workouts(name: 'Pushup1', image_path: 'assets/images/pushup.jpeg')
    );

    returnee.add(
      workouts(name: 'Pushup2', image_path: 'assets/images/pushup.jpeg')
    );

    returnee.add(
      workouts(name: 'Pushup3', image_path: 'assets/images/pushup.jpeg')
    );

    return returnee;
  }
}
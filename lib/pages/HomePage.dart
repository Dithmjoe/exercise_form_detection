// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:posex/modals/workouts.dart';

const backgroundBlack = Color(0xFF323232);
const white = Color(0xFFF3F3F3);
const red = Color(0xF3693636);

//ignore: must_be_immutable
class Homepage extends StatelessWidget {
  Homepage({super.key});

  List<workouts> exlist = [];
  final exNameList = ['Workout', 'Core', 'Back', 'Biceps'];

  void getworkouts() {
    exlist = workouts.getworkouts();
  }

  @override
  Widget build(BuildContext context) {
    getworkouts();
    return Scaffold(
      appBar: appBar(),
      body: body(),
      backgroundColor: backgroundBlack,
    );
  }

  SingleChildScrollView body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          streakBox(),
          Column(
            children: [
              excerciseList('Workout'),
              excerciseList('Core'),
              excerciseList('Back'),
              excerciseList('Biceps'),
            ],
          ),
        ],
      ),
    );
  }

  Column excerciseList(String exname) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 25),
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(exname, style: TextStyle(fontSize: 25, color: white)),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(width: 15),
            itemCount: exlist.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return excerciseScroller(index);
            },
          ),
        ),
      ],
    );
  }

  SizedBox excerciseScroller(int index) {
    return SizedBox(
      height: 100,
      width: 169,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(exlist[index].image_path),
          Container(
            height: 110,
            width: 169,
            decoration: BoxDecoration(color: Color(0x88323232)),
          ),
          Column(
            children: [
              SizedBox(height: 70),
              Container(
                width: 150,
                height: 2,
                decoration: BoxDecoration(color: white),
              ),
              Text(
                exlist[index].name,
                style: TextStyle(
                  fontFamily: 'JockeyOne',
                  fontSize: 20,
                  color: white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container streakBox() {
    return Container(
      height: 99,
      width: 338,
      margin: EdgeInsets.only(left: 10, top: 25),
      decoration: BoxDecoration(
        color: red,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 28,
                width: 28,
                padding: EdgeInsets.all(1),
                child: SvgPicture.asset('assets/icons/Lightning.svg'),
              ),
              Text('Streak', style: TextStyle(fontSize: 24, color: white)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 24),
              Container(
                width: 287,
                height: 1,
                decoration: BoxDecoration(color: white),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              bool isActive = index == 1; // Monday is active
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: isActive ? Colors.orange : Colors.grey[700],
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: backgroundBlack,
      title: Text("PoseX", style: TextStyle(color: Color(0xFFFFFFFF))),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {},
        icon: SvgPicture.asset(
          'assets/icons/menuLines.svg',
          height: 40,
          width: 22,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.all(10),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
          ),
        ),
      ],
    );
  }
}

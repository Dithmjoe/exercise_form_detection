// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:posex/constants/colors.dart';
import 'package:posex/constants/routes.dart';
import 'package:posex/main.dart';
import 'package:posex/modals/workouts.dart';
import 'package:posex/services/auth/auth_services.dart';
import 'package:posex/pages/push.dart';

//ignore: must_be_immutable
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
      height: 120,
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
              SizedBox(height: 60),
              Container(
                width: 150,
                height: 2,
                decoration: BoxDecoration(color: white),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Text(
                  exlist[index].name,
                  style: const TextStyle(
                    fontFamily: 'JockeyOne',
                    fontSize: 20,
                    color: Colors.white,
                  ),
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
        PopupMenuButton<MenuAction>(
          onSelected: (value) async {
            switch (value) {
              case MenuAction.logOut:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  // devtools.log(value.toString());
                  await AuthServices.firebase().logOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(signInRoute, (_) => false);
                  }
                }
            }
          },
          icon: Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) {
            return [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logOut,
                child: Text('log out'),
              ),
            ];
          },
        ),
        // Container(
        //   margin: EdgeInsets.all(10),
        //   height: 50,
        //   width: 50,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: Colors.white,
        //   ),
        //   alignment: Alignment.center,
        // ),
      ],
    );
  }
}

enum MenuAction { logOut }

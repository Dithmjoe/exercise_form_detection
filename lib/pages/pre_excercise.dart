import 'package:flutter/material.dart';
import 'package:posex/constants/colors.dart';
import 'package:posex/constants/routes.dart';

class PreExcercise extends StatelessWidget {
  const PreExcercise({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlack,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              image: AssetImage('assets/images/pushup.jpeg'),
              fit: BoxFit.fill,
              width: double.infinity,
            ),
            SizedBox(height: 20),
            Text('Push Up', style: TextStyle(color: white, fontSize: 32)),
            Text(
              'Focus Area: Shoulders, Chest',
              style: TextStyle(color: white, fontSize: 16),
            ),
            SizedBox(height: 41),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Instructions:',
                    style: TextStyle(color: white, fontSize: 25),
                  ),
                  Text(instructions, style: TextStyle(color: white, fontSize: 16),),
                  Text(
                    'Common mistakes:',
                    style: TextStyle(color: white, fontSize: 25),
                  ),
                  Text(mistakes, style: TextStyle(color: white, fontSize: 16),),
                ],
              ),
            ),
            TextButton(onPressed: () {
              Navigator.of(context).pushNamed(videoRoute);
            }, style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(oliveGold)), child: Text('Start', style: TextStyle(color: backgroundBlack, fontSize: 36),))
          ],
        ),
      ),
    );
  }
}


const instructions = '''

1. Start in a High Plank Position
Place your hands shoulder-width apart, fingers pointing forward.
Align your head, back, hips, and heels in a straight line.

2. Lower Your Body
Engage your core and glutes.
Bend your elbows at about a 45-degree angle, lowering your chest towards the floor.
Keep your body in a straight line

3. Push Back Up
Press through your palms to extend your arms back to the starting position.

''';

const mistakes = '''
❌ Letting your hips drop
❌ Flaring your elbows too wide
❌ Not going low enough
❌ Rushing through the movement
''';
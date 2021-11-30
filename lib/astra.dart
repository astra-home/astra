import 'dart:math';

import 'package:flutter/material.dart';

import 'circle/circle.dart';
import 'circle/weight.dart';

class Astra extends StatefulWidget {
  const Astra({Key? key}) : super(key: key);

  @override
  _AstraState createState() => _AstraState();
}

class _AstraState extends State<Astra> with TickerProviderStateMixin {
  int size = 200;
  List<AstraCircle> circles = [];
  Random random = Random();

  List<AnimationController> weightPointControllers = [];
  List<AnimationController> heightControllers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 15; i++) {
      weightPointControllers.add(
        AnimationController(
          vsync: this,
          duration: Duration(seconds: random.nextInt(25) + 5),
        )
          ..forward()
          ..repeat(reverse: true),
      );
    }

    for (var i = 1; i < 4; i++) {
      List<AstraWeight> weights = [];
      for (var i = 0; i < 6; i++) {
        weights.add(
          AstraWeight(
            deg: (random.nextDouble() * 360),
            type: AstraWeightType.peak,
            heightAnimation: Tween(begin: 0.0, end: 4.0)
                .chain(CurveTween(curve: Curves.easeInOut))
                .animate(randomFromList(weightPointControllers)),
            positionAnimation: Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut))
                .animate(randomFromList(weightPointControllers)),
            verticalWeight: i.toDouble(),
            horizontalWeight: 20,
            direction: random.nextDouble() > 0.5
                ? AstraWeightDirection.clockwise
                : AstraWeightDirection.counterclockwise,
          ),
        );
      }

      for (var weight in weights) {
        weight.positionAnimation.addListener(() {
          weight.animationOffset = (weight.positionAnimation.value * 360);
          setState(() {});
        });

        weight.heightAnimation.addListener(() {
          weight.verticalWeight = weight.heightAnimation.value;
          setState(() {});
        });
      }

      circles.add(
        AstraCircle(
          origin: Offset(size / 2, size / 2),
          radius: (size / 2) + (i * 2),
          weights: weights,
        ),
      );
    }
  }

  T randomFromList<T>(List<T> list) {
    return list[(random.nextDouble() * list.length).floor()];
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in weightPointControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: size.toDouble(),
      height: size.toDouble(),
      child: CustomPaint(
        painter: AstraPainter(circles),
        isComplex: true,
        willChange: true,
      ),
    );
  }
}

class AstraPainter extends CustomPainter {
  List<AstraCircle> circles = [];
  AstraPainter(this.circles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < circles.length; i++) {
      var circle = circles[i];
      final paint = Paint()
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.8 - (0.1 * i));

      var path = circle.drawPath();
      canvas.drawPath(path, paint);
    }

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.height / 2,
        Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

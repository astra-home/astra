import 'dart:math';

import 'package:flutter/material.dart';

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
    for (var i = 0; i < 8; i++) {
      weightPointControllers.add(
        AnimationController(
          vsync: this,
          duration: Duration(seconds: random.nextInt(25) + 35),
        )
          ..forward()
          ..repeat(reverse: true),
      );
    }

    for (var i = 1; i < 4; i++) {
      circles.add(
        AstraCircle(
          origin: Offset(size / 2, size / 2),
          radius: (size / 2) + (2.5 * i),
          controllers: weightPointControllers,
          verticalWeight: i.toDouble(),
          state: this,
        ),
      );
    }
  }

  void refresh() {
    debugPrint('refreshing');
    setState(() {});
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
        ..color = Colors.white.withOpacity(0.8 - (0.2 * i));

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

class AstraCircle {
  Offset origin;
  double radius;
  Random rand = Random();
  List<AstraWeight> weights = [];
  List<AnimationController> controllers;
  _AstraState state;

  AstraCircle(
      {required this.origin,
      required this.radius,
      required this.controllers,
      required this.state,
      required double verticalWeight}) {
    weights = _generateWeightPoints(8, verticalWeight);
  }

  Offset _getPointForDeg(int deg) {
    var offset =
        weights.map((w) => w.offsetForDegree(deg)).reduce((sum, w) => sum + w);

    offset =
        min(offset, 8.0); // prevent merging points going above set height limit
    return Offset((radius + offset) * sin(gradToRad(deg)) + origin.dx,
        (radius + offset) * cos(gradToRad(deg)) + origin.dy);
  }

  List<Offset> _generatePoints(int resolution) {
    List<Offset> points = [];
    for (var i = 0; i < 360; i += resolution) {
      points.add(_getPointForDeg(i));
    }
    return points;
  }

  List<CubicBezier> _buildBeziers(List<Offset> points) {
    List<CubicBezier> beziers = [];
    while (points.isNotEmpty) {
      beziers.add(CubicBezier(points[0], points[1], points[2],
          points.length == 3 ? beziers[0].p0 : points[3]));
      points.removeRange(0, 3);
    }
    return beziers;
  }

  // make beziers tangent to eachother
  void _makeBeziersTangent(List<CubicBezier> beziers) {
    for (var i = 0; i < beziers.length; i++) {
      // p3 - p2 = q0 - q1
      var next = i == beziers.length - 1 ? beziers[0] : beziers[i + 1];
      var px = beziers[i].p3.dx - beziers[i].p2.dx;
      var py = beziers[i].p3.dy - beziers[i].p2.dy;

      next.p1 = Offset(next.p0.dx + px, next.p0.dy + py);
    }
  }

  List<AstraWeight> _generateWeightPoints(int count, double verticalWeight) {
    List<AstraWeight> weightPoints = [];
    for (var i = 0; i < count; i++) {
      weightPoints.add(
        AstraWeight(
          deg: (rand.nextDouble() * 360),
          type: AstraPointType.peak,
          heightAnimation: Tween(begin: 0.0, end: 8.0)
              .chain(CurveTween(curve: Curves.easeInOut))
              .animate(_randomController(controllers)),
          positionAnimation: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut))
              .animate(_randomController(controllers)),
          verticalWeight: verticalWeight,
          horizontalWeight: 20,
          direction: rand.nextDouble() > 0.5
              ? AstraPointDirection.clockwise
              : AstraPointDirection.counterclockwise,
          state: state,
        ),
      );
    }
    return weightPoints;
  }

  T _randomController<T>(List<T> list) {
    return list[(rand.nextDouble() * list.length).floor()];
  }

  Path drawPath() {
    var points = _generatePoints(3);
    var path = Path()..moveTo(points[0].dx, points[0].dy);
    var beziers = _buildBeziers(points);
    _makeBeziersTangent(beziers);
    for (var bezier in beziers) {
      path.cubicTo(bezier.p1.dx, bezier.p1.dy, bezier.p2.dx, bezier.p2.dy,
          bezier.p3.dx, bezier.p3.dy);
    }
    return path..close();
  }

  double gradToRad(int grad) {
    return grad * pi / 180;
  }
}

class CubicBezier {
  Offset p0;
  Offset p1;
  Offset p2;
  Offset p3;

  CubicBezier(this.p0, this.p1, this.p2, this.p3);
}

enum AstraPointType { peak, twin, trio }
enum AstraPointDirection { clockwise, counterclockwise }

class AstraWeight {
  double deg;
  double animationOffset = 0;

  AstraPointType type;

  double verticalWeight;
  double horizontalWeight;

  AstraPointDirection direction;

  Animation positionAnimation;
  Animation heightAnimation;

  _AstraState state;

  AstraWeight({
    this.deg = 0,
    this.verticalWeight = 1.1,
    this.horizontalWeight = 30,
    this.direction = AstraPointDirection.clockwise,
    required this.positionAnimation,
    required this.heightAnimation,
    required this.type,
    required this.state,
  }) {
    positionAnimation.addListener(() {
      animationOffset = (positionAnimation.value * 360);
      state.refresh();
    });

    heightAnimation.addListener(() {
      verticalWeight = heightAnimation.value;
      state.refresh();
    });
  }

  double offsetForDegree(int circleDeg) {
    var weightDeg = getAnimatedDegree();
    double distance = (weightDeg - circleDeg).abs();

    if (horizontalWeight > distance) {
      return (1 - (distance / horizontalWeight)) * verticalWeight;
    }

    // handle weight influence after 360 degrees
    if (horizontalWeight > (distance - 360).abs()) {
      return (1 - ((distance - 360).abs() / horizontalWeight)) * verticalWeight;
    }

    return 0;
  }

  double getAnimatedDegree() {
    var animatedDeg = deg;
    if (direction == AstraPointDirection.clockwise) {
      animatedDeg -= animationOffset;
    } else {
      animatedDeg += animationOffset;
    }

    if (animatedDeg > 360) {
      animatedDeg -= 360;
    }
    return animatedDeg;
  }
}

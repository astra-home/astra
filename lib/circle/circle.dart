import 'dart:math';

import 'package:flutter/material.dart';

import 'weight.dart';

class AstraCircle {
  Offset origin;
  double radius;
  List<AstraWeight> weights;

  AstraCircle({
    required this.origin,
    required this.radius,
    required this.weights,
  });

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

  void _makeBeziersTangent(List<CubicBezier> beziers) {
    for (var i = 0; i < beziers.length; i++) {
      // p3 - p2 = q0 - q1
      var next = i == beziers.length - 1 ? beziers[0] : beziers[i + 1];
      var px = beziers[i].p3.dx - beziers[i].p2.dx;
      var py = beziers[i].p3.dy - beziers[i].p2.dy;

      next.p1 = Offset(next.p0.dx + px, next.p0.dy + py);
    }
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

import 'package:flutter/material.dart';

enum AstraWeightType { peak, twin, trio }
enum AstraWeightDirection { clockwise, counterclockwise }

class AstraWeight {
  double deg;
  double animationOffset = 0;

  AstraWeightType type;

  double verticalWeight;
  double horizontalWeight;

  AstraWeightDirection direction;

  Animation positionAnimation;
  Animation heightAnimation;

  AstraWeight({
    this.deg = 0,
    this.verticalWeight = 1.1,
    this.horizontalWeight = 30,
    this.direction = AstraWeightDirection.clockwise,
    required this.positionAnimation,
    required this.heightAnimation,
    required this.type,
  });

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
    if (direction == AstraWeightDirection.clockwise) {
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

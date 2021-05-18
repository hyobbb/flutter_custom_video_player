import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StaticIndicator extends StatelessWidget {
  final double height;
  final double width;
  final bool border;
  final Color color;

  const StaticIndicator({
    required this.color,
    required this.width,
    this.height = 8.0,
    this.border = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: (border)
            ? Border(right: BorderSide(width: 1, color: Colors.black))
            : const Border(),
        color: color,
      ),
    );
  }
}

class DynamicIndicator extends StatelessWidget {
  final double height;
  final double width;
  final AnimationController controller;
  final bool border;
  final Color activeColor;
  final Color backgroundColor;

  DynamicIndicator({
    this.height = 8.0,
    required this.width,
    required this.controller,
    this.border = true,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: (border)
            ? Border(right: BorderSide(width: 1, color: Colors.black))
            : const Border(),
        color: backgroundColor,
      ),
      child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) => Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: height,
                  color: activeColor,
                  width: controller.value * width,
                ),
              )),
    );
  }
}

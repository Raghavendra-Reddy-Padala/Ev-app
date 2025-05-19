import 'package:flutter/material.dart';
import 'package:mjollnir/shared/constants/colors.dart';

// ignore: must_be_immutable
class Arrow extends StatelessWidget {
  final bool left;
  final double? size;
  Color? color;
  Arrow(
      {super.key,
      required this.left,
      this.size = 40,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Icon(
      (left) ? Icons.arrow_circle_left : Icons.arrow_circle_right,
      size: size,
      color: (left) ? AppColors.primary : color,
    );
  }
}

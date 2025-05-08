import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/colors.dart';

enum LoadingType { circular, linear, custom }

enum LoadingSize { small, medium, large }

class LoadingIndicator extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final Color? color;
  final String? message;
  final double? value;

  const LoadingIndicator({
    super.key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(context),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    final indicatorColor = color ?? AppColors.primary;
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: _getSize(),
          height: _getSize(),
          child: CircularProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: _getStrokeWidth(),
          ),
        );
      case LoadingType.linear:
        return SizedBox(
          width: 200.w,
          child: LinearProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            backgroundColor: indicatorColor.withOpacity(0.2),
            minHeight: _getStrokeWidth() / 2,
          ),
        );
      case LoadingType.custom:
        return SizedBox(
          width: _getSize() * 1.5,
          height: _getSize() * 1.5,
          child: CustomLoadingAnimation(
            color: indicatorColor,
            size: _getSize() * 1.5,
          ),
        );
    }
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 24.w;
      case LoadingSize.medium:
        return 40.w;
      case LoadingSize.large:
        return 64.w;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2.5;
      case LoadingSize.medium:
        return 3.5;
      case LoadingSize.large:
        return 4.5;
    }
  }
}

class CustomLoadingAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const CustomLoadingAnimation({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  State<CustomLoadingAnimation> createState() => _CustomLoadingAnimationState();
}

class _CustomLoadingAnimationState extends State<CustomLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnimations;

  final int _numDots = 6;

  @override
  void initState() {
    super.initState();

    // Main rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _dotControllers = List.generate(_numDots, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + (index * 100)),
      )..repeat(reverse: true);
    });

    _dotAnimations = _dotControllers.map((controller) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_rotationController, _pulseController, ..._dotControllers]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * 0.3 * (_pulseController.value * 0.4 + 0.6),
                height:
                    widget.size * 0.3 * (_pulseController.value * 0.4 + 0.6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: widget.size * 0.1 * _pulseController.value,
                      spreadRadius: widget.size * 0.05 * _pulseController.value,
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(_numDots, (i) {
                    final angle = (i / _numDots) * 2 * 3.14159;
                    final radius = widget.size * 0.35;
                    final x = radius * cos(angle);
                    final y = radius * sin(angle);
                    final dotSize =
                        widget.size * 0.12 * _dotAnimations[i].value;

                    return Positioned(
                      left: widget.size / 2 + x - dotSize / 2,
                      top: widget.size / 2 + y - dotSize / 2,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color
                              .withOpacity(0.7 + 0.3 * _dotAnimations[i].value),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color
                                  .withOpacity(0.3 * _dotAnimations[i].value),
                              blurRadius: dotSize * 0.5,
                              spreadRadius: dotSize * 0.1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Container(
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color
                        .withOpacity(0.2 + 0.2 * _pulseController.value),
                    width: widget.size * 0.01,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

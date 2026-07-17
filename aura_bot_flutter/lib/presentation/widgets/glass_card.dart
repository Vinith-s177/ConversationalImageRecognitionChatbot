import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_bot_flutter/core/theme/anti_gravity_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 16.0,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: AntiGravityTheme.cardGradient,
            border: border ?? Border.all(
              color: AntiGravityTheme.borderOverlay,
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

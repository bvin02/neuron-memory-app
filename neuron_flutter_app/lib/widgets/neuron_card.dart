import 'dart:ui';
import 'package:flutter/material.dart';

class NeuronCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient? gradientOverlay;
  final Gradient? borderGradient;
  final bool blurBackground;
  final void Function(BuildContext)? onTap;

  const NeuronCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.gradientOverlay,
    this.borderGradient,
    this.blurBackground = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4), // Add margin to show shadow
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF080810),
                blurRadius: 24,
                spreadRadius: -4,
                offset: Offset(-8, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: null,
                gradient: gradientOverlay ?? const RadialGradient(
                  center: Alignment(1.0, 1.0),
                  radius: 2,
                  colors: [
                    Color(0xFF0F0F17), // Dark center
                    Color.fromARGB(255, 30, 30, 46), // Base color
                    Color.fromARGB(255, 35, 36, 58), // Lighter edge
                  ],
                  stops: [0.1, 0.6, 0.9],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    gradient: borderGradient ?? const RadialGradient(
                      center: Alignment(1.0, -1.0),
                      radius: 1.8,
                      colors: [
                        Color(0xFF41414D),
                        Color(0xFF32324b),
                      ],
                      stops: [0.1, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.5),
                      gradient: gradientOverlay ?? const RadialGradient(
                        center: Alignment(1.0, 1.0),
                        radius: 2,
                        colors: [
                          Color(0xFF0F0F17),
                          Color.fromARGB(255, 30, 30, 46),
                          Color.fromARGB(255, 35, 36, 58),
                        ],
                        stops: [0.1, 0.6, 0.9],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            height: 1.6,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

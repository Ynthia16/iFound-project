import 'package:flutter/material.dart';

class IFoundBackground extends StatelessWidget {
  final Widget child;
  const IFoundBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF0D0D0D),
                    const Color(0xFF1A1A1A),
                  ]
                : [
                    const Color(0xFFF8FBFF),
                    const Color(0xFFE3F2FD),
                    const Color(0xFFF8FBFF),
                  ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.blue.withOpacity(0.06)
                : Colors.blue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -60,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.blueAccent.withOpacity(0.04)
                : Colors.blueAccent.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: -40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.blue.withOpacity(0.03)
                : Colors.blue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
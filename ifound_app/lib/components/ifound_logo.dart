import 'package:flutter/material.dart';

class IFoundLogo extends StatelessWidget {
  final double size;
  const IFoundLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.search_rounded,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
} 
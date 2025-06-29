import 'package:flutter/material.dart';

class IFoundStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  const IFoundStars({super.key, required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isSelected = index < rating;
        return IconButton(
          icon: Icon(
            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
            color: isSelected ? const Color(0xFFFFC107) : Colors.grey[400],
            size: 32,
          ),
          onPressed: () => onChanged(index + 1),
        );
      }),
    );
  }
} 
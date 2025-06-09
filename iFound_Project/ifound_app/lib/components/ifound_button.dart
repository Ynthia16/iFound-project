import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IFoundButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final Widget? icon;
  final Color? backgroundColor;
  const IFoundButton({super.key, required this.text, this.onPressed, this.width, this.icon, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: backgroundColor == Colors.white ? Color(0xFF4285F4) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
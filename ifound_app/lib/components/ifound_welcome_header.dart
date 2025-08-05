import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class IFoundWelcomeHeader extends StatelessWidget {
  final String name;
  final String? illustrationAsset;
  const IFoundWelcomeHeader({super.key, required this.name, this.illustrationAsset});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF2196F3),
              width: 2,
            ),
          ),
         child: Icon(
            MdiIcons.fileCheckOutline,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Hello, $name',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class IFoundWelcomeHeader extends StatelessWidget {
  final String name;
  final String? illustrationAsset;
  const IFoundWelcomeHeader({super.key, required this.name, this.illustrationAsset});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (illustrationAsset != null)
          SvgPicture.asset(illustrationAsset!, width: 48, height: 48),
        if (illustrationAsset != null) const SizedBox(width: 12),
        Expanded(
          child: Text(
            'welcome_back'.tr(namedArgs: {'name': name}),
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2196F3)),
          ),
        ),
      ],
    );
  }
} 
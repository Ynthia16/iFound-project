import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
        MdiIcons.fileCheckOutline,
        //  MdiIcons.alertCircleOutline,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}


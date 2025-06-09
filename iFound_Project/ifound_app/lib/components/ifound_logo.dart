import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';

class IFoundLogo extends StatelessWidget {
  final double size;
  const IFoundLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/ifound_logo.svg',
      width: size,
    );
  }
} 
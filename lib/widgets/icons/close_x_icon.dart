import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CloseXIcon extends StatelessWidget {
  const CloseXIcon({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_closeSvg, width: size, height: size);
  }
}

const String _closeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
  <path d="M18 6L6 18M6 6l12 12"
        stroke="#000"
        stroke-width="6"
        stroke-linecap="round"
        stroke-linejoin="round"/>
  <path d="M18 6L6 18M6 6l12 12"
        stroke="#F24c36"
        stroke-width="4.2"
        stroke-linecap="round"
        stroke-linejoin="round"/>
</svg>
''';


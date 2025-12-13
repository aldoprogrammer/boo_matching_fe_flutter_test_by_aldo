import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperLikeHeartIcon extends StatelessWidget {
  const SuperLikeHeartIcon({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_superLikeSvg, width: size, height: size);
  }
}

const String _superLikeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" stroke="#000" stroke-width="1.2" fill="#4EDCD4" stroke-linejoin="round"/>
<ellipse cx="11" cy="9.5" rx="2.5" ry="2" fill="#FFFFFF" fill-opacity="0.6"/>
</svg>
''';


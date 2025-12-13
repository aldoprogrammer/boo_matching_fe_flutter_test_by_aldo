import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PowerUpsIcon extends StatelessWidget {
  const PowerUpsIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _powerUpsSvg,
      width: size,
      height: size,
    );
  }
}

const String _powerUpsSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30" fill="none">
  <path fill="#fff" fill-rule="evenodd" d="M12.832 18.247H6.203c-.97 0-1.482-1.147-.834-1.87L17.08 3.312c.783-.873 2.21-.111 1.922 1.025l-1.844 7.245h6.639c.966 0 1.48 1.14.84 1.864L12.93 26.684c-.777.878-2.21.127-1.929-1.011l1.83-7.426Zm7.542-9.166h3.423c3.12 0 4.78 3.682 2.712 6.02L14.802 28.34c-2.506 2.835-7.134.41-6.228-3.265l1.067-4.328H6.203c-3.131 0-4.786-3.706-2.696-6.038L15.219 1.642c2.527-2.82 7.14-.359 6.205 3.31l-1.05 4.129Z" clip-rule="evenodd"/>
  <path fill="#FFD104" d="M6.203 18.247h6.629l-1.83 7.426c-.281 1.138 1.151 1.889 1.928 1.011l11.707-13.24c.64-.723.126-1.863-.84-1.863h-6.64l1.845-7.245c.289-1.136-1.14-1.898-1.922-1.025L5.37 16.378c-.648.722-.135 1.87.834 1.87Z"/>
  <path fill="#000" fill-rule="evenodd" d="M10.79 19.847H6.203c-2.354 0-3.597-2.785-2.027-4.537L15.89 2.243c1.899-2.119 5.365-.27 4.663 2.487l-1.336 5.25h4.58c2.346 0 3.593 2.768 2.04 4.524l-11.708 13.24c-1.883 2.13-5.36.307-4.68-2.454l1.341-5.443Zm-4.586-1.6c-.97 0-1.482-1.148-.835-1.87L17.08 3.312c.783-.873 2.211-.111 1.922 1.025l-1.844 7.245h6.639c.966 0 1.48 1.14.84 1.863L12.93 26.684c-.776.878-2.21.127-1.929-1.011l1.83-7.426H6.205Z" clip-rule="evenodd"/>
</svg>
''';


import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class ShowSVG extends StatelessWidget {
  final String svgPath;
  final double? width;
  final double? height;
  final Color? color;
  final Function()? onTap;
  const ShowSVG({
    super.key,
    required this.svgPath,
    this.width,
    this.height,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        svgPath,
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      ),
    );
  }
}

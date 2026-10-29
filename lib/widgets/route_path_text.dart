import 'package:flutter/material.dart';

class RoutePathText extends StatelessWidget {
  const RoutePathText({
    super.key,
    required this.path,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
    this.textAlign,
    this.style,
  });

  final String path;
  final int maxLines;
  final TextOverflow overflow;
  final bool softWrap;
  final TextAlign? textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      path,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textAlign: textAlign,
      style: style,
    );
  }
}

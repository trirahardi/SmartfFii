import 'package:flutter/material.dart';
import '../../core/theme/neo_colors.dart';

class NeoBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const NeoBadge({
    super.key,
    required this.text,
    this.backgroundColor = NeoColors.yellowAccent,
    this.textColor = NeoColors.textDark,
    this.icon,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: NeoColors.black, width: 2.0),
        boxShadow: NeoColors.hardShadow(offset: 2.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


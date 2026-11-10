import 'package:flutter/material.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/neo_colors.dart';

class NeoCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor = NeoColors.surfaceLight,
    this.borderColor = NeoColors.black,
    this.borderWidth = 4.0,
    this.shadowOffset = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;
    final currentOffset = (_isPressed && isClickable) ? 2.0 : widget.shadowOffset;
    final translation = (_isPressed && isClickable)
        ? Offset(widget.shadowOffset - 2.0, widget.shadowOffset - 2.0)
        : Offset.zero;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        boxShadow: NeoColors.hardShadow(
          offset: currentOffset,
          color: widget.borderColor,
        ),
      ),
      child: widget.child,
    );

    if (!isClickable) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        AudioService().playClickSound();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: translation,
        child: card,
      ),
    );
  }
}


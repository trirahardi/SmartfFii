import 'package:flutter/material.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/neo_colors.dart';

enum NeoButtonVariant {
  primary,
  secondary,
  danger,
  warning,
  success,
  outline,
}

class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;

  const NeoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = NeoButtonVariant.primary,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderWidth = 2.0,
    this.shadowOffset = 4.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  Color _getBgColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    if (widget.onPressed == null || widget.isLoading) return const Color(0xFFD1D5DB); // Gray 300

    switch (widget.variant) {
      case NeoButtonVariant.primary:
        return NeoColors.primaryBlue;
      case NeoButtonVariant.secondary:
        return NeoColors.primaryBlueLight;
      case NeoButtonVariant.danger:
        return NeoColors.dangerRed;
      case NeoButtonVariant.warning:
        return NeoColors.yellowAccent;
      case NeoButtonVariant.success:
        return NeoColors.successGreen;
      case NeoButtonVariant.outline:
        return NeoColors.surfaceLight;
    }
  }

  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    if (widget.onPressed == null || widget.isLoading) return const Color(0xFF6B7280);

    switch (widget.variant) {
      case NeoButtonVariant.primary:
      case NeoButtonVariant.danger:
        return NeoColors.textLight;
      case NeoButtonVariant.secondary:
      case NeoButtonVariant.warning:
      case NeoButtonVariant.success:
      case NeoButtonVariant.outline:
        return NeoColors.textDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final currentOffset = (_isPressed && !isDisabled) ? 0.0 : widget.shadowOffset;
    final translation = (_isPressed && !isDisabled)
        ? Offset(widget.shadowOffset, widget.shadowOffset)
        : Offset.zero;

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Memproses...',
            style: TextStyle(
              color: _getTextColor(),
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ] else ...[
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.text.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getTextColor(),
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              AudioService().playClickSound();
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: translation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _getBgColor(),
            border: Border.all(
              color: NeoColors.black,
              width: widget.borderWidth,
            ),
            boxShadow: NeoColors.hardShadow(
              offset: currentOffset,
              color: NeoColors.black,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}


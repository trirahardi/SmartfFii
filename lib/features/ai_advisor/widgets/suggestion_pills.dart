import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';

/// Tombol-tombol pintasan cepat untuk bertanya ke Mentor AI
class SuggestionPills extends StatelessWidget {
  final ValueChanged<String> onSelected;
  final bool disabled;

  const SuggestionPills({
    super.key,
    required this.onSelected,
    this.disabled = false,
  });

  static const List<String> suggestions = [
    'Analisis Otomatis',
    'Pengeluaran Terbesar',
    'Saran Hemat',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((text) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: disabled ? null : () => onSelected(text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: disabled ? Colors.grey.shade300 : NeoColors.white,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: NeoColors.black,
                      offset: disabled ? Offset.zero : const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  text.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: disabled ? Colors.grey.shade600 : NeoColors.black,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


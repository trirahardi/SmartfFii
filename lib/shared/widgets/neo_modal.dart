import 'package:flutter/material.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/neo_colors.dart';

class NeoModal {
  NeoModal._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    AudioService().playClickSound();

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: const Color(0x99000000),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: NeoColors.surfaceLight,
              border: Border.all(color: NeoColors.black, width: 4.0),
              boxShadow: NeoColors.hardShadow(offset: 8.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Neobrutalism
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: const BoxDecoration(
                    color: NeoColors.bgLight,
                    border: Border(
                      bottom: BorderSide(color: NeoColors.black, width: 4.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            color: NeoColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.0,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AudioService().playClickSound();
                          Navigator.of(dialogContext).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: NeoColors.dangerRedLight,
                            border: Border.all(color: NeoColors.black, width: 2.0),
                            boxShadow: NeoColors.hardShadow(offset: 2.0),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: NeoColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Konten Modal
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


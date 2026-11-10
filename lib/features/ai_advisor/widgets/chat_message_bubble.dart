import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/theme/neo_colors.dart';
import '../models/chat_message.dart';

/// Bubble tampilan pesan obrolan AI atau Pengguna
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLastAiMessage;
  final bool isAiLoading;
  final VoidCallback? onRegenerate;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isLastAiMessage = false,
    this.isAiLoading = false,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar AI
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                color: NeoColors.white,
                border: Border.all(color: NeoColors.black, width: 2),
                boxShadow: NeoColors.hardShadow(offset: 3),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ],

          // Area Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? NeoColors.yellowAccent : NeoColors.white,
                    border: Border.all(color: NeoColors.black, width: 2),
                    boxShadow: NeoColors.hardShadow(offset: 4),
                  ),
                  child: message.content.trim().isEmpty
                      ? const _BouncingDotsIndicator()
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NeoColors.black,
                              height: 1.4,
                            ),
                            strong: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.black,
                            ),
                            listBullet: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.black,
                            ),
                            code: const TextStyle(
                              fontSize: 12,
                              backgroundColor: Color(0xFFE5E7EB),
                              fontFamily: 'monospace',
                            ),
                            blockquote: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: NeoColors.black,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              border: const Border(
                                left: BorderSide(
                                  color: NeoColors.black,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                // Tombol Muat Ulang Respon (jika pesan AI terakhir)
                if (!isUser &&
                    isLastAiMessage &&
                    !isAiLoading &&
                    message.content.trim().isNotEmpty &&
                    onRegenerate != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onRegenerate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NeoColors.white,
                        border: Border.all(color: NeoColors.black, width: 2),
                        boxShadow: NeoColors.hardShadow(offset: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.refresh, size: 14, color: NeoColors.black),
                          SizedBox(width: 4),
                          Text(
                            'MUAT ULANG RESPON',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 Bouncing Dots Neobrutalism
class _BouncingDotsIndicator extends StatefulWidget {
  const _BouncingDotsIndicator();

  @override
  State<_BouncingDotsIndicator> createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<_BouncingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final val = (_animController.value - delay) % 1.0;
            final offset = (val < 0.5) ? -6.0 * (1 - (val * 2 - 1).abs()) : 0.0;

            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: NeoColors.black,
                  border: Border.all(color: NeoColors.black, width: 1),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

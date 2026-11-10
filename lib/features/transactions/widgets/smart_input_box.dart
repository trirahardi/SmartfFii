import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../services/smart_input_parser.dart';
import 'smart_preview_card.dart';

class SmartInputBox extends StatefulWidget {
  final List<CategoryModel> categories;
  final Future<void> Function({
    required String type,
    required String category,
    required int nominal,
    required String description,
  }) onSaveTransaction;

  const SmartInputBox({
    super.key,
    required this.categories,
    required this.onSaveTransaction,
  });

  @override
  State<SmartInputBox> createState() => _SmartInputBoxState();
}

class _SmartInputBoxState extends State<SmartInputBox> {
  final _textController = TextEditingController();
  SmartInputResult? _previewResult;
  bool _isProcessing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleProcessAI() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 350));

    final result = SmartInputParser.parse(text, widget.categories);
    AudioService().playChatSound();

    if (mounted) {
      setState(() {
        _previewResult = result;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoColors.yellowAccent,
                  border: Border.all(color: NeoColors.black, width: 2),
                ),
                child: const Icon(Icons.smart_toy, size: 18, color: NeoColors.black),
              ),
              const SizedBox(width: 8),
              const Text(
                'SMART INPUT AI',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tuliskan transaksi Anda secara alami, biarkan AI yang mencatat.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NeoColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Textarea Input
          Container(
            decoration: BoxDecoration(
              color: NeoColors.surfaceLight,
              border: Border.all(color: NeoColors.black, width: 2.0),
              boxShadow: NeoColors.hardShadow(offset: 2.0),
            ),
            child: TextField(
              controller: _textController,
              maxLines: 3,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Contoh: Makan siang di warteg habis 25 ribu...',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Proses
          NeoButton(
            text: 'Proses Dengan AI',
            isLoading: _isProcessing,
            onPressed: _handleProcessAI,
            variant: NeoButtonVariant.primary,
            icon: const Icon(Icons.psychology, color: NeoColors.white),
          ),

          // Tampilan Preview
          if (_previewResult != null) ...[
            const SizedBox(height: 16),
            SmartPreviewCard(
              initialResult: _previewResult!,
              categories: widget.categories,
              onSave: ({
                required String type,
                required String category,
                required int nominal,
                required String description,
              }) async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await widget.onSaveTransaction(
                  type: type,
                  category: category,
                  nominal: nominal,
                  description: description,
                );
                if (mounted) {
                  setState(() {
                    _previewResult = null;
                    _textController.clear();
                  });
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Transaksi berhasil dicatat secara cerdas!'),
                      backgroundColor: NeoColors.successGreen,
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}


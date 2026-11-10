import '../../features/ai_advisor/models/chat_message.dart';

abstract class AiRepository {
  Future<String> askMentor({
    required String message,
    required List<ChatMessage> history,
    required String financialContextJson,
  });

  Future<Map<String, dynamic>> parseSmartInput({
    required String prompt,
    required List<String> categories,
  });
}


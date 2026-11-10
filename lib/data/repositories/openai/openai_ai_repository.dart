import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/config/ai_config.dart';
import '../../../core/config/ai_prompts.dart';
import '../../../features/ai_advisor/models/chat_message.dart';
import '../ai_repository.dart';

class OpenAiAiRepository implements AiRepository {
  final http.Client _client;

  OpenAiAiRepository({http.Client? client}) : _client = client ?? http.Client();

  String get _endpoint {
    String base = AiConfig.baseUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return '$base/chat/completions';
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AiConfig.apiKey.trim()}',
    };
  }

  @override
  Future<String> askMentor({
    required String message,
    required List<ChatMessage> history,
    required String financialContextJson,
  }) async {
    if (!AiConfig.hasApiKey) {
      throw const SocketException('API Key belum diisi pada env.json.');
    }

    // Batasi histori 8 pesan terakhir agar token efisien
    final recentHistory = history.length > 8 ? history.sublist(history.length - 8) : history;

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': AiPrompts.getMentorSystemPrompt(financialContextJson),
      },
      ...recentHistory.map((m) => {
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.content,
      }),
      {
        'role': 'user',
        'content': message,
      },
    ];

    try {
      final response = await _client.post(
        Uri.parse(_endpoint),
        headers: _headers,
        body: jsonEncode({
          'model': AiConfig.model,
          'messages': messages,
          'temperature': 0.6,
          'max_tokens': 900,
        }),
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String? ?? '';
          return _sanitizeOutput(content);
        }
        return 'Maaf, AI tidak memberikan jawaban. Silakan coba kembali.';
      } else if (response.statusCode == 401) {
        throw const HttpException('Kunci API tidak valid atau belum diatur (Error 401). Silakan periksa konfigurasi env.json.');
      } else if (response.statusCode == 429) {
        throw const HttpException('Maaf, antrean server AI sedang penuh atau kuota habis (Error 429). Mohon tunggu sekitar satu menit lalu coba lagi.');
      } else {
        throw HttpException('Server AI merespons dengan status error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw const SocketException('Permintaan ke AI melebihi batas waktu (Timeout). Mohon periksa koneksi internet Anda.');
    } on SocketException catch (e) {
      if (e.message.contains('API Key')) rethrow;
      throw const SocketException('Gagal terhubung ke server AI. Mohon pastikan perangkat Anda terhubung ke internet.');
    } on http.ClientException {
      throw const SocketException('Jaringan terputus saat menghubungi AI. Mohon periksa internet Anda.');
    }
  }

  @override
  Future<Map<String, dynamic>> parseSmartInput({
    required String prompt,
    required List<String> categories,
  }) async {
    if (!AiConfig.hasApiKey) {
      throw const SocketException('API Key belum diisi pada env.json.');
    }

    final messages = [
      {
        'role': 'system',
        'content': AiPrompts.getSmartInputSystemPrompt(categories),
      },
      {
        'role': 'user',
        'content': prompt,
      },
    ];

    // Coba dengan response_format json_object terlebih dahulu
    try {
      final bodyPayload = {
        'model': AiConfig.model,
        'messages': messages,
        'temperature': 0.1,
        'response_format': {'type': 'json_object'},
      };

      http.Response response = await _client.post(
        Uri.parse(_endpoint),
        headers: _headers,
        body: jsonEncode(bodyPayload),
      ).timeout(const Duration(seconds: 25));

      // Jika server mengembalikan 400 (beberapa provider tidak mendukung response_format), coba ulang tanpa response_format
      if (response.statusCode == 400) {
        bodyPayload.remove('response_format');
        response = await _client.post(
          Uri.parse(_endpoint),
          headers: _headers,
          body: jsonEncode(bodyPayload),
        ).timeout(const Duration(seconds: 25));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String? ?? '';
          return _cleanAndParseJson(content);
        }
      } else if (response.statusCode == 401) {
        throw const HttpException('Kunci API tidak valid (401).');
      } else if (response.statusCode == 429) {
        throw const HttpException('Antrean server AI penuh (429).');
      }
      throw HttpException('Status server AI: ${response.statusCode}');
    } on TimeoutException {
      throw const SocketException('Waktu parsing AI habis.');
    }
  }

  Map<String, dynamic> _cleanAndParseJson(String content) {
    String clean = content.replaceAll(RegExp(r'```json\s*'), '').replaceAll(RegExp(r'```\s*'), '').trim();
    // Cari kurung kurawal pertama dan terakhir
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start != -1 && end != -1 && end >= start) {
      clean = clean.substring(start, end + 1);
    }
    return jsonDecode(clean) as Map<String, dynamic>;
  }

  String _sanitizeOutput(String text) {
    // Bersihkan karakter emoji / simbol sesuai aturan ketat prompt
    return text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\uFFFD\u2500-\u25FF\u200B-\u200D\uFEFF\u25AF]', unicode: true), '')
        .trim();
  }
}


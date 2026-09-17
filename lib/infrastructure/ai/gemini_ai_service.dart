import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/services/ai_service.dart';
import 'ai_prompt_helper.dart';

class GeminiAIService implements AIService {
  final AIServiceConfig config;
  final http.Client _client;

  GeminiAIService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  AIProviderType get providerType => AIProviderType.gemini;

  @override
  Future<bool> testConnection() async {
    if (config.apiKey.trim().isEmpty) {
      throw ValidationException('Gemini API Key không được để trống.');
    }

    final model = config.effectiveModel;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${config.apiKey}',
    );

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Respond with "OK"'}
              ]
            }
          ],
          'generationConfig': {'maxOutputTokens': 10},
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        final msg = body['error']?['message'] ?? 'Status ${response.statusCode}';
        throw ValidationException('Kết nối Gemini thất bại: $msg');
      }
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException('Không thể kết nối đến máy chủ Gemini: $e');
    }
  }

  @override
  Future<RequirementReview> reviewRequirement(
    Requirement requirement, {
    List<Requirement>? allRequirements,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw ValidationException('Vui lòng nhập Gemini API Key trong phần Cài đặt AI.');
    }

    final model = config.effectiveModel;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${config.apiKey}',
    );

    final promptText = '${AIPromptHelper.systemInstruction}\n\n${AIPromptHelper.buildUserPrompt(requirement, allRequirements: allRequirements)}';

    int attempts = 0;
    while (attempts <= config.maxRetries) {
      attempts++;
      try {
        final response = await _client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': promptText}
                ]
              }
            ],
            'generationConfig': {
              'temperature': config.temperature,
              'responseMimeType': 'application/json',
            },
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final candidates = decoded['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.isNotEmpty) {
              return AIPromptHelper.parseAIResponse(text);
            }
          }
          throw DocumentParseException('Phản hồi từ Gemini không có nội dung.');
        } else if (response.statusCode == 429) {
          // Rate limit cooldown and retry
          if (attempts <= config.maxRetries) {
            await Future.delayed(Duration(seconds: 2 * attempts));
            continue;
          }
          throw DocumentParseException('Gemini API đã vượt quá giới hạn (Rate Limit / Quota Exceeded). Vui lòng thử lại sau.');
        } else {
          final errorBody = jsonDecode(response.body);
          final msg = errorBody['error']?['message'] ?? 'Mã lỗi HTTP ${response.statusCode}';
          throw DocumentParseException('Lỗi Gemini API: $msg');
        }
      } on TimeoutException {
        if (attempts <= config.maxRetries) {
          continue;
        }
        throw DocumentParseException('Hết thời gian chờ phản hồi từ Gemini API (Timeout).');
      } catch (e) {
        if (e is DocumentParseException || e is ValidationException) rethrow;
        if (attempts > config.maxRetries) {
          throw DocumentParseException('Lỗi kết nối Gemini: $e');
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    throw DocumentParseException('Không thể hoàn tất đánh giá bằng Gemini API.');
  }

  @override
  Future<List<RequirementReview>> batchReviewRequirements(
    List<Requirement> requirements, {
    void Function(int completed, int total)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    final results = <RequirementReview>[];
    for (int i = 0; i < requirements.length; i++) {
      if (shouldCancel != null && shouldCancel()) {
        break;
      }
      final review = await reviewRequirement(
        requirements[i],
        allRequirements: requirements,
      );
      results.add(review);
      onProgress?.call(i + 1, requirements.length);

      // Brief spacing between calls to avoid hitting rate limits too quickly
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return results;
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/services/ai_service.dart';
import 'ai_prompt_helper.dart';

class OpenAIAIService implements AIService {
  final AIServiceConfig config;
  final http.Client _client;

  OpenAIAIService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  AIProviderType get providerType => AIProviderType.openai;

  String get _baseUrl => (config.baseUrl != null && config.baseUrl!.trim().isNotEmpty)
      ? config.baseUrl!.trim()
      : 'https://api.openai.com/v1';

  @override
  Future<bool> testConnection() async {
    if (config.apiKey.trim().isEmpty) {
      throw ValidationException('OpenAI API Key không được để trống.');
    }

    final url = Uri.parse('$_baseUrl/chat/completions');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey.trim()}',
        },
        body: jsonEncode({
          'model': config.effectiveModel,
          'messages': [
            {'role': 'user', 'content': 'Hi'}
          ],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        final msg = body['error']?['message'] ?? 'Status ${response.statusCode}';
        throw ValidationException('Kết nối OpenAI thất bại: $msg');
      }
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException('Không thể kết nối đến máy chủ OpenAI: $e');
    }
  }

  @override
  Future<RequirementReview> reviewRequirement(
    Requirement requirement, {
    List<Requirement>? allRequirements,
  }) async {
    if (config.apiKey.trim().isEmpty) {
      throw ValidationException('Vui lòng nhập OpenAI API Key trong phần Cài đặt AI.');
    }

    final url = Uri.parse('$_baseUrl/chat/completions');
    final userPrompt = AIPromptHelper.buildUserPrompt(requirement, allRequirements: allRequirements);

    int attempts = 0;
    while (attempts <= config.maxRetries) {
      attempts++;
      try {
        final response = await _client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${config.apiKey.trim()}',
          },
          body: jsonEncode({
            'model': config.effectiveModel,
            'temperature': config.temperature,
            'response_format': {'type': 'json_object'},
            'messages': [
              {
                'role': 'system',
                'content': AIPromptHelper.systemInstruction,
              },
              {
                'role': 'user',
                'content': userPrompt,
              }
            ],
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final choices = decoded['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final content = choices[0]['message']?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              return AIPromptHelper.parseAIResponse(content);
            }
          }
          throw DocumentParseException('Phản hồi từ OpenAI không có nội dung.');
        } else if (response.statusCode == 429) {
          if (attempts <= config.maxRetries) {
            await Future.delayed(Duration(seconds: 2 * attempts));
            continue;
          }
          throw DocumentParseException('OpenAI API đã vượt quá giới hạn (Rate Limit / Quota Exceeded). Vui lòng kiểm tra tài khoản OpenAI của bạn.');
        } else {
          final errorBody = jsonDecode(response.body);
          final msg = errorBody['error']?['message'] ?? 'Mã lỗi HTTP ${response.statusCode}';
          throw DocumentParseException('Lỗi OpenAI API: $msg');
        }
      } on TimeoutException {
        if (attempts <= config.maxRetries) {
          continue;
        }
        throw DocumentParseException('Hết thời gian chờ phản hồi từ OpenAI API (Timeout).');
      } catch (e) {
        if (e is DocumentParseException || e is ValidationException) rethrow;
        if (attempts > config.maxRetries) {
          throw DocumentParseException('Lỗi kết nối OpenAI: $e');
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    throw DocumentParseException('Không thể hoàn tất đánh giá bằng OpenAI API.');
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

      await Future.delayed(const Duration(milliseconds: 300));
    }
    return results;
  }
}

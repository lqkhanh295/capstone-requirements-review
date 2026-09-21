import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/services/ai_service.dart';
import 'ai_prompt_helper.dart';

class OllamaAIService implements AIService {
  final AIServiceConfig config;
  final http.Client _client;

  OllamaAIService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  AIProviderType get providerType => AIProviderType.ollama;

  String get _baseUrl => config.effectiveBaseUrl;

  @override
  Future<bool> testConnection() async {
    final tagsUrl = Uri.parse('$_baseUrl/api/tags');

    try {
      final response = await _client.get(tagsUrl).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ValidationException(
          'Máy chủ Ollama phản hồi mã lỗi ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException(
        'Không thể kết nối đến Ollama tại $_baseUrl.\n'
        'Vui lòng đảm bảo dịch vụ Ollama đang chạy trên máy của bạn '
        '(ví dụ: mở "D:\\ollama\\start_ollama.bat" hoặc chạy lệnh "ollama serve").\n'
        'Chi tiết lỗi: $e',
      );
    }
  }

  @override
  Future<RequirementReview> reviewRequirement(
    Requirement requirement, {
    List<Requirement>? allRequirements,
  }) async {
    final chatUrl = Uri.parse('$_baseUrl/api/chat');
    final userPrompt = AIPromptHelper.buildUserPrompt(requirement, allRequirements: allRequirements);

    int attempts = 0;
    while (attempts <= config.maxRetries) {
      attempts++;
      try {
        final response = await _client.post(
          chatUrl,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': config.effectiveModel,
            'stream': false,
            'format': 'json',
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
            'options': {
              'temperature': config.temperature,
            },
          }),
        ).timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          final content = body['message']?['content'] as String?;
          if (content == null || content.trim().isEmpty) {
            throw ValidationException('Ollama trả về phản hồi rỗng.');
          }

          return AIPromptHelper.parseAIResponse(content);
        } else {
          final errorMsg = response.body;
          if (attempts > config.maxRetries) {
            throw ValidationException('Lỗi từ Ollama (${response.statusCode}): $errorMsg');
          }
        }
      } catch (e) {
        if (attempts > config.maxRetries) {
          if (e is ValidationException) rethrow;
          throw ValidationException(
            'Lỗi khi gửi yêu cầu phân tích tới Ollama (${config.effectiveModel}): $e',
          );
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }

    throw ValidationException('Không nhận được phản hồi hợp lệ từ Ollama sau $attempts lần thử.');
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

      await Future.delayed(const Duration(milliseconds: 200));
    }
    return results;
  }
}

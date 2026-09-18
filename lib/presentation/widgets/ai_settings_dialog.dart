import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/ai_service.dart';
import '../providers/ai_providers.dart';

class AISettingsDialog extends ConsumerStatefulWidget {
  const AISettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AISettingsDialog(),
    );
  }

  @override
  ConsumerState<AISettingsDialog> createState() => _AISettingsDialogState();
}

class _AISettingsDialogState extends ConsumerState<AISettingsDialog> {
  late AIProviderType _selectedProvider;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _baseUrlController;
  late double _temperature;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final config = ref.read(aiConfigProvider);
    _selectedProvider = config.provider;
    _apiKeyController = TextEditingController(text: config.apiKey);
    _modelController = TextEditingController(text: config.model);
    _baseUrlController = TextEditingController(text: config.baseUrl ?? '');
    _temperature = config.temperature;
  }

  @override
  void dispose() {
    _apiKeyController.disposeSecondary();
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _onProviderChanged(AIProviderType? newProvider) {
    if (newProvider == null) return;
    setState(() {
      _selectedProvider = newProvider;
      _modelController.text = newProvider.defaultModel;
    });
  }

  void _saveSettings() {
    final newConfig = AIServiceConfig(
      provider: _selectedProvider,
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim().isNotEmpty
          ? _modelController.text.trim()
          : _selectedProvider.defaultModel,
      baseUrl: _baseUrlController.text.trim().isNotEmpty ? _baseUrlController.text.trim() : null,
      temperature: _temperature,
    );

    ref.read(aiConfigProvider.notifier).updateConfig(newConfig);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final aiReviewState = ref.watch(aiReviewProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.sparkles, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: AppTheme.space12),
                  const Text(
                    'Cấu hình AI Provider',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space16),

              // Provider Selection
              const Text(
                'AI Provider',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AIProviderType>(
                    value: _selectedProvider,
                    isExpanded: true,
                    items: AIProviderType.values.map((provider) {
                      return DropdownMenuItem(
                        value: provider,
                        child: Text(provider.label),
                      );
                    }).toList(),
                    onChanged: _onProviderChanged,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space16),

              // API Key Field (for Gemini / OpenAI)
              if (_selectedProvider != AIProviderType.mock) ...[
                Text(
                  '${_selectedProvider == AIProviderType.gemini ? "Gemini" : "OpenAI"} API Key',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    hintText: _selectedProvider == AIProviderType.gemini
                        ? 'AIzaSy...'
                        : 'sk-...',
                    prefixIcon: const Icon(LucideIcons.keyRound, size: 16),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureApiKey ? LucideIcons.eyeOff : LucideIcons.eye, size: 16),
                      onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),

                // Model Selection
                const Text(
                  'Model Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    hintText: _selectedProvider.defaultModel,
                    prefixIcon: const Icon(LucideIcons.cpu, size: 16),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.space12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.info, size: 16, color: AppTheme.primary),
                      SizedBox(width: AppTheme.space8),
                      Expanded(
                        child: Text(
                          'Mock AI Service hoạt động offline bằng bộ phân tích ngữ nghĩa (Semantic Rules Engine), không cần API Key.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
              ],

              // Custom Base URL (OpenAI only)
              if (_selectedProvider == AIProviderType.openai) ...[
                const Text(
                  'Base URL (Tùy chọn cho Proxy / Ollama / Local LLM)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                TextField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://api.openai.com/v1',
                    prefixIcon: Icon(LucideIcons.globe, size: 16),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
              ],

              // Test Connection Status Banner
              if (aiReviewState.connectionStatus != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.space12),
                  margin: const EdgeInsets.only(bottom: AppTheme.space16),
                  decoration: BoxDecoration(
                    color: (aiReviewState.connectionSuccess ?? false)
                        ? AppTheme.statusPassed.withOpacity(0.1)
                        : AppTheme.statusFailed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: (aiReviewState.connectionSuccess ?? false)
                          ? AppTheme.statusPassed.withOpacity(0.3)
                          : AppTheme.statusFailed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        (aiReviewState.connectionSuccess ?? false)
                            ? LucideIcons.checkCircle2
                            : LucideIcons.alertCircle,
                        size: 16,
                        color: (aiReviewState.connectionSuccess ?? false)
                            ? AppTheme.statusPassed
                            : AppTheme.statusFailed,
                      ),
                      const SizedBox(width: AppTheme.space8),
                      Expanded(
                        child: Text(
                          aiReviewState.connectionStatus!,
                          style: TextStyle(
                            fontSize: 12,
                            color: (aiReviewState.connectionSuccess ?? false)
                                ? AppTheme.statusPassed
                                : AppTheme.statusFailed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons
              Row(
                children: [
                  if (_selectedProvider != AIProviderType.mock) ...[
                    OutlinedButton.icon(
                      onPressed: aiReviewState.isTestingConnection
                          ? null
                          : () {
                              final testConfig = AIServiceConfig(
                                provider: _selectedProvider,
                                apiKey: _apiKeyController.text.trim(),
                                model: _modelController.text.trim().isNotEmpty
                                    ? _modelController.text.trim()
                                    : _selectedProvider.defaultModel,
                                baseUrl: _baseUrlController.text.trim().isNotEmpty
                                    ? _baseUrlController.text.trim()
                                    : null,
                              );
                              ref.read(aiConfigProvider.notifier).updateConfig(testConfig);
                              ref.read(aiReviewProvider.notifier).testConnection();
                            },
                      icon: aiReviewState.isTestingConnection
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.activity, size: 14),
                      label: const Text('Kiểm tra kết nối', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Lưu cấu hình'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeSecondary() {}
}

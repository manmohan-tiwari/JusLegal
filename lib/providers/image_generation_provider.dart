import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/core/core.dart';
import '../services/ai_service.dart';

final siliconFlowApiKeyProvider = Provider<String>((ref) {
  return EnvConfig.siliconflowApiKey;
});

/// SiliconFlow service provider
final siliconFlowProvider = Provider<SiliconFlowService>((ref) {
  final apiKey = ref.watch(siliconFlowApiKeyProvider);
  return SiliconFlowService(apiKey: apiKey);
});

/// Generate an image based on a prompt
/// Usage: ref.watch(generateImageProvider('your prompt'))
final generateImageProvider =
    FutureProvider.family<String, String>((ref, prompt) async {
  final service = ref.watch(siliconFlowProvider);
  return service.generateLegalDocumentImage(prompt: prompt);
});

/// Generate case timeline images
/// Usage: ref.watch(generateTimelineImagesProvider(('CaseType', ['Stage1', 'Stage2'])))
final generateTimelineImagesProvider = FutureProvider.family<
    List<String>,
    ({String caseType, List<String> stages})>((ref, params) async {
  final service = ref.watch(siliconFlowProvider);
  return service.generateCaseTimelineImages(
    caseType: params.caseType,
    stages: params.stages,
  );
});

/// Generate case header image
/// Usage: ref.watch(generateCaseHeaderImageProvider(('Case Title', 'Consumer Rights')))
final generateCaseHeaderImageProvider = FutureProvider.family<
    String,
    ({String caseTitle, String category})>((ref, params) async {
  final service = ref.watch(siliconFlowProvider);
  return service.generateCaseHeaderImage(
    caseTitle: params.caseTitle,
    category: params.category,
  );
});

/// Fetch available models
/// Usage: ref.watch(availableModelsProvider)
final availableModelsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(siliconFlowProvider);
  return service.getAvailableModels();
});

/// Get account info
/// Usage: ref.watch(accountInfoProvider)
final accountInfoProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(siliconFlowProvider);
  return service.getAccountInfo();
});

/// Invalidate image cache when needed
/// Usage: ref.refresh(generateImageProvider('prompt'))
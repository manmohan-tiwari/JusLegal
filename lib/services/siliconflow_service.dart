import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/exceptions/ai_exceptions.dart';

/// SiliconFlow Image Generation Service
/// Provides methods to generate legal document illustrations, case diagrams, and UI assets
class SiliconFlowService {
  static const String baseUrl = 'https://api.siliconflow.cn/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  late final Dio _dio;
  final String apiKey;

  SiliconFlowService({required this.apiKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add request/response logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: true,
        ),
      );
    }
  }

  /// Generate an image for legal document illustration
  /// Common use cases: case diagrams, timeline illustrations, process flows
  Future<String> generateLegalDocumentImage({
    required String prompt,
    String model = 'black-forest-labs/FLUX.1-pro',
    String aspectRatio = '1024x768',
    int numInferenceSteps = 20,
    double guidanceScale = 7.5,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('SiliconFlow API key not configured');
    }

    if (prompt.trim().isEmpty) {
      throw ArgumentError.value(prompt, 'prompt', 'Prompt cannot be empty');
    }

    try {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Generating image with prompt: $prompt');
      }

      final response = await _dio.post(
        '/image/generations',
        data: {
          'prompt': prompt,
          'model': model,
          'image_size': aspectRatio,
          'num_inference_steps': numInferenceSteps,
          'guidance_scale': guidanceScale,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['images'] != null && data['images'].isNotEmpty) {
          final imageUrl = data['images'][0]['url'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('[SiliconFlow] ✅ Image generated successfully: $imageUrl');
            }
            return imageUrl;
          }
        }

        throw Exception('No image URL in response: $data');
      } else {
        throw Exception(
          'Image generation failed: ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] ❌ DioException: ${e.message}');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw TimeoutException('Connection timeout while generating image');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('Receive timeout while generating image');
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired SiliconFlow API key');
      } else if (e.response?.statusCode == 429) {
        throw RateLimitException('SiliconFlow rate limit exceeded. Please try again later.');
      }

      throw Exception('Image generation failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] ❌ Unexpected error: $e');
      }
      rethrow;
    }
  }

  /// Generate images for case timeline visualization
  /// Returns a list of image URLs showing different stages of a legal case
  Future<List<String>> generateCaseTimelineImages({
    required String caseType,
    required List<String> stages,
    int imagesPerStage = 1,
  }) async {
    final images = <String>[];

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final prompt = _buildTimelinePrompt(caseType, stage, i + 1, stages.length);

      try {
        final imageUrl = await generateLegalDocumentImage(
          prompt: prompt,
          aspectRatio: '1024x576', // Wider for timeline visualization
        );
        images.add(imageUrl);

        // Rate limiting: small delay between requests to avoid throttling
        if (i < stages.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SiliconFlow] Failed to generate stage image for "$stage": $e');
        }
        // Continue with other stages even if one fails
      }
    }

    if (images.isEmpty) {
      throw Exception('Failed to generate any timeline images');
    }

    return images;
  }

  /// Generate an image for case documentation or complaint letter header
  Future<String> generateCaseHeaderImage({
    required String caseTitle,
    required String category,
  }) async {
    final prompt = _buildHeaderPrompt(caseTitle, category);
    return generateLegalDocumentImage(
      prompt: prompt,
      aspectRatio: '1280x400',
      numInferenceSteps: 15,
    );
  }

  /// List available models (requires active API connection)
  Future<List<String>> getAvailableModels() async {
    try {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Fetching available models');
      }

      final response = await _dio.get('/models');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final models = (data['data'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((m) => m['id'] as String)
                .toList() ??
            [];

        if (kDebugMode) {
          debugPrint('[SiliconFlow] Found ${models.length} available models');
        }

        return models;
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Failed to fetch models: $e');
      }
      rethrow;
    }
  }

  /// Get current account balance and usage info
  Future<Map<String, dynamic>> getAccountInfo() async {
    try {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Fetching account info');
      }

      final response = await _dio.get('/user/info');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('[SiliconFlow] Account info: $data');
        }
        return data;
      } else {
        throw Exception('Failed to fetch account info: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Failed to fetch account info: $e');
      }
      rethrow;
    }
  }

  String _buildTimelinePrompt(
    String caseType,
    String stage,
    int stageNumber,
    int totalStages,
  ) {
    return '''Professional legal case timeline illustration for a $caseType case.
Stage $stageNumber of $totalStages: $stage
Style: Clean, professional, corporate legal document aesthetic.
Colors: Blues, grays, and professional tones.
Include stage indicator and progress visualization.
High quality, clear, and suitable for legal documentation.''';
  }

  String _buildHeaderPrompt(String caseTitle, String category) {
    return '''Professional header illustration for a legal case document.
Case: $caseTitle
Category: $category
Style: Modern, professional, formal legal aesthetic.
Include symbolic elements representing justice, law, and protection.
Colors: Deep blues, golds, and professional tones.
High resolution, suitable for document header.''';
  }
}
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/ai_runtime_config.dart';
import '../core/constants/ai_constants.dart';
import '../core/exceptions/ai_exceptions.dart';

class GroqService {
  late final Dio _dio;

  GroqService() {
    _dio = Dio(BaseOptions(
      baseUrl: AiRuntimeConfig.proxyEnabled
          ? AiRuntimeConfig.proxyBaseUrl
          : AIConstants.groqBaseUrl,
      connectTimeout: const Duration(seconds: AIConstants.timeoutSeconds),
      receiveTimeout: const Duration(seconds: AIConstants.timeoutSeconds),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<String> _getApiKey() async {
    if (AiRuntimeConfig.proxyEnabled) {
      return '';
    }

    if (!AiRuntimeConfig.allowDirectVendorCalls) {
      throw ApiKeyException('Direct Groq calls are disabled outside debug builds');
    }

    final apiKey = AiRuntimeConfig.groqApiKey;
    if (apiKey.isEmpty) {
      throw ApiKeyException('Groq API Key not found or invalid');
    }
    return apiKey;
  }

  Options _requestOptions(String apiKey) {
    final headers = <String, dynamic>{
      'X-JusLegal-Provider': 'groq',
    };

    if (!AiRuntimeConfig.proxyEnabled) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    return Options(headers: headers);
  }

  Future<Map<String, dynamic>> analyze(String systemPrompt, String problemText, {String category = 'general'}) async {
    try {
      final apiKey = await _getApiKey();
      
      final response = await _dio.post(
        '', // URL is set in BaseOptions
        options: _requestOptions(apiKey),
        data: {
          'model': AIConstants.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': problemText},
          ],
          'temperature': AIConstants.temperature,
          'max_tokens': AIConstants.maxTokens,
          'top_p': AIConstants.topP,
          'response_format': {'type': 'json_object'},
          'stream': false,
        },
      );

      if (kDebugMode) {
        print('[GroqService] Raw API response: ${_debugPreview(response.data)}');
      }
      final parsed = _parseJsonResponse(response, 'groq', AIConstants.groqModel);
      if (kDebugMode) {
        print('[GroqService] Parsed response keys: ${parsed.keys.toList()}');
        print('[GroqService] Parsed response preview: ${_debugPreview(parsed)}');
      }
      return parsed;
    } catch (e) {
      _handleDioError(e, 'Groq');
    }
  }

  Future<String> generateRaw(String systemPrompt, String prompt) async {
    try {
      final apiKey = await _getApiKey();
      
      final response = await _dio.post(
        '', // URL is set in BaseOptions
        options: _requestOptions(apiKey),
        data: {
          'model': AIConstants.groqModel,
          'messages': [
            if (systemPrompt.isNotEmpty) {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': AIConstants.temperature,
          'max_tokens': AIConstants.maxTokens,
          'top_p': AIConstants.topP,
          'stream': false,
        },
      );

      if (kDebugMode) {
        print('[GroqService] Raw API response (letter): ${_debugPreview(response.data)}');
      }
      return _parseRawResponse(response);
    } catch (e) {
      _handleDioError(e, 'Groq');
    }
  }

  Map<String, dynamic> _parseJsonResponse(Response response, String provider, String modelName) {
    if (response.statusCode == 200) {
      final data = response.data;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw ParseException('No choices returned from $provider API');
      }
      
      final content = _extractContent(choices[0]['message']['content']);
      String cleanContent = content;
      
      if (cleanContent.startsWith('```json')) {
        cleanContent = cleanContent.substring(7);
      }
      if (cleanContent.endsWith('```')) {
        cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      }
      cleanContent = cleanContent.trim();
      if (kDebugMode) {
        print('[GroqService] Clean JSON content: ${_debugPreview(cleanContent)}');
      }

      try {
        final parsedJson = jsonDecode(cleanContent) as Map<String, dynamic>;
        parsedJson['_model'] = modelName;
        parsedJson['_provider'] = provider;
        return parsedJson;
      } catch (e) {
        throw ParseException('Failed to parse JSON response: $e');
      }
    } else {
      throw NetworkException('HTTP Error: ${response.statusCode}');
    }
  }

  String _parseRawResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw ParseException('No choices returned from API');
      }
      final content = _extractContent(choices[0]['message']['content']).trim();
      if (kDebugMode) {
        print('[GroqService] Raw letter content: ${_debugPreview(content)}');
      }
      return content;
    } else {
      throw NetworkException('HTTP Error: ${response.statusCode}');
    }
  }

  String _extractContent(dynamic content) {
    if (content is String) return content;
    if (content is List) {
      final buffer = StringBuffer();
      for (final item in content) {
        if (item is Map && item['text'] is String) {
          buffer.write(item['text']);
        } else if (item is String) {
          buffer.write(item);
        }
      }
      return buffer.toString();
    }
    if (content is Map && content['text'] is String) {
      return content['text'] as String;
    }
    return content.toString();
  }

  String _debugPreview(dynamic value) {
    final text = value.toString();
    return text.length > 700 ? '${text.substring(0, 700)}...' : text;
  }

  Never _handleDioError(dynamic e, String provider) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else if (e.response?.statusCode == 429) {
        throw RateLimitException('Rate limit exceeded', provider);
      } else if (e.response?.statusCode == 401) {
        throw ApiKeyException('Invalid $provider API Key');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } else if (e is RateLimitException || e is ApiKeyException || e is ParseException || e is NetworkException) {
      throw e;
    }
    throw ParseException('Unexpected error: $e');
  }
}

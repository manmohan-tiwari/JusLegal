import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/config/env_config.dart';
import '../core/config/ai_config.dart';
import '../core/exceptions/ai_exceptions.dart';

/// Calls OpenRouter only through the Cloudflare Worker proxy.
class OpenRouterService {
  final Dio _dio;

  OpenRouterService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: WORKER_BASE_URL,
              connectTimeout: ApiConstants.connectionTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              headers: {
                'Content-Type': 'application/json',
                if (EnvConfig.proxyAuthToken.isNotEmpty)
                  'Authorization': 'Bearer ${EnvConfig.proxyAuthToken}',
              },
            ));

  Future<Map<String, dynamic>> analyze(
    String systemPrompt,
    String problemText, {
    String category = 'general',
  }) async {
    final content = await _call(systemPrompt, problemText, jsonResponse: true);
    try {
      final parsed =
          jsonDecode(_stripCodeFence(content)) as Map<String, dynamic>;
      parsed['_model'] = OPENROUTER_MODEL;
      parsed['_provider'] = 'openrouter';
      return parsed;
    } on FormatException catch (error) {
      throw ParseException('Failed to parse OpenRouter response: $error');
    }
  }

  Future<String> generateRaw(String systemPrompt, String prompt) => _call(
        systemPrompt,
        prompt,
        jsonResponse: false,
        maxTokens: ApiConstants.letterMaxTokens,
      );

  /// Sends a conversational request with JusLegal's chat context.
  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory,
    {String languageCode = 'en'}
  ) =>
      _sendChatRequest(userMessage, conversationHistory, languageCode);

  Future<String> _sendChatRequest(
    String userMessage,
    List<Map<String, String>> conversationHistory,
    String languageCode,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
            '[OpenRouterService] Calling Worker /callOpenRouter for chat');
      }
      final history =
          _historyWithCurrentMessage(userMessage, conversationHistory);
      final response = await _dio.post<Map<String, dynamic>>(
        '/callOpenRouter',
        data: {
          'model': OPENROUTER_MODEL,
          'messages': [
            {
              'role': 'system',
              'content': chatSystemPromptForLanguage(languageCode),
            },
            ...history,
          ],
          'temperature': ApiConstants.temperature,
          'max_tokens': ApiConstants.maxTokens,
          'stream': false,
        },
      );
      return _contentFrom(response.data);
    } on DioException catch (error) {
      _throwDioError(error);
    }
  }

  List<Map<String, String>> _historyWithCurrentMessage(
    String userMessage,
    List<Map<String, String>> history,
  ) {
    final messages = history
        .where((message) => message['role'] != 'system')
        .map(Map<String, String>.from)
        .toList();
    if (messages.isEmpty ||
        messages.last['role'] != 'user' ||
        messages.last['content'] != userMessage) {
      messages.add({'role': 'user', 'content': userMessage});
    }
    return messages;
  }

  Future<String> _call(
    String systemPrompt,
    String prompt, {
    required bool jsonResponse,
    int? maxTokens,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[OpenRouterService] Calling Worker /callOpenRouter');
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/callOpenRouter',
        data: {
          'model': OPENROUTER_MODEL,
          'messages': [
            if (systemPrompt.isNotEmpty)
              {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': ApiConstants.temperature,
          'max_tokens': maxTokens ?? ApiConstants.maxTokens,
          if (jsonResponse) 'response_format': {'type': 'json_object'},
          'stream': false,
        },
      );
      return _contentFrom(response.data);
    } on DioException catch (error) {
      _throwDioError(error);
    }
  }

  String _contentFrom(Map<String, dynamic>? data) {
    final choices = data?['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw ParseException('No choices returned from OpenRouter');
    }
    final message = Map<String, dynamic>.from(choices.first as Map)['message'];
    if (message is! Map || message['content'] is! String) {
      throw ParseException('Unexpected OpenRouter response format');
    }
    final content = message['content'] as String;
    if (kDebugMode) {
      debugPrint('[OpenRouterService] chat response received '
          '(length=${content.length})');
    }
    return content;
  }

  String _stripCodeFence(String value) {
    var result = value.trim();
    if (result.startsWith('```json')) result = result.substring(7);
    if (result.startsWith('```')) result = result.substring(3);
    if (result.endsWith('```')) result = result.substring(0, result.length - 3);
    return result.trim();
  }

  Never _throwDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw NetworkException('OpenRouter request timed out');
    }
    if (error.response?.statusCode == 429) {
      throw RateLimitException('OpenRouter rate limit exceeded', 'OpenRouter');
    }
    throw NetworkException(
        'OpenRouter request failed (${error.response?.statusCode ?? 'network error'})');
  }
}

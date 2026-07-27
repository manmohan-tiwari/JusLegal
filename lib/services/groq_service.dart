import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/config/env_config.dart';
import '../core/config/ai_config.dart';
import '../core/exceptions/ai_exceptions.dart';

/// Calls Groq only through the Cloudflare Worker proxy.
class GroqService {
  final Dio _dio;

  GroqService({Dio? dio})
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
      parsed['_model'] = GROQ_MODEL;
      parsed['_provider'] = 'groq';
      return parsed;
    } on FormatException catch (error) {
      throw ParseException('Failed to parse Groq response: $error');
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
  ) =>
      _sendChatRequest(userMessage, conversationHistory);

  Future<String> _sendChatRequest(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('[GroqService] Calling Worker /callGroq for chat');
      }
      final history =
          _historyWithCurrentMessage(userMessage, conversationHistory);
      final response = await _dio.post<Map<String, dynamic>>(
        '/callGroq',
        data: {
          'model': GROQ_MODEL,
          'messages': [
            {'role': 'system', 'content': jusLegalChatSystemPrompt},
            ...history,
          ],
          'temperature': ApiConstants.temperature,
          'max_tokens': ApiConstants.maxTokens,
          'stream': false,
        },
      );
      return _contentFrom(response.data, 'Groq');
    } on DioException catch (error) {
      _throwDioError(error, 'Groq');
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
      if (kDebugMode) debugPrint('[GroqService] Calling Worker /callGroq');
      final response = await _dio.post<Map<String, dynamic>>(
        '/callGroq',
        data: {
          'model': GROQ_MODEL,
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
      return _contentFrom(response.data, 'Groq');
    } on DioException catch (error) {
      _throwDioError(error, 'Groq');
    }
  }

  String _contentFrom(Map<String, dynamic>? data, String provider) {
    final choices = data?['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw ParseException('No choices returned from $provider');
    }
    final message = Map<String, dynamic>.from(choices.first as Map)['message'];
    if (message is! Map || message['content'] is! String) {
      throw ParseException('Unexpected $provider response format');
    }
    final content = message['content'] as String;
    if (kDebugMode) {
      debugPrint('[$provider] response received (length=${content.length})');
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

  Never _throwDioError(DioException error, String provider) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw NetworkException('$provider request timed out');
    }
    if (error.response?.statusCode == 429) {
      throw RateLimitException('$provider rate limit exceeded', provider);
    }
    throw NetworkException(
        '$provider request failed (${error.response?.statusCode ?? 'network error'})');
  }
}

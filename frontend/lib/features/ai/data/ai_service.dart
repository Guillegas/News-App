import 'package:dio/dio.dart';
import '../domain/repository/ai_repository.dart';

/// Concrete implementation of [AiRepository] using OpenAI's Chat API.
class AiService implements AiRepository {
  static const _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  final String _apiKey;
  final Dio _dio;

  AiService({required String apiKey})
      : _apiKey = apiKey,
        _dio = Dio();

  bool get isAvailable => _apiKey.isNotEmpty;

  Future<String> _chat(String systemPrompt, String userMessage) async {
    final response = await _dio.post(
      _baseUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
        'max_tokens': 300,
        'temperature': 0.7,
      },
    );

    final choices = response.data['choices'] as List;
    if (choices.isNotEmpty) {
      return choices[0]['message']['content'] as String;
    }
    return 'No response from AI.';
  }

  @override
  Future<String> summarizeArticle({
    required String title,
    required String content,
  }) {
    return _chat(
      'You are a news assistant. Summarize articles in 2-3 clear, concise sentences. '
      'Focus on the key facts and main takeaway. Reply ONLY with the summary.',
      'Title: $title\n\nContent: $content',
    );
  }

  @override
  Future<String> suggestHeadline({
    required String title,
    required String content,
  }) {
    return _chat(
      'You are a senior news editor. Suggest ONE improved, more engaging headline. '
      'Reply ONLY with the headline, no quotes or extra text.',
      'Original title: $title\n\nContent: $content',
    );
  }

  @override
  Future<String> analyzeSentiment({
    required String title,
    required String content,
  }) {
    return _chat(
      'Analyze the sentiment of news articles. Reply with EXACTLY this format:\n'
      'Sentiment: [Positive/Negative/Neutral]\n'
      'Explanation: [One sentence explaining why]',
      'Title: $title\n\nContent: $content',
    );
  }
}

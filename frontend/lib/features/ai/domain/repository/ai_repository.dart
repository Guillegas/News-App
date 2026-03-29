/// Contract for AI-powered article analysis.
abstract class AiRepository {
  /// Returns a concise 2-3 sentence summary.
  Future<String> summarizeArticle({
    required String title,
    required String content,
  });

  /// Suggests an improved, more engaging headline.
  Future<String> suggestHeadline({
    required String title,
    required String content,
  });

  /// Analyzes the sentiment (Positive / Negative / Neutral).
  Future<String> analyzeSentiment({
    required String title,
    required String content,
  });
}

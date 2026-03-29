import '../repository/ai_repository.dart';

class AnalyzeSentimentParams {
  final String title;
  final String content;

  const AnalyzeSentimentParams({required this.title, required this.content});
}

class AnalyzeSentimentUseCase {
  final AiRepository _repository;

  AnalyzeSentimentUseCase(this._repository);

  Future<String> call(AnalyzeSentimentParams params) {
    return _repository.analyzeSentiment(
      title: params.title,
      content: params.content,
    );
  }
}

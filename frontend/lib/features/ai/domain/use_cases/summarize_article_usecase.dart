import '../repository/ai_repository.dart';

class SummarizeArticleParams {
  final String title;
  final String content;

  const SummarizeArticleParams({required this.title, required this.content});
}

class SummarizeArticleUseCase {
  final AiRepository _repository;

  SummarizeArticleUseCase(this._repository);

  Future<String> call(SummarizeArticleParams params) {
    return _repository.summarizeArticle(
      title: params.title,
      content: params.content,
    );
  }
}

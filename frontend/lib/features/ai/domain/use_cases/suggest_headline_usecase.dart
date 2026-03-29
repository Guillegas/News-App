import '../repository/ai_repository.dart';

class SuggestHeadlineParams {
  final String title;
  final String content;

  const SuggestHeadlineParams({required this.title, required this.content});
}

class SuggestHeadlineUseCase {
  final AiRepository _repository;

  SuggestHeadlineUseCase(this._repository);

  Future<String> call(SuggestHeadlineParams params) {
    return _repository.suggestHeadline(
      title: params.title,
      content: params.content,
    );
  }
}

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/repository/article_publisher_repository.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/delete_article_params.dart';

class DeleteArticleUseCase implements UseCase<DataState<void>, DeleteArticleParams> {
  final ArticlePublisherRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<DataState<void>> call({DeleteArticleParams? params}) {
    return _repository.deleteArticle(params!.articleId, params.thumbnailStoragePath);
  }
}

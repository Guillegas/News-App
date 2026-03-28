import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/repository/article_publisher_repository.dart';

class GetPublishedArticlesUseCase
    implements UseCase<DataState<List<JournalistArticleEntity>>, void> {
  final ArticlePublisherRepository _repository;

  GetPublishedArticlesUseCase(this._repository);

  @override
  Future<DataState<List<JournalistArticleEntity>>> call({void params}) {
    return _repository.getPublishedArticles();
  }
}

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/repository/article_publisher_repository.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/publish_article_params.dart';

class PublishArticleUseCase
    implements UseCase<DataState<JournalistArticleEntity>, PublishArticleParams> {
  final ArticlePublisherRepository _repository;

  PublishArticleUseCase(this._repository);

  @override
  Future<DataState<JournalistArticleEntity>> call({PublishArticleParams? params}) {
    return _repository.publishArticle(params!);
  }
}

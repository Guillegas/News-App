import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/repository/article_publisher_repository.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/update_article_params.dart';

class UpdateArticleUseCase
    implements UseCase<DataState<JournalistArticleEntity>, UpdateArticleParams> {
  final ArticlePublisherRepository _repository;

  UpdateArticleUseCase(this._repository);

  @override
  Future<DataState<JournalistArticleEntity>> call({UpdateArticleParams? params}) {
    return _repository.updateArticle(
      params!.articleId,
      title: params.title,
      content: params.content,
    );
  }
}

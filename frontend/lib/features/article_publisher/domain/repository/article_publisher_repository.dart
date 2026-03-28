import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/publish_article_params.dart';

abstract class ArticlePublisherRepository {
  Future<DataState<JournalistArticleEntity>> publishArticle(PublishArticleParams params);

  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles();

  Future<DataState<void>> deleteArticle(String articleId, String thumbnailStoragePath);

  Future<DataState<JournalistArticleEntity>> updateArticle(
    String articleId, {
    required String title,
    required String content,
  });
}

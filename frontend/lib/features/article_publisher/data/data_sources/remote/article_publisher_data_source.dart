import 'package:news_app_clean_architecture/features/article_publisher/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/publish_article_params.dart';

abstract class ArticlePublisherDataSource {
  Future<JournalistArticleModel> publishArticle(PublishArticleParams params);

  Future<List<JournalistArticleModel>> getPublishedArticles();

  Future<void> deleteArticle(String articleId, String thumbnailStoragePath);

  Future<JournalistArticleModel> updateArticle(
    String articleId, {
    required String title,
    required String content,
  });
}

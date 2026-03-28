import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_publisher/data/data_sources/remote/article_publisher_data_source.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/repository/article_publisher_repository.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/publish_article_params.dart';

class ArticlePublisherRepositoryImpl implements ArticlePublisherRepository {
  final ArticlePublisherDataSource _dataSource;

  ArticlePublisherRepositoryImpl(this._dataSource);

  @override
  Future<DataState<JournalistArticleEntity>> publishArticle(
    PublishArticleParams params,
  ) async {
    try {
      final model = await _dataSource.publishArticle(params);
      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles() async {
    try {
      final models = await _dataSource.getPublishedArticles();
      return DataSuccess(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> deleteArticle(
      String articleId, String thumbnailStoragePath) async {
    try {
      await _dataSource.deleteArticle(articleId, thumbnailStoragePath);
      return DataSuccess(null);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<JournalistArticleEntity>> updateArticle(
    String articleId, {
    required String title,
    required String content,
  }) async {
    try {
      final model = await _dataSource.updateArticle(
        articleId,
        title: title,
        content: content,
      );
      return DataSuccess(model.toEntity());
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }
}

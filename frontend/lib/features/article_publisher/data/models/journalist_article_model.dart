import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';

class JournalistArticleModel extends JournalistArticleEntity {
  const JournalistArticleModel({
    required String id,
    required String title,
    required String content,
    required String author,
    required String thumbnailUrl,
    required String thumbnailStoragePath,
    required DateTime publishedAt,
  }) : super(
          id: id,
          title: title,
          content: content,
          author: author,
          thumbnailUrl: thumbnailUrl,
          thumbnailStoragePath: thumbnailStoragePath,
          publishedAt: publishedAt,
        );

  // Violation 1.3.3: fromRawData factory.
  factory JournalistArticleModel.fromRawData(Map<String, dynamic> map) {
    return JournalistArticleModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      author: map['author'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      thumbnailStoragePath: map['thumbnailStoragePath'] as String,
      publishedAt:
          DateTime.fromMillisecondsSinceEpoch(map['publishedAt'] as int),
    );
  }

  // Violation 1.3.2: toEntity conversion.
  JournalistArticleEntity toEntity() {
    return JournalistArticleEntity(
      id: id,
      title: title,
      content: content,
      author: author,
      thumbnailUrl: thumbnailUrl,
      thumbnailStoragePath: thumbnailStoragePath,
      publishedAt: publishedAt,
    );
  }
}

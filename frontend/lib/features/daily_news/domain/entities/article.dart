import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final int? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  /// Firestore document ID — only set for journalist-published articles.
  /// Not persisted in the local SQLite database.
  final String? firestoreId;

  /// Storage path for the thumbnail — only set for journalist-published articles.
  final String? thumbnailStoragePath;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.firestoreId,
    this.thumbnailStoragePath,
  });

  /// Whether this article was published by a journalist (own article).
  bool get isOwnArticle => firestoreId != null && firestoreId!.isNotEmpty;

  @override
  List<Object?> get props {
    return [
      id,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      firestoreId,
      thumbnailStoragePath,
    ];
  }
}

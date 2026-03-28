import 'package:equatable/equatable.dart';

class JournalistArticleEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String author;
  final String thumbnailUrl;
  final String thumbnailStoragePath;
  final DateTime publishedAt;

  const JournalistArticleEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.thumbnailUrl,
    required this.thumbnailStoragePath,
    required this.publishedAt,
  });

  @override
  List<Object> get props => [
        id,
        title,
        content,
        author,
        thumbnailUrl,
        thumbnailStoragePath,
        publishedAt,
      ];
}

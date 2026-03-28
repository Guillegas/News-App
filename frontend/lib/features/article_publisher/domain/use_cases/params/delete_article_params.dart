import 'package:equatable/equatable.dart';

class DeleteArticleParams extends Equatable {
  final String articleId;
  final String thumbnailStoragePath;

  const DeleteArticleParams({
    required this.articleId,
    required this.thumbnailStoragePath,
  });

  @override
  List<Object> get props => [articleId, thumbnailStoragePath];
}

import 'package:equatable/equatable.dart';

class UpdateArticleParams extends Equatable {
  final String articleId;
  final String title;
  final String content;

  const UpdateArticleParams({
    required this.articleId,
    required this.title,
    required this.content,
  });

  @override
  List<Object> get props => [articleId, title, content];
}

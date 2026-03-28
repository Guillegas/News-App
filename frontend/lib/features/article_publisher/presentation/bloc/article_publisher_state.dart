import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';

abstract class ArticlePublisherState extends Equatable {
  const ArticlePublisherState();

  @override
  List<Object?> get props => [];
}

class ArticlePublisherInitial extends ArticlePublisherState {
  const ArticlePublisherInitial();
}

class ArticlePublisherLoading extends ArticlePublisherState {
  const ArticlePublisherLoading();
}

class ArticlePublisherSuccess extends ArticlePublisherState {
  final JournalistArticleEntity article;

  const ArticlePublisherSuccess(this.article);

  @override
  List<Object> get props => [article];
}

class ArticlePublisherDeleted extends ArticlePublisherState {
  const ArticlePublisherDeleted();
}

class ArticlePublisherUpdated extends ArticlePublisherState {
  final JournalistArticleEntity article;

  const ArticlePublisherUpdated(this.article);

  @override
  List<Object> get props => [article];
}

class ArticlePublisherError extends ArticlePublisherState {
  final Exception error;

  const ArticlePublisherError(this.error);

  @override
  List<Object> get props => [error];
}

import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/publish_article_params.dart';

abstract class ArticlePublisherEvent extends Equatable {
  const ArticlePublisherEvent();

  @override
  List<Object> get props => [];
}

class PublishArticleEvent extends ArticlePublisherEvent {
  final PublishArticleParams params;

  const PublishArticleEvent(this.params);

  @override
  List<Object> get props => [params];
}

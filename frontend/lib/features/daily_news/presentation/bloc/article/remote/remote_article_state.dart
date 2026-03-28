import 'package:equatable/equatable.dart';
import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final Exception? error;

  const RemoteArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  /// Unique timestamp so Equatable always considers a refresh as a new state.
  final int _timestamp;

  RemoteArticlesDone(List<ArticleEntity> article)
      : _timestamp = DateTime.now().millisecondsSinceEpoch,
        super(articles: article);

  @override
  List<Object?> get props => [articles, _timestamp];
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(Exception error) : super(error: error);
}

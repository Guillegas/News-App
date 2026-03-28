import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/entities/journalist_article_entity.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/get_published_articles_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;
  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;

  RemoteArticlesBloc(this._getArticleUseCase, this._getPublishedArticlesUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    final dataState = await _getArticleUseCase();

    // Fetch published articles from Firestore in parallel.
    final publishedState = await _getPublishedArticlesUseCase();

    final List<ArticleEntity> allArticles = [];

    // Add NewsAPI articles first.
    if (dataState is DataSuccess && dataState.data != null) {
      allArticles.addAll(dataState.data!);
    }

    // Convert and prepend published (journalist) articles so they
    // appear at the top of the feed.
    if (publishedState is DataSuccess && publishedState.data != null) {
      allArticles.insertAll(
        0,
        publishedState.data!.map(_mapToArticleEntity),
      );
    }

    if (allArticles.isNotEmpty) {
      emit(RemoteArticlesDone(allArticles));
    } else if (dataState is DataFailed) {
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  /// Maps a Firestore-published article into the common [ArticleEntity]
  /// so both sources share the same list widget.
  ArticleEntity _mapToArticleEntity(JournalistArticleEntity e) {
    return ArticleEntity(
      author: e.author,
      title: e.title,
      description: e.content.length > 120
          ? '${e.content.substring(0, 120)}...'
          : e.content,
      url: '',
      urlToImage: e.thumbnailUrl,
      publishedAt: e.publishedAt.toIso8601String(),
      content: e.content,
    );
  }
}

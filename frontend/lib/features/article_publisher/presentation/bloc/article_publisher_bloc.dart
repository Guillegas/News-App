import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/publish_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_event.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_state.dart';

class ArticlePublisherBloc
    extends Bloc<ArticlePublisherEvent, ArticlePublisherState> {
  final PublishArticleUseCase _publishArticleUseCase;

  ArticlePublisherBloc(this._publishArticleUseCase)
      : super(const ArticlePublisherInitial()) {
    on<PublishArticleEvent>(_onPublishArticle);
  }

  Future<void> _onPublishArticle(
    PublishArticleEvent event,
    Emitter<ArticlePublisherState> emit,
  ) async {
    emit(const ArticlePublisherLoading());
    final dataState = await _publishArticleUseCase(params: event.params);

    if (dataState is DataSuccess) {
      emit(ArticlePublisherSuccess(dataState.data!));
    }

    if (dataState is DataFailed) {
      emit(ArticlePublisherError(dataState.error!));
    }
  }
}

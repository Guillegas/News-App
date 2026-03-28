import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/delete_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/publish_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/update_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_event.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_state.dart';

class ArticlePublisherBloc
    extends Bloc<ArticlePublisherEvent, ArticlePublisherState> {
  final PublishArticleUseCase _publishArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;

  ArticlePublisherBloc(
    this._publishArticleUseCase,
    this._deleteArticleUseCase,
    this._updateArticleUseCase,
  ) : super(const ArticlePublisherInitial()) {
    on<PublishArticleEvent>(_onPublishArticle);
    on<DeleteArticleEvent>(_onDeleteArticle);
    on<UpdateArticleEvent>(_onUpdateArticle);
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

  Future<void> _onDeleteArticle(
    DeleteArticleEvent event,
    Emitter<ArticlePublisherState> emit,
  ) async {
    emit(const ArticlePublisherLoading());
    final dataState = await _deleteArticleUseCase(params: event.params);

    if (dataState is DataSuccess) {
      emit(const ArticlePublisherDeleted());
    }
    if (dataState is DataFailed) {
      emit(ArticlePublisherError(dataState.error!));
    }
  }

  Future<void> _onUpdateArticle(
    UpdateArticleEvent event,
    Emitter<ArticlePublisherState> emit,
  ) async {
    emit(const ArticlePublisherLoading());
    final dataState = await _updateArticleUseCase(params: event.params);

    if (dataState is DataSuccess) {
      emit(ArticlePublisherUpdated(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(ArticlePublisherError(dataState.error!));
    }
  }
}

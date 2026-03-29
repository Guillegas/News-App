import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/article_publisher/data/data_sources/remote/article_publisher_data_source.dart';
import 'package:news_app_clean_architecture/features/article_publisher/data/data_sources/remote/article_publisher_data_source_impl.dart';
import 'package:news_app_clean_architecture/features/article_publisher/data/repository/article_publisher_repository_impl.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/repository/article_publisher_repository.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/delete_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/get_published_articles_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/publish_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/update_article_usecase.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/auth/data/data_sources/firebase_auth_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/use_cases/sign_in_usecase.dart';
import 'features/auth/domain/use_cases/sign_out_usecase.dart';
import 'features/auth/domain/use_cases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

import 'config/api_keys.dart';
import 'features/ai/data/ai_service.dart';
import 'features/ai/domain/repository/ai_repository.dart';
import 'features/ai/domain/use_cases/summarize_article_usecase.dart';
import 'features/ai/domain/use_cases/suggest_headline_usecase.dart';
import 'features/ai/domain/use_cases/analyze_sentiment_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // --- Local Database ---
  // On native platforms, Floor uses sqflite with a persistent file.
  // On web, Floor/sqflite is not fully supported so we catch any errors
  // and build an in-memory database as a best-effort fallback.
  AppDatabase database;
  if (kIsWeb) {
    try {
      database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    } catch (_) {
      // sqflite web factories may fail; the saved-articles feature
      // degrades gracefully while the rest of the app keeps working.
      database = _NoOpAppDatabase();
    }
  } else {
    database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }
  sl.registerSingleton<AppDatabase>(database);

  // --- Dio (REST) ---
  final dio = Dio();
  // On web, NewsAPI blocks browser requests (CORS).  We route every
  // outgoing request through a lightweight proxy so the app works.
  if (kIsWeb) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final original = options.uri.toString();
          options.path = 'https://corsproxy.io/?${Uri.encodeComponent(original)}';
          options.baseUrl = '';
          options.queryParameters = {};
          handler.next(options);
        },
      ),
    );
  }
  sl.registerSingleton<Dio>(dio);

  // --- Firebase ---
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // --- Auth ---
  sl.registerSingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSource(sl()),
  );
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl()),
  );
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl(), sl(), sl(), sl()),
  );

  // --- AI Service ---
  // The key lives in lib/config/api_keys.dart which is gitignored.
  sl.registerSingleton<AiRepository>(AiService(apiKey: openAiApiKey));
  sl.registerSingleton<SummarizeArticleUseCase>(SummarizeArticleUseCase(sl()));
  sl.registerSingleton<SuggestHeadlineUseCase>(SuggestHeadlineUseCase(sl()));
  sl.registerSingleton<AnalyzeSentimentUseCase>(AnalyzeSentimentUseCase(sl()));

  // --- Data Sources ---
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<ArticlePublisherDataSource>(
    ArticlePublisherDataSourceImpl(sl(), sl()),
  );

  // --- Repositories ---
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl()),
  );
  sl.registerSingleton<ArticlePublisherRepository>(
    ArticlePublisherRepositoryImpl(sl()),
  );

  // --- Use Cases (daily_news) ---
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  // --- Use Cases (article_publisher) ---
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl()));
  sl.registerSingleton<GetPublishedArticlesUseCase>(
      GetPublishedArticlesUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()));

  // --- Blocs ---
  sl.registerFactory<RemoteArticlesBloc>(
      () => RemoteArticlesBloc(sl(), sl()));
  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));
  sl.registerFactory<ArticlePublisherBloc>(
      () => ArticlePublisherBloc(sl(), sl(), sl()));
}

/// Minimal no-op fallback so the app can start on web even when sqflite
/// is unavailable.  The saved-articles feature simply returns empty lists.
class _NoOpArticleDao extends ArticleDao {
  @override
  Future<List<ArticleModel>> getArticles() async => [];
  @override
  Future<void> insertArticle(ArticleModel article) async {}
  @override
  Future<void> deleteArticle(ArticleModel articleModel) async {}
}

class _NoOpAppDatabase extends AppDatabase {
  @override
  ArticleDao get articleDAO => _NoOpArticleDao();
}

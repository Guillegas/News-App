import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      centerTitle: false,
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/CreateArticle'),
      backgroundColor: kSymmetryPurple,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: const Center(child: CupertinoActivityIndicator()),
            floatingActionButton: _buildFab(context),
          );
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: Color(0xFF8B8B8B)),
                  SizedBox(height: 12),
                  Text(
                    'Could not load articles',
                    style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 16),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFab(context),
          );
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: articles.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 14, endIndent: 14),
        itemBuilder: (context, index) {
          return ArticleWidget(
            article: articles[index],
            onArticlePressed: (article) => _onArticlePressed(context, article),
          );
        },
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}

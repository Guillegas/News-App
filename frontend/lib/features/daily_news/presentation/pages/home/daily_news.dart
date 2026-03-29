import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: Text(
        'Daily News',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      centerTitle: false,
      actions: [
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            final isDark = mode == ThemeMode.dark;
            return GestureDetector(
              onTap: () => context.read<ThemeCubit>().toggleTheme(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.bookmark,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _onLogoutPressed(context),
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              Icons.logout,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8B8B8B)),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close, color: Color(0xFF8B8B8B)),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.pushNamed(context, '/CreateArticle');
        // Refresh articles after returning from create screen
        if (context.mounted) {
          context.read<RemoteArticlesBloc>().add(const GetArticles());
        }
      },
      backgroundColor: kSymmetryPurple,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    final filtered = _searchQuery.isEmpty
        ? articles
        : articles.where((a) {
            final title = (a.title ?? '').toLowerCase();
            final desc = (a.description ?? '').toLowerCase();
            final author = (a.author ?? '').toLowerCase();
            return title.contains(_searchQuery) ||
                desc.contains(_searchQuery) ||
                author.contains(_searchQuery);
          }).toList();

    return Scaffold(
      appBar: _buildAppbar(context),
      body: RefreshIndicator(
        color: kSymmetryPurple,
        onRefresh: () async {
          context.read<RemoteArticlesBloc>().add(const GetArticles());
          // Small delay so the indicator shows briefly, then the
          // BlocBuilder will rebuild with the new data automatically.
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: filtered.isEmpty
                  ? ListView(
                      // ListView needed for RefreshIndicator to work
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text(
                            'No articles found',
                            style: TextStyle(
                                color: Color(0xFF8B8B8B), fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 14, endIndent: 14),
                      itemBuilder: (context, index) {
                        return ArticleWidget(
                          article: filtered[index],
                          onArticlePressed: (article) =>
                              _onArticlePressed(context, article),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) async {
    await Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
    // Refresh feed when returning (article may have been edited/deleted)
    if (context.mounted) {
      context.read<RemoteArticlesBloc>().add(const GetArticles());
    }
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  void _onLogoutPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

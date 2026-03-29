import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/ai/presentation/ai_bottom_sheet.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_bloc.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_event.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_state.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/screens/edit_article_screen.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  /// Published (journalist) articles have a firestoreId set.
  bool get _isOwnArticle => article != null && article!.isOwnArticle;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LocalArticleBloc>()),
        BlocProvider(create: (_) => sl<ArticlePublisherBloc>()),
      ],
      child: BlocListener<ArticlePublisherBloc, ArticlePublisherState>(
        listener: (context, state) {
          if (state is ArticlePublisherDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Article deleted'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is ArticlePublisherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevron_back, color: null),
        ),
      ),
      actions: [
        if (_isOwnArticle)
          Builder(
            builder: (context) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: null),
              onSelected: (value) {
                if (value == 'edit') _onEditPressed(context);
                if (value == 'delete') _onDeletePressed(context);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        // AI assistant button
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.auto_awesome, color: kSymmetryPurple),
            onPressed: () => _onAiPressed(context),
          ),
        ),
        // Share button for all articles
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.share, color: null),
            onPressed: () => _onSharePressed(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleDescription(),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article!.title!,
            style: const TextStyle(
                fontFamily: 'Butler',
                fontSize: 20,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                _formatDate(article!.publishedAt!),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          if (article!.author != null && article!.author!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Ionicons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text(
                  article!.author!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8B8B8B)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: Image.network(
        article!.urlToImage ?? '',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildArticleDescription() {
    final desc = article!.description ?? '';
    final content = article!.content ?? '';

    // Avoid showing duplicated text when description is a truncated
    // version of content (happens with own published articles).
    final bool descIsRedundant = desc.isNotEmpty &&
        content.isNotEmpty &&
        (content.startsWith(desc.replaceAll('...', '')) ||
            desc == content);

    final text = descIsRedundant ? content : '$desc\n\n$content';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        text.trim(),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _onFloatingActionButtonPressed(context),
        child: const Icon(Ionicons.bookmark, color: Colors.white),
      ),
    );
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Article saved successfully.'),
      ),
    );
  }

  void _onAiPressed(BuildContext context) {
    AiBottomSheet.show(
      context,
      title: article!.title ?? '',
      content: '${article!.description ?? ''}\n\n${article!.content ?? ''}',
    );
  }

  void _onSharePressed(BuildContext context) {
    final title = article!.title ?? 'Check out this article';
    final content = article!.description ?? '';
    final url = article!.url ?? '';

    final shareText = url.isNotEmpty
        ? '$title\n\n$content\n\nRead more: $url'
        : '$title\n\n$content';

    Share.share(shareText);
  }

  void _onEditPressed(BuildContext context) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ArticlePublisherBloc>(),
          child: EditArticleScreen(
            articleId: article!.firestoreId!,
            initialTitle: article!.title ?? '',
            initialContent: article!.content ?? '',
          ),
        ),
      ),
    );

    // If the article was updated, go back to the home so the feed refreshes.
    if (updated == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  void _onDeletePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text('Are you sure you want to delete this article? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ArticlePublisherBloc>().add(
                    DeleteArticleEvent(
                      DeleteArticleParams(
                        articleId: article!.firestoreId!,
                        thumbnailStoragePath:
                            article!.thumbnailStoragePath ?? '',
                      ),
                    ),
                  );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

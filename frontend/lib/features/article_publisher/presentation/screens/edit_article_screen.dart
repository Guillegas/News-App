import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_bloc.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_event.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_state.dart';

class EditArticleScreen extends StatefulWidget {
  final String articleId;
  final String initialTitle;
  final String initialContent;

  const EditArticleScreen({
    Key? key,
    required this.articleId,
    required this.initialTitle,
    required this.initialContent,
  }) : super(key: key);

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _textColor => _isDark ? Colors.white : Colors.black;
  Color get _hintColor => _isDark ? Colors.white38 : const Color(0xFFBDBDBD);
  Color get _borderColor => _isDark ? Colors.white24 : const Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticlePublisherBloc, ArticlePublisherState>(
      listener: _onStateChange,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.chevron_left, color: _textColor, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Edit Article',
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                _buildTitleInput(),
                const SizedBox(height: 16),
                _buildContentInput(),
              ],
            ),
          ),
          bottomNavigationBar: _buildUpdateButton(state),
        );
      },
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _titleController,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: _textColor),
        maxLines: 3,
        minLines: 2,
        decoration: InputDecoration(
          hintText: 'Write your title here...',
          hintStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w400, color: _hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _contentController,
        style: TextStyle(fontSize: 16, color: _textColor, height: 1.5),
        maxLines: null,
        minLines: 12,
        decoration: InputDecoration(
          hintText: 'Add article here, .....',
          hintStyle: TextStyle(fontSize: 16, color: _hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(ArticlePublisherState state) {
    final isLoading = state is ArticlePublisherLoading;
    return Container(
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onUpdateTapped,
          style: ElevatedButton.styleFrom(
            backgroundColor: kSymmetryPurple.withOpacity(_isDark ? 0.5 : 0.25),
            disabledBackgroundColor:
                kSymmetryPurple.withOpacity(_isDark ? 0.3 : 0.15),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
          child: isLoading
              ? CupertinoActivityIndicator(
                  color: _isDark ? Colors.white : Colors.black)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, color: _textColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Update Article',
                      style: TextStyle(
                          color: _textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _onUpdateTapped() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showError('Please enter a title');
      return;
    }
    if (content.isEmpty) {
      _showError('Please write your article content');
      return;
    }

    context.read<ArticlePublisherBloc>().add(
          UpdateArticleEvent(
            UpdateArticleParams(
              articleId: widget.articleId,
              title: title,
              content: content,
            ),
          ),
        );
  }

  void _onStateChange(BuildContext context, ArticlePublisherState state) {
    if (state is ArticlePublisherUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
    if (state is ArticlePublisherError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }
}

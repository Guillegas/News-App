import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_bloc.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_event.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/bloc/article_publisher_state.dart';
import 'package:news_app_clean_architecture/features/article_publisher/presentation/widgets/thumbnail_picker_widget.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({Key? key}) : super(key: key);

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Uint8List? _thumbnailBytes;
  String? _thumbnailFileName;

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
  Color get _inputTextColor => _isDark ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticlePublisherBloc, ArticlePublisherState>(
      listener: _onStateChange,
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildPublishButton(state),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: _textColor, size: 30),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleInput(),
                const SizedBox(height: 16),
                _buildAttachImageSection(),
                const SizedBox(height: 16),
                _buildContentInput(),
              ],
            ),
          ),
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
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: _inputTextColor,
        ),
        maxLines: 3,
        minLines: 2,
        decoration: InputDecoration(
          hintText: 'Write your title here...',
          hintStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: _hintColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildAttachImageSection() {
    if (_thumbnailBytes != null) {
      return _buildImagePreview();
    }
    return _buildAttachImageButton();
  }

  Widget _buildAttachImageButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickThumbnail,
        icon: Icon(Icons.camera_alt_outlined,
            color: _isDark ? Colors.white : Colors.black87),
        label: Text(
          'Attach Image',
          style: TextStyle(
            color: _isDark ? Colors.white : Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kSymmetryPurple.withOpacity(_isDark ? 0.35 : 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _pickThumbnail,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.memory(
              _thumbnailBytes!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: _pickThumbnail,
                ),
              ),
            ),
          ],
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
        style: TextStyle(
          fontSize: 16,
          color: _inputTextColor,
          height: 1.5,
        ),
        maxLines: null,
        minLines: 12,
        decoration: InputDecoration(
          hintText: 'Add article here, .....',
          hintStyle: TextStyle(
            fontSize: 16,
            color: _hintColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPublishButton(ArticlePublisherState state) {
    final isLoading = state is ArticlePublisherLoading;

    return Container(
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onPublishTapped,
          style: ElevatedButton.styleFrom(
            backgroundColor: kSymmetryPurple.withOpacity(_isDark ? 0.5 : 0.25),
            disabledBackgroundColor:
                kSymmetryPurple.withOpacity(_isDark ? 0.3 : 0.15),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            elevation: 0,
          ),
          child: isLoading
              ? CupertinoActivityIndicator(
                  color: _isDark ? Colors.white : Colors.black)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward, color: _textColor, size: 24),
                    Text(
                      ')',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Publish Article',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, ArticlePublisherState state) {
    if (state is ArticlePublisherSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }

    if (state is ArticlePublisherError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickThumbnail() async {
    final result = await ThumbnailPickerHelper.pickFromGallery();
    if (result != null) {
      setState(() {
        _thumbnailBytes = result.bytes;
        _thumbnailFileName = result.fileName;
      });
    }
  }

  void _onPublishTapped() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showValidationError('Please enter a title');
      return;
    }

    if (_thumbnailBytes == null) {
      _showValidationError('Please attach a thumbnail image');
      return;
    }

    if (content.isEmpty) {
      _showValidationError('Please write your article content');
      return;
    }

    context.read<ArticlePublisherBloc>().add(
          PublishArticleEvent(
            PublishArticleParams(
              title: title,
              content: content,
              author: 'Journalist',
              thumbnailBytes: _thumbnailBytes!,
              thumbnailFileName: _thumbnailFileName!,
            ),
          ),
        );
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

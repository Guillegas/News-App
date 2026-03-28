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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticlePublisherBloc, ArticlePublisherState>(
      listener: _onStateChange,
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(state),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Create Article',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildBody(ArticlePublisherState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title Input ---
          _buildTitleInput(),
          const SizedBox(height: 24),

          // --- Attach Image Button / Image Preview ---
          _buildAttachImageSection(),
          const SizedBox(height: 24),

          // --- Content Input ---
          _buildContentInput(),
          const SizedBox(height: 40),

          // --- Publish Button ---
          _buildPublishButton(state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      maxLines: 2,
      decoration: const InputDecoration(
        hintText: 'Write your title here...',
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFFBDBDBD),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _pickThumbnail,
        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
        label: const Text(
          'Attach Image',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kSymmetryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
      constraints: const BoxConstraints(minHeight: 200),
      child: TextField(
        controller: _contentController,
        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
        maxLines: null,
        minLines: 8,
        decoration: const InputDecoration(
          hintText: 'Add article here, .....',
          hintStyle: TextStyle(
            fontSize: 16,
            color: Color(0xFFBDBDBD),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPublishButton(ArticlePublisherState state) {
    final isLoading = state is ArticlePublisherLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onPublishTapped,
        style: ElevatedButton.styleFrom(
          backgroundColor: kSymmetryPurple,
          disabledBackgroundColor: kSymmetryPurple.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Publish Article',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_thumbnailBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach a thumbnail image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your article content'),
          backgroundColor: Colors.orange,
        ),
      );
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
}

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();
  Uint8List? _thumbnailBytes;
  String? _thumbnailFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _authorController.dispose();
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
      title: const Text('New Article'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody(ArticlePublisherState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThumbnailPickerWidget(
              selectedImageBytes: _thumbnailBytes,
              onTap: _pickThumbnail,
            ),
            if (_thumbnailBytes == null)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Thumbnail is required',
                  style: TextStyle(color: Colors.transparent, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter article title',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _subtitleController,
              label: 'Subtitle',
              hint: 'Enter article subtitle',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _authorController,
              label: 'Author',
              hint: 'Enter your name',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _contentController,
              label: 'Content',
              hint: 'Write your article here...',
              maxLines: 10,
            ),
            const SizedBox(height: 32),
            _buildPublishButton(state),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
        labelStyle: const TextStyle(color: Color(0xFF8B8B8B)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildPublishButton(ArticlePublisherState state) {
    final isLoading = state is ArticlePublisherLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onPublishTapped,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFF8B8B8B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const Text(
                'Publish Article',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
    final isThumbnailMissing = _thumbnailBytes == null;
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (isThumbnailMissing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a thumbnail image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!isFormValid) return;

    context.read<ArticlePublisherBloc>().add(
          PublishArticleEvent(
            PublishArticleParams(
              title: _titleController.text.trim(),
              subtitle: _subtitleController.text.trim(),
              content: _contentController.text.trim(),
              author: _authorController.text.trim(),
              thumbnailBytes: _thumbnailBytes!,
              thumbnailFileName: _thumbnailFileName!,
            ),
          ),
        );
  }
}

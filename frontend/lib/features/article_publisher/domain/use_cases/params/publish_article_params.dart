import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class PublishArticleParams extends Equatable {
  final String title;
  final String content;
  final String author;
  final Uint8List thumbnailBytes;
  final String thumbnailFileName;

  const PublishArticleParams({
    required this.title,
    required this.content,
    required this.author,
    required this.thumbnailBytes,
    required this.thumbnailFileName,
  });

  @override
  List<Object> get props =>
      [title, content, author, thumbnailBytes, thumbnailFileName];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/article_publisher/data/data_sources/remote/article_publisher_data_source.dart';
import 'package:news_app_clean_architecture/features/article_publisher/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/article_publisher/domain/use_cases/params/publish_article_params.dart';

class ArticlePublisherDataSourceImpl implements ArticlePublisherDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ArticlePublisherDataSourceImpl(this._firestore, this._storage);

  static const String _articlesCollection = 'articles';
  static const String _thumbnailsFolder = 'media/articles';

  @override
  Future<JournalistArticleModel> publishArticle(
      PublishArticleParams params) async {
    final docRef = _firestore.collection(_articlesCollection).doc();
    final articleId = docRef.id;

    final storageRef =
        _storage.ref('$_thumbnailsFolder/$articleId/${params.thumbnailFileName}');

    await storageRef.putData(
      params.thumbnailBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final thumbnailUrl = await storageRef.getDownloadURL();

    await docRef.set({
      'id': articleId,
      'title': params.title,
      'content': params.content,
      'author': params.author,
      'thumbnailUrl': thumbnailUrl,
      'thumbnailStoragePath': storageRef.fullPath,
      'publishedAt': FieldValue.serverTimestamp(),
    });

    final snapshot = await docRef.get();
    return _mapSnapshotToModel(snapshot);
  }

  @override
  Future<List<JournalistArticleModel>> getPublishedArticles() async {
    final querySnapshot = await _firestore
        .collection(_articlesCollection)
        .orderBy('publishedAt', descending: true)
        .get();

    return querySnapshot.docs.map(_mapSnapshotToModel).toList();
  }

  @override
  Future<void> deleteArticle(
      String articleId, String thumbnailStoragePath) async {
    // Delete image from Storage
    try {
      await _storage.ref(thumbnailStoragePath).delete();
    } catch (_) {
      // Image might already be gone — continue with doc deletion
    }

    // Delete document from Firestore
    await _firestore.collection(_articlesCollection).doc(articleId).delete();
  }

  @override
  Future<JournalistArticleModel> updateArticle(
    String articleId, {
    required String title,
    required String content,
  }) async {
    final docRef = _firestore.collection(_articlesCollection).doc(articleId);

    await docRef.update({
      'title': title,
      'content': content,
    });

    final snapshot = await docRef.get();
    return _mapSnapshotToModel(snapshot);
  }

  JournalistArticleModel _mapSnapshotToModel(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return JournalistArticleModel.fromRawData({
      ...data,
      'publishedAt': (data['publishedAt'] as Timestamp).millisecondsSinceEpoch,
    });
  }
}

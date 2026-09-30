import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/products/domain/product_review.dart';

class ProductReviewRepository {
  const ProductReviewRepository();

  Future<ProductReviewSummary> load(String productId) async {
    final id = int.tryParse(productId);
    if (id == null || !AgrisellSupabase.isInitialized) {
      return const ProductReviewSummary.empty();
    }
    try {
      final response = await AgrisellSupabase.client.rpc<Object?>(
        'marketplace_product_reviews',
        params: {'target_commodity_id': id},
      );
      return parse(response);
    } on PostgrestException catch (error) {
      throw ProductReviewException(error.message);
    }
  }

  static ProductReviewSummary parse(Object? value) {
    if (value is! Map) return const ProductReviewSummary.empty();
    final json = Map<String, Object?>.from(value);
    final rows = json['reviews'];
    final reviews = rows is List
        ? rows.whereType<Map>().map(_reviewFrom).toList(growable: false)
        : const <ProductReview>[];
    return ProductReviewSummary(
      averageRating: _number(json['averageRating']),
      reviewCount: _integer(json['reviewCount']),
      reviews: reviews,
    );
  }

  static ProductReview _reviewFrom(Map<Object?, Object?> row) {
    final json = Map<String, Object?>.from(row);
    final adminResponseText = _text(json['adminResponse']);
    final moderationNoteText = _text(json['moderationNote']);
    final moderationStatusText = _text(json['moderationStatus']);
    return ProductReview(
      reviewerName: _text(json['reviewerName'], fallback: 'Verified buyer'),
      rating: _number(json['rating']),
      comment: _text(json['comment']),
      submittedAt: DateTime.tryParse(_text(json['submittedAt'])),
      adminResponse: adminResponseText.isEmpty ? null : adminResponseText,
      adminRespondedAt: DateTime.tryParse(_text(json['adminRespondedAt'])),
      moderationNote: moderationNoteText.isEmpty ? null : moderationNoteText,
      moderationStatus:
          moderationStatusText.isEmpty ? null : moderationStatusText,
    );
  }

  static String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static double _number(Object? value) => switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text) ?? 0,
    _ => 0,
  };

  static int _integer(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text) ?? 0,
    _ => 0,
  };
}

class ProductReviewException implements Exception {
  const ProductReviewException(this.message);

  final String message;
}

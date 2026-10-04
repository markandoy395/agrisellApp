part of 'supabase_rider_data_source.dart';

mixin _SupabaseRiderDocumentDataSourceMixin implements RiderRemoteDataSource {
  SupabaseClient get _client;

  @override
  Future<String> uploadObject({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    await QueryOwner(_client).requireStoragePath(path);
    return _client.storage
        .from(SupabaseRiderDataSource.bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            contentType: contentType,
            upsert: false,
          ),
        );
  }

  @override
  Future<void> deleteObject(String path) async {
    await QueryOwner(_client).requireStoragePath(path);
    await _client.storage.from(SupabaseRiderDataSource.bucket).remove([path]);
  }

  @override
  Future<String> createSignedUrl(String path) => Future.value(
    authenticatedStorageUrl(
      _client.storage.from(SupabaseRiderDataSource.bucket).getPublicUrl(path),
    ),
  );

  @override
  Future<RiderDocument> createDocument(RiderDocument document) async {
    await QueryOwner(_client).requireRiderId(document.riderId);
    final values = document.toJson()
      ..remove('document_id')
      ..remove('verification_status')
      ..remove('rejection_reason');
    final row = await _client
        .from('rider_documents')
        .insert(values)
        .select()
        .single();
    return RiderDocument.fromJson(_map(row));
  }

  @override
  Future<List<RiderDocument>> getDocuments(String riderId) async {
    await QueryOwner(_client).requireRiderId(riderId);
    final rows = await _client
        .from('rider_documents')
        .select()
        .eq('rider_id', riderId)
        .order('created_at');
    return rows
        .map((row) => RiderDocument.fromJson(_map(row)))
        .toList(growable: false);
  }

  @override
  Future<RiderDocument> updateDocument(
    String documentId,
    Map<String, Object?> values,
  ) async {
    final row = await _client
        .from('rider_documents')
        .update(values)
        .eq('document_id', documentId)
        .eq('rider_id', await QueryOwner(_client).riderId())
        .select()
        .single();
    return RiderDocument.fromJson(_map(row));
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await _client
        .from('rider_documents')
        .delete()
        .eq('document_id', documentId)
        .eq('rider_id', await QueryOwner(_client).riderId());
  }
}

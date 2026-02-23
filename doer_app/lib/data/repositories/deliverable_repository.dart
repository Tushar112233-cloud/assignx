import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/deliverable_model.dart';

/// Repository for deliverable operations.
///
/// Handles uploading work files, managing deliverables,
/// and submitting work for QC review.
class DeliverableRepository {
  DeliverableRepository(this._client);

  final SupabaseClient _client;

  /// Gets the current user's ID.
  String? get _userId => _client.auth.currentUser?.id;

  /// Fetches deliverables for a project.
  ///
  /// Returns deliverables in reverse chronological order (newest first).
  Future<List<DeliverableModel>> getDeliverables(String projectId) async {
    try {
      final response = await _client.from('project_deliverables').select('''
        *,
        uploader:profiles!uploaded_by(id, full_name, avatar_url)
      ''').eq('project_id', projectId).order('version', ascending: false);

      return (response as List)
          .map((json) => DeliverableModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.getDeliverables error: $e');
      }
      rethrow;
    }
  }

  /// Gets the latest deliverable for a project.
  Future<DeliverableModel?> getLatestDeliverable(String projectId) async {
    try {
      final response = await _client
          .from('project_deliverables')
          .select('''
            *,
            uploader:profiles!uploaded_by(id, full_name, avatar_url)
          ''')
          .eq('project_id', projectId)
          .order('version', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DeliverableModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.getLatestDeliverable error: $e');
      }
      rethrow;
    }
  }

  /// Gets the next version number for a deliverable.
  Future<int> getNextVersion(String projectId) async {
    try {
      final response = await _client
          .from('project_deliverables')
          .select('version')
          .eq('project_id', projectId)
          .order('version', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 1;
      return (response['version'] as int) + 1;
    } catch (e) {
      return 1;
    }
  }

  /// Uploads a file to Supabase Storage.
  ///
  /// Returns the public URL of the uploaded file.
  Future<String?> uploadFile({
    required String projectId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      // Create storage path: deliverables/{project_id}/{timestamp}_{filename}
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'deliverables/$projectId/${timestamp}_$fileName';

      await _client.storage
          .from('project-files')
          .uploadBinary(storagePath, bytes);

      // Get public URL
      final url = _client.storage
          .from('project-files')
          .getPublicUrl(storagePath);

      return url;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.uploadFile error: $e');
      }
      rethrow;
    }
  }

  /// Creates a new deliverable record.
  ///
  /// Call this after uploading the file.
  Future<DeliverableModel?> createDeliverable({
    required String projectId,
    required String fileUrl,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
    bool isFinal = false,
  }) async {
    try {
      final version = await getNextVersion(projectId);

      final response = await _client.from('project_deliverables').insert({
        'project_id': projectId,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_type': fileType,
        'file_size_bytes': fileSizeBytes,
        'version': version,
        'is_final': isFinal,
        'qc_status': 'pending',
        'uploaded_by': _userId,
      }).select('''
        *,
        uploader:profiles!uploaded_by(id, full_name, avatar_url)
      ''').single();

      return DeliverableModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.createDeliverable error: $e');
      }
      rethrow;
    }
  }

  /// Submits a deliverable for QC review.
  ///
  /// Uploads the file, creates the deliverable record, and updates project status.
  Future<DeliverableModel?> submitDeliverable({
    required String projectId,
    required String filePath,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
    bool isFinal = true,
    String? notes,
  }) async {
    try {
      // 1. Upload file
      final fileUrl = await uploadFile(
        projectId: projectId,
        filePath: filePath,
        fileName: fileName,
      );

      if (fileUrl == null) throw Exception('Failed to upload file');

      // 2. Create deliverable record
      final deliverable = await createDeliverable(
        projectId: projectId,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
        isFinal: isFinal,
      );

      // 3. Update project status to 'delivered'
      await _client.from('projects').update({
        'status': 'delivered',
        'delivered_at': DateTime.now().toIso8601String(),
        'progress_percentage': 100,
        'completion_notes': notes,
        'status_updated_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

      return deliverable;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.submitDeliverable error: $e');
      }
      rethrow;
    }
  }

  /// Updates a deliverable (for revisions).
  Future<DeliverableModel?> updateDeliverable({
    required String deliverableId,
    required String projectId,
    required String filePath,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  }) async {
    try {
      // Upload new file
      final fileUrl = await uploadFile(
        projectId: projectId,
        filePath: filePath,
        fileName: fileName,
      );

      if (fileUrl == null) throw Exception('Failed to upload file');

      // Create new version (don't update old one)
      return await createDeliverable(
        projectId: projectId,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
        isFinal: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.updateDeliverable error: $e');
        return null;
      }
      rethrow;
    }
  }

  /// Gets revision requests for a project.
  Future<List<RevisionRequest>> getRevisionRequests(String projectId) async {
    try {
      final response = await _client
          .from('project_revisions')
          .select('''
            *,
            requester:profiles!requested_by(id, full_name)
          ''')
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RevisionRequest.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.getRevisionRequests error: $e');
        return [];
      }
      rethrow;
    }
  }
}

/// Provider for the deliverable repository.
final deliverableRepositoryProvider = Provider<DeliverableRepository>((ref) {
  return DeliverableRepository(SupabaseConfig.client);
});

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/deliverable_model.dart';

/// Repository for deliverable operations.
///
/// Handles uploading work files, managing deliverables,
/// and submitting work for QC review.
class DeliverableRepository {
  DeliverableRepository();

  /// Fetches deliverables for a project.
  Future<List<DeliverableModel>> getDeliverables(String projectId) async {
    try {
      final response = await ApiClient.get('/projects/$projectId/deliverables');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['deliverables'] as List? ?? [];

      return list
          .map((json) => DeliverableModel.fromJson(json as Map<String, dynamic>))
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
      final response = await ApiClient.get('/projects/$projectId/deliverables/latest');
      if (response == null) return null;
      return DeliverableModel.fromJson(response as Map<String, dynamic>);
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
      final response = await ApiClient.get('/projects/$projectId/deliverables/next-version');
      if (response is Map<String, dynamic>) {
        return response['version'] as int? ?? 1;
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  /// Uploads a file to the API storage.
  ///
  /// Returns the public URL of the uploaded file.
  Future<String?> uploadFile({
    required String projectId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final file = File(filePath);
      final response = await ApiClient.uploadFile(
        '/upload',
        file,
        folder: 'assignx/deliverables',
        extraFields: {
          'projectId': projectId,
          'fileName': fileName,
        },
      );

      if (response is Map<String, dynamic>) {
        return response['url'] as String?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.uploadFile error: $e');
      }
      rethrow;
    }
  }

  /// Creates a new deliverable record.
  Future<DeliverableModel?> createDeliverable({
    required String projectId,
    required String fileUrl,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
    bool isFinal = false,
  }) async {
    try {
      final response = await ApiClient.post('/projects/$projectId/deliverables', {
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': fileType,
        'fileSizeBytes': fileSizeBytes,
        'isFinal': isFinal,
      });

      if (response == null) return null;
      return DeliverableModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeliverableRepository.createDeliverable error: $e');
      }
      rethrow;
    }
  }

  /// Submits a deliverable for QC review.
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

      // 2. Create deliverable and submit for review
      final response = await ApiClient.post('/projects/$projectId/deliverables/submit', {
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': fileType,
        'fileSizeBytes': fileSizeBytes,
        'isFinal': isFinal,
        'notes': notes,
      });

      if (response == null) return null;
      return DeliverableModel.fromJson(response as Map<String, dynamic>);
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
      final fileUrl = await uploadFile(
        projectId: projectId,
        filePath: filePath,
        fileName: fileName,
      );

      if (fileUrl == null) throw Exception('Failed to upload file');

      // Create new version
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
      final response = await ApiClient.get('/projects/$projectId/revisions');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['revisions'] as List? ?? [];

      return list
          .map((json) => RevisionRequest.fromJson(json as Map<String, dynamic>))
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
  return DeliverableRepository();
});

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';

/// Result of a Cloudinary upload operation.
class CloudinaryUploadResult {
  /// The secure URL of the uploaded file.
  final String url;

  /// The public ID assigned by Cloudinary.
  final String publicId;

  /// The format of the uploaded file (e.g., 'jpg', 'png').
  final String format;

  /// The size of the file in bytes.
  final int bytes;

  const CloudinaryUploadResult({
    required this.url,
    required this.publicId,
    required this.format,
    required this.bytes,
  });

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      url: json['url'] as String,
      publicId: json['publicId'] as String,
      format: json['format'] as String,
      bytes: json['bytes'] as int,
    );
  }
}

/// Folder structure for Cloudinary uploads.
enum CloudinaryFolder {
  /// User avatars: assignx/avatars/{userId}
  avatars,

  /// Project files: assignx/projects/{projectId}
  projects,

  /// Marketplace items: assignx/marketplace/{userId}
  marketplace,
}

/// Progress callback for upload operations.
typedef UploadProgressCallback = void Function(double progress);

/// Service for handling Cloudinary image uploads.
///
/// Uses server-side upload via API endpoint for security -
/// API secret is never exposed in the app.
///
/// ## Usage
/// ```dart
/// final service = CloudinaryService();
///
/// // Pick and upload avatar
/// final result = await service.pickAndUploadImage(
///   folder: CloudinaryFolder.avatars,
///   entityId: userId,
///   source: ImageSource.gallery,
///   onProgress: (progress) => print('Upload: ${progress * 100}%'),
/// );
///
/// if (result != null) {
///   print('Uploaded: ${result.url}');
/// }
/// ```
class CloudinaryService {
  final ImagePicker _picker;
  final http.Client _httpClient;
  final Logger _logger;
  final SupabaseClient _supabase;

  /// Maximum image dimension for compression.
  static const int maxImageDimension = 1024;

  /// JPEG quality for compression (0-100).
  static const int jpegQuality = 85;

  /// Maximum file size in bytes (5MB).
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  CloudinaryService({
    ImagePicker? picker,
    http.Client? httpClient,
    Logger? logger,
    SupabaseClient? supabase,
  })  : _picker = picker ?? ImagePicker(),
        _httpClient = httpClient ?? http.Client(),
        _logger = logger ?? Logger(printer: PrettyPrinter(methodCount: 0)),
        _supabase = supabase ?? Supabase.instance.client;

  /// Get the current authenticated user ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Generates the folder path for Cloudinary based on folder type and entity ID.
  ///
  /// [folder] - The type of folder (avatars, projects, marketplace).
  /// [entityId] - The ID of the entity (userId for avatars/marketplace, projectId for projects).
  String getFolderPath(CloudinaryFolder folder, String entityId) {
    switch (folder) {
      case CloudinaryFolder.avatars:
        return 'assignx/avatars/$entityId';
      case CloudinaryFolder.projects:
        return 'assignx/projects/$entityId';
      case CloudinaryFolder.marketplace:
        return 'assignx/marketplace/$entityId';
    }
  }

  /// Pick an image from the specified source.
  ///
  /// [source] - The source to pick from (camera or gallery).
  /// [maxWidth] - Maximum width of the picked image.
  /// [maxHeight] - Maximum height of the picked image.
  /// [quality] - Compression quality (0-100).
  ///
  /// Returns the picked [XFile] or null if cancelled.
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth ?? maxImageDimension.toDouble(),
        maxHeight: maxHeight ?? maxImageDimension.toDouble(),
        imageQuality: quality ?? jpegQuality,
      );
      return pickedFile;
    } catch (e) {
      _logger.e('Error picking image: $e');
      return null;
    }
  }

  /// Compress an image file.
  ///
  /// Uses the image_picker's built-in compression when picking,
  /// but this method can be used for additional compression if needed.
  Future<Uint8List?> compressImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();

      // If file is already under the size limit, return as-is
      if (bytes.length <= maxFileSizeBytes) {
        return bytes;
      }

      // For web, we can't do additional compression without a package
      // The image_picker already handles compression via quality parameter
      _logger.w('Image is larger than ${maxFileSizeBytes ~/ 1024 ~/ 1024}MB, '
          'consider reducing quality');

      return bytes;
    } catch (e) {
      _logger.e('Error compressing image: $e');
      return null;
    }
  }

  /// Upload an image to Cloudinary via the server API.
  ///
  /// [imageBytes] - The image data as bytes.
  /// [folder] - The Cloudinary folder to upload to.
  /// [entityId] - The entity ID for folder path construction.
  /// [publicId] - Optional custom public ID for the file.
  /// [onProgress] - Optional callback for upload progress.
  ///
  /// Returns the [CloudinaryUploadResult] on success, null on failure.
  Future<CloudinaryUploadResult?> uploadImage({
    required Uint8List imageBytes,
    required CloudinaryFolder folder,
    required String entityId,
    String? publicId,
    UploadProgressCallback? onProgress,
  }) async {
    // Validate base URL is configured
    if (ApiConfig.baseUrl.isEmpty) {
      _logger.e('API_BASE_URL not configured');
      throw StateError(
        'API_BASE_URL not configured. '
        'Build with: --dart-define=API_BASE_URL=https://your-web-app.vercel.app',
      );
    }

    try {
      // Convert to base64
      final base64Data = base64Encode(imageBytes);
      final folderPath = getFolderPath(folder, entityId);

      // Notify initial progress
      onProgress?.call(0.1);

      // Get auth token for API request
      final session = _supabase.auth.currentSession;
      if (session == null) {
        _logger.e('User not authenticated');
        throw Exception('User not authenticated');
      }

      // Prepare request body
      final body = jsonEncode({
        'base64Data': base64Data,
        'folder': folderPath,
        if (publicId != null) 'publicId': publicId,
        'resourceType': 'image',
      });

      onProgress?.call(0.3);

      // Make API request
      final response = await _httpClient.post(
        Uri.parse('${ApiConfig.baseUrl}/api/cloudinary/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: body,
      );

      onProgress?.call(0.9);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        onProgress?.call(1.0);
        return CloudinaryUploadResult.fromJson(responseData);
      } else {
        final errorBody = jsonDecode(response.body);
        _logger.e('Upload failed: ${response.statusCode} - ${errorBody['error'] ?? 'Unknown error'}');
        return null;
      }
    } catch (e) {
      _logger.e('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Upload an image file to Cloudinary.
  ///
  /// [file] - The image file to upload.
  /// [folder] - The Cloudinary folder to upload to.
  /// [entityId] - The entity ID for folder path construction.
  /// [publicId] - Optional custom public ID for the file.
  /// [onProgress] - Optional callback for upload progress.
  ///
  /// Returns the [CloudinaryUploadResult] on success, null on failure.
  Future<CloudinaryUploadResult?> uploadFile({
    required XFile file,
    required CloudinaryFolder folder,
    required String entityId,
    String? publicId,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      return uploadImage(
        imageBytes: bytes,
        folder: folder,
        entityId: entityId,
        publicId: publicId,
        onProgress: onProgress,
      );
    } catch (e) {
      _logger.e('Error reading file for upload: $e');
      return null;
    }
  }

  /// Pick an image and upload it in one operation.
  ///
  /// [folder] - The Cloudinary folder to upload to.
  /// [entityId] - The entity ID for folder path construction.
  /// [source] - The image source (camera or gallery).
  /// [publicId] - Optional custom public ID for the file.
  /// [onProgress] - Optional callback for upload progress.
  ///
  /// Returns the [CloudinaryUploadResult] on success, null on failure or cancellation.
  Future<CloudinaryUploadResult?> pickAndUploadImage({
    required CloudinaryFolder folder,
    required String entityId,
    required ImageSource source,
    String? publicId,
    UploadProgressCallback? onProgress,
  }) async {
    // Pick image
    final file = await pickImage(source: source);
    if (file == null) {
      _logger.d('Image picking cancelled');
      return null;
    }

    // Upload
    return uploadFile(
      file: file,
      folder: folder,
      entityId: entityId,
      publicId: publicId,
      onProgress: onProgress,
    );
  }

  /// Upload an avatar image for the current user.
  ///
  /// [source] - The image source (camera or gallery).
  /// [onProgress] - Optional callback for upload progress.
  ///
  /// Returns the [CloudinaryUploadResult] on success, null on failure.
  /// Throws if user is not authenticated.
  Future<CloudinaryUploadResult?> uploadAvatar({
    required ImageSource source,
    UploadProgressCallback? onProgress,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return pickAndUploadImage(
      folder: CloudinaryFolder.avatars,
      entityId: userId,
      source: source,
      publicId: 'avatar',
      onProgress: onProgress,
    );
  }

  /// Upload a project file.
  ///
  /// [file] - The file to upload.
  /// [projectId] - The project ID.
  /// [onProgress] - Optional callback for upload progress.
  ///
  /// Returns the [CloudinaryUploadResult] on success, null on failure.
  Future<CloudinaryUploadResult?> uploadProjectFile({
    required XFile file,
    required String projectId,
    UploadProgressCallback? onProgress,
  }) async {
    return uploadFile(
      file: file,
      folder: CloudinaryFolder.projects,
      entityId: projectId,
      onProgress: onProgress,
    );
  }

  /// Upload a marketplace item image.
  ///
  /// [source] - The image source (camera or gallery).
  /// [onProgress] - Optional callback for upload progress.
  ///
  /// Returns the [CloudinaryUploadResult] on success, null on failure.
  /// Throws if user is not authenticated.
  Future<CloudinaryUploadResult?> uploadMarketplaceImage({
    required ImageSource source,
    UploadProgressCallback? onProgress,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return pickAndUploadImage(
      folder: CloudinaryFolder.marketplace,
      entityId: userId,
      source: source,
      onProgress: onProgress,
    );
  }

  /// Delete an image from Cloudinary via the server API.
  ///
  /// [publicId] - The public ID of the image to delete.
  ///
  /// Returns true on success, false on failure.
  Future<bool> deleteImage(String publicId) async {
    if (ApiConfig.baseUrl.isEmpty) {
      _logger.e('API_BASE_URL not configured');
      return false;
    }

    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        _logger.e('User not authenticated');
        return false;
      }

      final response = await _httpClient.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/cloudinary/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: jsonEncode({
          'publicId': publicId,
          'resourceType': 'image',
        }),
      );

      if (response.statusCode == 200) {
        _logger.d('Image deleted: $publicId');
        return true;
      } else {
        _logger.e('Delete failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Error deleting from Cloudinary: $e');
      return false;
    }
  }

  /// Dispose of resources.
  void dispose() {
    _httpClient.close();
  }
}

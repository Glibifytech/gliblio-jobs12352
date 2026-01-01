import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final _client = SupabaseService.instance.client;
  final _uuid = const Uuid();
  static const String bucketName = 'post-images';

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      // Request photos permission first
      final permission = await _requestPhotosPermission();
      if (!permission) {
        // Photos permission denied
        return null;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      // Error picking image from gallery
      return null;
    }
  }

  /// Take photo with camera
  Future<XFile?> takePhoto() async {
    try {
      // Request camera permission first
      final permission = await _requestCameraPermission();
      if (!permission) {
        // Camera permission denied
        return null;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      // Error taking photo
      return null;
    }
  }

  /// Upload image to Blackblaze via backend (NEW - replaces Supabase upload)
  /// Returns: https://photo.gliblio.com/{user_id}/{timestamp}-{fileName}
  Future<String?> uploadPostImage(XFile imageFile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get file bytes
      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await imageFile.readAsBytes();
      } else {
        fileBytes = await File(imageFile.path).readAsBytes();
      }

      // Convert to base64
      final base64File = base64Encode(fileBytes);
      
      // Get file extension and create filename
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName = '${_uuid.v4()}$fileExtension';

      // Upload via backend API (uses Blackblaze with user ID subfolder)
      final apiService = ApiService.instance;
      final url = await apiService.uploadPostImage(
        file: base64File,
        fileName: fileName,
      );

      if (url != null) {
        // Image uploaded to backend successfully
      }
      
      return url;
    } catch (e) {
      // Error uploading image
      return null;
    }
  }

  /// Upload multiple images for a post
  Future<List<String>> uploadPostImages(List<XFile> imageFiles) async {
    final uploadedUrls = <String>[];

    for (final imageFile in imageFiles) {
      final url = await uploadPostImage(imageFile);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  /// Upload avatar image to Supabase storage (Direct upload with anon key)
  /// TODO: Migrate complex operations (notifications, moderation) to backend
  Future<String?> uploadAvatarImage(XFile imageFile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Current user ID
      if (userId == null) {
        // No authenticated user found
        return null;
      }

      // Generate unique filename
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.${imageFile.name.split('.').last}';
      final filePath = '$userId/$fileName';
      // Upload path

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Direct upload using anon key (RLS policies control access)
      await _client.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
          );

      // Get public URL instead of signed URL for avatars
      final publicUrl = _client.storage.from('avatars').getPublicUrl(filePath);

      // Avatar uploaded successfully
      return publicUrl;
    } catch (e) {
      // Error uploading avatar
      return null;
    }
  }

  /// Delete image from storage (Direct delete with anon key)
  /// RLS policies ensure users can only delete their own images
  Future<bool> deletePostImage(String imageUrl) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the user folder and filename in the path
      final userFolderIndex =
          pathSegments.indexWhere((segment) => segment == userId);
      if (userFolderIndex == -1) {
        // Invalid image URL: user folder not found
        return false;
      }

      // Reconstruct path from user folder onwards
      final filePath = pathSegments.sublist(userFolderIndex).join('/');

      // Deleting image
      await _client.storage.from(bucketName).remove([filePath]);

      // Image deleted successfully
      return true;
    } catch (e) {
      // Error deleting image
      return false;
    }
  }

  /// Get optimized image URL with transformations
  String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    try {
      final uri = Uri.parse(originalUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters);

      if (width != null) queryParams['width'] = width.toString();
      if (height != null) queryParams['height'] = height.toString();
      queryParams['quality'] = quality;
      queryParams['format'] = 'auto';

      return uri.replace(queryParameters: queryParams).toString();
    } catch (e) {
      return originalUrl; // Return original if transformation fails
    }
  }

  /// Check if storage bucket exists and is accessible
  Future<bool> checkStorageAccess() async {
    try {
      await _client.storage.listBuckets();
      return true;
    } catch (e) {
      // Storage access check failed
      return false;
    }
  }

  /// Request photos permission with proper handling
  Future<bool> _requestPhotosPermission() async {
    try {
      final status = await Permission.photos.status;

      // Always request permission on iOS to ensure it's properly granted
      if (Platform.isIOS || status.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        // Photos permission permanently denied
        await openAppSettings();
        return false;
      }

      return status.isGranted;
    } catch (e) {
      // Error requesting photos permission
      return false;
    }
  }

  /// Request camera permission with proper handling
  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;

      // Always request permission on iOS to ensure it's properly granted
      if (Platform.isIOS || status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        // Camera permission permanently denied
        await openAppSettings();
        return false;
      }

      return status.isGranted;
    } catch (e) {
      // Error requesting camera permission
      return false;
    }
  }
}

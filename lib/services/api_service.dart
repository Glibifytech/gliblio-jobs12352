import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import './auth_service.dart';

/// API Service - All requests go through backend
/// Backend validates JWT and uses service_role
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  String? _backendUrl;

  Future<String> get _baseUrl async {
    if (_backendUrl != null) return _backendUrl!;
    
    try {
      final envString = await rootBundle.loadString('env.json');
      final env = json.decode(envString);
      _backendUrl = env['backendUrl'] ?? '';
      return _backendUrl!;
    } catch (e) {
      _backendUrl = '';
      return _backendUrl!;
    }
  }

  /// Get JWT token
  String? _getToken() {
    return AuthService.instance.currentSession?.accessToken;
  }

  /// Get headers with JWT
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
    };
    final token = _getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ============================================
  // STORAGE: Upload Image
  // ============================================

  Future<String?> uploadImage({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final url = Uri.parse('$baseUrl/api/supabase/storage/upload');
      final headers = _getHeaders();
      final body = jsonEncode({
        'bucket': bucket,
        'path': path,
        'file': base64Encode(fileBytes),
        'contentType': contentType,
      });
      
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data']['path'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // STORAGE: Get Signed URL
  // ============================================

  Future<String?> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 2592000, // 30 days
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final url = Uri.parse('$baseUrl/api/supabase/storage/signed-url');
      final body = jsonEncode({
        'bucket': bucket,
        'path': path,
        'expiresIn': expiresIn,
      });
      
      final response = await http.post(url, headers: _getHeaders(), body: body);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data']['signedUrl'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // DATABASE: Query
  // ============================================

  Future<List<dynamic>?> query({
    required String table,
    required String operation,
    String? select,
    Map<String, dynamic>? data,
    List<Map<String, dynamic>>? filters,
    int? limit,
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final url = Uri.parse('$baseUrl/api/supabase/db/query');
      final body = jsonEncode({
        'table': table,
        'operation': operation,
        if (select != null) 'select': select,
        if (data != null) 'data': data,
        if (filters != null) 'filters': filters,
        if (limit != null) 'limit': limit,
      });
      
      final response = await http.post(url, headers: _getHeaders(), body: body);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // DATABASE: RPC
  // ============================================

  Future<dynamic> rpc({
    required String functionName,
    Map<String, dynamic>? params,
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final url = Uri.parse('$baseUrl/api/supabase/db/rpc');
      final body = jsonEncode({
        'function_name': functionName,
        if (params != null) 'params': params,
      });
      
      final response = await http.post(url, headers: _getHeaders(), body: body);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  // ============================================
  // CHAT: Upload Image via Backend (Service Role)
  // ============================================

  Future<String?> uploadChatImage({
    required String conversationId,
    required String file, // base64 encoded file
    required String fileName,
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final url = Uri.parse('$baseUrl/api/supabase/storage/upload-chat-image');
      
      final headers = _getHeaders();
      final body = jsonEncode({
        'conversationId': conversationId,
        'file': file,
        'fileName': fileName,
      });
      
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data']['signedUrl']; // Return signed URL instead of public URL
      } else {
        final errorResult = jsonDecode(response.body);
        throw Exception(errorResult['error'] ?? 'Failed to upload chat image');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // BLACKBLAZE: Upload Post Image
  // ============================================

  /// Upload post image to Blackblaze via backend
  /// Returns: https://photo.gliblio.com/{user_id}/{timestamp}-{fileName}
  Future<String?> uploadPostImage({
    required String file, // base64 encoded file
    required String fileName,
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final url = Uri.parse('$baseUrl/api/upload/post-image');
      
      final headers = _getHeaders();
      final body = jsonEncode({
        'file': file,
        'fileName': fileName,
      });
      
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['url']; // Blackblaze URL with user subfolder
      } else {
        final errorResult = jsonDecode(response.body);
        throw Exception(errorResult['error'] ?? 'Failed to upload post image');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload avatar to Blackblaze via backend
  /// Returns: https://photo.gliblio.com/{user_id}/{timestamp}-{fileName}
  Future<String?> uploadAvatar({
    required String file, // base64 encoded file
    required String fileName,
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final url = Uri.parse('$baseUrl/api/upload/avatar');
      
      final headers = _getHeaders();
      final body = jsonEncode({
        'file': file,
        'fileName': fileName,
      });
      
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['url']; // Blackblaze URL with user subfolder
      } else {
        final errorResult = jsonDecode(response.body);
        throw Exception(errorResult['error'] ?? 'Failed to upload avatar');
      }
    } catch (e) {
      rethrow;
    }
  }
}

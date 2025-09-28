import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

/// WebDAV service for Nextcloud storage under a specific app folder.
///
/// Rules:
/// - Credentials must come from .env (NEXTCLOUD_USERNAME, NEXTCLOUD_PASSWORD).
/// - All file operations are scoped to [appFolder] = "HireMe_Id_App/".
/// - The app folder is auto-created on first use.
class WebDAVService {
  static const String baseRoot =
      'https://cl0ud.codrihub.my.id/remote.php/dav/files/';
  static const String appFolder = 'HireMe_Id_App/';

  late final webdav.Client _client;
  late final String _baseUrl; // includes username and trailing slash

  WebDAVService() {
  final username = dotenv.env['NEXTCLOUD_USERNAME'];
  final password = dotenv.env['NEXTCLOUD_PASSWORD'];

    if (username == null || username.isEmpty ||
        password == null || password.isEmpty) {
      throw StateError(
        'Missing NEXTCLOUD_USERNAME or NEXTCLOUD_PASSWORD in .env',
      );
    }

    _baseUrl = '$baseRoot$username/';

    _client = webdav.newClient(
      _baseUrl,
      user: username,
      password: password,
      // For Nextcloud it's usually safe to keep these defaults
      debug: kDebugMode,
    );
  }

  /// Ensure the application folder exists on the server.
  Future<void> _ensureAppFolder() async {
    final entries = await _client.readDir('/');
    final folderName = appFolder.replaceAll('/', '');
    final exists = entries.any((e) {
      final name = (e as dynamic).name as String?;
      final isDir = (e as dynamic).isDir as bool?;
      return name == folderName && (isDir == true);
    });
    if (!exists) {
      await _client.mkdir('/$appFolder');
    }
  }

  /// Test connection and make sure the app folder exists.
  Future<bool> testConnection() async {
    try {
      // A lightweight call to list root and then ensure folder
      await _client.readDir('/');
      await _ensureAppFolder();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload a local file to /HireMe_Id_App/[fileName].
  Future<void> uploadFile(String localPath, String fileName) async {
    if (fileName.isEmpty) {
      throw ArgumentError('fileName cannot be empty');
    }
    final file = File(localPath);
    if (!await file.exists()) {
      throw ArgumentError('Local file not found: $localPath');
    }

    await _ensureAppFolder();
    final remotePath = '/$appFolder$fileName';
    await _client.writeFromFile(localPath, remotePath);
  }

  /// Download /HireMe_Id_App/[fileName] to [localPath].
  Future<void> downloadFile(String fileName, String localPath) async {
    if (fileName.isEmpty) {
      throw ArgumentError('fileName cannot be empty');
    }
    await _ensureAppFolder();
    final remotePath = '/$appFolder$fileName';
    await _client.read2File(remotePath, localPath);
  }

  /// Delete /HireMe_Id_App/[fileName].
  Future<void> deleteFile(String fileName) async {
    if (fileName.isEmpty) {
      throw ArgumentError('fileName cannot be empty');
    }
    await _ensureAppFolder();
    final remotePath = '/$appFolder$fileName';
    await _client.remove(remotePath);
  }

  /// List all files under /HireMe_Id_App/.
  Future<List<String>> listFiles() async {
    await _ensureAppFolder();
    final list = await _client.readDir('/$appFolder');
    final files = <String>[];
    for (final e in list) {
      final dyn = e as dynamic;
      final name = dyn.name as String?;
      final isDir = dyn.isDir as bool?;
      if (name != null && (isDir == null || isDir == false)) {
        files.add(name);
      }
    }
    return files;
  }

  /// Build a direct URL to a file under the app folder (requires Basic Auth).
  String buildFileUrl(String fileName) {
    final encoded = Uri.encodeComponent(fileName);
    return '$_baseUrl$appFolder$encoded';
  }

  /// Headers for Basic authentication to access Nextcloud files via HTTP.
  static Map<String, String> authHeaders() {
    final username = dotenv.env['NEXTCLOUD_USERNAME'] ?? '';
    final password = dotenv.env['NEXTCLOUD_PASSWORD'] ?? '';
    if (username.isEmpty || password.isEmpty) {
      throw StateError('Missing NEXTCLOUD_USERNAME or NEXTCLOUD_PASSWORD');
    }
    final creds = base64Encode(utf8.encode('$username:$password'));
    return {
      'Authorization': 'Basic $creds',
      'Accept': 'image/*,application/octet-stream;q=0.9,*/*;q=0.8',
    };
  }
}

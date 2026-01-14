import 'dart:typed_data';

/// Abstract class representing platform-specific operations.
abstract class IpfsPlatform {
  /// Whether the current platform is Web.
  bool get isWeb;

  /// Whether the current platform is Desktop/Mobile (supports dart:io).
  bool get isIO;

  /// Helper to get the path separator for the platform.
  String get pathSeparator;

  // --- File System Operations ---

  /// Writes bytes to a file at DocumentsDirectory/ipfs/[fileNames].
  Future<void> writeBytes(List<String> fileNames, Uint8List bytes);

  /// Reads bytes from a file at DocumentsDirectory/ipfs/[fileNames].
  Future<Uint8List?> readBytes(List<String> fileNames);

  /// Checks if a file or directory exists at DocumentsDirectory/ipfs/[fileNames].
  Future<bool> exists(List<String> fileNames);

  /// Deletes a file or directory at DocumentsDirectory/ipfs/[fileNames].
  Future<void> delete(List<String> fileNames);

  /// Creates a directory at DocumentsDirectory/ipfs/[fileNames].
  Future<void> createDirectory(List<String> fileNames);

  /// Lists files in a directory at DocumentsDirectory/ipfs/[fileNames].
  /// Returns a list of filenames/paths.
  Future<List<String>> listDirectory(List<String> fileNames);

  // --- Network Operations ---

  // Note: HttpServer and Sockets are complex to abstract fully here.
  // Instead, we might expose methods to start services if supported.
}

/// Returns the platform implementation (stub throws).
IpfsPlatform getPlatform() => throw UnsupportedError(
  'Cannot create platform without dart:io or dart:html',
);

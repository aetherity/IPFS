import 'dart:io';
import 'dart:typed_data';

import '../utils/join_path.dart';
import 'platform_stub.dart';

/// IO implementation of the IPFS platform interface.
class IpfsPlatformIO implements IpfsPlatform {
  @override
  bool get isWeb => false;

  @override
  bool get isIO => true;

  @override
  Future<void> writeBytes(List<String> fileNames, Uint8List bytes) async {
    String path = await joinPath(fileNames);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<Uint8List?> readBytes(List<String> fileNames) async {
    String path = await joinPath(fileNames);
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }

  @override
  Future<bool> exists(List<String> fileNames) async {
    String path = await joinPath(fileNames);
    return await File(path).exists() || await Directory(path).exists();
  }

  @override
  Future<void> delete(List<String> fileNames) async {
    String path = await joinPath(fileNames);
    final type = await FileSystemEntity.type(path);
    if (type == FileSystemEntityType.file) {
      await File(path).delete();
    } else if (type == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: true);
    }
  }

  @override
  Future<void> createDirectory(List<String> fileNames) async {
    String path = await joinPath(fileNames);
    await Directory(path).create(recursive: true);
  }

  @override
  Future<List<String>> listDirectory(List<String> fileNames) async {
    String path = await joinPath(fileNames);
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final entities = await dir.list().toList();
    return entities.map((e) => e.path).toList();
  }

  /// Returns the IO platform implementation.
  IpfsPlatform getPlatform() => IpfsPlatformIO();

}

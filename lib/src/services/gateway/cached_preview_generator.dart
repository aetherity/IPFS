import 'dart:typed_data';
import 'package:dart_ipfs/src/services/gateway/file_preview_handler.dart';
import 'package:dart_ipfs/src/services/gateway/preview_cache_manager.dart';
import 'package:dart_ipfs/src/core/data_structures/block.dart';
import 'dart:convert';
import 'package:dart_ipfs/src/services/gateway/content_type_handler.dart';

class CachedPreviewGenerator {
  final PreviewCacheManager _cacheManager;
  final FilePreviewHandler _previewHandler;
  final ContentTypeHandler _contentTypeHandler = ContentTypeHandler();

  CachedPreviewGenerator(this._cacheManager, this._previewHandler);

  Future<Uint8List?> generatePreview(Block block, String contentType) async {
    // Try to get from cache first
    final cached = await _cacheManager.getPreview(block.cid, contentType);
    if (cached != null) {
      return cached;
    }

    // Generate new preview if not in cache
    final preview = _previewHandler.generatePreview(block, contentType);
    if (preview != null) {
      final previewBytes = Uint8List.fromList(utf8.encode(preview));
      await _cacheManager.cachePreview(block.cid, contentType, previewBytes);
      return previewBytes;
    }

    return null;
  }

  Future<void> preloadPreviews(List<Block> blocks) async {
    for (final block in blocks) {
      final contentType = _detectContentType(block);
      if (_previewHandler.isSupportedType(contentType)) {
        await generatePreview(block, contentType);
      }
    }
  }

  String _detectContentType(Block block) {
    return _contentTypeHandler.detectContentType(block);
  }
}

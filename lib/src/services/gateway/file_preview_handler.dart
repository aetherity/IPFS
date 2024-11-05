import 'dart:typed_data';
import 'package:mime/mime.dart';
import '../../core/data_structures/block.dart';
import '../../core/data_structures/unixfs.dart';

/// Handles file preview generation for supported file types
class FilePreviewHandler {
  static const _maxPreviewSize = 5 * 1024 * 1024; // 5MB preview limit
  static const _supportedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
  static const _supportedTextTypes = ['text/plain', 'text/markdown', 'text/html', 'application/json'];
  
  /// Generates a preview for the given block if supported
  String? generatePreview(Block block, String contentType, {int? maxSize}) {
    if (block.data.length > (maxSize ?? _maxPreviewSize)) {
      return null;
    }

    if (_supportedImageTypes.contains(contentType)) {
      return _generateImagePreview(block.data);
    } else if (_supportedTextTypes.contains(contentType)) {
      return _generateTextPreview(block.data, contentType);
    }
    
    return null;
  }

  String _generateImagePreview(Uint8List data) {
    final base64Data = Uri.encodeFull(String.fromCharCodes(data));
    return '''
      <div class="preview-container">
        <img src="data:image/png;base64,$base64Data" alt="Preview" class="preview-image">
      </div>
    ''';
  }

  String _generateTextPreview(Uint8List data, String contentType) {
    final text = String.fromCharCodes(data);
    final formattedText = _formatTextContent(text, contentType);
    
    return '''
      <div class="preview-container">
        <pre class="preview-text"><code>$formattedText</code></pre>
      </div>
    ''';
  }

  String _formatTextContent(String text, String contentType) {
    switch (contentType) {
      case 'text/markdown':
        return _formatMarkdown(text);
      case 'application/json':
        return _formatJson(text);
      case 'text/html':
        return _escapeHtml(text);
      default:
        return _escapeHtml(text);
    }
  }

  String _formatMarkdown(String text) {
    // Basic markdown formatting
    final formatted = text
        .replaceAll(RegExp(r'#{1,6}\s(.+)'), '<h3>$1</h3>')
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), '<strong>$1</strong>')
        .replaceAll(RegExp(r'\*(.+?)\*'), '<em>$1</em>')
        .replaceAll(RegExp(r'`(.+?)`'), '<code>$1</code>');
    return _escapeHtml(formatted);
  }

  String _formatJson(String text) {
    try {
      final parsedJson = JsonDecoder().convert(text);
      return JsonEncoder.withIndent('  ').convert(parsedJson);
    } catch (_) {
      return text;
    }
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
} 
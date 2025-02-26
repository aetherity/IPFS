// src/services/gateway/adaptive_compression_handler.dart
import 'dart:typed_data';
import 'package:dart_ipfs/src/core/cid.dart';
import 'package:dart_ipfs/src/services/gateway/compressed_cache_store.dart';
import 'package:dart_ipfs/src/core/data_structures/block.dart';
import 'package:dart_ipfs/src/core/data_structures/blockstore.dart';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'dart:io';
import 'package:es_compression/lz4.dart';

class CompressionConfig {
  final bool enabled;
  final int maxUncompressedSize;
  final Map<String, CompressionType> contentTypeRules;

  CompressionConfig({
    this.enabled = true,
    this.maxUncompressedSize = 52428800, // 50MB
    Map<String, CompressionType>? contentTypeRules,
  }) : contentTypeRules = contentTypeRules ?? _defaultCompressionRules;

  static final _defaultCompressionRules = {
    'text/': CompressionType.gzip,
    'application/json': CompressionType.gzip,
    'application/javascript': CompressionType.gzip,
    'image/': CompressionType.none,
    'video/': CompressionType.none,
    'audio/': CompressionType.none,
  };
}

class CompressionAnalysis {
  final Map<CompressionType, double> compressionRatios;
  final CompressionType recommendedType;

  CompressionAnalysis({
    required this.compressionRatios,
    required this.recommendedType,
  });
}

class AdaptiveCompressionHandler {
  final BlockStore _blockStore;
  final CompressionConfig _config;
  final String _metadataPath;

  AdaptiveCompressionHandler(this._blockStore, this._config)
      : _metadataPath = '${_blockStore.path}/metadata';

  Future<Block> compressBlock(Block block, String contentType) async {
    if (!_config.enabled || block.size > _config.maxUncompressedSize) {
      return block;
    }

    final compressionType = getOptimalCompression(contentType, block.size);
    if (compressionType == CompressionType.none) {
      return block;
    }

    final compressedData = await _compressData(block.data, compressionType);
    if (compressedData.length >= block.size) {
      return block; // Skip if compression doesn't help
    }

    // Create new block with compressed data and store it in the blockstore
    final compressedBlock = await Block.fromData(compressedData, format: 'raw');

    // Store the compressed block
    await _blockStore.putBlock(compressedBlock);

    // Store compression metadata
    await _storeCompressionMetadata(block.cid, {
      'originalSize': block.size.toString(),
      'compressedSize': compressedData.length.toString(),
      'compressionType': compressionType.name,
      'originalCid': block.cid.encode(),
    });

    return compressedBlock;
  }

  CompressionType getOptimalCompression(String contentType, int size) {
    for (final entry in _config.contentTypeRules.entries) {
      if (contentType.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return CompressionType.lz4; // Default to fast compression
  }

  Future<Uint8List> _compressData(Uint8List data, CompressionType type) async {
    switch (type) {
      case CompressionType.none:
        return data;
      case CompressionType.gzip:
        return Uint8List.fromList(GZipEncoder().encode(data)!);
      case CompressionType.zlib:
        return Uint8List.fromList(ZLibEncoder().encode(data));
      case CompressionType.lz4:
        return Uint8List.fromList(Lz4Encoder().convert(data));
    }
  }

  Future<void> _storeCompressionMetadata(
      CID cid, Map<String, String> metadata) async {
    final metadataFile = File('$_metadataPath/${cid.encode()}.json');
    await metadataFile.parent.create(recursive: true);
    await metadataFile.writeAsString(jsonEncode(metadata));
  }

  CompressionAnalysis analyzeCompression(
    Uint8List data,
    String contentType,
    Map<CompressionType, int> compressedSizes,
  ) {
    final ratios = <CompressionType, double>{};

    for (final entry in compressedSizes.entries) {
      ratios[entry.key] = entry.value / data.length;
    }

    // Find the compression type with the best ratio
    var bestType = CompressionType.none;
    var bestRatio = 1.0;

    for (final entry in ratios.entries) {
      if (entry.value < bestRatio) {
        bestRatio = entry.value;
        bestType = entry.key;
      }
    }

    return CompressionAnalysis(
      compressionRatios: ratios,
      recommendedType: bestType,
    );
  }
}

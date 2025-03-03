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
  final Map<String, CompType> contentTypeRules;

  CompressionConfig({
    this.enabled = true,
    this.maxUncompressedSize = 52428800, // 50MB
    Map<String, CompType>? contentTypeRules,
  }) : contentTypeRules = contentTypeRules ?? _defaultCompressionRules;

  static final _defaultCompressionRules = {
    'text/': CompType.gzip,
    'application/json': CompType.gzip,
    'application/javascript': CompType.gzip,
    'image/': CompType.none,
    'video/': CompType.none,
    'audio/': CompType.none,
  };
}

class CompressionAnalysis {
  final Map<CompType, double> compressionRatios;
  final CompType recommendedType;

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
    if (compressionType == CompType.none) {
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

  CompType getOptimalCompression(String contentType, int size) {
    for (final entry in _config.contentTypeRules.entries) {
      if (contentType.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return CompType.lz4; // Default to fast compression
  }

  Future<Uint8List> _compressData(Uint8List data, CompType type) async {
    switch (type) {
      case CompType.none:
        return data;
      case CompType.gzip:
        return Uint8List.fromList(GZipEncoder().encode(data)!);
      case CompType.zlib:
        return Uint8List.fromList(ZLibEncoder().encode(data));
      case CompType.lz4:
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
    Map<CompType, int> compressedSizes,
  ) {
    final ratios = <CompType, double>{};

    for (final entry in compressedSizes.entries) {
      ratios[entry.key] = entry.value / data.length;
    }

    // Find the compression type with the best ratio
    var bestType = CompType.none;
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

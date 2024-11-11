import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import 'package:dart_ipfs/src/core/cid.dart';
import 'package:dart_ipfs/src/core/config/config.dart';
import 'package:dart_ipfs/src/core/data_structures/block.dart';
import 'package:dart_ipfs/src/protocols/pubsub/pubsub_client.dart';
import 'package:dart_ipfs/src/core/ipfs_node/bitswap_handler.dart';
import 'package:dart_ipfs/src/core/data_structures/blockstore.dart';
import 'package:dart_ipfs/src/proto/generated/core/cid.pb.dart' as pb_cid;
import 'package:dart_ipfs/src/services/gateway/content_type_handler.dart';
import 'package:dart_ipfs/src/services/gateway/lazy_preview_handler.dart';
import 'package:dart_ipfs/src/proto/generated/base_messages.pb.dart' as pb_base;

class MessageHandler {
  final StreamController<pb_base.NetworkEvent> _eventController =
      StreamController<pb_base.NetworkEvent>.broadcast();
  final PubSubClient? _pubSubClient;
  final IPFSConfig config;
  late final BlockStore _blockStore;

  MessageHandler(this.config, [this._pubSubClient]);

  Future<void> handleCIDMessage(pb_cid.IPFSCIDProto protoMessage) async {
    final cid = CID.fromProto(protoMessage);
    // Add handling logic here, for example:
    await processContent(cid);
    // or
    await storeCID(cid);
    // or
    notifyListeners(cid);
  }

  Future<void> processContent(CID cid) async {
    try {
      // Get the block data associated with the CID
      final block = await getBlock(cid);
      if (block == null) {
        throw Exception('Block not found for CID: ${cid.encode()}');
      }

      // Create a content type handler instance
      final contentHandler = ContentTypeHandler();

      // Detect content type
      final contentType = contentHandler.detectContentType(block);

      // Process the content based on its type
      final processedData = contentHandler.processContent(block, contentType);

      // Handle the processed data (e.g., store it, send it, etc.)
      await handleProcessedData(cid, processedData, contentType);
    } catch (e) {
      print('Error processing content for CID ${cid.encode()}: $e');
      rethrow;
    }
  }

  Future<void> storeCID(CID cid) async {
    try {
      // Get the block associated with the CID
      final block = await getBlock(cid);
      if (block == null) {
        throw Exception('Block not found for CID: ${cid.encode()}');
      }

      // Create a BlockStore instance with path from config
      final blockStore = BlockStore(path: config.blockStorePath);

      // Convert the block to proto format and store it
      final response = await blockStore.addBlock(block.toProto());

      if (!response.success) {
        throw Exception('Failed to store block: ${response.message}');
      }

      // Notify any listeners about the new CID
      notifyListeners(cid);

      print('Successfully stored CID: ${cid.encode()}');
    } catch (e) {
      print('Error storing CID ${cid.encode()}: $e');
      rethrow;
    }
  }

  void notifyListeners(CID cid) {
    try {
      // Create a network event for content update
      final event = pb_base.NetworkEvent()
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
        ..eventType = 'CONTENT_UPDATED'
        ..data = utf8.encode(cid.encode());

      // Broadcast the event to all subscribers
      _eventController.add(event);

      // If using PubSub, publish to a dedicated topic for content updates
      final message = {
        'type': 'content_update',
        'cid': cid.encode(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Convert the message to JSON and publish to the content updates topic
      final messageJson = jsonEncode(message);
      _pubSubClient?.publish('content_updates', messageJson);

      print('Notified listeners about new content: ${cid.encode()}');
    } catch (e) {
      print('Error notifying listeners about CID ${cid.encode()}: $e');
    }
  }

  Future<Block?> getBlock(CID cid) async {
    try {
      // First try to get from local blockstore
      final blockStore = _blockStore;
      final response = await blockStore.getBlock(cid.encode());

      if (response.found) {
        return Block.fromProto(response.block);
      }

      // If not found locally, try to get from network via bitswap
      final bitswap = BitswapHandler(config, blockStore);
      return await bitswap.wantBlock(cid.encode());
    } catch (e) {
      print('Error retrieving block for CID ${cid.encode()}: $e');
      return null;
    }
  }

  Future<void> handleProcessedData(
      CID cid, Uint8List data, String contentType) async {
    try {
      // Create a new block with the processed data
      final block = await Block.fromData(data, format: 'raw');

      // Store the block in the datastore
      final blockStore = _blockStore;
      final storeResponse = await blockStore.addBlock(block.toProto());

      if (!storeResponse.success) {
        throw Exception(
            'Failed to store processed data: ${storeResponse.message}');
      }

      // Cache the content type mapping for future reference
      final contentHandler = ContentTypeHandler();
      await contentHandler.cacheContentType(cid.encode(), contentType);

      // If this is a directory listing or markdown content,
      // generate and cache preview
      if (contentType == 'text/html' || contentType == 'text/markdown') {
        final previewHandler = LazyPreviewHandler();
        previewHandler.generateLazyPreview(block, contentType);
      }

      // Notify subscribers about the new processed content
      final event = pb_base.NetworkEvent()
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
        ..eventType = 'CONTENT_PROCESSED'
        ..data = utf8.encode(jsonEncode({
          'cid': cid.encode(),
          'contentType': contentType,
          'size': data.length,
          'timestamp': DateTime.now().toIso8601String(),
        }));

      _eventController.add(event);

      // If using PubSub, publish to content updates topic
      if (_pubSubClient != null) {
        await _pubSubClient.publish(
            'content_updates',
            jsonEncode({
              'type': 'content_processed',
              'cid': cid.encode(),
              'contentType': contentType,
              'size': data.length,
              'timestamp': DateTime.now().toIso8601String(),
            }));
      }

      print('Successfully handled processed data for CID: ${cid.encode()}');
    } catch (e) {
      print('Error handling processed data for CID ${cid.encode()}: $e');
      rethrow;
    }
  }

  pb_cid.IPFSCIDProto prepareCIDMessage(CID cid) {
    return cid.toProto();
  }
}

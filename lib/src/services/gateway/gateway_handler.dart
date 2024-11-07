import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import '../../core/data_structures/cid.dart';
import '../../core/data_structures/block.dart';
import '../../core/data_structures/blockstore.dart';
import '../../services/gateway/content_type_handler.dart';

/// Handles IPFS Gateway HTTP requests following the IPFS Gateway specs
class GatewayHandler {
  final BlockStore blockStore;

  GatewayHandler(this.blockStore);

  /// Handles path-based gateway requests (/ipfs/ and /ipns/)
  Future<Response> handlePath(Request request) async {
    final path = request.url.path;

    // Parse IPFS path
    if (path.startsWith('ipfs/')) {
      final cidStr = path.substring(5).split('/')[0];
      try {
        final block = await _getBlockByCid(cidStr);
        if (block != null) {
          final contentTypeHandler = ContentTypeHandler();
          final contentType = contentTypeHandler.detectContentType(block,
              filename: path.split('/').last);
          final processedContent =
              contentTypeHandler.processContent(block, contentType);

          return Response.ok(
            processedContent,
            headers: {
              'Content-Type': contentType,
              'X-IPFS-Path': '/ipfs/$cidStr',
            },
          );
        }
        return Response.notFound('Block not found');
      } catch (e) {
        return Response.internalServerError(body: 'Error: $e');
      }
    }

    return Response.notFound('Invalid IPFS path');
  }

  /// Handles subdomain-based gateway requests (CID.ipfs.localhost)
  Future<Response> handleSubdomain(Request request) async {
    final host = request.headers['host'];
    if (host == null) return Response.badRequest(body: 'Missing host header');

    // Parse CID from subdomain
    final parts = host.split('.');
    if (parts.length >= 3 && parts[parts.length - 2] == 'ipfs') {
      final cidStr = parts[0];
      try {
        final block = await _getBlockByCid(cidStr);
        if (block != null) {
          return Response.ok(
            block.data,
            headers: {
              'Content-Type': 'application/octet-stream',
              'X-IPFS-Path': '/ipfs/$cidStr',
            },
          );
        }
        return Response.notFound('Block not found');
      } catch (e) {
        return Response.internalServerError(body: 'Error: $e');
      }
    }

    return Response.badRequest(body: 'Invalid IPFS subdomain');
  }

  /// Handles trustless gateway requests with response verification
  Future<Response> handleTrustless(Request request) async {
    final trustlessHeader = request.headers['x-ipfs-trustless'];
    if (trustlessHeader != 'true') {
      return Response.badRequest(body: 'Missing trustless header');
    }

    // Get the requested CID
    final cidStr = request.url.queryParameters['cid'];
    if (cidStr == null) {
      return Response.badRequest(body: 'Missing CID parameter');
    }

    try {
      final block = await _getBlockByCid(cidStr);
      if (block != null) {
        // Verify the block's integrity
        if (_verifyBlock(block)) {
          return Response.ok(
            block.data,
            headers: {
              'Content-Type': 'application/octet-stream',
              'X-IPFS-Path': '/ipfs/$cidStr',
              'X-IPFS-Roots': block.cid.encode(),
            },
          );
        }
        return Response.internalServerError(body: 'Block verification failed');
      }
      return Response.notFound('Block not found');
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  // Helper method to get a block by CID string
  Future<Block?> _getBlockByCid(String cidStr) async {
    try {
      // Convert CID string to IPFSCIDProto
      final IPFSCIDProto = IPFSCIDProto()..codec = cidStr;
      final response = blockStore.getBlock(IPFSCIDProto);
      if (response.found) {
        return Block.fromProto(response.block);
      }
    } catch (e) {
      print('Error getting block: $e');
    }
    return null;
  }

  // Helper method to verify block integrity
  bool _verifyBlock(Block block) {
    try {
      // Verify that the block's CID matches its content
      final computedCid = CID.fromContent(
        'raw',
        content: block.data,
      );
      return computedCid.encode() == block.cid.encode();
    } catch (e) {
      print('Block verification error: $e');
      return false;
    }
  }
}

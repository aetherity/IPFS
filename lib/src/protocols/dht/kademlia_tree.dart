import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:dart_ipfs/src/protocols/dht/dht_client.dart';
import 'package:dart_ipfs/src/protocols/dht/kademlia_tree/helpers.dart'
    as helpers;

import 'red_black_tree.dart';
import 'connection_statistics.dart';
import 'kademlia_tree/kademlia_node.dart';
import 'package:p2plib/p2plib.dart' as p2p;
import 'package:dart_ipfs/src/core/data_structures/node_stats.dart';
import 'package:dart_ipfs/src/proto/generated/dht_messages.pb.dart';
import 'kademlia_tree/refresh.dart';
import 'kademlia_tree/find_closest_peers.dart';
import 'package:dart_ipfs/src/proto/generated/base_messages.pb.dart';
import 'package:dart_ipfs/src/core/messages/message_factory.dart';
import 'kademlia_tree/protocol_messages.dart';
import 'rate_limiter.dart';
import 'kademlia_tree/value_store.dart';
import 'kademlia_tree/lru_cache.dart';

/// Represents a Kademlia tree for efficient peer routing and lookup.
class KademliaTree {
  // Tree structure
  KademliaNode? _root;

  // Kademlia protocol constants
  static const int K = 20; // k-bucket size
  static const int ALPHA = 3; // Number of concurrent lookups
  static const Duration REFRESH_INTERVAL = Duration(hours: 1);
  static const Duration REPUBLISH_INTERVAL = Duration(hours: 24);
  static const Duration NODE_TIMEOUT = Duration(seconds: 5);

  // List of k-buckets (256 for IPv6 compatibility)
  List<RedBlackTree<p2p.PeerId, KademliaNode>> _buckets = [];

  // Peer tracking
  Map<p2p.PeerId, DateTime> _lastSeen = {};
  Set<p2p.PeerId> _recentContacts = {};
  Map<int, Completer<DHTMessage>> _pendingRequests = {};

  // Statistics
  Map<p2p.PeerId, List<bool>> _lookupSuccessHistory = {};
  Map<p2p.PeerId, ConnectionStatistics> _connectionStats = {};
  Map<p2p.PeerId, NodeStats> _nodeStats = {};

  final refreshTimeout = Duration(minutes: 30);
  final DHTClient dhtClient;

  late final ValueStore _valueStore;

  // Rate limiters for different operations
  late final RateLimiter _lookupLimiter;
  late final RateLimiter _storeLimiter;
  late final RateLimiter _findValueLimiter;

  final Map<int, LRUCache> _bucketCaches = {};

  KademliaTree(this.dhtClient, {KademliaNode? root}) {
    _root = root ??
        KademliaNode(
          dhtClient.peerId,
          0,
          dhtClient.peerId,
          lastSeen: DateTime.now().millisecondsSinceEpoch,
        );

    _initializeBuckets();
    _startPeriodicTasks();
    _valueStore = ValueStore(dhtClient);
    _startValueMaintenanceTasks();

    // Initialize rate limiters with reasonable defaults
    _lookupLimiter = RateLimiter(
      maxOperations: 50, // 50 lookups per window
      interval: Duration(minutes: 1),
    );

    _storeLimiter = RateLimiter(
      maxOperations: 100, // 100 store operations per window
      interval: Duration(minutes: 1),
    );

    _findValueLimiter = RateLimiter(
      maxOperations: 100, // 100 find value queries per window
      interval: Duration(minutes: 1),
    );
  }

  void _initializeBuckets() {
    for (int i = 0; i < 256; i++) {
      _buckets.add(RedBlackTree<p2p.PeerId, KademliaNode>(
        compare: (p2p.PeerId a, p2p.PeerId b) {
          final distanceA = helpers.calculateDistance(_root!.peerId, a);
          final distanceB = helpers.calculateDistance(_root!.peerId, b);
          return distanceA.compareTo(distanceB);
        },
      ));
    }
  }

  void _startPeriodicTasks() {
    Timer.periodic(REFRESH_INTERVAL, (_) => refresh());
    Timer.periodic(REPUBLISH_INTERVAL, (_) => _republishKeys());
  }

  void _startValueMaintenanceTasks() {
    // Republish values periodically
    Timer.periodic(REPUBLISH_INTERVAL, (_) async {
      await _valueStore.republishValues();
    });
  }

  // Public getters
  Map<p2p.PeerId, DateTime> get lastSeen => _lastSeen;
  Set<p2p.PeerId> get recentContacts => _recentContacts;
  Map<p2p.PeerId, List<bool>> get lookupSuccessHistory => _lookupSuccessHistory;
  Map<p2p.PeerId, ConnectionStatistics> get connectionStats => _connectionStats;
  Map<p2p.PeerId, NodeStats> get nodeStats => _nodeStats;
  List<RedBlackTree<p2p.PeerId, KademliaNode>> get buckets => _buckets;
  KademliaNode? get root => _root;

  // Implementing iterative node lookup as per Kademlia spec
  Future<List<p2p.PeerId>> nodeLookup(p2p.PeerId target) async {
    try {
      await _lookupLimiter.acquire();

      Set<p2p.PeerId> queriedPeers = {};
      List<p2p.PeerId> closestPeers = findClosestPeers(target, K);
      int consecutiveFailedAttempts = 0;
      Duration backoffDuration = Duration(milliseconds: 100); // Initial backoff
      final maxBackoff = Duration(seconds: 10);
      final minImprovement = 0.01; // 1% improvement threshold

      double previousBestDistance = double.infinity;
      int stagnantRounds = 0;
      final maxStagnantRounds = 3;

      for (int iteration = 0; iteration < 20; iteration++) {
        List<p2p.PeerId> peersToQuery = closestPeers
            .where((p) => !queriedPeers.contains(p))
            .take(ALPHA)
            .toList();

        if (peersToQuery.isEmpty) {
          // If no new peers to query and we've queried some peers, we're done
          if (queriedPeers.isNotEmpty) break;
          return closestPeers;
        }

        // Calculate current best distance
        double currentBestDistance =
            helpers.calculateDistance(target, closestPeers.first).toDouble();

        // Check for sufficient improvement
        double improvement =
            (previousBestDistance - currentBestDistance) / previousBestDistance;
        if (improvement < minImprovement) {
          stagnantRounds++;
          if (stagnantRounds >= maxStagnantRounds) break;
        } else {
          stagnantRounds = 0;
          previousBestDistance = currentBestDistance;
        }

        try {
          List<Future<List<p2p.PeerId>>> queries =
              peersToQuery.map((peer) async {
            try {
              // Apply exponential backoff if there were failures
              if (consecutiveFailedAttempts > 0) {
                await Future.delayed(backoffDuration);
              }
              return await _sendFindNodeRequest(peer, target);
            } catch (e) {
              consecutiveFailedAttempts++;
              // Exponential backoff with max limit
              backoffDuration *= 2;
              if (backoffDuration > maxBackoff) {
                backoffDuration = maxBackoff;
              }
              rethrow;
            }
          }).toList();

          List<List<p2p.PeerId>> results =
              await Future.wait(queries, eagerError: false).timeout(
            Duration(seconds: 30),
            onTimeout: () => [],
          );

          // Reset backoff on successful queries
          if (results.isNotEmpty) {
            consecutiveFailedAttempts = 0;
            backoffDuration = Duration(milliseconds: 100);
          }

          Set<p2p.PeerId> newPeers = {};
          for (var peerList in results) {
            newPeers.addAll(peerList);
          }

          queriedPeers.addAll(peersToQuery);

          // Remove any peers that have consistently failed
          newPeers.removeWhere((peer) =>
              lookupSuccessHistory[peer]?.last == false &&
              lookupSuccessHistory[peer]!.length >= 3);

          List<p2p.PeerId> allPeers = [...closestPeers, ...newPeers];
          allPeers.sort((a, b) => helpers
              .calculateDistance(target, a)
              .compareTo(helpers.calculateDistance(target, b)));

          List<p2p.PeerId> newClosestPeers = allPeers.take(K).toList();

          // Enhanced termination condition
          if (_areListsEqual(closestPeers, newClosestPeers) &&
              currentBestDistance <
                  previousBestDistance * (1 + minImprovement)) {
            break;
          }

          closestPeers = newClosestPeers;
        } catch (e) {
          print('Error in lookup iteration $iteration: $e');
          // Don't break on errors, let the backoff mechanism handle it
          continue;
        }
      }

      return closestPeers;
    } finally {
      _lookupLimiter.release();
    }
  }

  Future<List<p2p.PeerId>> _sendFindNodeRequest(
      p2p.PeerId peer, p2p.PeerId target) async {
    final requestId = _generateRequestId();
    final message =
        FindNodeMessage(requestId.toString(), _root!.peerId, peer, target)
            .toDHTMessage();

    try {
      final response = await _sendMessageWithTimeout(peer, message);
      return _processFindNodeResponse(response);
    } catch (e) {
      print('Error in find node request to $peer: $e');
      return [];
    }
  }

  int _generateRequestId() =>
      DateTime.now().millisecondsSinceEpoch + Random().nextInt(1000000);

  Future<DHTMessage> _sendMessageWithTimeout(
      p2p.PeerId peer, DHTMessage message) {
    final completer = Completer<DHTMessage>();
    _pendingRequests[int.parse(message.messageId)] = completer;

    // Convert to IPFSMessage protobuf using MessageFactory
    final ipfsMessage = MessageFactory.createBaseMessage(
      protocolId: '/ipfs/kad/1.0.0',
      payload: message.writeToBuffer(),
      senderId: _root!.peerId.toString(),
      type: IPFSMessage_MessageType.DHT,
    );

    final messageBytes = ipfsMessage.writeToBuffer();

    // Use sendDatagram directly from dhtClient's router
    dhtClient.router.sendDatagram(
      addresses: dhtClient.router.resolvePeerId(peer),
      datagram: messageBytes,
    );

    return completer.future.timeout(NODE_TIMEOUT, onTimeout: () {
      _pendingRequests.remove(int.parse(message.messageId));
      throw TimeoutException('Request timed out');
    });
  }

  List<p2p.PeerId> _processFindNodeResponse(DHTMessage response) {
    try {
      if (response.type != DHTMessage_MessageType.FIND_NODE) return [];

      return response.closerPeers
          .map((peer) => p2p.PeerId(value: Uint8List.fromList(peer.peerId)))
          .toList();
    } catch (e) {
      print('Error processing find node response: $e');
      return [];
    }
  }

  // Message handling
  void handleIncomingMessage(p2p.Message message) {
    try {
      final dhtMessage = DHTMessage.fromBuffer(message.payload!);
      final requestId = int.parse(dhtMessage.messageId);

      if (_pendingRequests.containsKey(requestId)) {
        _pendingRequests[requestId]!.complete(dhtMessage);
        _pendingRequests.remove(requestId);
      }

      _updateLastSeen(message.srcPeerId);
    } catch (e) {
      print('Error handling incoming message: $e');
    }
  }

  void _updateLastSeen(p2p.PeerId peerId) {
    _lastSeen[peerId] = DateTime.now();
  }

  // Helper methods
  bool _areListsEqual(List<p2p.PeerId> a, List<p2p.PeerId> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].toString() != b[i].toString()) return false;
    }
    return true;
  }

  void _republishKeys() async {
    try {
      await _valueStore.republishValues();
    } catch (e) {
      print('Error in _republishKeys: $e');
    }
  }

  void refresh() {
    // This will use the extension method from refresh.dart
    Refresh(this).refresh();
  }

  List<p2p.PeerId> findClosestPeers(p2p.PeerId target, int k) {
    return FindClosestPeers(this).findClosestPeers(target, k);
  }

  Future<p2p.Message?> sendPingRequest(p2p.PeerId peer) async {
    final requestId = _generateRequestId();
    final pingMessage =
        PingMessage(requestId.toString(), _root!.peerId, peer).toDHTMessage();

    try {
      final response = await _sendMessageWithTimeout(peer, pingMessage);

      // Convert DHTMessage to p2p.Message
      return p2p.Message(
        srcPeerId: peer,
        dstPeerId: _root!.peerId,
        header: p2p.PacketHeader(
          id: int.parse(response.messageId),
          issuedAt: DateTime.now().millisecondsSinceEpoch,
        ),
        payload: response.writeToBuffer(),
      );
    } catch (e) {
      print('Ping request failed: $e');
      return null;
    }
  }

  Future<bool> sendPing(p2p.PeerId peer) async {
    final requestId = _generateRequestId();
    final message =
        PingMessage(requestId.toString(), _root!.peerId, peer).toDHTMessage();

    try {
      final response = await _sendMessageWithTimeout(peer, message);
      return response.type == DHTMessage_MessageType.PING;
    } catch (e) {
      print('Ping failed for peer $peer: $e');
      return false;
    }
  }

  Future<bool> storeValue(
      p2p.PeerId peer, Uint8List key, Uint8List value) async {
    try {
      await _storeLimiter.acquire();

      final requestId = _generateRequestId();
      final message =
          StoreMessage(requestId.toString(), _root!.peerId, peer, key, value)
              .toDHTMessage();

      try {
        final response = await _sendMessageWithTimeout(peer, message);
        return response.type == DHTMessage_MessageType.PUT_VALUE;
      } catch (e) {
        print('Store value failed for peer $peer: $e');
        return false;
      }
    } finally {
      _storeLimiter.release();
    }
  }

  Future<(Uint8List?, List<p2p.PeerId>)> findValue(Uint8List key) async {
    try {
      await _findValueLimiter.acquire();

      final targetPeerId = p2p.PeerId(value: key);
      final closestPeers = findClosestPeers(targetPeerId, K);

      for (final peer in closestPeers) {
        final requestId = _generateRequestId();
        final message =
            FindValueMessage(requestId.toString(), _root!.peerId, peer, key)
                .toDHTMessage();

        try {
          final response = await _sendMessageWithTimeout(peer, message);
          if (response.type == DHTMessage_MessageType.GET_VALUE &&
              response.record.isNotEmpty) {
            return (Uint8List.fromList(response.record), <p2p.PeerId>[]);
          }
          // If value not found, return closer peers
          final closerPeers = _processFindNodeResponse(response);
          return (null, closerPeers);
        } catch (e) {
          print('Find value failed for peer $peer: $e');
        }
      }
      return (null, <p2p.PeerId>[]);
    } finally {
      _findValueLimiter.release();
    }
  }

  Future<void> storeLocalValue(String key, Uint8List value) async {
    await _valueStore.store(key, value);
  }

  Future<Uint8List?> getValue(String key) async {
    return await _valueStore.retrieve(key);
  }

  // Add getter to show explicit usage
  Map<int, LRUCache> get bucketCaches => _bucketCaches;
}

extension RedBlackTreeGetOperator<K, V> on RedBlackTree<K, V> {
  V? operator [](K key) {
    // Implement the [] logic here
    for (var entry in this.entries) {
      if (entry.key == key) {
        return entry.value;
      }
    }
    return null;
  }
}

// Extension for RedBlackTree to support containsKey functionality
extension RedBlackTreeContainsKey<K, V> on RedBlackTree<K, V> {
  bool containsKey(K key) {
    for (var entry in this.entries) {
      if (entry.key == key) {
        return true;
      }
    }
    return false;
  }
}

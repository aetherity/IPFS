// lib/src/core/ipfs_node/pubsub_handler.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_ipfs/src/transport/p2plib_router.dart';
import '../../proto/generated/dht/ipfs_node_network_events.pb.dart';
import '../../utils/dnslink_resolver.dart';
import '/../src/protocols/pubsub/pubsub_client.dart';
import '../data_structures/node_stats.dart'; // Assuming you have a NodeStats class
import '/../src/core/ipfs_node/ipfs_node_network_events.dart'; // Import network events

/// Handles PubSub operations for an IPFS node.
class PubSubHandler {
  final PubSubClient _pubSubClient;
  final IpfsNodeNetworkEvents _networkEvents; // Reference to network events

  /// Constructs a [PubSubHandler] with the provided router, peer ID, and network events.
  PubSubHandler(P2plibRouter router, String peerId, this._networkEvents)
      : _pubSubClient = PubSubClient(router, peerId);

  /// Starts the PubSub client and listens for incoming messages.
  Future<void> start() async {
    try {
      await _pubSubClient.start();
      print('PubSub client started.');

      // Listen for various network events
      _networkEvents.networkEvents.listen((event) {
        if (event.hasPubsubMessageReceived()) {
          _handlePubsubMessage(event.pubsubMessageReceived);
        }
        // Add more event handlers as needed
      });
    } catch (e) {
      print('Error starting PubSub client: $e');
    }
  }

  /// Stops the PubSub client.
  Future<void> stop() async {
    try {
      await _pubSubClient.stop();
      print('PubSub client stopped.');
    } catch (e) {
      print('Error stopping PubSub client: $e');
    }
  }

  /// Subscribes to a PubSub topic.
  Future<void> subscribe(String topic) async {
    try {
      await _pubSubClient.subscribe(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribes from a PubSub topic.
  Future<void> unsubscribe(String topic) async {
    try {
      await _pubSubClient.unsubscribe(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Publishes a message to a PubSub topic.
  Future<void> publish(String topic, String message) async {
    try {
      // Convert message to Uint8List for compliance with IPFS specifications
      final messageBytes = utf8.encode(message);
      await _pubSubClient.publish(topic, Uint8List.fromList(messageBytes) as String);
      print('Published message to topic: $topic');
    } catch (e) {
      print('Error publishing message to topic $topic: $e');
    }
  }

  /// Handles incoming messages on a subscribed topic.
  void onMessage(String topic, Function(String) handler) {
    try {
      _pubSubClient.onMessage.listen((messageBytes) { 
        final decodedMessage = utf8.decode(messageBytes as List<int>);
        handler(decodedMessage);
        print('Processed message on topic: $topic');
      });
    } catch (e) {
      print('Error setting handler for messages on topic $topic: $e');
    }
  }

  /// Resolves a DNSLink to its corresponding CID.
  Future<String?> resolveDNSLink(String domainName) async {
    try {
      final cid = await DNSLinkResolver.resolve(domainName); // Assuming you have a DNSLinkResolver utility
      if (cid != null) {
        print('Resolved DNSLink for domain $domainName to CID: $cid');
        return cid;
      } else {
        throw Exception('DNSLink for domain $domainName not found.');
      }
    } catch (e) {
      print('Error resolving DNSLink for domain $domainName: $e');
      return null;
    }
  }

  /// Gets the node's statistics.
  Future<NodeStats> stats() async {
    try {
      final stats = await _pubSubClient.getNodeStats();
      print('Retrieved node statistics.');
      return stats;
    } catch (e) {
      print('Error retrieving node statistics: $e');
      throw Exception('Failed to retrieve node statistics.');
    }
  }

  /// Handles a received Pubsub message event.
  void _handlePubsubMessage(PubsubMessageReceivedEvent event) {
    final message = utf8.decode(event.messageContent);
    print('Received message on topic ${event.topic}: $message');
    
    // Further processing of the message can be done here
    // For example, dispatching it to specific handlers based on the topic
  }
}

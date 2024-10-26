// lib/src/core/ipfs_node/ipfs_node.dart

import 'bitswap_handler.dart';
import 'dht_handler.dart';
import 'pubsub_handler.dart';
import 'datastore_handler.dart';
import 'routing_handler.dart';
import 'network_handler.dart';

/// The main class representing an IPFS node.
class IPFSNode {
  final BitswapHandler bitswapHandler;
  final DHTHandler dhtHandler;
  final PubSubHandler pubSubHandler;
  final DatastoreHandler datastoreHandler;
  final RoutingHandler routingHandler;
  final NetworkHandler networkHandler;

  IPFSNode(config)
      : bitswapHandler = BitswapHandler(config),
        dhtHandler = DHTHandler(config),
        pubSubHandler = PubSubHandler(config),
        datastoreHandler = DatastoreHandler(config),
        routingHandler = RoutingHandler(config),
        networkHandler = NetworkHandler(config);

  /// Starts the IPFS node.
  Future<void> start() async {
    await bitswapHandler.start();
    await dhtHandler.start();
    await pubSubHandler.start();
    await datastoreHandler.start();
    await routingHandler.start();
    await networkHandler.start();
  }

  /// Stops the IPFS node.
  Future<void> stop() async {
    await bitswapHandler.stop();
    await dhtHandler.stop();
    await pubSubHandler.stop();
    await datastoreHandler.stop();
    await routingHandler.stop();
    await networkHandler.stop();
  }
}
import 'package:dart_ipfs/src/protocols/dht/kademlia_tree/kademlia_node.dart';
import 'package:p2plib/p2plib.dart' as p2p;
import 'package:collection/collection.dart';
import 'package:dart_ipfs/src/protocols/dht/kademlia_tree.dart';
import 'package:dart_ipfs/src/protocols/dht/kademlia_tree/helpers.dart';
// lib/src/protocols/dht/kademlia_tree/find_closest_peers.dart

extension FindClosestPeers on KademliaTree {
  /// Finds the k closest peers to a target peer ID.
  List<p2p.PeerId> findClosestPeers(p2p.PeerId target, int k) {
    // Create a priority queue to store peers based on distance
    PriorityQueue<KademliaTreeNode> queue = PriorityQueue<KademliaTreeNode>(
      (KademliaTreeNode a, KademliaTreeNode b) {
        return calculateDistance(target, a.peerId)
            .compareTo(calculateDistance(target, b.peerId));
      },
    );

    // Add all nodes from all buckets to the priority queue
    for (var bucket in buckets) {
      for (var nodeEntry in bucket.entries) {
        // Convert protobuf KademliaNode to KademliaTreeNode
        final node = KademliaTreeNode(
          nodeEntry.value.peerId,
          nodeEntry.value.distance,
          nodeEntry.value.associatedPeerId,
          lastSeen: nodeEntry.value.lastSeen.toInt(),
        );
        queue.add(node);
      }
    }

    // Retrieve the k closest peers from the priority queue
    List<p2p.PeerId> closestPeers = [];
    for (int i = 0; i < k && queue.isNotEmpty; i++) {
      final node = queue.removeFirst();
      closestPeers.add(node.peerId);
    }

    return closestPeers;
  }
}

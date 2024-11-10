import 'package:p2plib/p2plib.dart' as p2p;
import 'package:dart_ipfs/src/core/types/peer_types.dart';

/// Stores and manages peer information for the DHT protocol
class PeerStore {
  // Internal storage of peers using PeerId as key
  final Map<p2p.PeerId, IPFSPeer> _peers = {};

  /// Adds or updates a peer in the store
  void addPeer(IPFSPeer peer) {
    _peers[peer.id] = peer;
  }

  /// Removes a peer from the store
  void removePeer(p2p.PeerId peerId) {
    _peers.remove(peerId);
  }

  /// Gets a peer by their ID
  IPFSPeer? getPeer(p2p.PeerId peerId) {
    return _peers[peerId];
  }

  /// Gets all stored peers
  List<IPFSPeer> getAllPeers() {
    return _peers.values.toList();
  }

  /// Checks if a peer exists in the store
  bool hasPeer(p2p.PeerId peerId) {
    return _peers.containsKey(peerId);
  }

  /// Updates peer information if the peer exists
  void updatePeer(
    p2p.PeerId peerId, {
    List<p2p.FullAddress>? addresses,
    int? latency,
    String? agentVersion,
  }) {
    if (_peers.containsKey(peerId)) {
      final existingPeer = _peers[peerId]!;
      _peers[peerId] = IPFSPeer(
        id: peerId,
        addresses: addresses ?? existingPeer.addresses,
        latency: latency ?? existingPeer.latency,
        agentVersion: agentVersion ?? existingPeer.agentVersion,
      );
    }
  }
}

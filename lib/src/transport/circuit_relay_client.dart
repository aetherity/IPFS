import 'dart:async';

import 'p2plib_router.dart'; // Import the P2P library for peer-to-peer communication

/// Handles circuit relay operations for an IPFS node.
class CircuitRelayClient {
  final P2plibRouter _router; // Router instance for handling connections
  final StreamController<CircuitRelayEvent> _circuitRelayEventsController =
      StreamController<CircuitRelayEvent>.broadcast();

  CircuitRelayClient(this._router);

  /// Starts the circuit relay client.
  Future<void> start() async {
    try {
      // Initialize any necessary resources or connections
      await _router.start();
      print('Circuit Relay Client started.');
    } catch (e) {
      print('Error starting Circuit Relay Client: $e');
    }
  }

  /// Stops the circuit relay client.
  Future<void> stop() async {
    try {
      // Clean up resources and close connections
      await _router.stop();
      _circuitRelayEventsController.close(); // Close the event stream
      print('Circuit Relay Client stopped.');
    } catch (e) {
      print('Error stopping Circuit Relay Client: $e');
    }
  }

  /// Connects to a peer using a circuit relay.
  Future<void> connect(String peerId) async {
    try {
      await _router.connect(peerId);
      print('Connected to peer via circuit relay: $peerId');
    } catch (e) {
      print('Error connecting to peer via circuit relay: $e');
    }
  }

  /// Disconnects from a peer using a circuit relay.
  Future<void> disconnect(String peerId) async {
    try {
      await _router.disconnect(peerId);
      print('Disconnected from peer via circuit relay: $peerId');
    } catch (e) {
      print('Error disconnecting from peer via circuit relay: $e');
    }
  }

  /// Listens for incoming circuit relay events.
  Stream<CircuitRelayEvent> get onCircuitRelayEvents =>
      _circuitRelayEventsController.stream;

  get connectionEvents => null;

  /// Emits a new circuit relay event.
  void emitCircuitRelayEvent(CircuitRelayEvent event) {
    _circuitRelayEventsController.add(event);
  }
}

/// Represents a circuit relay event.
class CircuitRelayEvent {
  final String type; // Type of the event (e.g., 'connected', 'disconnected')
  final String peerId; // ID of the peer involved in the event

  CircuitRelayEvent(this.type, this.peerId);
}
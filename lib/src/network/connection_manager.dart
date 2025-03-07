import 'package:dart_ipfs/src/core/types/p2p_types.dart';
import 'package:dart_ipfs/src/proto/generated/connection.pb.dart';
import 'package:dart_ipfs/src/proto/generated/google/protobuf/timestamp.pb.dart';
import 'package:dart_ipfs/src/core/metrics/metrics_collector.dart';
import 'package:fixnum/fixnum.dart';

class ConnectionManager {
  final Map<String, ConnectionState> _connections = {};
  final MetricsCollector _metrics;

  ConnectionManager(this._metrics);

  Future<void> handleNewConnection(LibP2PPeerId peerId) async {
    final now = DateTime.now();
    final timestamp = Timestamp()
      ..seconds = Int64(now.millisecondsSinceEpoch ~/ 1000)
      ..nanos = (now.millisecondsSinceEpoch % 1000) * 1000000;

    final state = ConnectionState()
      ..peerId = peerId.toString()
      ..status = ConnectionState_Status.CONNECTED
      ..connectedAt = timestamp
      ..metadata.addAll({
        'client_version': 'ipfs-dart/1.0.0',
        'protocols': ['dht', 'bitswap'].join(','),
      });

    _connections[peerId.toString()] = state;
    await _updateMetrics(peerId.toString());
  }

  Future<void> _updateMetrics(String peerId) async {
    final metrics = ConnectionMetrics()
      ..peerId = peerId
      ..messagesSent = _metrics.getMessagesSent(peerId)
      ..messagesReceived = _metrics.getMessagesReceived(peerId)
      ..bytesSent = _metrics.getBytesSent(peerId)
      ..bytesReceived = _metrics.getBytesReceived(peerId)
      ..averageLatencyMs = _metrics.getAverageLatency(peerId).inMilliseconds;

    await _metrics.updateConnectionMetrics(metrics);
  }
}

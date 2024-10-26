// lib/src/core/data_structures/pin.dart

import 'package:fixnum/fixnum.dart' as fixnum;
import '/../src/proto/dht/pin.pb.dart' as proto; // Import the generated Protobuf file
import 'cid.dart'; // Import CID class for handling CIDs

/// Represents a pin in the IPFS network.
class Pin {
  final CID cid; // The CID of the content to be pinned
  final PinType type; // The type of pin (direct, recursive, etc.)
  final DateTime timestamp; // The timestamp when the pin was created

  Pin({
    required this.cid,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a [Pin] from its Protobuf representation.
  factory Pin.fromProto(proto.Pin pbPin) {
    return Pin(
      cid: CID.fromProto(pbPin.cid),
      type: _pinTypeFromProto(pbPin.type),
      timestamp: DateTime.fromMillisecondsSinceEpoch(pbPin.timestamp.toInt()),
    );
  }

  /// Converts the [Pin] to its Protobuf representation.
  proto.Pin toProto() {
    return proto.Pin()
      ..cid = cid.toProto()
      ..type = _pinTypeToProto(type)
      ..timestamp = fixnum.Int64(timestamp.millisecondsSinceEpoch);
  }

  @override
  String toString() {
    return 'Pin(cid: $cid, type: $type, timestamp: $timestamp)';
  }

  /// Converts a [proto.PinTypeProto] to a [PinType].
  static PinType _pinTypeFromProto(proto.PinTypeProto protoType) {
    switch (protoType) {
      case proto.PinTypeProto.DIRECT:
        return PinType.DIRECT;
      case proto.PinTypeProto.RECURSIVE:
        return PinType.RECURSIVE;
      default:
        throw ArgumentError('Unknown pin type in protobuf: $protoType');
    }
  }

  /// Converts a [PinType] to a [proto.PinTypeProto].
  static proto.PinTypeProto _pinTypeToProto(PinType type) {
    switch (type) {
      case PinType.DIRECT:
        return proto.PinTypeProto.DIRECT;
      case PinType.RECURSIVE:
        return proto.PinTypeProto.RECURSIVE;
      default:
        throw ArgumentError('Unknown pin type: $type');
    }
  }
}

/// Enum representing the different types of pins in IPFS.
enum PinType {
  DIRECT,
  RECURSIVE,
}
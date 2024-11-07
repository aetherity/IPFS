import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';

abstract class BaseProtoMessage extends GeneratedMessage {
  /// Convert message to bytes
  Uint8List toBytes() {
    return writeToBuffer();
  }

  /// Create message from bytes
  static T fromBytes<T extends BaseProtoMessage>(
    Uint8List bytes,
    T Function() factory,
  ) {
    final message = factory();
    message.mergeFromBuffer(bytes);
    return message;
  }

  /// Create a deep copy of the message
  T clone<T extends BaseProtoMessage>() {
    return deepCopy() as T;
  }
}

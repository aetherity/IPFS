import 'dart:typed_data';
import 'package:dart_ipfs/src/proto/generated/core/cid.pb.dart';
import 'package:dart_ipfs/src/utils/encoding.dart';

class CID {
  final IPFSCIDVersion version;
  final List<int> multihash;
  final String codec;
  final String multibasePrefix;

  const CID({
    required this.version,
    required this.multihash,
    required this.codec,
    required this.multibasePrefix,
  });

  IPFSCIDProto toProto() {
    return IPFSCIDProto()
      ..version = version
      ..multihash.addAll(multihash)
      ..codec = codec
      ..multibasePrefix = multibasePrefix;
  }

  static CID fromProto(IPFSCIDProto proto) {
    return CID(
      version: proto.version,
      multihash: proto.multihash,
      codec: proto.codec,
      multibasePrefix: proto.multibasePrefix,
    );
  }

  static CID fromBytes(Uint8List bytes, String codec) {
    // Implementation for converting bytes to CID
    return CID(
      version: IPFSCIDVersion.IPFS_CID_VERSION_1,
      multihash: bytes.toList(),
      codec: codec,
      multibasePrefix: 'base58btc',
    );
  }

  static CID fromContent(String codec, {required Uint8List content}) {
    return CID(
      version: IPFSCIDVersion.IPFS_CID_VERSION_1,
      multihash: content.toList(),
      codec: codec,
      multibasePrefix: 'base58btc',
    );
  }

  String encode() {
    final bytes = BytesBuilder();
    bytes.addByte(_versionToIndex(version));
    bytes.add(multihash);
    return EncodingUtils.toBase58(bytes.toBytes());
  }

  int _versionToIndex(IPFSCIDVersion version) {
    switch (version) {
      case IPFSCIDVersion.IPFS_CID_VERSION_UNSPECIFIED:
        return 0;
      case IPFSCIDVersion.IPFS_CID_VERSION_0:
        return 1;
      case IPFSCIDVersion.IPFS_CID_VERSION_1:
        return 2;
      default:
        throw UnsupportedError('Unsupported CID version: $version');
    }
  }
}
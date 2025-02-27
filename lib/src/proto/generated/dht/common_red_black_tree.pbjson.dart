//
//  Generated code. Do not modify.
//  source: dht/common_red_black_tree.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use nodeColorDescriptor instead')
const NodeColor$json = {
  '1': 'NodeColor',
  '2': [
    {'1': 'RED', '2': 0},
    {'1': 'BLACK', '2': 1},
  ],
};

/// Descriptor for `NodeColor`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nodeColorDescriptor = $convert.base64Decode(
    'CglOb2RlQ29sb3ISBwoDUkVEEAASCQoFQkxBQ0sQAQ==');

@$core.Deprecated('Use rBTreePeerIdDescriptor instead')
const RBTreePeerId$json = {
  '1': 'RBTreePeerId',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `RBTreePeerId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rBTreePeerIdDescriptor = $convert.base64Decode(
    'CgxSQlRyZWVQZWVySWQSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use nodeDescriptor instead')
const Node$json = {
  '1': 'Node',
  '2': [
    {'1': 'peer_id', '3': 1, '4': 1, '5': 11, '6': '.ipfs.dht.common_red_black_tree.RBTreePeerId', '10': 'peerId'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `Node`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDescriptor = $convert.base64Decode(
    'CgROb2RlEkUKB3BlZXJfaWQYASABKAsyLC5pcGZzLmRodC5jb21tb25fcmVkX2JsYWNrX3RyZW'
    'UuUkJUcmVlUGVlcklkUgZwZWVySWQSEgoEZGF0YRgCIAEoDFIEZGF0YQ==');

@$core.Deprecated('Use k_PeerIdDescriptor instead')
const K_PeerId$json = {
  '1': 'K_PeerId',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
  ],
};

/// Descriptor for `K_PeerId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List k_PeerIdDescriptor = $convert.base64Decode(
    'CghLX1BlZXJJZBIOCgJpZBgBIAEoDFICaWQ=');

@$core.Deprecated('Use v_PeerInfoDescriptor instead')
const V_PeerInfo$json = {
  '1': 'V_PeerInfo',
  '2': [
    {'1': 'peer_id', '3': 1, '4': 1, '5': 12, '10': 'peerId'},
    {'1': 'ip_address', '3': 2, '4': 1, '5': 9, '10': 'ipAddress'},
    {'1': 'port', '3': 3, '4': 1, '5': 5, '10': 'port'},
    {'1': 'protocols', '3': 4, '4': 3, '5': 9, '10': 'protocols'},
    {'1': 'latency', '3': 5, '4': 1, '5': 5, '10': 'latency'},
    {'1': 'connection_status', '3': 6, '4': 1, '5': 14, '6': '.ipfs.dht.common_red_black_tree.V_PeerInfo.ConnectionStatus', '10': 'connectionStatus'},
    {'1': 'last_seen', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lastSeen'},
    {'1': 'agent_version', '3': 8, '4': 1, '5': 9, '10': 'agentVersion'},
    {'1': 'public_key', '3': 9, '4': 1, '5': 12, '10': 'publicKey'},
    {'1': 'addresses', '3': 10, '4': 3, '5': 9, '10': 'addresses'},
    {'1': 'observed_addr', '3': 11, '4': 1, '5': 9, '10': 'observedAddr'},
  ],
  '4': [V_PeerInfo_ConnectionStatus$json],
};

@$core.Deprecated('Use v_PeerInfoDescriptor instead')
const V_PeerInfo_ConnectionStatus$json = {
  '1': 'ConnectionStatus',
  '2': [
    {'1': 'DISCONNECTED', '2': 0},
    {'1': 'CONNECTING', '2': 1},
    {'1': 'CONNECTED', '2': 2},
  ],
};

/// Descriptor for `V_PeerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List v_PeerInfoDescriptor = $convert.base64Decode(
    'CgpWX1BlZXJJbmZvEhcKB3BlZXJfaWQYASABKAxSBnBlZXJJZBIdCgppcF9hZGRyZXNzGAIgAS'
    'gJUglpcEFkZHJlc3MSEgoEcG9ydBgDIAEoBVIEcG9ydBIcCglwcm90b2NvbHMYBCADKAlSCXBy'
    'b3RvY29scxIYCgdsYXRlbmN5GAUgASgFUgdsYXRlbmN5EmgKEWNvbm5lY3Rpb25fc3RhdHVzGA'
    'YgASgOMjsuaXBmcy5kaHQuY29tbW9uX3JlZF9ibGFja190cmVlLlZfUGVlckluZm8uQ29ubmVj'
    'dGlvblN0YXR1c1IQY29ubmVjdGlvblN0YXR1cxI3CglsYXN0X3NlZW4YByABKAsyGi5nb29nbG'
    'UucHJvdG9idWYuVGltZXN0YW1wUghsYXN0U2VlbhIjCg1hZ2VudF92ZXJzaW9uGAggASgJUgxh'
    'Z2VudFZlcnNpb24SHQoKcHVibGljX2tleRgJIAEoDFIJcHVibGljS2V5EhwKCWFkZHJlc3Nlcx'
    'gKIAMoCVIJYWRkcmVzc2VzEiMKDW9ic2VydmVkX2FkZHIYCyABKAlSDG9ic2VydmVkQWRkciJD'
    'ChBDb25uZWN0aW9uU3RhdHVzEhAKDERJU0NPTk5FQ1RFRBAAEg4KCkNPTk5FQ1RJTkcQARINCg'
    'lDT05ORUNURUQQAg==');


//
//  Generated code. Do not modify.
//  source: routing_table.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use routingTableDescriptor instead')
const RoutingTable$json = {
  '1': 'RoutingTable',
  '2': [
    {'1': 'entries', '3': 1, '4': 3, '5': 11, '6': '.ipfs.dht.routing_table.RoutingTable.EntriesEntry', '10': 'entries'},
  ],
  '3': [RoutingTable_EntriesEntry$json],
};

@$core.Deprecated('Use routingTableDescriptor instead')
const RoutingTable_EntriesEntry$json = {
  '1': 'EntriesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.ipfs.dht.kademlia_tree.KademliaNode', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `RoutingTable`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routingTableDescriptor = $convert.base64Decode(
    'CgxSb3V0aW5nVGFibGUSSwoHZW50cmllcxgBIAMoCzIxLmlwZnMuZGh0LnJvdXRpbmdfdGFibG'
    'UuUm91dGluZ1RhYmxlLkVudHJpZXNFbnRyeVIHZW50cmllcxpgCgxFbnRyaWVzRW50cnkSEAoD'
    'a2V5GAEgASgJUgNrZXkSOgoFdmFsdWUYAiABKAsyJC5pcGZzLmRodC5rYWRlbWxpYV90cmVlLk'
    'thZGVtbGlhTm9kZVIFdmFsdWU6AjgB');


//
//  Generated code. Do not modify.
//  source: core/operation_log.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use operationLogEntryProtoDescriptor instead')
const OperationLogEntryProto$json = {
  '1': 'OperationLogEntryProto',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'operation', '3': 2, '4': 1, '5': 9, '10': 'operation'},
    {'1': 'details', '3': 3, '4': 1, '5': 9, '10': 'details'},
    {'1': 'cid', '3': 4, '4': 1, '5': 11, '6': '.ipfs.core.data_structures.CIDProto', '10': 'cid'},
    {'1': 'node_type', '3': 5, '4': 1, '5': 14, '6': '.ipfs.core.data_structures.NodeTypeProto', '10': 'nodeType'},
  ],
};

/// Descriptor for `OperationLogEntryProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationLogEntryProtoDescriptor = $convert.base64Decode(
    'ChZPcGVyYXRpb25Mb2dFbnRyeVByb3RvEhwKCXRpbWVzdGFtcBgBIAEoA1IJdGltZXN0YW1wEh'
    'wKCW9wZXJhdGlvbhgCIAEoCVIJb3BlcmF0aW9uEhgKB2RldGFpbHMYAyABKAlSB2RldGFpbHMS'
    'NQoDY2lkGAQgASgLMiMuaXBmcy5jb3JlLmRhdGFfc3RydWN0dXJlcy5DSURQcm90b1IDY2lkEk'
    'UKCW5vZGVfdHlwZRgFIAEoDjIoLmlwZnMuY29yZS5kYXRhX3N0cnVjdHVyZXMuTm9kZVR5cGVQ'
    'cm90b1IIbm9kZVR5cGU=');

@$core.Deprecated('Use operationLogProtoDescriptor instead')
const OperationLogProto$json = {
  '1': 'OperationLogProto',
  '2': [
    {'1': 'entries', '3': 1, '4': 3, '5': 11, '6': '.ipfs.core.data_structures.OperationLogEntryProto', '10': 'entries'},
  ],
};

/// Descriptor for `OperationLogProto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationLogProtoDescriptor = $convert.base64Decode(
    'ChFPcGVyYXRpb25Mb2dQcm90bxJLCgdlbnRyaWVzGAEgAygLMjEuaXBmcy5jb3JlLmRhdGFfc3'
    'RydWN0dXJlcy5PcGVyYXRpb25Mb2dFbnRyeVByb3RvUgdlbnRyaWVz');


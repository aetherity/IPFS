//
//  Generated code. Do not modify.
//  source: core/block.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'cid.pb.dart' as $0;

class BlockProto extends $pb.GeneratedMessage {
  factory BlockProto({
    $core.List<$core.int>? data,
    $0.IPFSCIDProto? cid,
    $core.String? format,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (cid != null) {
      $result.cid = cid;
    }
    if (format != null) {
      $result.format = format;
    }
    return $result;
  }
  BlockProto._() : super();
  factory BlockProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'ipfs.core.data_structures'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOM<$0.IPFSCIDProto>(2, _omitFieldNames ? '' : 'cid', subBuilder: $0.IPFSCIDProto.create)
    ..aOS(3, _omitFieldNames ? '' : 'format')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockProto clone() => BlockProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockProto copyWith(void Function(BlockProto) updates) => super.copyWith((message) => updates(message as BlockProto)) as BlockProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockProto create() => BlockProto._();
  BlockProto createEmptyInstance() => create();
  static $pb.PbList<BlockProto> createRepeated() => $pb.PbList<BlockProto>();
  @$core.pragma('dart2js:noInline')
  static BlockProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockProto>(create);
  static BlockProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  @$pb.TagNumber(2)
  $0.IPFSCIDProto get cid => $_getN(1);
  @$pb.TagNumber(2)
  set cid($0.IPFSCIDProto v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCid() => $_has(1);
  @$pb.TagNumber(2)
  void clearCid() => clearField(2);
  @$pb.TagNumber(2)
  $0.IPFSCIDProto ensureCid() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get format => $_getSZ(2);
  @$pb.TagNumber(3)
  set format($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

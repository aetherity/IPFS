//
//  Generated code. Do not modify.
//  source: dht/ipfs_node_network_events.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NodeErrorEvent_ErrorType extends $pb.ProtobufEnum {
  static const NodeErrorEvent_ErrorType UNKNOWN = NodeErrorEvent_ErrorType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const NodeErrorEvent_ErrorType INVALID_REQUEST = NodeErrorEvent_ErrorType._(1, _omitEnumNames ? '' : 'INVALID_REQUEST');
  static const NodeErrorEvent_ErrorType NOT_FOUND = NodeErrorEvent_ErrorType._(2, _omitEnumNames ? '' : 'NOT_FOUND');
  static const NodeErrorEvent_ErrorType METHOD_NOT_FOUND = NodeErrorEvent_ErrorType._(3, _omitEnumNames ? '' : 'METHOD_NOT_FOUND');
  static const NodeErrorEvent_ErrorType INTERNAL_ERROR = NodeErrorEvent_ErrorType._(4, _omitEnumNames ? '' : 'INTERNAL_ERROR');
  static const NodeErrorEvent_ErrorType NETWORK = NodeErrorEvent_ErrorType._(5, _omitEnumNames ? '' : 'NETWORK');
  static const NodeErrorEvent_ErrorType PROTOCOL = NodeErrorEvent_ErrorType._(6, _omitEnumNames ? '' : 'PROTOCOL');
  static const NodeErrorEvent_ErrorType SECURITY = NodeErrorEvent_ErrorType._(7, _omitEnumNames ? '' : 'SECURITY');
  static const NodeErrorEvent_ErrorType DATASTORE = NodeErrorEvent_ErrorType._(8, _omitEnumNames ? '' : 'DATASTORE');

  static const $core.List<NodeErrorEvent_ErrorType> values = <NodeErrorEvent_ErrorType> [
    UNKNOWN,
    INVALID_REQUEST,
    NOT_FOUND,
    METHOD_NOT_FOUND,
    INTERNAL_ERROR,
    NETWORK,
    PROTOCOL,
    SECURITY,
    DATASTORE,
  ];

  static final $core.Map<$core.int, NodeErrorEvent_ErrorType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static NodeErrorEvent_ErrorType? valueOf($core.int value) => _byValue[value];

  const NodeErrorEvent_ErrorType._($core.int v, $core.String n) : super(v, n);
}

class NetworkStatusChangedEvent_ChangeType extends $pb.ProtobufEnum {
  static const NetworkStatusChangedEvent_ChangeType UNKNOWN = NetworkStatusChangedEvent_ChangeType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const NetworkStatusChangedEvent_ChangeType ONLINE = NetworkStatusChangedEvent_ChangeType._(1, _omitEnumNames ? '' : 'ONLINE');
  static const NetworkStatusChangedEvent_ChangeType OFFLINE = NetworkStatusChangedEvent_ChangeType._(2, _omitEnumNames ? '' : 'OFFLINE');
  static const NetworkStatusChangedEvent_ChangeType CONNECTIVITY_CHANGED = NetworkStatusChangedEvent_ChangeType._(3, _omitEnumNames ? '' : 'CONNECTIVITY_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType SWARM_PEER_JOINED = NetworkStatusChangedEvent_ChangeType._(4, _omitEnumNames ? '' : 'SWARM_PEER_JOINED');
  static const NetworkStatusChangedEvent_ChangeType SWARM_PEER_LEFT = NetworkStatusChangedEvent_ChangeType._(5, _omitEnumNames ? '' : 'SWARM_PEER_LEFT');
  static const NetworkStatusChangedEvent_ChangeType NODE_STARTED = NetworkStatusChangedEvent_ChangeType._(6, _omitEnumNames ? '' : 'NODE_STARTED');
  static const NetworkStatusChangedEvent_ChangeType NODE_STOPPED = NetworkStatusChangedEvent_ChangeType._(7, _omitEnumNames ? '' : 'NODE_STOPPED');
  static const NetworkStatusChangedEvent_ChangeType INTERFACE_ADDED = NetworkStatusChangedEvent_ChangeType._(8, _omitEnumNames ? '' : 'INTERFACE_ADDED');
  static const NetworkStatusChangedEvent_ChangeType INTERFACE_REMOVED = NetworkStatusChangedEvent_ChangeType._(9, _omitEnumNames ? '' : 'INTERFACE_REMOVED');
  static const NetworkStatusChangedEvent_ChangeType INTERFACE_UP = NetworkStatusChangedEvent_ChangeType._(10, _omitEnumNames ? '' : 'INTERFACE_UP');
  static const NetworkStatusChangedEvent_ChangeType INTERFACE_DOWN = NetworkStatusChangedEvent_ChangeType._(11, _omitEnumNames ? '' : 'INTERFACE_DOWN');
  static const NetworkStatusChangedEvent_ChangeType IP_ADDRESS_CHANGED = NetworkStatusChangedEvent_ChangeType._(12, _omitEnumNames ? '' : 'IP_ADDRESS_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType IP_ADDRESS_ADDED = NetworkStatusChangedEvent_ChangeType._(13, _omitEnumNames ? '' : 'IP_ADDRESS_ADDED');
  static const NetworkStatusChangedEvent_ChangeType IP_ADDRESS_REMOVED = NetworkStatusChangedEvent_ChangeType._(14, _omitEnumNames ? '' : 'IP_ADDRESS_REMOVED');
  static const NetworkStatusChangedEvent_ChangeType GATEWAY_CHANGED = NetworkStatusChangedEvent_ChangeType._(15, _omitEnumNames ? '' : 'GATEWAY_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType GATEWAY_REACHABLE = NetworkStatusChangedEvent_ChangeType._(16, _omitEnumNames ? '' : 'GATEWAY_REACHABLE');
  static const NetworkStatusChangedEvent_ChangeType GATEWAY_UNREACHABLE = NetworkStatusChangedEvent_ChangeType._(17, _omitEnumNames ? '' : 'GATEWAY_UNREACHABLE');
  static const NetworkStatusChangedEvent_ChangeType FIREWALL_CHANGED = NetworkStatusChangedEvent_ChangeType._(18, _omitEnumNames ? '' : 'FIREWALL_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType FIREWALL_BLOCKING = NetworkStatusChangedEvent_ChangeType._(19, _omitEnumNames ? '' : 'FIREWALL_BLOCKING');
  static const NetworkStatusChangedEvent_ChangeType FIREWALL_ALLOWING = NetworkStatusChangedEvent_ChangeType._(20, _omitEnumNames ? '' : 'FIREWALL_ALLOWING');
  static const NetworkStatusChangedEvent_ChangeType NAT_TYPE_CHANGED = NetworkStatusChangedEvent_ChangeType._(21, _omitEnumNames ? '' : 'NAT_TYPE_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType NAT_PORT_MAPPING_CHANGED = NetworkStatusChangedEvent_ChangeType._(22, _omitEnumNames ? '' : 'NAT_PORT_MAPPING_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType DNS_RESOLVED = NetworkStatusChangedEvent_ChangeType._(23, _omitEnumNames ? '' : 'DNS_RESOLVED');
  static const NetworkStatusChangedEvent_ChangeType DNS_FAILED = NetworkStatusChangedEvent_ChangeType._(24, _omitEnumNames ? '' : 'DNS_FAILED');
  static const NetworkStatusChangedEvent_ChangeType EXTERNAL_ADDRESS_CHANGED = NetworkStatusChangedEvent_ChangeType._(25, _omitEnumNames ? '' : 'EXTERNAL_ADDRESS_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType BANDWIDTH_CHANGED = NetworkStatusChangedEvent_ChangeType._(26, _omitEnumNames ? '' : 'BANDWIDTH_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType ROUTING_CHANGED = NetworkStatusChangedEvent_ChangeType._(27, _omitEnumNames ? '' : 'ROUTING_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType CONTENT_ROUTING_CHANGED = NetworkStatusChangedEvent_ChangeType._(28, _omitEnumNames ? '' : 'CONTENT_ROUTING_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType PEER_ROUTING_CHANGED = NetworkStatusChangedEvent_ChangeType._(29, _omitEnumNames ? '' : 'PEER_ROUTING_CHANGED');
  static const NetworkStatusChangedEvent_ChangeType CONNECTION_UPGRADED = NetworkStatusChangedEvent_ChangeType._(30, _omitEnumNames ? '' : 'CONNECTION_UPGRADED');
  static const NetworkStatusChangedEvent_ChangeType CONNECTION_PRUNED = NetworkStatusChangedEvent_ChangeType._(31, _omitEnumNames ? '' : 'CONNECTION_PRUNED');
  static const NetworkStatusChangedEvent_ChangeType PROTOCOL_AVAILABLE = NetworkStatusChangedEvent_ChangeType._(32, _omitEnumNames ? '' : 'PROTOCOL_AVAILABLE');
  static const NetworkStatusChangedEvent_ChangeType PROTOCOL_UNAVAILABLE = NetworkStatusChangedEvent_ChangeType._(33, _omitEnumNames ? '' : 'PROTOCOL_UNAVAILABLE');

  static const $core.List<NetworkStatusChangedEvent_ChangeType> values = <NetworkStatusChangedEvent_ChangeType> [
    UNKNOWN,
    ONLINE,
    OFFLINE,
    CONNECTIVITY_CHANGED,
    SWARM_PEER_JOINED,
    SWARM_PEER_LEFT,
    NODE_STARTED,
    NODE_STOPPED,
    INTERFACE_ADDED,
    INTERFACE_REMOVED,
    INTERFACE_UP,
    INTERFACE_DOWN,
    IP_ADDRESS_CHANGED,
    IP_ADDRESS_ADDED,
    IP_ADDRESS_REMOVED,
    GATEWAY_CHANGED,
    GATEWAY_REACHABLE,
    GATEWAY_UNREACHABLE,
    FIREWALL_CHANGED,
    FIREWALL_BLOCKING,
    FIREWALL_ALLOWING,
    NAT_TYPE_CHANGED,
    NAT_PORT_MAPPING_CHANGED,
    DNS_RESOLVED,
    DNS_FAILED,
    EXTERNAL_ADDRESS_CHANGED,
    BANDWIDTH_CHANGED,
    ROUTING_CHANGED,
    CONTENT_ROUTING_CHANGED,
    PEER_ROUTING_CHANGED,
    CONNECTION_UPGRADED,
    CONNECTION_PRUNED,
    PROTOCOL_AVAILABLE,
    PROTOCOL_UNAVAILABLE,
  ];

  static final $core.Map<$core.int, NetworkStatusChangedEvent_ChangeType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static NetworkStatusChangedEvent_ChangeType? valueOf($core.int value) => _byValue[value];

  const NetworkStatusChangedEvent_ChangeType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

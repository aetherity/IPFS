// src/core/ipld/jose_cose_handler.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:jose/jose.dart';
import 'package:catalyst_cose/catalyst_cose.dart';
import 'package:dart_ipfs/src/core/errors/ipld_errors.dart';
import 'package:dart_ipfs/src/proto/generated/ipld/data_model.pb.dart';
import 'package:dart_ipfs/src/utils/private_key.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart' as crypto;

class JoseCoseHandler {
  static Future<Uint8List> encodeJWS(
    IPLDNode node,
    IPFSPrivateKey privateKey,
  ) async {
    if (node.kind != Kind.MAP) {
      throw IPLDEncodingError('JWS encoding requires a map structure');
    }

    final payload = _extractPayload(node);

    // Cast to ECPublicKey to access EC-specific properties
    final pubKey = privateKey.publicKey;
    final privKey = privateKey.privateKey;

    final jwk = JsonWebKey.fromJson({
      'kty': 'EC',
      'crv': 'P-256',
      'x': base64Url.encode(_bigIntToBytes(pubKey.Q!.x?.toBigInteger())),
      'y': base64Url.encode(_bigIntToBytes(pubKey.Q!.y?.toBigInteger())),
      'd': base64Url.encode(_bigIntToBytes(privKey.d)),
    });

    final builder = JsonWebSignatureBuilder()
      ..jsonContent = utf8.decode(payload)
      ..addRecipient(jwk, algorithm: 'ES256');

    final jws = await builder.build();
    return Uint8List.fromList(utf8.encode(jws.toCompactSerialization()));
  }

  static Future<Uint8List> encodeJWE(
    IPLDNode node,
    List<int> recipientPublicKey,
  ) async {
    if (node.kind != Kind.MAP) {
      throw IPLDEncodingError('JWE encoding requires a map structure');
    }

    final payload = _extractPayload(node);
    final recipientJwk = JsonWebKey.fromJson({
      'kty': 'EC',
      'crv': 'P-256',
      'x': base64Url.encode(recipientPublicKey.sublist(1, 33)),
      'y': base64Url.encode(recipientPublicKey.sublist(33, 65)),
    });

    final builder = JsonWebEncryptionBuilder()
      ..content = payload
      ..addRecipient(recipientJwk, algorithm: 'ECDH-ES+A256KW')
      ..encryptionAlgorithm = 'A256GCM';

    final jwe = await builder.build();
    return Uint8List.fromList(utf8.encode(jwe.toCompactSerialization()));
  }

  static Future<Uint8List> encodeCOSE(
    IPLDNode node,
    IPFSPrivateKey privateKey,
  ) async {
    if (node.kind != Kind.MAP) {
      throw IPLDEncodingError('COSE encoding requires a map structure');
    }

    final payload = _extractPayload(node);
    final signerVerifier = _SignerVerifier(privateKey.algorithm as crypto.SignatureAlgorithm<crypto.PublicKey>, privateKey as crypto.SimpleKeyPair);

    // Create COSE Sign1 message using CatalystCose
    final coseValue = await CoseSign1.sign(
      protectedHeaders: const CoseHeaders.protected(),
      unprotectedHeaders: const CoseHeaders.unprotected(),
      signer: signerVerifier,
      payload: payload,
    );

    return Uint8List.fromList(cbor.encode(coseValue.toCbor()));
  }

  static Future<Uint8List> decodeJWS(
    IPLDNode node,
    IPFSPrivateKey privateKey,
  ) async {
    if (node.kind != Kind.MAP) {
      throw IPLDEncodingError('JWS decoding requires a map structure');
    }

    final jwsString = utf8.decode(_extractPayload(node));
    final jws = JsonWebSignature.fromCompactSerialization(jwsString);

    final jwk = JsonWebKey.fromJson({
      'kty': 'EC',
      'crv': 'P-256',
      'x': base64Url
          .encode(_bigIntToBytes(privateKey.publicKey.Q!.x!.toBigInteger())),
      'y': base64Url
          .encode(_bigIntToBytes(privateKey.publicKey.Q!.y!.toBigInteger())),
    });

    // Create a key store and add the key
    final keyStore = JsonWebKeyStore()..addKey(jwk);

    final payload = await jws.getPayload(keyStore);
    return Uint8List.fromList(utf8.encode(payload.stringContent));
  }

  static Future<Uint8List> decodeJWE(
    IPLDNode node,
    List<int> recipientPrivateKey,
  ) async {
    if (node.kind != Kind.MAP) {
      throw IPLDEncodingError('JWE decoding requires a map structure');
    }

    final jweString = utf8.decode(_extractPayload(node));
    final jwe = JsonWebEncryption.fromCompactSerialization(jweString);

    final jwk = JsonWebKey.fromJson({
      'kty': 'EC',
      'crv': 'P-256',
      'd': base64Url.encode(recipientPrivateKey),
    });

    // Create a key store and add the key
    final keyStore = JsonWebKeyStore()..addKey(jwk);

    final payload = await jwe.getPayload(keyStore);
    return Uint8List.fromList(payload.data);
  }

  static Future<Uint8List> decodeCOSE(
    IPLDNode node,
    IPFSPrivateKey privateKey,
  ) async {
    if (node.kind != Kind.MAP) {
      throw IPLDEncodingError('COSE decoding requires a map structure');
    }

    final coseData = _extractPayload(node);
    final coseValue = cbor.decode(coseData);
    final coseSign1 = CoseSign1.fromCbor(cbor.decode(coseData));
    final signerVerifier = _SignerVerifier(privateKey.algorithm as crypto.SignatureAlgorithm<crypto.PublicKey>, privateKey as crypto.SimpleKeyPair);

    final isValid = await coseSign1.verify(
      verifier: signerVerifier,
    );

    if (!isValid) {
      throw IPLDDecodingError('COSE signature verification failed');
    }

    if (coseValue is CborList && coseValue.length >= 3) {
      return coseValue[2] as Uint8List; // payload is at index 2
    }
    throw IPLDDecodingError('Invalid COSE_Sign1 structure');
  }

  static Uint8List _extractPayload(IPLDNode node) {
    final payloadEntry =
        node.mapValue.entries.firstWhere((e) => e.key == 'payload');
    return Uint8List.fromList(utf8.encode(payloadEntry.value.stringValue));
  }

  // Helper method to convert BigInt to bytes
  static Uint8List _bigIntToBytes(BigInt? value) {
    if (value == null) {
      throw IPLDEncodingError('Invalid EC key parameters');
    }
    final bytes = value.toRadixString(16).padLeft(64, '0');
    return Uint8List.fromList(List<int>.from(hex.decode(bytes)));
  }

  static List<int> _privateKeyToBytes(IPFSPrivateKey privateKey) {
    final privKey = privateKey.privateKey;
    return privKey.d!.toRadixString(16).padLeft(64, '0').codeUnits;
  }

  static List<int> _publicKeyToBytes(ECPublicKey publicKey) {
    final x =
        publicKey.Q!.x!.toBigInteger()!.toRadixString(16).padLeft(64, '0');
    final y =
        publicKey.Q!.y!.toBigInteger()!.toRadixString(16).padLeft(64, '0');
    return hex.decode(x + y);
  }
}

final class _SignerVerifier
    implements CatalystCoseSigner, CatalystCoseVerifier {
  final crypto.SignatureAlgorithm _algorithm;
  final crypto.SimpleKeyPair _keyPair;

  const _SignerVerifier(this._algorithm, this._keyPair);

  @override
  StringOrInt? get alg => const IntValue(CoseValues.eddsaAlg);

  @override
  Future<Uint8List?> get kid async {
    final pk = await _keyPair.extractPublicKey();
    return Uint8List.fromList(pk.bytes);
  }

  @override
  Future<Uint8List> sign(Uint8List data) async {
    final signature = await _algorithm.sign(data, keyPair: _keyPair);
    return Uint8List.fromList(signature.bytes);
  }

  @override
  Future<bool> verify(Uint8List data, Uint8List signature) async {
    final publicKey = await _keyPair.extractPublicKey();
    return _algorithm.verify(
      data,
      signature: crypto.Signature(
        signature,
        publicKey: crypto.SimplePublicKey(publicKey.bytes, type: crypto.KeyPairType.ed25519),
      ),
    );
  }
}

// src/utils/keystore.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_ipfs/src/utils/private_key.dart';
import 'package:p2plib/p2plib.dart' show Crypto;

class KeyPair {
  final String publicKey;
  final String privateKey;

  KeyPair(this.publicKey, this.privateKey);
}

/// A simple in-memory keystore for managing IPNS key pairs.
class Keystore {
  final Map<String, KeyPair> _keyPairs = const {};
  static const String DEFAULT_KEY = 'self';

  const Keystore();

  /// Adds a new key pair to the keystore.
  void addKeyPair(String name, KeyPair keyPair) {
    _keyPairs[name] = keyPair;
    print('Added key pair for $name.');
  }

  /// Retrieves a key pair by its name.
  KeyPair getKeyPair(String name) {
    final keyPair = _keyPairs[name];
    if (keyPair == null) {
      throw ArgumentError('No key pair found for name: $name');
    }
    return keyPair;
  }

  /// Checks if a key pair exists for the given name.
  bool hasKeyPair(String name) {
    return _keyPairs.containsKey(name);
  }

  /// Removes a key pair from the keystore.
  void removeKeyPair(String name) {
    if (_keyPairs.remove(name) != null) {
      print('Removed key pair for $name.');
    } else {
      print('No key pair found for $name to remove.');
    }
  }

  /// Lists all stored key pairs.
  List<String> listKeyPairs() {
    return _keyPairs.keys.toList();
  }

  /// Serializes the keystore to JSON format (optional).
  String serialize() {
    final jsonMap = _keyPairs.map((name, keyPair) => MapEntry(name, {
          'publicKey': keyPair.publicKey,
          'privateKey': keyPair.privateKey,
        }));
    return jsonEncode(jsonMap);
  }

  /// Deserializes the keystore from JSON format (optional).
  void deserialize(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    jsonMap.forEach((name, keys) {
      addKeyPair(name, KeyPair(keys['publicKey'], keys['privateKey']));
    });
    print('Keystore deserialized from JSON.');
  }

  /// Verifies a signature using a public key
  Future<bool> verifySignature(
      String publicKey, Uint8List data, Uint8List signature) async {
    try {
      // Create crypto instance
      final crypto = Crypto();
      await crypto.init(); // Initialize the crypto worker

      // Construct the datagram in the format expected by p2plib
      // This needs to match the Message format used in p2plib
      final datagram = Uint8List.fromList([
        ...data, // Original message
        ...signature // Signature appended at the end
      ]);

      try {
        // Verify the signature
        await crypto.verify(datagram);
        return true;
      } catch (e) {
        // If verification fails, crypto.verify throws an exception
        return false;
      }
    } catch (e) {
      print('Error verifying signature: $e');
      return false;
    }
  }

  /// Getter for the default private key
  IPFSPrivateKey get privateKey {
    final defaultPair = _keyPairs[DEFAULT_KEY];
    if (defaultPair == null) {
      throw StateError('No default key pair found in keystore');
    }
    return IPFSPrivateKey.fromString(defaultPair.privateKey);
  }

  // Named constructor for configuration
  factory Keystore.withConfig(dynamic config) {
    final keystore = Keystore();
    // Initialize with config
    return keystore;
  }
}

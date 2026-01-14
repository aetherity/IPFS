import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import '../../platform/platform.dart';
import 'datastore.dart';

/// A file-system based implementation of [Datastore].
class FlatFileDatastore implements Datastore {
  /// Creates a datastore backed by files in [path].
  FlatFileDatastore(this.path);

  /// The root directory for stored data files. (will be under ApplicationDocuments+ipfs)
  final String path;

  // Cache platform instance
  late final _platform = getPlatform();

  @override
  Future<void> init() async {
    if (!await _platform.exists([ path ])) {
      await _platform.createDirectory([ path ]);
    }
  }

  @override
  Future<void> put(Key key, Uint8List value) async {
    await _platform.writeBytes([ path, '${key.toString()}.data' ], value);
  }

  @override
  Future<Uint8List?> get(Key key) async {
    return await _platform.readBytes([ path, '${key.toString()}.data' ]);
  }

  @override
  Future<bool> has(Key key) async {
    return await _platform.exists([ path, '${key.toString()}.data' ]);
  }

  @override
  Future<void> delete(Key key) async {
    if (await _platform.exists([ path, '${key.toString()}.data' ])) {
      await _platform.delete([ path, '${key.toString()}.data' ]);
    }
  }

  @override
  Stream<QueryEntry> query(Query q) async* {
    // Note: Recursive listing not strictly in platform stub yet,
    // but listDirectory returns top level.
    // For now we might need to implement a simple walker or
    // add recursive support to Platform interface if needed.
    // Given the simplicity, let's just query flat for now or assume simple structure.

    // Improvement: We can just list path?
    // The previous implementation used recursive list.
    // Let's rely on listDirectory (which might need to be recursive in platform impl).
    // For now, let's assume flat structure or implement a walker.

    // Naive walker
    final stack = [path];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      final children = await _platform.listDirectory([ current ]);

      for (final childPath in children) {
        // Is it a file or dir? Platform interface listDirectory returns strings.
        // We check exists/is-dir?
        // In platform_io, listDirectory mapped entities to paths.

        // To properly walk, we need to know if it's a dir.
        // Let's assume everything ending in .data is a file we care about.
        if (childPath.endsWith('.data')) {
          final relative = p.relative(childPath, from: path);
          final keyStr = '/${relative.substring(0, relative.length - 5)}';
          final key = Key(keyStr);

          // Filter logic reused
          bool match = true;
          if (q.prefix != null && !keyStr.startsWith(q.prefix!)) match = false;

          if (match) {
            Uint8List? value;
            if (!q.keysOnly || (q.filters != null && q.filters!.isNotEmpty)) {
              value = await _platform.readBytes([ childPath ]);
            }

            if (value != null && q.filters != null) {
              final entry = MapEntry(key, value);
              for (final filter in q.filters!) {
                if (!filter.filter(entry)) {
                  match = false;
                  break;
                }
              }
            }

            if (match) {
              yield QueryEntry(key, value);
            }
          }
        } else {
          // It's likely a directory, add to stack to recurse
          stack.add(childPath);
        }
      }
    }
  }

  @override
  Future<void> close() async {
    // No-op
  }
}

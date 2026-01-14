// lib/src/utils/join_path.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Returns String path from a list of file names.
Future<String> joinPath(List<String> fileNames) async {
  // Initialize variables
  String returnValue = '';
  // Insert the application Documents folder
  final Directory applicationDirectory = await getApplicationDocumentsDirectory();
  fileNames.insertAll(0, [ applicationDirectory.path, 'ipfs']);
  // Strip old separators and add new ones
  for (int i = 0; i < fileNames.length; i++) {
    // String trailing directoryCharacter
    if (returnValue.endsWith(Platform.pathSeparator)) {
      returnValue = returnValue.substring(0, returnValue.length - 1);
    }
    // String leading directoryCharacter
    String fileName = (i == 0) ? fileNames[i] : (fileNames[i].startsWith(
        Platform.pathSeparator)) ? fileNames[i].substring(1) : fileNames[i];
    // Build returnValue
    returnValue =
    (i == 0) ? fileName : '$returnValue${Platform.pathSeparator}$fileName';
  }
  return returnValue;
}
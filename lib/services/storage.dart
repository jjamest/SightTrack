// import 'dart:io';

// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:sighttrack/logging.dart';

// class StorageRepository {
//   Future<void> uploadFile(File file) async {
//     try {
//       final fileName = DateTime.now().toIso8601String();
//       final result = await Amplify.Storage.uploadFile(
//               localFile: AWSFile.fromPath(file.path),
//               path: StoragePath.fromString('$fileName.jpg'))
//           .result;
//       Log.i('Uploaded file: ${result.uploadedItem.path}');
//     } on StorageException catch (e) {
//       Log.e("In StorageRepository, error uploading file: $e");
//     }
//   }
// }

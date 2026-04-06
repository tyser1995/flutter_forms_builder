import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

typedef PickedImage = ({Uint8List bytes, String name});

Future<PickedImage?> pickImage() async {
  final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
  if (result == null || result.files.single.bytes == null) return null;
  return (bytes: result.files.single.bytes!, name: result.files.single.name);
}

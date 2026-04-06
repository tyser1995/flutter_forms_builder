import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

typedef PickedImage = ({Uint8List bytes, String name});

Future<PickedImage?> pickImage() {
  final completer = Completer<PickedImage?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';

  input.onChange.listen((e) {
    final file = input.files?.first;
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is List<int>) {
        completer.complete((bytes: Uint8List.fromList(result), name: file.name));
      } else {
        completer.complete(null);
      }
    });
  });

  // Complete with null if the user dismisses the dialog without picking
  html.window.addEventListener('focus', (_) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!completer.isCompleted) completer.complete(null);
    });
  }, true);

  input.click();
  return completer.future;
}

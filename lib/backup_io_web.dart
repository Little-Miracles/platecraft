// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

/// Downloads [text] as a file, like any "Save as" in the browser.
Future<void> downloadText(String fileName, String text) async {
  final blob = html.Blob([text], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}

/// Opens the file picker and returns the chosen file's text (null: cancelled).
Future<String?> pickTextFile() {
  final done = Completer<String?>();
  final input = html.FileUploadInputElement()
    ..accept = '.json,application/json';
  input.onChange.listen((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) return done.complete(null);
    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) => done.complete(reader.result as String?));
    reader.onError.listen((_) => done.complete(null));
    reader.readAsText(file);
  });
  input.click();
  return done.future;
}

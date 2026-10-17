/// Not in a browser (tests): there is no download or file picker.
Future<void> downloadText(String fileName, String text) async =>
    throw UnsupportedError('Backups are saved from the browser');

Future<String?> pickTextFile() async => null;

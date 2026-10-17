/// Saving and opening the backup file. In the browser it is a real download
/// and a file picker; elsewhere (tests) a stub.
export 'backup_io_stub.dart' if (dart.library.html) 'backup_io_web.dart';

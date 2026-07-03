import 'dart:typed_data';

export 'pdf_downloader_stub.dart'
    if (dart.library.html) 'pdf_downloader_web.dart';

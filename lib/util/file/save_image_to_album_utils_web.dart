import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

class SaveImageToAlbumOfPlatformWeb {
  SaveImageToAlbumOfPlatformWeb._();

  static Future<bool> saveBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!kIsWeb) return false;

    try {
      final blob = Blob([bytes.toJS].toJS);
      final url = URL.createObjectURL(blob);
      final anchor = HTMLAnchorElement()
        ..href = url
        ..download = fileName
        ..style.display = 'none';
      document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
      URL.revokeObjectURL(url);
      return true;
    } catch (_) {
      return false;
    }
  }
}

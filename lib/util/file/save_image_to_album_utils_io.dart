import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SaveImageToAlbumUtilsIo {
  SaveImageToAlbumUtilsIo._();

  static Future<bool> saveBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (kIsWeb) return false;

    final ok = await _ensureAlbumPermission();
    if (!ok) return false;

    try {
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: fileName,
      );
      final isSuccess = result['isSuccess'];
      return isSuccess == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _ensureAlbumPermission() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isIOS) {
        // iOS 14+ 推荐 photosAddOnly；老系统会自动回落
        final status = await Permission.photosAddOnly.request();
        return status.isGranted;
      }
    } catch (e) {
      Log.e(e);
    }

    // Android 使用 MediaStore 写入（Android 10+ 无需存储权限）；这里不强制申请，交由原生侧兜底。
    return true;
  }
}


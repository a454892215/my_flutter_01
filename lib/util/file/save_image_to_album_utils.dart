import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/util/file/save_image_to_album_utils_io.dart';
import 'package:flutter_comm/util/file/save_image_to_album_utils_web.dart';
import 'package:flutter_comm/widget/toast_util.dart';


class SaveImageToAlbumUtils {
  SaveImageToAlbumUtils._();

  /// 保存图片字节到本地。
  ///
  /// - Android/iOS：保存到系统相册（`image_gallery_saver_plus`）
  /// - Web：触发浏览器下载到本地（Downloads）
  static Future<bool> _saveImageBytes({
    required Uint8List bytes,
    String? fileName,
  }) async {
    if (bytes.isEmpty) return false;
    final name =
        (fileName?.trim().isNotEmpty == true) ? _withTimestamp(fileName!.trim()) : _defaultFileName();
    if(kIsWeb){
      return SaveImageToAlbumOfPlatformWeb.saveBytes(bytes: bytes, fileName: name);
    }else{
      return SaveImageToAlbumUtilsIo.saveBytes(bytes: bytes, fileName: name);
    }
  }

  static String _defaultFileName() {
    final now = DateTime.now();
    // 保持简单：统一 PNG 后缀（Web 下载与相册保存都适用）
    return 'primary_pay_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.png';
  }

  static String _withTimestamp(String fileName) {
    final now = DateTime.now();
    final ts = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    final dot = fileName.lastIndexOf('.');
    if (dot > 0 && dot < fileName.length - 1) {
      final name = fileName.substring(0, dot);
      final ext = fileName.substring(dot); // keep ".png"
      return '${name}_$ts$ext';
    }
    return '${fileName}_$ts.png';
  }

  /// 从页面已渲染的图片（RepaintBoundary）直接取内存像素并保存。
  ///
  /// 注意：这不会重新发起网络请求；保存的是当前 UI 实际显示出来的内容。
  static Future<bool> save({
    required GlobalKey boundaryKey,
    required BuildContext context,
    String? fileName,
    bool showToast = true,
  }) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      Log.e("boundary = null");
      if (showToast) Toast.show("保存图片失败");
      return false;
    }

    try {
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      final ok = bytes != null &&
          bytes.isNotEmpty &&
          await SaveImageToAlbumUtils._saveImageBytes(bytes: bytes, fileName: fileName);

      if (showToast) {
        if (ok) {
          Toast.success(msg: kIsWeb ? "下载图片成功" : "保存图片成功");
        } else {
          Toast.error(msg: kIsWeb ? "下载图片失败" : "保存图片失败");
        }
      }
      return ok;
    } catch (e) {
      Log.e("图片保存到本地发生异常：$e");
      if (showToast) Toast.error(msg: kIsWeb ? "下载图片失败" : "保存图片失败");
      return false;
    }
    }

}


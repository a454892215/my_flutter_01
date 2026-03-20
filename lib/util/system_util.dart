import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class SysUtil {

  /// Android 端：该插件在原生代码中调用的是 Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)。
  /// 在 Android 8.0+ 上，这个 ID 对每个应用和每个签名是唯一的。
  /// iOS 端：调用的是 UIDevice.current.identifierForVendor?.uuidString。如果用户卸载了该供应商（Vendor）下的所有 App，该值会被重置。
  static String _deviceId = "";

  // 暴露只读 getter，外部通过 SysUtil.deviceId 直接同步访问
  static String get deviceId => _deviceId;

  /// 外部唯一的初始化入口
  static Future<void> init() async {
    if (_deviceId.isNotEmpty) return;
    _deviceId = await fetchDeviceId();
  }

  /// 私有化获取逻辑：纯粹的 API 交互
  static Future<String> fetchDeviceId() async {
    if(_deviceId.isEmpty){
      await init();
      return _deviceId;
    }
    String? id;
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // 注意：Android 开发中 ANDROID_ID 虽然相对稳定，但仍需处理 null
        id = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor;
      }
    } catch (e) {
      // 记录错误日志，logger 是你项目依赖中有的
      // logger.e("获取设备ID失败: $e");
      id = null;
    }

    // 兜底逻辑：确保全局变量不会是空字符串
    return (id != null && id.isNotEmpty)
        ? id
        : "${DateTime.now().millisecondsSinceEpoch}-test";
  }
}
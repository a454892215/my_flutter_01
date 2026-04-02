import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as my_path;
import 'package:path_provider/path_provider.dart';

class FileU {
  static bool isWeb() {
    return kIsWeb == true;
  }

  /// 获取 APK 下载保存的专用目录
  /// 生产环境建议：APK 安装包通常较大，建议放在临时目录，安装后可由系统或手动清理。
  static Future<dynamic> getApkSaveDirPath() async {
    return getTemporaryDirectoryPath();
  }

  /// 1. 获取临时目录
  static Future<dynamic> getTemporaryDirectoryPath() async {
    if (isWeb()) {
      return getWebLocalPath();
    } else {
      return getTemporaryDirectory();
    }
  }

  /// 2. 获取app doc目录: 是APP私有目录，保存敏感数据，持久化配置，非缓存数据： 与 TemporaryDirectory（临时目录）不同，系统绝不会在磁盘空间不足时自动清理此目录的文件。
  /// Android: 映射到 /data/user/0/包名/app_flutter。
  /// 注意：它不是标准的 files 目录，而是 path_provider 插件专门在私有目录下创建的 app_flutter 子目录。
  /// iOS: 映射到沙盒中的 Documents/ 目录。 该目录会被 iCloud 自动备份。
  static Future<dynamic> getApplicationDocumentsDirectoryPath() async {
    if (isWeb()) {
      return getWebLocalPath();
    } else {
      return getApplicationDocumentsDirectory();
    }
  }

  /// 2. 获取web 本地下载目录
  static Future<String> getWebLocalPath() async {
    return my_path.absolute("build${my_path.separator}");
  }
}

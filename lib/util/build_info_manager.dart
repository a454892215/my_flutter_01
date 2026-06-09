

import 'package:flutter_comm/util/Log.dart';
import 'package:flutter_comm/util/sp/sp_util.dart';
import 'package:flutter_comm/widget/toast_util.dart';

/// 打包时由 [scripts/flutter_build_apk_with_git.sh] / [scripts/build_ipa.sh] 通过
/// `--dart-define-from-file` 注入；本地直接 `flutter run` / `flutter build` 时为空。
/// **不**注入 commit message，避免敏感信息写入 APK。
///
/// ```dart
/// BuildGitInfo.commitIdSuffix8
/// BuildGitInfo.commitTime
/// ```
const testEnvName = "TEST";
const localTestEnvName = "LocalTest";
const proEnvName = "PRO";
const proTestEnvName = "PRO_TEST";

final class BuildInfo {
  BuildInfo._();

  static const curEnvKeyOfDev = "curEnvKeyOfDev";

  static final List<String> devEnvSwitchList = [testEnvName, localTestEnvName, proTestEnvName];

  static const String _currentUseEnv = appEnv;

  static String _curEnvOfDev = _currentUseEnv;
  static void switchTestEnv(){
    if(!isTestMode()){
      Log.e("非法调用，当前不是测试环境，不能切换baseUrl");
      return;
    }
    int curIndex = devEnvSwitchList.indexOf(_curEnvOfDev);
    int nextIndex = curIndex + 1;
    if(nextIndex >= devEnvSwitchList.length){
      nextIndex = 0;
    }
    _curEnvOfDev = devEnvSwitchList[nextIndex];
    spUtil.setString(curEnvKeyOfDev, _curEnvOfDev);
    Toast.show("测试模式下，环境已切换为：$_curEnvOfDev, 请重新启动app 生效");
  }

   static String getCurUseEnv(){
     if(isTestMode()){
     return spUtil.getString(curEnvKeyOfDev) ?? _currentUseEnv;
     }
     return _currentUseEnv;
   }

  static const String appEnv = String.fromEnvironment(
    'APP_EVN',
    defaultValue: proTestEnvName,
  );

  /// 当前分支最近一次提交的完整 hash 的**后 8 位**（小写 hex）。
  static const String commitIdSuffix8 = String.fromEnvironment(
    'BUILD_GIT_COMMIT_SUFFIX8',
    defaultValue: '',
  );

  /// `git log -1 --format=%ci`。
  static const String commitTime = String.fromEnvironment(
    'BUILD_GIT_ISO_TIME',
    defaultValue: '',
  );

  /// 编译打包时候的时间
  static const String buildTime = String.fromEnvironment(
    'BUILD_ISO_TIME',
    defaultValue: '',
  );

  /// 是否已通过打包脚本注入 Git 元数据。
  static bool get isEmbedded =>
      commitIdSuffix8.isNotEmpty || commitTime.isNotEmpty;

  static String getInfo(){
    return "APP_EVN:${getCurUseEnv()} baseUrl:? buildTime:${BuildInfo.buildTime} Git:($isEmbedded,  $commitTime,  $commitIdSuffix8) ";
  }

  static bool isTestMode(){
    return appEnv.contains("TEST");
  }

  static bool isProEnv(){
    return appEnv.contains(proEnvName);
  }


  static bool isUseChuker(){
    return isTestMode();
  }
}

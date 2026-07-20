String keyLoginToken = "key_login_token";


class PrefKeys {
  PrefKeys._();

  // 主题类型。
  static const String intThemeMode = 'themeMode';

  // 语言
  static const String strLocale = 'locale';

  // 总资产金额是否可见
  static const String boolAssetVisible = 'assetVisible';

  // 登录token
  static const String strToken = 'token';
  static const String refreshTokenKey = 'refreshTokenKey';

  /// 最近一次初始化成功的环境名（用于环境切换时清理本地缓存）。
  static const String strLastEnvName = 'lastEnvName';

  /// API 域名轮询：候选域名列表（StringList）。
  /// 用于防域名封锁，启动时优先从本地缓存读取并合并到传入候选列表，保证至少留存多个可用域名。
  static const String strListApiDomainCandidates = 'apiDomainCandidates';

  /// API 域名轮询：最近一次探测成功的 baseUrl（String）。
  /// 启动时会优先探测该域名，以加快首次可用域名选取。
  static const String strApiBaseUrlLastGood = 'apiBaseUrlLastGood';


  /// 首页弹窗：邀请有奖（当天只弹一次）
  /// 存储格式：yyyyMMdd（例如 20260424）
  static const String intHomeInviteRewardLastShownYmd = 'homeInviteRewardLastShownYmd';

  /// 首页弹窗：消息通知引导（注册日起每 15 天检查一次）
  /// 存储格式：毫秒时间戳
  static const String intHomeMsgNotifyLastCheckMs = 'homeMsgNotifyLastCheckMs';

  /// 应用已安装标记（SharedPreferences 卸载即清；Keychain 卸载后可能残留）。
  static const String boolAppInstallMarker = 'appInstallMarker';
}
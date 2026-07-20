import 'package:flutter_comm/util/sp/sp_util.dart';
import 'package:flutter_comm/util/sp/sp_util_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/// 登录 token 的唯一存储入口（Keychain / EncryptedSharedPreferences + 内存缓存）。
///
/// iOS Keychain 在卸载后可能仍保留数据，重装同 bundleId 时会读到旧 token。
/// 通过 [PrefKeys.boolAppInstallMarker]（SharedPreferences，卸载即清）检测重装并清理残留。
class SecureTokenStorage {
  SecureTokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _keyAccessToken = PrefKeys.strToken;
  static const _keyRefreshToken = PrefKeys.refreshTokenKey;

  static String _accessToken = '';
  static String _refreshToken = '';
  static bool _initialized = false;

  static String get accessToken => _accessToken;
  static String get refreshToken => _refreshToken;

  static bool get hasToken => _accessToken.isNotEmpty;

  /// 在 [PrefUtils.init] 之后、`runApp` 之前调用。
  static Future<void> init() async {
    if (_initialized) return;

    await _clearKeychainTokensIfReinstalled();

    _accessToken = (await _storage.read(key: _keyAccessToken))?.trim() ?? '';
    _refreshToken = (await _storage.read(key: _keyRefreshToken))?.trim() ?? '';
    _initialized = true;
  }

  /// SharedPreferences 随卸载清除，Keychain 可能残留；无安装标记时：
  /// - prefs 为空 → 新装或卸载重装，清理 Keychain 残留 token
  /// - prefs 非空 → 旧版升级，仅补写标记，保留已有 token
  static Future<void> _clearKeychainTokensIfReinstalled() async {
    if (spUtil.containsKey(PrefKeys.boolAppInstallMarker)) return;

    if (spUtil.getKeys().isEmpty) {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
    }
    await spUtil.setBool(PrefKeys.boolAppInstallMarker, true);
  }

  /// 登录成功后保存 access / refresh token。
  static Future<void> saveLoginTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    await setAccessToken(accessToken ?? '');
    await setRefreshToken(refreshToken ?? '');
  }

  static Future<void> setAccessToken(String value) async {
    _accessToken = value.trim();
    if (_accessToken.isEmpty) {
      await _storage.delete(key: _keyAccessToken);
    } else {
      await _storage.write(key: _keyAccessToken, value: _accessToken);
    }
  }

  static Future<void> setRefreshToken(String value) async {
    _refreshToken = value.trim();
    if (_refreshToken.isEmpty) {
      await _storage.delete(key: _keyRefreshToken);
    } else {
      await _storage.write(key: _keyRefreshToken, value: _refreshToken);
    }
  }

  static Future<void> clearAll() async {
    _accessToken = '';
    _refreshToken = '';
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}

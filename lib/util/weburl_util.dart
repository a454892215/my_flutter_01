

class WebURLUtil {
  static const String _BASE_URL = "";

  /// 活动-签到
  static Map<String ,String> ACTIVITY_DETAIL_CHECK_IN = {
    "url": "$_BASE_URL/promotion-detail/check-in?is-app=1",
    "title": ""
  };

  /// 活动-宝箱
  static Map<String ,String> ACTIVITY_DETAIL_REWARD_BOX = {
    "url": "$_BASE_URL/promotion-detail/reward-box?is-app=1",
    "title": "活动-宝箱"
  };


}

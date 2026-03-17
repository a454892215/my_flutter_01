import 'package:flutter_comm/util/sp_util.dart';
import 'package:flutter_comm/util/sp_util_key.dart';

import 'Log.dart';


class WebURLUtil {
  static const String _BASE_URL = "https://h5.cyestari.com";

  /// 活动-首存
  static  Map<String ,String> ACTIVITY_DETAIL_FIRST_DEPOSIT = {
    "url": "$_BASE_URL/promotion-detail/first-deposit?is-app=1",
    "title": "Primeira recarga"
  };

  /// 活动-充值福利
  static Map<String ,String> ACTIVITY_DETAIL_DEPOSIT_BONUS = {
    "url": "$_BASE_URL/promotion-detail/deposit-bonus?is-app=1",
    "title": "Recarga benefícios"
  };

  /// 活动-签到
  static Map<String ,String> ACTIVITY_DETAIL_CHECK_IN = {
    "url": "$_BASE_URL/promotion-detail/check-in?is-app=1",
    "title": ""
  };

  /// 活动-宝箱
  static Map<String ,String> ACTIVITY_DETAIL_REWARD_BOX = {
    "url": "$_BASE_URL/promotion-detail/reward-box?is-app=1",
    "title": "Jackpot de desempacotar"
  };

  /// 活动-邀请
  static Map<String ,String> ACTIVITY_DETAIL_INVITE = {
    "url": "$_BASE_URL/promotion-detail/invite?is-app=1",
    "title": "Bónus de Convite"
  };

  /// 活动-每周累计投注
  static Map<String ,String> ACTIVITY_REFUND = {
    "url": "$_BASE_URL/promotion-detail/refund?is-app=1",
    "title": "Apostas cumulativas semanais"
  };

  /// 活动Telegram
  static Map<String ,String> ACTIVITY_DETAIL_TELEGRAM = {
    "url": "$_BASE_URL/promotion-detail/telegram?is-app=1",
    "title": "Canal De Telegram"
  };

  /// 客服
  static  Map<String ,String> CUSTOMER_SERVICE = {
    "url": "https://www.google.com",
    "title": "客服地址"
  };

  static Map<String ,String> REGISTER_RULES = {
    "url": "$_BASE_URL/privacy?is-app=1",
    "title": "Privacy"
  };

  static Map<String ,String> getBannerTarPageParam(String p1){
    String url = "$_BASE_URL$p1?is-app=1";
    Log.d("=======url:$url");
    return {
      "url": url,
      "title": "Promoção"
    };
  }


  static Map<String ,String> getCsLinkParam(String url){
    url = "$url?is-app=1";
    Log.d("=======url:$url");
    return {
      "url": url,
      "title": "Atendimento Ao Cliente"
    };
  }
}

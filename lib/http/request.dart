import 'api.dart';
import 'dio_util.dart';

ApiRequest apiRequest = ApiRequest();

class ApiRequest {
  DioUtil httpUtil = DioUtil(baseUrl);

  dynamic requestRegister(Map<String, Object> params) {
    return httpUtil.post(register, params);
  }

  dynamic requestLogin(Map<String, Object> params) {
    return httpUtil.post(login, params);
  }

  Future requestSms(Map<String, Object> params) async {
    return await httpUtil.post(sms, params);
  }

  Future requestBanner({Map<String, Object>? params}) async {
    return await httpUtil.get(banner, params: params);
  }

  Future requestMemberInfo() async {
    return await httpUtil.get(memberInfo, params:{});
  }

  Future requestBalance() async {
    return await httpUtil.get(balance, params:{});
  }

  Future requestMemberNav() async {
    return await httpUtil.get(memberNav,params: {});
  }

  Future requestGameList({Map<String, Object>? params}) async {
    return await httpUtil.get(gameList, params: params);
  }

  Future requestHotGameList({Map<String, Object>? params}) async {
    return await httpUtil.get(hotGameList, params: params);
  }

  Future requestForgetPsw({Map<String, Object>? params}) async {
    return await httpUtil.post(forgetPsw, params ?? {});
  }

  Future requestLastWin() async {
    return await httpUtil.get(lastwin, params: {});
  }

  Future requestNotice() async {
    return await httpUtil.get(notice, params: {});
  }

  Future requestVips() async {
    return await httpUtil.get(vips, params: {});
  }

  Future requestSignConfig() async {
    return await httpUtil.get(signConfig, params: {});
  }

  Future requestSignRewardRecord() async {
    return await httpUtil.get(signRewardRecord, params: {});
  }

  Future requestSign() async {
    return await httpUtil.get(sign, params: {});
  }

  Future requestMessageList({Map<String, Object>? params}) async {
    return await httpUtil.get(messageList, params: params);
  }

  Future requestMessageRead(Map<String, Object> params) async {
    return await httpUtil.post(messageRead, params);
  }

  Future requestMessageNum() async {
    return await httpUtil.get(messageNum, params:{});
  }

  Future requestMessageDelete(Map<String, Object> params) async {
    return await httpUtil.post(messageDelete, params);
  }

  Future requestPayChannel() async {
    return await httpUtil.get(payChannel, params:{});
  }

  Future requestWithdrawConfig() async {
    return await httpUtil.get(withdrawConfig, params:{});
  }

  Future requestPayDeposit(Map<String, Object> data) async {
    return await httpUtil.post(payDeposit, data);
  }

  Future requestMemberRecord({Map<String, Object>? params}) async {
    return await httpUtil.get(memberRecord, params:params);
  }

  Future requestPayWithdraw(Map<String, Object> data) async {
    return await httpUtil.post(payWithdraw, data);
  }

  Future requestTreasureConfig() async {
    return await httpUtil.get(treasureConfig, params:{});
  }

  Future requestTreasureApply() async {
    return await httpUtil.get(treasureApply, params:{});
  }

  Future requestPromoDepositConfig() async {
    return await httpUtil.get(promoDepositConfig, params:{});
  }

  Future requestUpdateAvatar({Map<String, Object>? params}) async {
    return await httpUtil.get(updateAvatar, params: params);
  }

  Future requestGameRecList({Map<String, Object>? params}) async {
    return await httpUtil.get(gameRecList, params: params);
  }

  Future requestGameSearch({Map<String, Object>? params}) async {
    return await httpUtil.get(gameSearch, params: params);
  }

  Future requestGameRecord({Map<String, Object>? params}) async {
    return await httpUtil.get(gameRecord, params: params);
  }

  Future requestTagList({Map<String, Object>? params}) async {
    return await httpUtil.get(tagList, params: params);
  }

  Future requestBonusRecord({Map<String, Object>? params}) async {
    return await httpUtil.get(bonusRecord, params: params);
  }

  Future requestFavInsert({Map<String, Object>? params}) async {
    return await httpUtil.get(favInsert, params: params);
  }

  Future requestFavDelete({Map<String, Object>? params}) async {
    return await httpUtil.get(favDelete, params: params);
  }

  Future requestGameFavList({Map<String, Object>? params}) async {
    return await httpUtil.get(gameFavList, params: params);
  }

  Future requestSmsSendMail({Map<String, Object>? params}) async {
    return await httpUtil.post(smsSendMail, params ?? {});
  }

  Future requestAppUpdate({Map<String, Object>? params}) async {
    return await httpUtil.get(appUpgrade, params: params);
  }

  Future requestGameLaunch({Map<String, Object>? params}) async {
    return await httpUtil.get(gameLaunch, params: params);
  }

  Future requestMemberFavList({Map<String, Object>? params}) async {
    return await httpUtil.get(memberFavList, params: params);
  }

  Future requestMemberCsList({Map<String, Object>? params}) async {
    return await httpUtil.get(memberCsList, params: params);
  }

  Future requestMemberPasswordUpdate({Map<String, Object>? params}) async {
    return await httpUtil.post(memberPasswordUpdate, params ?? {});
  }

  Future requestMemberBindPhone({Map<String, Object>? params}) async {
    return await httpUtil.post(memberBindPhone, params ?? {});
  }

  Future requestMemberBindEmail({Map<String, Object>? params}) async {
    return await httpUtil.post(memberBindEmail, params ?? {});
  }

  Future requestSmsSendOnline({Map<String, Object>? params}) async {
    return await httpUtil.post(smsSendOnline, params ?? {});
  }

  Future requestSmsSendOnlineMail({Map<String, Object>? params}) async {
    return await httpUtil.post(smsSendOnlineMail, params ?? {});
  }

  Future requestBankCardInsert({Map<String, Object>? params}) async {
    return await httpUtil.post(bankCardInsert, params ?? {});
  }

  Future requestBankCardList({Map<String, Object>? params}) async {
    return await httpUtil.get(bankCardList, params: params);
  }

  Future requestBankTypeList({Map<String, Object>? params}) async {
    return await httpUtil.get(bankTypeList, params: params);
  }

  Future requestPasswordUpdate({Map<String, Object>? params}) async {
    return await httpUtil.post(passwordUpdate, params ?? {});
  }

  Future requestMemberUpdateInfo({Map<String, Object>? params}) async {
    return await httpUtil.post(memberUpdateInfo, params ?? {});
  }
}

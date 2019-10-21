
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:fast_pass/app/routers/handler_router.dart';

class Routes{
  static const String webViews = '/my/setting/customWebView';
  static const String home = '/home';
  static const String search = '/home/search';
  static const String searchGoods = '/home/searchGoods';
  static const String searchArticles = '/home/searchArticles';
  static const String newIncludedCommodities = '/home/newIncludedCommodities';
  static const String goodDetail = '/home/goodDetail';
  static const String buyTips = '/buy/buyTips';
  static const String buySelectSize = '/buy/buySelectSize';
  static const String buyAddress = '/buy/buyAddress';
  static const String buyPay = '/buy/buyPay';
  static const String sellTips = '/sell/sellTips';
  static const String sellSelectSize = '/sell/sellSelectSize';
  static const String sellPrice = '/sell/sellPrice';
  static const String sellPay = '/sell/sellPay';
  static const String login = '/login';
  static const String forgotPassword = '/login/forgotPassword';
  static const String setPassword = '/login/setPassword';
  static const String register = '/register/index';
  static const String helpWord = '/register/helpWord';
  static const String index = '/';
  static const String assetsIndex = '/assets/index';
  static const String dealIndex = '/deal/index';
  static const String verifiedPPassword = '/deal/verifiedPPassword';
  static const String crashBtc = '/deal/crashBtc';
  static const String myIndex = '/my/index';
  static const String settingIndex = '/my/setting/index';
  static const String modifyPassword = '/my/setting/modifyPassword';
  static const String modifyLoginPassword = '/my/setting/modifyLoginPassword';
  static const String modifyPaymentPassword = '/my/setting/modifyPaymentPassword';
  static const String team = '/my/setting/team';
  static const String realName = '/my/setting/realName';
  static const String about = '/my/setting/about';
  static const String feedback = '/my/setting/feedback';
  static const String inviteFriends = '/my/setting/inviteFriends';
  static const String problems = '/my/setting/problems';
  static const String modifyNickname = '/my/setting/modifyNickname';
  static const String personInfo = '/my/setting/personInfo';
  static const String informationDetail = '/information';
  static const String sportsShoesPage = '/loginregister';
  static const String informationAll = '/informationall';
  static const String IndividualCenterPage = '/logingregister/individualCenterPage';
  static const String LoginRPage = '/logingregister/LoginRPage';
  static const String FQAPage = '/help';
  static const String OrderDetailPage = '/OrderDetailPage';
  static const String DepositDetailPage = '/DepositDetailPage';
  static const String GoingStarehousePage = '/GoingStarehousePage';
  static const String AddressManagePage = '/AddressManagePage';
  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        return Center(
          child: Text('Not found'),
        );
      },
    );
    router.define(home,handler:homePageHandler);
    router.define(search,handler:searchPageHandler);
    router.define(searchGoods,handler:searchGoodsPageHandler);
    router.define(searchArticles,handler:searchArticlesPageHandler);
    router.define(newIncludedCommodities,handler:newIncludedCommoditiesPageHandler);
    router.define(goodDetail,handler:goodDetailPageHandler);
    router.define(buyTips,handler:buyTipsPageHandler);
    router.define(buySelectSize,handler:buySelectSizePageHandler);
    router.define(buyAddress,handler:buyAddressPageHandler);
    router.define(buyPay,handler:buyPayPageHandler);
    router.define(sellTips,handler:sellTipsPageHandler);
    router.define(sellSelectSize,handler:sellSelectSizePageHandler);
    router.define(sellPrice,handler:sellPricePageHandler);
    router.define(sellPay,handler:sellPayPageHandler);
    router.define(informationDetail,handler:informationDetailPageHandler);
    router.define(login, handler: loginPageHandler);
    router.define(forgotPassword, handler: forgotPasswordPageHandler);
    router.define(setPassword, handler: setPasswordPageHandler);
    router.define(register, handler: registerPageHandler);
    router.define(helpWord, handler: helpWordPageHandler);
    router.define(index, handler: indexHandler);
    router.define(assetsIndex, handler: assetsIndexHandler);
    router.define(dealIndex, handler: dealIndexHandler);
    router.define(verifiedPPassword, handler: verifiedPPasswordHandler);
    router.define(crashBtc, handler: crashBtcHandler);
    router.define(myIndex, handler: myIndexHandler);
    router.define(settingIndex, handler: settingIndexHandler);
    router.define(modifyPassword, handler: modifyPasswordIndexHandler);
    router.define(modifyLoginPassword, handler: modifyLoginPasswordIndexHandler);
    router.define(modifyPaymentPassword, handler: modifyPaymentPasswordIndexHandler);
    router.define(team, handler: teamPageHandler);
    router.define(realName, handler: realNamePageHandler);
    router.define(about, handler: aboutPageHandler);
    router.define(feedback, handler: feedbackPageHandler);
    router.define(inviteFriends, handler: inviteFriendsPageHandler);
    router.define(problems, handler: problemsPageHandler);
    router.define(personInfo, handler: personInfoPageHandler);
    router.define(modifyNickname, handler: modifyNicknamePageHandler);
    router.define(sportsShoesPage, handler: sportsShoesPageHandler);
    router.define(informationAll, handler: informationAllHandler);
    router.define(IndividualCenterPage, handler: individualCenterPageHandler);
    router.define(LoginRPage, handler: loginRPageHandler);
    router.define(FQAPage, handler: FQAPageHandler);
    router.define(webViews,handler:webViewHandler);
    router.define(OrderDetailPage,handler:orderDetailPageHandler);
    router.define(DepositDetailPage,handler:depositDetailPageHandler);
    router.define(GoingStarehousePage,handler:goingPageHandler);
    router.define(AddressManagePage,handler:addressManagePageHandler);
  }

}
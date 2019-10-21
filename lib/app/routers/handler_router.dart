import 'package:fast_pass/app/pages/help/fp_FQA_page.dart';
import 'package:fast_pass/app/pages/information/information_details_page.dart';
import 'package:fast_pass/app/pages/information/information_all_page.dart';
import 'package:fast_pass/app/pages/loginregister/fp_deposit_page.dart';
import 'package:fast_pass/app/pages/loginregister/fp_address_manage_page.dart';
import 'package:fast_pass/app/pages/loginregister/fp_going_storehouse_page.dart';
import 'package:fast_pass/app/pages/loginregister/fp_individual_center_page.dart';
import 'package:fast_pass/app/pages/loginregister/fp_login_page.dart';
import 'package:fast_pass/app/pages/loginregister/fp_order_detail.dart';
import 'package:fast_pass/app/pages/loginregister/fp_sports_shoes_page.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:fast_pass/app/pages/buy/fp_buy_select_size_page.dart';
import 'package:fast_pass/app/pages/buy/fp_buy_address_page.dart';
import 'package:fast_pass/app/pages/buy/fp_buy_pay_page.dart';
import 'package:fast_pass/app/pages/buy/fp_buy_tips_page.dart';
import 'package:fast_pass/app/pages/sell/fp_sell_pay_page.dart';
import 'package:fast_pass/app/pages/sell/fp_sell_price_page.dart';
import 'package:fast_pass/app/pages/sell/fp_sell_select_size_page.dart';
import 'package:fast_pass/app/pages/sell/fp_sell_tips_page.dart';
import 'package:fast_pass/app/pages/home/fp_good_detail_page.dart';
import 'package:fast_pass/app/pages/home/fp_index_page.dart';
import 'package:fast_pass/app/pages/home/fp_search_page.dart';
import 'package:fast_pass/app/pages/home/fp_search_goods_page.dart';
import 'package:fast_pass/app/pages/home/fp_search_articles_page.dart';
import 'package:fast_pass/app/pages/home/fp_new_Included_commodities.dart';
import 'package:fast_pass/app/pages/index_page.dart';
import 'package:fast_pass/app/pages/assets/index_page.dart';
import 'package:fast_pass/app/pages/deal/index_page.dart';
import 'package:fast_pass/app/pages/login_page.dart';
import 'package:fast_pass/app/pages/forgot_password_page.dart';
import 'package:fast_pass/app/pages/set_password_page.dart';
import 'package:fast_pass/app/pages/register/index_page.dart';
import 'package:fast_pass/app/pages/register/help_word_page.dart';
import 'package:fast_pass/app/pages/my/index_page.dart';
import 'package:fast_pass/app/pages/my/setting/index_page.dart';
import 'package:fast_pass/app/pages/my/setting/modify_password_page.dart';
import 'package:fast_pass/app/pages/my/setting/modify_login_password_page.dart';
import 'package:fast_pass/app/pages/my/setting/modify_payment_password_page.dart';
import 'package:fast_pass/app/pages/my/team_page.dart';
import 'package:fast_pass/app/pages/my/real_name_page.dart';
import 'package:fast_pass/app/pages/my/about_page.dart';
import 'package:fast_pass/app/pages/my/feedback_page.dart';
import 'package:fast_pass/app/pages/my/Invite_friends_page.dart';
import 'package:fast_pass/app/pages/my/problems_page.dart';
import 'package:fast_pass/app/pages/my/person_info_page.dart';
import 'package:fast_pass/app/pages/my/modify_nickname_page.dart';
import 'package:fast_pass/app/pages/deal/verified_ppassword_page.dart';
import 'package:fast_pass/app/pages/deal/crash_btc_page.dart';

//buySelectSize
Handler buySelectSizePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      return FPBuySelectSizePage(id: id);
    }
);
//buyAddress
Handler buyAddressPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      return FPBuyAddressPage(id: id);
    }
);
//buyPay
Handler buyPayPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      String orderId = params['orderId'][0].toString();
      return FPBuyPayPage(id: id,orderId:orderId);
    }
);
//buyTips
Handler buyTipsPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        String id = params['id'][0].toString();
        String type = params['type'][0].toString();
      return FPBuyTipsPage(id: id,type:type);
    }
);
//sellSelectSize
Handler sellSelectSizePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      return FPSellSelectSizePage(id: id);
    }
);
//sellPrice
Handler sellPricePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      return FPSellPricePage(id: id);
    }
);
//sellPay
Handler sellPayPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      String orderId = params['orderId'][0].toString();
      return FPSellPayPage(id: id,orderId: orderId,);
    }
);
//sellTips
Handler sellTipsPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      String type = params['type'][0].toString();
      return FPSellTipsPage(id: id,type:type);
    }
);
//goodDetail
Handler goodDetailPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['id'][0].toString();
      return FPGoodDetailPage(goodID: id);
    }
);
//home
Handler homePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      return FPIndexPage();
    }
);
//search
Handler searchPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      return FPSearchPage();
    }
);
//search
//文章详情页
Handler searchGoodsPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String a =  params['key'][0].toString();
      print('key = $a');
      return FPSearchGoodsPage(keyString:a);
    }
);
//文章详情页
Handler searchArticlesPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        String a =  params['key'][0].toString();
        print('key = $a');
        return FPSearchArticlesPage(keyString:a);
    }
);
//录入商品
Handler newIncludedCommoditiesPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return FPNewIncludedCommoditiesPage();
    }
);
//登录
Handler loginPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      return LoginPage();
    }
);
//忘记密码
Handler forgotPasswordPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return ForgotPasswordPage();
    }
);
//文章详情页
Handler informationDetailPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
         String a =  params['id'][0].toString();
        return InformationDetailsState(number:a);
    }
);
//设置密码
Handler setPasswordPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return SetPasswordPage();
    }
);
//注册
Handler registerPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return RegisterPage();
    }
);
//助记词
Handler helpWordPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return HelpWordPage();
    }
);
//导航页
Handler indexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      return IndexPage();
    }
);
//资产
Handler assetsIndexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return AssetsIndexPage();
    }
);
//交易
Handler dealIndexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return DealIndexPage();
    }
);
//验证支付密码
Handler verifiedPPasswordHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return VerifiedPPasswordPage();
    }
);
//BTC提现
Handler crashBtcHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return CrashBtcPage();
    }
);
//我的
Handler myIndexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return MyIndexPage();
    }
);
//setting
Handler settingIndexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return SettingIndexPage();
    }
);
//我的团队
Handler teamPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return TeamPage();
    }
);
//实名认证
Handler realNamePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return RealNameAuthenticationPage();
    }
);
//关于我们
Handler aboutPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return AboutPage();
    }
);
//意见反馈
Handler feedbackPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return FeedbackPage();
    }
);
//修改密码
Handler modifyPasswordIndexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return ModifyPasswordPage();
    }
);
//修改登录密码
Handler modifyLoginPasswordIndexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return ModifyLoginPasswordPage();
    }
);
//修改支付密码
Handler modifyPaymentPasswordIndexHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return ModifyPaymentPasswordPage();
    }
);
//邀请好友
Handler inviteFriendsPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return InviteFriendsPage();
    }
);
//常见问题
Handler problemsPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return ProblemsPage();
    }
);
//修改昵称
Handler modifyNicknamePageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return ModifyNicknamePage();
    }
);
//个人信息
Handler personInfoPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return PersonInfoPage();
    }
);

//运动鞋
Handler sportsShoesPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return SportsShoesPage();
    }
);

//咨询
Handler informationAllHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String ind = params['index'][0].toString();
        return informationAll(index:ind);
    }
);

//个人中心
Handler individualCenterPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String ind = '0';
      if(params.length != 0){
        ind = params['index'][0].toString();
      }
      return IndividualCenterPage(index: ind);
    }
);

//登录注册
Handler loginRPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        String a = params['isLogin'][0].toString();
        return LoginRPage(isLogin: a);
    }
);
//FQA
Handler FQAPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
        return FQAPage();
    }
);

//webview
Handler webViewHandler = Handler( 
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String id = params['url'][0].toString();
        return WebViewState(url: id,);
    }
);

//交易信息
Handler orderDetailPageHandler = Handler( 
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String dic = params['name'][0].toString();
      String type = params['type'][0].toString();
        return OrderDetailPage(name: dic,type: type);
    }
);
//会员仓详情
Handler depositDetailPageHandler = Handler( 
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      String dic = params['name'][0].toString();
      String type = params['type'][0].toString();
        return DepositDetailPage(name: dic,type: type);
    }
);



//地址管理
Handler addressManagePageHandler = Handler(
handlerFunc: (BuildContext context, Map<String, List<String>> params){
        String number = params['number'][0].toString();
        return AddressManagePage(number: number);
    }
);

//出仓
Handler goingPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params){
      print('内容');
      print(params.toString());
      String dic = params['number'][0].toString();
      return GoingStarehousePage(number: dic);
    }
);
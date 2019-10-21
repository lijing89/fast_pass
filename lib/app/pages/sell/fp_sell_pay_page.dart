import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:fake_alipay/fake_alipay.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/dash_line.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';

class FPSellPayPage extends StatefulWidget {
  final String id;
  final String orderId;
  FPSellPayPage({this.id,this.orderId});
  @override
  _FPSellPayPageState createState() => _FPSellPayPageState();
}

class _FPSellPayPageState extends State<FPSellPayPage> {

  String _selectSize;
  String _priceTips = '';
  String _sizeId = '';
  String _goodName = '';
  String _newHighestBuyPrice = '',_newLowestSellPrice = '';
  String _sizeValue = '';
  Map _goodDetailInfo= {};
  Map _orderDetailInfo= {};
  String _tradeId;
  int _sellType,_price = 0;// 1砍价买 2直接买
  int _orderTime = 0;//订单提交时间戳
//  SwiperController _swiperController = SwiperController();

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();


  String _BZJ = '';

  Alipay alipay = Alipay();
  StreamSubscription<AlipayResp> _pay;

  _aliPayMoney(BuildContext){
    print('支付宝支付 _tradeId = $_tradeId');
//    String key = 'MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCyrWxWht7q45++vrN71pOYAV3/yz+vWg94aoYJXG6sXt1v0i/rNF1DJfJfy2H1kWSVs+hHHppzP9l7OhUxAgNdiz8akyHsYMrXyEJf8P0wsaL7GbrQz0l/1TN1QucRxVURJfyAxkrkjWDiXjNY8nI/hReWjFiM1mWJnOtb53Vcc9afh9seM0Kv9LOeQL4cLuUAnN0IVOOcrw3ndzDomodQAUQO1+8toSUTAtgE8YaIzLF8ZgIqVBdLZIAM98K9Ze6sU3QKMDXHjosGcEygesNzNrItzTLJKyf0wGhNCo5ySKgpp5rnyiQCcQOSwOVnrQU6GDrKMrHs91i86dm2oxSBAgMBAAECggEAMgVA3hxVzbY5o2Gpx5JzsUs4sIKK6qEw0YooyfgZd6H7JfHWvmbjcQfviYfbfa7dVNePwFE99eO7E7dX9WdV39s6qErmZVFXl/8VLdy+VOJ1+Qvj888ECYh7Jmm7XIs83FchED/y+Xbm15h9kXoWJ9gvmVLi+1KODG9kqE7s2RuQX5tAnVN07cMvpcyAcaXylFIZp4z8nqLaUCvT0va3VRkJ34Sk7I0zKiggN5z0xXGDX0H+SR1Znx4YPNEGEVQwSy13sVyKhPW8RRB2BGnjTG3grwjprUNuG/vUQpFb5afAsNlcp+ZpdPGM1aZ9s1GHmPqasImWyzVmt8PuAtmgbQKBgQDtv1bF6cD1ztVNOM3U9KEIRHzujAVVM1h8D59SLXCBDEPXYXaFlrPWxuayeUGd+GZrUhl8gFUG9J04LFMRf7L0zfJ/dih4ale89u7yxrINBIajz+0Yg50IBQ4Mre64mSxOBiOHgYqrEKXU4R3ea5Rqu4lqUg+zhwq8v0UG07rjpwKBgQDAZSEhlldlGWFoMktScYrty8G/YmQCZWH/g+YL7bWNfO3Xt/3gu8aW7tCHY65I1fdj6q5XNlRAg1I1SwTmyeI6GrAdKBlEQcrcB9IgB79P6d1KenwzlJW1yczzCVcL3/Pll8mZAw2urGd2M5CXFRxth6qgtJQGNvucLw6iX8BrlwKBgQDLb9IBko8yByWQaY3/rsBowaohuaEKkeAicH/FIurFEkiu8VAo6ZbDrvlTON0EHr0NEniKh4m6ZPBvU8ZVD++C+QOLPAFPYLfpE2fOSGWtK/VGETLxqhVh+mlWQjMmtLMrpKccWaXd0WYFbghP/cBHQGhKmSOkXGa8sfKP7/dYuwKBgAgKcfcIZICqLeL/7xvz+N11XZSVFR7wg8b9CTlIZwURypLwcqDY2DToqDhwVxFeN+eqID0u3RiRJHdrujm3CEhrYx7k1SGAKm1FumdyS3GYkZISSmyRcixV0cX6hvPNGVFoJZnKgeDh/bT39LwLutNtDxmGUoVr+NoPMWph3BXjAoGBALpmlEquByntlzFn1WVgJ7+Wemuh9D0yQM/kyNzqRh1M+x/jxeMRvo1EOeGXsNiG5oTQf5wc7g/CJic5jADShIFRHwrLuc+qEYFpqB0XsEsMqjTHqO2qMDsoZLRBwBSUl3MIUJ2fTmCmiRIImlzg+GC841zMD7CAqu3lHM3Wgifz';
//    alipay.payOrderSign(orderInfo: 'alipay_sdk=alipay-sdk-java-3.7.4.ALL&app_id=2019062865751149&biz_content=%7B%22out_order_no%22%3A%22201029813425545216%22%2C%22out_request_no%22%3A%22201029813425545217%22%2C%22order_title%22%3A%22app%E6%B5%8B%E8%AF%95%22%2C%22amount%22%3A%220.10%22%2C%22product_code%22%3A%22PRE_AUTH_ONLINE%22%2C%22payee_logon_id%22%3A%22finance%40fastpass.cn%22%7D&charset=utf-8&format=JSON&method=alipay.fund.auth.order.app.freeze&notify_url=http%3A%2F%2Fdoit.huapay.cn%2Falipay_demo%2Ftest&sign=RhPwTZ%2FWd4ZaR%2BJG8VkBW9IrEQzcaWWj7ncQ5%2Fq6%2F0nZRezEFMHj9tAdAV256B%2BP3HktDUhvhtGECekMeRgoFfNSabcCLGnwKdi3dAhqJ8ksQJBttkCa6EA697NO%2FNVnOktFr26dLjey7IvPfjqnJdf3TbG0wahxDYtgk0TLnA9ULNiTRtQoP172lhrpw57%2BaLkIbTqBdOhpjqF%2B5fUZ2szQlEbIa0L5sU2mzXWZRVwtrGgTGUf6AP5Nj4gmJSfZd5IeYILAqWmmX5JVRQ3BiR16gbvwVUdNMvezeTuR1zxjvX2CD7%2BprxUpUGcIWRAU3%2FJ1xX4rsdDExKp2yT%2FPjg%3D%3D&sign_type=RSA2&timestamp=2019-09-05+15%3A53%3A40&version=1.0').then((onValue){
//      print('=========');
//    });

    if(!checkOrderTime(_orderTime)){
      Fluttertoast.showToast(msg:'订单超时,请返回重试.',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }

    ApiConfig().aliPayMoney(_tradeId).then((onValue){
      if (onValue['rspCode'] != '0000') {
        Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
        return;
      }
      //支付宝支付
      alipay.payOrderSign(orderInfo:onValue['invokeData']).then((onValue){
        Navigator.pop(context);
        Application.router.navigateTo(context, Routes.OrderDetailPage+'?name=${widget.orderId}&type=2',transition: TransitionType.native);
      });
    });
  }
  _weChatPayMoney(BuildContext){
    print('微信支付 _tradeId = $_tradeId');
//    fluwx
//        .pay(
//      appId: 'wxf508d92e25450ea1',
//      partnerId: '1900000109',
//      prepayId: '1101000000140415649af9fc314aa427',
//      packageValue: 'Sign=WXPay',
//      nonceStr: '1101000000140429eb40476f8896f4c9',
//      timeStamp: 1398746574,
//      sign: '7FFECB600D7157C5AA49810D2D8F28BC2811827B',
//    )
//        .then((data) {
//      print("---》$data");
//    });

    if(!checkOrderTime(_orderTime)){
      Fluttertoast.showToast(msg:'订单超时,请返回重试.',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }

    ApiConfig().wXPayMoney(_tradeId).then((onValue){
      if (onValue['rspCode'] != '0000') {
        Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
        return;
      }
      //微信支付
      fluwx.pay(
        appId: onValue['appId'].toString(),
        partnerId: onValue['mchId'].toString(),
        prepayId: onValue['prepayId'].toString(),
        packageValue: onValue['pack'].toString(),
        nonceStr: onValue['nonceStr'].toString(),
        timeStamp: int.parse(onValue['timeStamp']),
        sign:onValue['wxSign'].toString(),
      ).then((data) {
        Navigator.pop(context);
        Application.router.navigateTo(context, Routes.OrderDetailPage+'?name=${widget.orderId}&type=2',transition: TransitionType.native);
      });
    });
  }

  bool checkOrderTime(int orderTime){
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    double timeDif = (timeNow - orderTime)/(1000 * 60);
    print('orderTime = $orderTime,timeNow = $timeNow,timeDif = $timeDif');
    if(timeDif < 2)return true;
    return false;
  }

  //刷新数据
  Future refreshGoodsList() async {

    var onValue = await UserInfoCache().getMapInfo(key: UserInfoCache.sellInfo);
    print('sellInfo = ${onValue.toString()}');

    _goodName = onValue['goodName'];
    _selectSize = onValue['selectSize'];
    _sizeId = onValue['sizeId'];
    _price = onValue['price'];
    _priceTips = onValue['priceTips'];
    _BZJ = onValue['BZJ'];
    _sellType = onValue['sellType'];// 1砍价卖 2直接卖
    _sizeValue = onValue['sizeValue'];
    _orderTime = onValue['orderTime'];

    setState(() {});


    var goodDetailData = await ApiConfig().goodsDetail(widget.id);
    if(goodDetailData.isNotEmpty && int.parse(goodDetailData['rspCode']) < 1000){
      _goodDetailInfo = goodDetailData;
//      if(_goodDetailInfo['imgList'].isNotEmpty){
//        _swiperController.startAutoplay();
//      }
    }
    else return;

    await refreshPrices(goodId: widget.id,sizeId: _sizeId);

    var orderDetailData = await ApiConfig().buySellDetail(widget.orderId);
    if(orderDetailData.isNotEmpty && int.parse(orderDetailData['rspCode']) < 1000){
      _orderDetailInfo = orderDetailData;
      _tradeId = '${orderDetailData['tradeId']}';
    }
    else return;
    setState(() {});

  }

  Future refreshPrices({String goodId,sizeId}) async {

    print('goodId = $goodId');
    var priceData = await ApiConfig().goodsLowHeight([{'id':goodId,'sizeId':sizeId}])??{};
    if(priceData.isNotEmpty && int.parse(priceData['rspCode']) < 1000){
      List pricesList = priceData['rspList']??[];
      String buyString = pricesList[0]['buyingPrice'];
      String sellString = pricesList[0]['sellingPrice'];
      _newHighestBuyPrice = buyString??'--';
      _newLowestSellPrice = sellString??'--';
//      _newHighestBuyPrice = '¥${int.parse(buyString.replaceRange(0,1, '0'))/100}';
//      _newLowestSellPrice = '¥${int.parse(sellString.replaceRange(0,1, '0'))/100}';
    }
    else return;

    setState(() {});
  }

  @override
  void initState(){
    super.initState();

    _pay = alipay.payResp().listen((AlipayResp resp) {

      String content = 'pay: ${resp.resultStatus} - ${resp.result}';
      print(content);

      /// 9000——订单支付成功         下面的result有值
      /// 8000——正在处理中
      /// 4000——订单支付失败
      /// 5000——重复请求
      /// 6001——用户中途取消
      /// 6002——网络连接出错
      switch (resp.resultStatus) {
        case 9000:
          Fluttertoast.showToast(msg:'订单支付成功',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          Application.router.pop(context);
          break;
        case 6001:
          Fluttertoast.showToast(msg:'用户中途取消',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          break;
        case 4000:
          Fluttertoast.showToast(msg:'订单支付失败',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          break;
        case 5000:
          Fluttertoast.showToast(msg:'重复请求',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          break;
        case 6002:
          Fluttertoast.showToast(msg:'网络连接出错',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          break;
        default:
          Fluttertoast.showToast(msg:'支付失败',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          break;
      }
    });

    fluwx.responseFromPayment.listen((response){
      //do something
      switch (response.errCode) {
        case 1:
          Fluttertoast.showToast(msg:'订单支付成功',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          Application.router.pop(context);
          break;
        case -2:
          Fluttertoast.showToast(msg:'用户中途取消',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          break;
        default:
          Fluttertoast.showToast(msg:'支付失败',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          break;
      }
    });

    refreshGoodsList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_pay != null) {
      _pay.cancel();
    }
//    _swiperController.stopAutoplay();
//    _swiperController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              barView(context,Theme.of(context).primaryColor),
              Expanded(
                child: EasyRefresh(
                  key: _easyRefreshKey,
                  behavior: ScrollOverBehavior(),
                  refreshHeader: ClassicsHeader(
                    key: _headerKey,
                    showMore: true,
                    refreshingText: '正在刷新...',
                    refreshText: '下拉刷新',
                    refreshReadyText: '释放刷新',
                    refreshedText: '刷新完成',
                    moreInfo: "上次更新于 %T",
//                                    moreInfo: "更新于",
                    bgColor: Colors.transparent,
                    textColor: Colors.black87,
                    moreInfoColor: Colors.black54,
                    //showMore: false,
                  ),
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      dashLineAndStep(context),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(80.0),
                          bottom: ScreenUtil.getInstance().setWidth(80.0),
                        ),
                        color: AppStyle.colorDartBg,
                        child: Column(
                          children: <Widget>[
                            goodInfoItem(title: '商品名称',content: _goodName),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
                            goodInfoItem(title: '交易尺码',content: '${Application.sizeValueTitle(_sizeValue)} $_selectSize'),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
                            goodInfoItem(title: '最低卖价',content: _newLowestSellPrice),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
                            goodInfoItem(title: '最高卖价',content: _newHighestBuyPrice),
                          ],
                        ),
                      ),
                      headerImageView(headImage: _goodDetailInfo['titleImgUrl']),
                      Container(
                        padding: EdgeInsets.only(
                          left: ScreenUtil.getInstance().setWidth(16.0),
                          right: ScreenUtil.getInstance().setWidth(16.0),
                        ),
                        margin: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(40.0),
                          bottom: ScreenUtil.getInstance().setWidth(22.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                top: ScreenUtil.getInstance().setWidth(20.0),
                              ),
                              height: ScreenUtil.getInstance().setWidth(64.0),
                              decoration: BoxDecoration(
                                color: AppStyle.colorLightGreyBG,
                                borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(10.0)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '请确认交易信息无误后进行支付',
                                style: TextStyle(
                                  color: AppStyle.colorWhite,
                                  fontSize:ScreenUtil.getInstance().setSp(28.0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: ScreenUtil.getInstance().setWidth(16.0),
                                right: ScreenUtil.getInstance().setWidth(16.0),
                              ),
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: ScreenUtil.getInstance().setWidth(68.0)),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(width: ScreenUtil.getInstance().setWidth(60.0)),
                                      Container(
                                        height: ScreenUtil.getInstance().setWidth(74.0),
                                        alignment: Alignment.centerLeft,
                                        child: Image(image: AssetImage(AssetUtil.image('information-list.png')),fit: BoxFit.fitHeight,),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ScreenUtil.getInstance().setWidth(50.0)),
                                  listTitle('订单号：${_orderDetailInfo['orderNo']}'),
                                  orderInfoView('订单信息',_orderDetailInfo['orderInfo']??[]),
                                  orderInfoView('报价信息',_orderDetailInfo['tradeInfo']??[]),
                                  orderInfoView('支付信息',_orderDetailInfo['payInfo']??[]),
                                  SizedBox(height: ScreenUtil.getInstance().setWidth(70.0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      showMoneyView('您需要支付的保证金共计','(保证金为货款10%)',(_orderDetailInfo['orderAmt']??0)/100),
                      Container(
                        color: AppStyle.colorPrimary,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: ScreenUtil.getInstance().setWidth(16.0),
                            right: ScreenUtil.getInstance().setWidth(16.0),
                            bottom: ScreenUtil.getInstance().setWidth(16.0),
                          ),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: ScreenUtil.getInstance().setWidth(60.0)),
                              Row(
                                children: <Widget>[
                                  SizedBox(width: ScreenUtil.getInstance().setWidth(60.0)),
                                  Text(
                                    '请选择支付方式',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(20.0)),
                              payButtonsView(context),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(40.0)),
                              Center(
                                child: Text(
                                  '请您在2分钟内支付，否则本次支付将自动关闭',
                                  style: TextStyle(
                                    color: Color(0xFF474747),
                                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(120.0)),
                              buyTipsView(_orderDetailInfo['tradeTips']??[]),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(132.0)),
                              showMoneyViewBottom('您需要支付的保证金共计','(保证金为货款10%)',(_orderDetailInfo['orderAmt']??0)/100),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(40.0)),
                              payButtonsViewBottom(context),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(80.0)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  onRefresh: () async {
                    await refreshGoodsList();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderInfoView(String title,List orderInfoList){

    if(orderInfoList.isEmpty)return Container();
    List<Widget> items = [];
    items.add(SizedBox(height: ScreenUtil.getInstance().setWidth(70.0)));
    items.add(listTitle(title));
    items.add(SizedBox(height: ScreenUtil.getInstance().setWidth(46.0)));
    for(Map item in orderInfoList){
      items.add(SizedBox(height: ScreenUtil.getInstance().setWidth(24.0)));
      items.add(priceInfoItem(title: item['title'],content: item['content']));
    }

    return Column(children: items);
  }

  Widget headerImageView({@required String headImage}) {
    if (headImage != null) {
      return Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: ScreenUtil.getInstance().setWidth(400.0),
          color: AppStyle.colorWhite,
          child: CachedNetworkImage(
            imageUrl: headImage,
            placeholder: (context, url) => new CircularProgressIndicator(strokeWidth: 1.0,),
            errorWidget: (context, url, error) => new Icon(AppIcon.warn_light),
            fit: BoxFit.cover,
          )

//        Swiper(
//          itemBuilder: (BuildContext context, int index) {
//            return CachedNetworkImage(
//              imageUrl: headImagesList[index],
//              placeholder: (context, url) => new CircularProgressIndicator(strokeWidth: 1.0,),
//              errorWidget: (context, url, error) => new Icon(Icons.warning),
//              fit: BoxFit.fitWidth,
//            );
//          },
//          controller: _swiperController,
//          itemCount: headImagesList.length,
//          itemWidth: double.infinity,
//          layout: SwiperLayout.DEFAULT,
//          pagination: SwiperPagination(),
//          autoplayDelay: 3000,
//          autoplayDisableOnInteraction: true,
//        ),
      );
    }
    return Container();
  }

  Container buyTipsView(List tradeTipsList) {

    List<Widget> tradeTipsViewList = [];
    tradeTipsViewList.add(
        Text(
          '交易提示：',
          style: TextStyle(
            color: AppStyle.colorDark,
            fontSize: ScreenUtil.getInstance().setSp(28.0),
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w600,
          ),
        )
    );
    tradeTipsViewList.add(
        SizedBox(height: ScreenUtil.getInstance().setWidth(40.0))
    );
    if(tradeTipsList.isNotEmpty){
      for(Map item in tradeTipsList){
        tradeTipsViewList.add(
            Text(
              '${item['content']??''}',
              style: TextStyle(
                color: AppStyle.colorDark,
                fontSize: ScreenUtil.getInstance().setSp(24.0),
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
              ),
            )
        );
        tradeTipsViewList.add(
            SizedBox(height: ScreenUtil.getInstance().setWidth(28.0))
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(60.0),
        right: ScreenUtil.getInstance().setWidth(60.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tradeTipsViewList,
      ),
    );
  }

  Widget payTipsContent(String content){
    return Row(
      children: <Widget>[
        SizedBox(width: ScreenUtil.getInstance().setWidth(60.0)),
        Text(
          content,
          style: TextStyle(
            color: AppStyle.colorDark,
            fontSize: ScreenUtil.getInstance().setSp(24.0),
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget payButtonsView(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: ScreenUtil.getInstance().setWidth(60.0)),
        Expanded(
          child: GestureDetector(
            onTap: () => _aliPayMoney(context),
            child: Container(
              height: ScreenUtil.getInstance().setWidth(120.0),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: AppStyle.colorGreyLine,
                    width: 1,
                  )
              ),
              child: Image(image: AssetImage(AssetUtil.image('image-zhi@3x.png')),fit: BoxFit.cover,),
            ),
          ),
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(16.0)),
        Expanded(
          child: GestureDetector(
            onTap: () => _weChatPayMoney(context),
            child: Container(
              height: ScreenUtil.getInstance().setWidth(120.0),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: AppStyle.colorGreyLine,
                    width: 1,
                  )
              ),
              child: Image(image: AssetImage(AssetUtil.image('image-wei.png')),fit: BoxFit.cover,),
            ),
          ),
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(60.0)),
      ],
    );
  }
  Widget payButtonsViewBottom(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: ScreenUtil.getInstance().setWidth(60.0)),
        Expanded(
          child: GestureDetector(
            onTap: () => _aliPayMoney(context),
            child: Container(
              height: ScreenUtil.getInstance().setWidth(102.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(
                    color: AppStyle.colorGreyLine,
                    width: 1,
                  )
              ),
              child: Image(image: AssetImage(AssetUtil.image('image-zhi@3x.png')),fit: BoxFit.contain,),
            ),
          ),
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(16.0)),
        Expanded(
          child: GestureDetector(
            onTap: () => _weChatPayMoney(context),
            child: Container(
              height: ScreenUtil.getInstance().setWidth(102.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(
                    color: AppStyle.colorGreyLine,
                    width: 1,
                  )
              ),
              child: Image(image: AssetImage(AssetUtil.image('image-wei.png')),fit: BoxFit.contain,),
            ),
          ),
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(80.0)),
      ],
    );
  }

  Container showMoneyView(String tips,tipsT,price) {

    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil.getInstance().setWidth(80.0),
        bottom: ScreenUtil.getInstance().setWidth(80.0),
      ),
      width: double.infinity,
      color: AppStyle.colorPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '${tips??''}',
            style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(32.0),
              fontWeight: FontWeight.w400,
              color: AppStyle.colorWhite,
            ),
          ),
          Text(
            '${tipsT??''}',
            style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(32.0),
              fontWeight: FontWeight.w400,
              color: AppStyle.colorWhite,
            ),
          ),
          Text(
            '${price??''}',
            style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(72.0),
              fontWeight: FontWeight.w600,
              color: AppStyle.colorWhite,
            ),
          ),
        ],
      ),
    );
  }
  Container showMoneyViewBottom(String tips,tipsT,price) {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(16.0),
        right: ScreenUtil.getInstance().setWidth(16.0),
      ),
      width: double.infinity,
      color: AppStyle.colorWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '${tips??''}',
            style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(32.0),
              fontWeight: FontWeight.w400,
              color: AppStyle.colorPrimary,
            ),
          ),
          Text(
            '${tipsT??''}',
            style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(32.0),
              fontWeight: FontWeight.w400,
              color: AppStyle.colorPrimary,
            ),
          ),
          Text(
            '${price??''}',
            style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(72.0),
              fontWeight: FontWeight.w600,
              color: AppStyle.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget listTitle(String title){
    return Row(
      children: <Widget>[
        SizedBox(width: ScreenUtil.getInstance().setWidth(60.0)),
        Text(
          title,
          style: TextStyle(
            color: AppStyle.colorDark,
            fontSize: ScreenUtil.getInstance().setSp(32.0),
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget goodInfoItem({String title,content}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: ScreenUtil.getInstance().setWidth(50.0),),
        //富文本
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
              text: '$title:  ',
              style: TextStyle(
                color: AppStyle.colorLight,
                fontSize: ScreenUtil.getInstance().setSp(28.0),
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                    text: content,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                    children: [])
              ]),
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
      ],
    );
  }

  Widget priceInfoItem({String title,content}) {
    return Container(
      padding: EdgeInsets.only(
      ),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: ScreenUtil.getInstance().setWidth(60.0),),
          Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppStyle.colorDark,
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ),
          Expanded(
              child: Text(
                content,
                style: TextStyle(
                  color: AppStyle.colorDark,
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ),
          SizedBox(width: ScreenUtil.getInstance().setWidth(20.0),),
        ],
      ),
    );
  }

  Widget bottomButtonsView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Application.router.pop(context);
                },
                child: Container(
                  width: ScreenUtil.getInstance().setWidth(168.0),
                  height: ScreenUtil.getInstance().setWidth(74.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(74.0)),
                      border: Border.all(
                        color: AppStyle.colorGreyText,
                        width: 0.5,
                      )
                  ),
                  child: Center(
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                        fontWeight: FontWeight.w600,
                        color: AppStyle.colorDark,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setWidth(30.0),),
              Container(
                width: ScreenUtil.getInstance().setWidth(218.0),
                height: ScreenUtil.getInstance().setWidth(74.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(74.0)),
                  color: AppStyle.colorPink,
                ),
                child: Center(
                  child: Text(
                    '下一步',
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                      fontWeight: FontWeight.w600,
                      color: AppStyle.colorWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(100.0),),
        ],
      ),
    );
  }

  Widget dashLineAndStep(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil.getInstance().setWidth(80.0),
      ),
      color: AppStyle.colorPrimary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Container(color: AppStyle.colorPink,height: 2,),),
              SizedBox(width: 5,),
              Container(
                height: ScreenUtil.getInstance().setWidth(24.0),
                width: ScreenUtil.getInstance().setWidth(24.0),
                decoration: BoxDecoration(
                  color: AppStyle.colorWhite,
                  border: Border.all(
                    color: AppStyle.colorPink,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(24.0)),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(child: Container(color: AppStyle.colorPink,height: 2,),),
              SizedBox(width: 5,),
              Container(
                height: ScreenUtil.getInstance().setWidth(24.0),
                width: ScreenUtil.getInstance().setWidth(24.0),
                decoration: BoxDecoration(
                  color: AppStyle.colorWhite,
                  border: Border.all(
                    color: AppStyle.colorPink,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(24.0)),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(child: Container(color: AppStyle.colorPink,height: 2,),),
              SizedBox(width: 5,),
              Container(
                height: ScreenUtil.getInstance().setWidth(24.0),
                width: ScreenUtil.getInstance().setWidth(24.0),
                decoration: BoxDecoration(
                  color: AppStyle.colorWhite,
                  border: Border.all(
                    color: AppStyle.colorPink,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(24.0)),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(child: MySeparator(color: Colors.white,height: 2,),),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
          Row(
            children: <Widget>[
              Expanded(flex: 1,child: Container(height: 1,)),
              Expanded(flex: 2,child: Container(height: 1,)),
              Expanded(flex: 2,child: Container(height: 1,)),
              Expanded(flex: 2,child: Container(
                height: 30,
                child: Center(
                  child: Text(
                    '确认订单并付款',
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(24.0),
                      color: AppStyle.colorWhite,
                    ),
                  ),
                ),
              )),
              Expanded(flex: 1,child: Container(height: 1,)),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(30),),
        ],
      ),
    );
  }

  Widget barView(BuildContext context,Color backgroundColor){
    return Container(
        height: MediaQueryData.fromWindow(window).padding.top + 56.0,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top,
              left:  ScreenUtil.getInstance().setWidth(40.0),
              right:  ScreenUtil.getInstance().setWidth(40.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Application.router.navigateTo(context,Routes.home,clearStack:true,transition: TransitionType.native);
                  },
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
//                            color: Colors.red
                    ),
                    alignment: Alignment.center,
                    child: Image(image: AssetImage(AssetUtil.image('logo-bl copy@3x.png')),fit: BoxFit.fitHeight,),
                  ),
                ),
                Expanded(child: SizedBox(height: 1,)),
                GestureDetector(
                  onTap: (){
                    NavigatorUtil.push(
                        context,
                        WebViewState(
                          title: 'FAQ',
                          url: 'http://www.baidu.com',
                        ));
                  },
                  child: Container(
                    child: Text(
                      'FAQ',
                      style: TextStyle(
                          color: AppStyle.colorLight
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

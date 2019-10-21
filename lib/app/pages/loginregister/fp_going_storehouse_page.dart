
import 'dart:async';

import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:fake_alipay/fake_alipay.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/fp_count.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoingStarehousePage extends StatefulWidget {
  final String number;
  const GoingStarehousePage({Key key, this.number}) : super(key: key);
  @override
  _GoingStarehousePageState createState() =>
      _GoingStarehousePageState();
}

class _GoingStarehousePageState extends State<GoingStarehousePage>
    with SingleTickerProviderStateMixin {
  List ar = [];
  Map detail = {
  };
  bool _isLogin = false; //是否登录
  String imgUrl = '';
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  Map userMap = {};
  List shdz = [];
  Map shdzMap = {};
   Alipay alipay = Alipay();
  StreamSubscription<AlipayResp> _pay;
  CountModule count = new CountModule('文章详情');
  @override
  void initState() {
    super.initState();
    count.openPage();
     _pay = alipay.payResp().listen(_listenPay);

    fluwx.responseFromPayment.listen((response){
      //do something
      switch (response.errCode) {
        
        case 0:
          showToast('订单支付成功');
          Application.router.navigateTo(context, Routes.home);
          break;
        case -2:
          showToast('用户中途取消');
          break;
        default:
          showToast('支付失败');
          break;
      }
    });

    WidgetsBinding bind = WidgetsBinding.instance;
    bind.addPostFrameCallback((callback) {
      //加载数据
      getUserMessage();
    });
  }
   getUserMessage(){
    ApiConfig().getAccount().then((onValue){
       if(onValue == null){return;}
       if(onValue['rspCode'] != '0000'){
          showToast(onValue['rspDesc'],
          );
          return;
       }
       UserInfoCache().setUserInfo(userInfo: onValue);
       UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
       userMap = onValue;
       shdz = [];
       for (var item in onValue['addrs']) {
           if(item['type'] == '1'){
             shdz.add(item);
           }
         }
       if(shdz.length > 0){
         shdzMap = shdz[0];
       }
       if(mounted){
         setState(() {
       });
       }
     });

  }
  void _listenPay(AlipayResp resp) {
    String content = 'pay: ${resp.resultStatus} - ${resp.result}';
    showToast(content);
  }
  @override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
        UserInfoCache().getMapInfo(key: UserInfoCache.buyInfo).then((onValue){
          if(onValue == null || onValue == {})return;
          
           setState(() {
          shdzMap = onValue;
        });
          UserInfoCache().setMapInfo(key: UserInfoCache.buyInfo, map: {});
        });
        setState(() {
          _isLogin = onValue == '1'?true:false;

        });
    });
    }
  }

///退出登录设置
leaveLogIn(BuildContext context){
  setState(() {
    _isLogin = false;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: mydrawer,
      drawerScrimColor: Colors.transparent,
      key: _scaffoldkey,
      backgroundColor: Colors.white,
      appBar: myappbar(context, true, _isLogin,sckey: _scaffoldkey,leaveLogIn: leaveLogIn,image: imgUrl),
      body: userMap.length == 0
          ? LoadingDialog(
              //调用对话框
              text: '正在加载...',
            )
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.all(0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        shdzMap.length>0? Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              border: Border.all(
                                color: AppStyle.colorBackground,
                                width: 1,
                              )
                          ),
                          margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                          padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(20)),
                          alignment: Alignment.bottomLeft,
                          child: Text('收货地址',style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w500,)),),
                    Container(width: 70,height: 3,color: Colors.black,margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(20)),),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
                          Container(
                // color: AppStyle.colorBackground,
                padding: EdgeInsets.all(10),
                // margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                     Expanded(
                       flex: 9,
                       child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text('收货人',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(32),color: AppStyle.colorPrimary)),
                                ),
                                 Expanded(child: SizedBox(height: 1,)),
                                Container(
                                  child: Text(shdzMap['name']??'',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(32),color: AppStyle.colorPrimary)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text('手机号码',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(32),color: AppStyle.colorPrimary)),
                                ),
                                 Expanded(child: SizedBox(height: 1,)),
                                Container(
                                  child: Text(shdzMap['phone']??'',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(32),color: AppStyle.colorPrimary)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
                          Container(
//                                  child: Text('收货地址:  '+shdzMap['province']??''+'  '+shdzMap['city']??''+'  '+shdzMap['district']??''+'  '+shdzMap['addr']??'',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(32),color: AppStyle.colorPrimary),maxLines: 4,),
                                ),
                        ],
                      ),
                    ),
                     ),
                    Container(width: 0.5,height: 40,color: AppStyle.colorPrimary,margin: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(20)),),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                      child: new Text('更改',style:  TextStyle(fontSize: ScreenUtil.getInstance().setWidth(28))),
                      onPressed: () {
                        //地址管理
                        Application.router.navigateTo(context, '${Routes.AddressManagePage}?number=${'1'}',transition: TransitionType.native);
                      },
                      ),
                      )
                    )
                  ],
                ),
              ),
                            ],
                          ),
                        ):Center(
              child: Container(
                margin: EdgeInsets.only(top: 50,bottom: 50),
                width: 200,
                height: 40,
                child: RaisedButton(
                           color: AppStyle.colorWhite,
                            shape:new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)) ,
                            child: Container(
                              alignment: Alignment.center,
                              width: ScreenUtil.getInstance().setHeight(200),
                              child:  Text(
                              '添加收货地址',
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(28),
                                color: AppStyle.colorPrimary,
                                
                              ),
                              ),
                            ),
                            elevation: 2.0,/// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                  onPressed: (){
                    Application.router.navigateTo(context, '${Routes.AddressManagePage}?number=${'1'}',transition: TransitionType.native);
                  },
                ),
              ),
            ),
                        SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
                      Container(
                          child: Text('您需要支付的出仓费用',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(38),color: AppStyle.colorPrimary),maxLines: 4,),
                        ),
                        SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
                      Container(
                          child: Text('¥23.00',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(50),color: AppStyle.colorPrimary,fontWeight: FontWeight.w900)),
                        ),
                      SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
                      Container(
                          child: Text('请选择支付方式',style: TextStyle(fontSize: ScreenUtil.getInstance().setWidth(38),color: AppStyle.colorPrimary),maxLines: 4,),
                        ),
                        SizedBox(height: ScreenUtil.getInstance().setWidth(40),),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                               GestureDetector(
                        onTap: (){
                          if(shdzMap.length == 0){
                            showToast('先填写收货地址');
                            return;
                          }
                          ApiConfig().aliPayMoney(widget.number).then((onValue){
                            if (onValue['rspCode'] != '0000') {
                              showToast(onValue['rspDesc']);
                              return;
                            }
                            //支付宝支付
                            alipay.payOrderSign(orderInfo:onValue['invokeData']).then((onValue){

                            });
                          });

                        },
                        child: Container(
                          height: ScreenUtil.getInstance().setWidth(120.0),
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
                      SizedBox(width: ScreenUtil.getInstance().setWidth(40),),
                      GestureDetector(
                        onTap: (){
                          if(shdzMap.length == 0){
                            showToast('先填写收货地址');
                            return;
                          }
                          ApiConfig().wXPayMoney(widget.number).then((onValue){
                            if (onValue['rspCode'] != '0000') {
                              showToast(onValue['rspDesc']);
                              return;
                            }
                            //微信支付
                            fluwx.pay(
                              appId: onValue['appId'],
                              partnerId: onValue['mchId'],
                              prepayId: onValue['prepayId'],
                              packageValue: onValue['pack'],
                              nonceStr: onValue['nonceStr'],
                              timeStamp: onValue['timeStamp'],
                              sign:onValue['wxSign'],
                            ).then((data) {

                            });
                          });

                        },
                        child: Container(
                          height: ScreenUtil.getInstance().setWidth(130.0),
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
                            ],
                          )
                        ),
                     
                        
                      ],
                    ),
                  )
                ),
                Positioned(
                  bottom: 20.0,
                  left: 20.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppStyle.colorWhite,
                    ),
                    child: IconButton(
                      color: AppStyle.colorPrimary,
                      icon: Icon(
                        Icons.drag_handle,
                        size: 30.0,
                      ),
                      onPressed: () {
                        _scaffoldkey.currentState.openDrawer();
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  

  @override
  void dispose() {
    super.dispose();
    if (_pay != null) {
      _pay.cancel();
    }
    count.endPage();
  }

}
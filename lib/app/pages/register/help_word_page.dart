import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';

class HelpWordPage extends StatefulWidget {
  @override
  _HelpWordPageState createState() => _HelpWordPageState();
}

class _HelpWordPageState extends State<HelpWordPage> {

  String helpWord = '',phoneNumber,loginPassword;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    UserInfoCache().getInfo(key: UserInfoCache.helpWordKey).then((onValue){
      setState(() {
        helpWord = onValue;
      });
    });

  }

  void goLogin ()async{

    phoneNumber = await UserInfoCache().getInfo(key: UserInfoCache.phoneNumber);
    loginPassword = await UserInfoCache().getInfo(key: UserInfoCache.loginPassword);

//    print('phoneNumber = $phoneNumber,loginPassword = $loginPassword');

    //请求登录数据
    HttpUtil().post(
        '${ApiConfig.baseUrl}${ApiConfig.loginUrl}',
        data: {
          'account':'$phoneNumber',
          'password':'$loginPassword',
        }).then((response){

      Navigator.pop(context); //关闭对话框

//                    debugPrint(response.toString());
      if(response['error'] != 0){
        //弹窗
        Fluttertoast.showToast(
            msg: response['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }

      //请求网络数据
      HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.sessionIdUrl}',).then((response){
        if(response['error'] != 0){
          Fluttertoast.showToast(
              msg: response['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 2,
              backgroundColor: AppStyle.colorGreyDark,
              textColor: Colors.white,
              fontSize: 16.0
          );
          return;
        }
        //注册成功保存 session id
        UserInfoCache().saveInfo(key: UserInfoCache.sessionId,value: response['message']);
      });

      //登录成功缓存用户信息
      UserInfoCache().setUserInfo(userInfo: response['message']['user']);

      Application.cache?.setInt(Application.SplashCacheKey, 0);
      Application.router.navigateTo(context, Routes.index);

    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('备份助记词'),
        leading: Text(''),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: 2,child: SizedBox(),),
            Icon(
              AppIcon.edit,
              size: ScreenUtil.getInstance().setHeight(120.0),
              color: AppStyle.colorSecondary,
            ),
            SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
            Text(
              '抄写你的钱包助记词',
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(32.0),
              ),
            ),
            Expanded(flex: 1,child: SizedBox(),),
            Container(
              width: double.infinity,
              height: ScreenUtil.getInstance().setHeight(300),
              padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(32),),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(32),),
                  border: Border.all(
                    color: AppStyle.colorSecondary,
                    width: 2.0,
                  )
                ),
                padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0),),
                child: RichText(
                  text: TextSpan(
                    text: '$helpWord',
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(32.0),
                      color: AppStyle.colorDark,
                    )
                  )
                ),
              ),
            ),
            Expanded(flex: 1,child: SizedBox(),),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(32.0)),
              child: RaisedButton(
                color: AppStyle.colorBegin,
                child: Text(
                  '进入',
                  style: TextStyle(
                      color: AppStyle.colorLight,
                      fontSize: ScreenUtil.getInstance().setSp(30)
                  ),
                ),
                elevation: 0.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                onPressed: goLogin,
                shape: StadiumBorder(),//球场形状
//                            RoundedRectangleBorder(
//                                borderRadius: BorderRadius.only(
//                                    topLeft:Radius.circular(15.0),
//                                    bottomRight:Radius.circular(15.0),
//                                ),
//                            ),
              ),
            ),
            Expanded(flex: 1,child: SizedBox(),),
            Text(
              '请勿截图',
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(28),
                color: AppStyle.colorDanger,
              ),
            ),
            Text(
              '如果有人获取你的助记词将直接获取你的资产!',
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(28),
                color: AppStyle.colorDanger,
              ),
            ),
            Text(
              '请抄下助记词并存放在安全的地方。',
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(28),
                color: AppStyle.colorDanger,
              ),
            ),
            Expanded(flex: 2,child: SizedBox(),),
          ],
        ),
      ),
    );
  }
}

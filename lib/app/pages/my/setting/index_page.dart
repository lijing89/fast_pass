import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class SettingIndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Column(
          children: <Widget>[
            ItemView(
                '修改登录密码',Icon(AppIcon.right),(){
              Application.router.navigateTo(context, Routes.modifyLoginPassword);
            }
            ),
            ItemView('修改支付密码', Icon(AppIcon.right),(){
              Application.router.navigateTo(context, Routes.modifyPaymentPassword);
            }),
            ItemView('清除缓存', Container(),(){
              print('清除缓存');
              //弹窗
              Fluttertoast.showToast(
                  msg: "清除成功!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 2,
                  backgroundColor: AppStyle.colorGreyDark,
                  textColor: Colors.white,
                  fontSize: 16.0
              );

              UserInfoCache().clearCache();

            }),
            SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
            Center(
              child: InkWell(
                onTap: (){
                  print('退出登录');
                  UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '0');
                  Application.cache?.setInt(Application.SplashCacheKey, 0);
                  Application.router.navigateTo(context, Routes.login);
                },
                child: Text(
                  '安全退出',
                  style: TextStyle(
                      color: AppStyle.colorDanger
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}

class ItemView extends StatelessWidget {
  String _title;
  Function _onTapFunction;
  Widget _rightWidget;
  ItemView(this._title,this._rightWidget,this._onTapFunction);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTapFunction,
      child: Container(
        width: double.infinity,
        height: ScreenUtil.getInstance().setWidth(100.0),
        padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(32.0),),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1,color: AppStyle.colorGrey))
          ),
          child:
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _title,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(32.0)
                  ),
                ),
                Expanded(child: SizedBox(height: 1,)),
                _rightWidget,
                SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
              ],
            ),

        ),
      ),
    );
  }
}

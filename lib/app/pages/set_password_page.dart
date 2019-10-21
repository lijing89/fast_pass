import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class SetPasswordPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text('设置密码'),
            ),
            body: Theme(
                data: Theme.of(context).copyWith(
                    primaryColor: AppStyle.colorPrimary
                ),
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                        // 触摸收起键盘
                        FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
                            Container(
                                margin: EdgeInsets.only(
                                    left:ScreenUtil.getInstance().setWidth(64.0),
                                    right: ScreenUtil.getInstance().setWidth(64.0),
                                ),
                                child: RegisterFromDemo(),
                            ),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
                        ],
                    ),
                ),
            ),
        );
    }
}


class RegisterFromDemo extends StatefulWidget {
    @override
    _RegisterFromDemoState createState() => _RegisterFromDemoState();
}

class _RegisterFromDemoState extends State<RegisterFromDemo> {

    final registerFormKey = GlobalKey<FormState>();
    String newPassword,againPassword;
    bool autoValidate = false;

    void _gotoLogin() async{
        Application.cache?.setInt(Application.SplashCacheKey, 0);
        Application.router.navigateTo(context, Routes.login);

    }

    void setPassword (){

        registerFormKey.currentState.save();

        if(registerFormKey.currentState.validate()){

            debugPrint('newPassword:$newPassword');
            debugPrint('againPassword:$againPassword');

            _gotoLogin();//保存信息后退出登录页

        }else{
            setState(() {
                autoValidate = true;
            });
        }
    }

    String validateNewPassword (value){
        if(value.isEmpty){
            return '新密码不能为空.';
        }
        if(value.length < 6){
            return '新密码不能小于6位.';
        }
    }
    String validateNewPasswordAgain (value){
        if(value.isEmpty){
            return '重复密码不能为空.';
        }
        if(value != againPassword){
            return '重复密码与新密码不一致.';
        }
    }

    @override
    Widget build(BuildContext context) {
        return Form(
            key: registerFormKey,
            child: Column(
                children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(
//                            fillColor: AppStyle.colorLight,
                            icon: Icon(
                                Icons.vpn_key,
//                                color: AppStyle.colorSecondary,
                            ),
                            labelText: '新密码',
                            labelStyle: TextStyle(
//                                color: Colors.white,
                            ),
                        ),
                        onSaved: (value){
                            newPassword = value;
                        },
                        validator: validateNewPassword,
                        autovalidate: autoValidate,
                        style: TextStyle(
//                            color: AppStyle.colorLight
                        ),
                    ),
                    TextFormField(
                        obscureText: false,
                        decoration: InputDecoration(
                            icon: Icon(
                                Icons.vpn_key,
//                                color: AppStyle.colorSecondary,
                            ),
                            labelText: '重复密码',
                            labelStyle: TextStyle(
//                                        color: Colors.white,
                            ),
                            helperText: '请输入6位以上密码',
                            helperStyle: TextStyle(
                                color: AppStyle.colorSecondary,
                            ),
                        ),
                        onSaved: (value){
                            againPassword = value;
                        },
                        validator: validateNewPasswordAgain,
                        autovalidate: autoValidate,
                        style: TextStyle(
//                                    color: AppStyle.colorLight
                        ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
                    Container(
                        width: double.infinity,
                        child: RaisedButton(
                            child: Text(
                                '下一步',
                                style: TextStyle(
                                    color: AppStyle.colorBegin,
                                    fontSize: ScreenUtil.getInstance().setSp(30.0),
                                ),
                            ),
                            elevation: 2.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                            onPressed: setPassword,
                            shape: StadiumBorder(),//球场形状
                            color: AppStyle.colorPrimary,
//                            RoundedRectangleBorder(
//                                borderRadius: BorderRadius.only(
//                                    topLeft:Radius.circular(15.0),
//                                    bottomRight:Radius.circular(15.0),
//                                ),
//                            ),
                        ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
                ],
            ),
        );
    }
}
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';

class ModifyPaymentPasswordPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text('修改支付密码'),
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
                                child: ModifyPaymentPasswordFromDemo(),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}


class ModifyPaymentPasswordFromDemo extends StatefulWidget {
    @override
    _ModifyPaymentPasswordFromDemoState createState() => _ModifyPaymentPasswordFromDemoState();
}

class _ModifyPaymentPasswordFromDemoState extends State<ModifyPaymentPasswordFromDemo> {

    final registerFormKey = GlobalKey<FormState>();
    String oldPassword,newPassword,againPassword;
    bool autoValidate = false;


    void setPassword (){

        registerFormKey.currentState.save();
        //验证是否通过
        if(registerFormKey.currentState.validate()){

//            debugPrint('newPassword:$newPassword');
//            debugPrint('againPassword:$againPassword');
            HttpUtil().post(
                '${ApiConfig.updateUserInfoUrl}',
                data: {
                    'obj':'paypwd',
                    'password':oldPassword,
                    'repassword':againPassword
                }).then((response){

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
                //修改成功
                if(response['error'] == 0){
                    //简单计时器
                    Timer(Duration(seconds: 2),(){
                        Application.router.pop(context);
                    });
                };
                return;
            });

        }else{
            setState(() {
                autoValidate = true;
            });
        }
    }
    String validateOldPassword(value){
        if(value.isEmpty){
            return '旧密码不能为空';
        }
        if(value.length < 6){
            return '旧密码不能小于6位.';
        }
        oldPassword = value;
    }
    String validateNewPassword (value){
        if(value.isEmpty){
            return '新密码不能为空.';
        }
        if(value.length < 6){
            return '新密码不能小于6位.';
        }
        againPassword = value;
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
                            labelText: '旧密码',
                            labelStyle: TextStyle(
//                                color: Colors.white,
                            ),
                        ),
                        onSaved: (value){
                            oldPassword = value;
                        },
                        validator: validateNewPassword,
                        autovalidate: autoValidate,
                        style: TextStyle(
//                            color: AppStyle.colorLight
                        ),
                    ),
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
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 20.0),
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
                ],
            ),
        );
    }
}
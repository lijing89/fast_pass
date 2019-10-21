import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/http_util.dart';

class ModifyNicknamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('修改昵称'),
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
  String nickname;
  bool autoValidate = false;

  void commitNewNickname (){

    registerFormKey.currentState.save();

    if(registerFormKey.currentState.validate()){

      debugPrint('nickname:$nickname');

      HttpUtil().post(

          '${ApiConfig.updateUserInfoUrl}',
          data: {
            'obj':'title',
            'user_title':nickname

          }).then((response){
            print(response);
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


          UserInfoCache().getUserInfo().then((onValue){
            onValue['name'] = nickname;
            UserInfoCache().setUserInfo(userInfo: onValue);
          });

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

  String validateNickname (value){
    if(value.isEmpty){
      return '新昵称不能为空.';
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
                Icons.mode_edit,
//                                color: AppStyle.colorSecondary,
              ),
              labelText: '新昵称',
              labelStyle: TextStyle(
//                                color: Colors.white,
              ),
//              hintText: '请输入你的新昵称.',
            ),
            onSaved: (value){
              nickname = value;
            },
            validator: validateNickname,
            autovalidate: autoValidate,
            style: TextStyle(
//                            color: AppStyle.colorLight
            ),

          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
          Container(
            width: double.infinity,
            child: RaisedButton(
              child: Text(
                '修改',
                style: TextStyle(
                  color: AppStyle.colorBegin,
                  fontSize: ScreenUtil.getInstance().setSp(30.0),
                ),
              ),
              elevation: 2.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
              onPressed: commitNewNickname,
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
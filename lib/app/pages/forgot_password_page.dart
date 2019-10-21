import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class ForgotPasswordPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text('忘记密码'),
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
    String username,verificationCode;
    bool autoValidate = false;
    static const _splashCacheKey = 'fast_pass:splash:int';

    void _gotoIndex() async{
        Application.router.navigateTo(context, Routes.setPassword);
    }

    void setPassword (){

        if(registerFormKey.currentState.validate()){

            registerFormKey.currentState.save();

            debugPrint('username:$username');
            debugPrint('verificationCode:$verificationCode');

            _gotoIndex();//保存信息后退出登录页

        }else{
            setState(() {
                autoValidate = true;
            });
        }
    }

    String validateUsername (value){
        if(value.isEmpty){
            return '手机号不能为空.';
        }
        if(!Application.isChinaPhoneLegal(value)){
            return '请输入正确的手机号.';
        }else{
            //请求网络验证手机号是否注册过
        }
    }
    String validateVerificationCode (value){
        if(value.isEmpty){
            return '验证码不能为空.';
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
                                Icons.smartphone,
                                color: AppStyle.colorSecondary,
                            ),
                            labelText: '手机号',
                            labelStyle: TextStyle(
//                                color: Colors.white,
                            ),
                        ),
                        onSaved: (value){
                            username = value;
                        },
                        validator: validateUsername,
                        autovalidate: autoValidate,
                        style: TextStyle(
//                            color: AppStyle.colorLight
                        ),
                    ),
                    Stack(
                        alignment: Alignment(0 , 0),
                        children: <Widget>[
                            TextFormField(
                                obscureText: false,
                                decoration: InputDecoration(
                                    icon: Icon(
                                        Icons.security,
                                        color: AppStyle.colorSecondary,
                                    ),
                                    labelText: '验证码',
                                    labelStyle: TextStyle(
//                                        color: Colors.white,
                                    ),
                                ),
                                onSaved: (value){
                                    verificationCode = value;
                                },
                                validator: validateVerificationCode,
                                autovalidate: autoValidate,
                                style: TextStyle(
//                                    color: AppStyle.colorLight
                                ),
                            ),
                            Row(
                                children: <Widget>[
                                    Expanded(child: SizedBox(height: 1,),),
                                    Container(
                                        height: ScreenUtil.getInstance().setWidth(ScreenUtil.getInstance().setWidth(64.0),),
                                        width: 1,
                                        color: AppStyle.colorSecondary,
                                    ),
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                                    LoginFormCode(countdown: 60,available: true,onTapCallback: (){
                                        print('发送验证码');
                                    },),
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                                ],
                            )
                        ],
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
                            elevation: 0.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
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

/// 墨水瓶（`InkWell`）可用时使用的字体样式。
final TextStyle _availableStyle = TextStyle(
    fontSize: ScreenUtil.getInstance().setSp(32.0),
    color: AppStyle.colorSecondary,
);

/// 墨水瓶（`InkWell`）不可用时使用的样式。
final TextStyle _unavailableStyle = TextStyle(
    fontSize: ScreenUtil.getInstance().setSp(32.0),
    color: AppStyle.colorDark,
);

class LoginFormCode extends StatefulWidget {
    /// 倒计时的秒数，默认60秒。
    final int countdown;
    /// 用户点击时的回调函数。
    final Function onTapCallback;
    /// 是否可以获取验证码，默认为`false`。
    final bool available;

    LoginFormCode({
        this.countdown: 60,
        this.onTapCallback,
        this.available: false,
    });

    @override
    _LoginFormCodeState createState() => _LoginFormCodeState();
}

class _LoginFormCodeState extends State<LoginFormCode> {
    /// 倒计时的计时器。
    Timer _timer;
    /// 当前倒计时的秒数。
    int _seconds;
    /// 当前墨水瓶（`InkWell`）的字体样式。
    TextStyle inkWellStyle = _availableStyle;
    /// 当前墨水瓶（`InkWell`）的文本。
    String _verifyStr = '获取验证码';

    @override
    void initState() {
        super.initState();
        _seconds = widget.countdown;
    }

    @override
    void dispose() {
        // TODO: implement dispose
        super.dispose();
        _cancelTimer();
    }
    /// 启动倒计时的计时器。
    void _startTimer() {
        // 计时器（`Timer`）组件的定期（`periodic`）构造函数，创建一个新的重复计时器。
        _timer = Timer.periodic(
            Duration(seconds: 1),
                (timer) {
                if (_seconds == 0) {
                    _cancelTimer();
                    _seconds = widget.countdown;
                    inkWellStyle = _availableStyle;
                    setState(() {});
                    return;
                }
                _seconds--;
                _verifyStr = '已发送$_seconds'+'s';
                setState(() {});
                if (_seconds == 0) {
                    _verifyStr = '重新发送';
                }
            });
    }

    /// 取消倒计时的计时器。
    void _cancelTimer() {
        // 计时器（`Timer`）组件的取消（`cancel`）方法，取消计时器。
        _timer?.cancel();
    }

    @override
    Widget build(BuildContext context) {
        // 墨水瓶（`InkWell`）组件，响应触摸的矩形区域。
        return widget.available ? InkWell(
            child: Text(
                '  $_verifyStr  ',
                style: inkWellStyle,
            ),
            onTap: (_seconds == widget.countdown) ? () {
                _startTimer();
                inkWellStyle = _unavailableStyle;
                _verifyStr = '已发送$_seconds'+'s';
                setState(() {});
                widget.onTapCallback();
            } : null,
        ): InkWell(
            child: Text(
                '  获取验证码  ',
                style: _unavailableStyle,
            ),
        );
    }
}
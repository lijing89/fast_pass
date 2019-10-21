import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';

class RegisterPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Theme(
                data: Theme.of(context).copyWith(
                    primaryColor: Colors.white
                ),
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                        // 触摸收起键盘
                        FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppStyle.colorDark,
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(128),),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                            width: ScreenUtil.getInstance().setWidth(400.0),
                                            child: Image(image: AssetImage(AssetUtil.image('icon.jpeg')),fit: BoxFit.fitWidth,),
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(128),),
                                    Text(
                                        'UWallet',
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance().setSp(72.0),
                                            fontWeight: FontWeight.w400,
                                            color: AppStyle.colorLight,
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(64),),
                                    Container(
                                        margin: EdgeInsets.only(left:32.0,right: 32.0),
                                        child: RegisterFromDemo(),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(128),),
                                ],
                            ),
                        ),
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
    String phoneNumber,password,verificationCode,inviteCode,ppassword;
    bool autoValidate = false,_isAvailable = true;
    void _gotoHelpWord() async{
        Application.router.navigateTo(context, Routes.helpWord);
    }

    void submitRegistInfo (){

        if(registerFormKey.currentState.validate()){

            registerFormKey.currentState.save();

            debugPrint('phoneNumber:$phoneNumber');
            debugPrint('password:$password');
            debugPrint('ppassword:$ppassword');
            debugPrint('verificationCode:$verificationCode');
            debugPrint('inviteCode:$inviteCode');

            //显示加载动画
            showDialog<Null>(
                context: context, //BuildContext对象
                barrierDismissible: false,
                builder: (BuildContext context) {
                    return new LoadingDialog( //调用对话框
                        text: '正在获取详情...',
                    );
                });

            //请求网络数据
            HttpUtil().post(
                '${ApiConfig.baseUrl}${ApiConfig.registerUrl}',
                data: {
                    'mobile':phoneNumber,
                    'password':password,
                    'repassword':password,
                    'mobile_code':verificationCode,
                    'rec_name':inviteCode,
                    'ppassword':ppassword,
                }).then((response){
                print(response.toString());
                //退出加载动画
                Navigator.pop(context); //关闭对话框
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
                //注册成功保存助记词
                UserInfoCache().saveInfo(key: UserInfoCache.helpWordKey,value: response['message']['moc']);
                UserInfoCache().saveInfo(key: UserInfoCache.phoneNumber,value: phoneNumber);
                UserInfoCache().saveInfo(key: UserInfoCache.loginPassword,value: password);
                UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
                _gotoHelpWord();//保存信息后退出登录页
            });

        }else{
            setState(() {
                autoValidate = true;
            });
        }
    }

    String validatephoneNumber (value){
        if(value.isEmpty){
            _isAvailable = false;
            return '手机号不能为空.';
        }
        if(!Application.isChinaPhoneLegal(value)){
            _isAvailable = false;
            return '请输入正确的手机号.';
        }else{
            //请求网络验证手机号是否注册过
            _isAvailable = true;
            return null;
        }
    }
    String validatePassword (value){
        if(value.isEmpty){
            return '密码不能为空.';
        }
        if(value.length < 6){
            return '密码不能少于6位.';
        }
        password = value;
    }
    String validatePPassword (value){
        if(value.isEmpty){
            return '支付密码不能为空.';
        }
        if(value.length < 6){
            return '支付密码不能少于6位.';
        }
        if(value == password){
            return '支付密码不能和登录密码相同.';
        }
    }
    String validateVerificationCode (value){
        if(value.isEmpty){
            return '验证码不能为空.';
        }
    }
    String validateInviteCode (value){
        if(value.isEmpty){
            return '邀请手机号不能为空.';
        }
    }

    void _getVerificationCode(){

        registerFormKey.currentState.save();//保存信息
        if(validatephoneNumber(phoneNumber) != null){
            registerFormKey.currentState.validate();//开启验证
            //弹窗
            Fluttertoast.showToast(
                msg: "请输入正确的手机号,再获取验证码!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 2,
                backgroundColor: AppStyle.colorGreyDark,
                textColor: Colors.white,
                fontSize: 16.0
            );

        }else{
            //显示加载动画
            showDialog<Null>(
                context: context, //BuildContext对象
                barrierDismissible: false,
                builder: (BuildContext context) {
                    return new LoadingDialog( //调用对话框
                        text: '正在获取详情...',
                    );
                });

            //请求网络数据
            HttpUtil().post(
                '${ApiConfig.baseUrl}${ApiConfig.verificationCodeUrl}',
                data: {
                    'mobile':phoneNumber,
                }).then((response){
                print(response.toString());
                //退出加载动画
                Navigator.pop(context); //关闭对话框
                if(response['message']['status'] == 'fail'){
                    Fluttertoast.showToast(
                        msg: response['msg'],
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                }
            });

        }

        print('发送验证码');
    }

    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
        return Form(
            key: registerFormKey,
            child: Column(
                children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(
                            fillColor: AppStyle.colorLight,
                            icon: Icon(
                                Icons.smartphone,
                                color: AppStyle.colorLight,
                            ),
                            labelText: '手机号',
                            labelStyle: TextStyle(
                                color: Colors.white,
                            ),
                        ),
                        onSaved: (value){
                            phoneNumber = value;
                        },
                        validator: validatephoneNumber,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorLight
                        ),
                    ),
                    TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            icon: Icon(
                                Icons.vpn_key,
                                color: AppStyle.colorLight,
                            ),
                            labelText: '密码',
                            labelStyle: TextStyle(
                                color: Colors.white,
                            ),
                            helperText: '请输入6位以上密码',
                            helperStyle: TextStyle(
                                color: AppStyle.colorSecondary,
                            ),
                        ),
                        onSaved: (value){
                            password = value;
                        },
                        validator: validatePassword,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorLight
                        ),
                    ),
                    TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            icon: Icon(
                                Icons.vpn_key,
                                color: AppStyle.colorLight,
                            ),
                            labelText: '支付密码',
                            labelStyle: TextStyle(
                                color: Colors.white,
                            ),
                            helperText: '请输入6位以上支付密码',
                            helperStyle: TextStyle(
                                color: AppStyle.colorSecondary,
                            ),
                        ),
                        onSaved: (value){
                            ppassword = value;
                        },
                        validator: validatePPassword,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorLight
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
                                        color: AppStyle.colorLight,
                                    ),
                                    labelText: '验证码',
                                    labelStyle: TextStyle(
                                        color: Colors.white,
                                    ),
                                ),
                                onSaved: (value){
                                    verificationCode = value;
                                },
                                validator: validateVerificationCode,
                                autovalidate: autoValidate,
                                style: TextStyle(
                                    color: AppStyle.colorLight
                                ),
                            ),
                            Row(
                                children: <Widget>[
                                    Expanded(child: SizedBox(height: 1,),),
                                    Container(
                                        height: ScreenUtil.getInstance().setWidth(32),
                                        width: 1,
                                        color: AppStyle.colorLight,
                                    ),
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                    LoginFormCode(countdown: 60,available: _isAvailable,onTapCallback: _getVerificationCode,),
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                ],
                            )
                        ],
                    ),
                    TextFormField(
                        obscureText: false,
                        decoration: InputDecoration(
                            icon: Icon(
                                Icons.card_membership,
                                color: AppStyle.colorLight,
                            ),
                            labelText: '邀请手机号',
                            labelStyle: TextStyle(
                                color: Colors.white,
                            ),
                        ),
                        onSaved: (value){
                            inviteCode = value;
                        },
                        validator: validateInviteCode,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorLight
                        ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
                    Container(
                        width: double.infinity,
                        child: RaisedButton(
                            color: AppStyle.colorBegin,
                            child: Text(
                                '注册',
                                style: TextStyle(
                                    color: AppStyle.colorLight,
                                    fontSize: ScreenUtil.getInstance().setSp(30.0)
                                ),
                            ),
                            elevation: 0.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                            onPressed: submitRegistInfo,
                            shape: StadiumBorder(),//球场形状
//                            RoundedRectangleBorder(
//                                borderRadius: BorderRadius.only(
//                                    topLeft:Radius.circular(15.0),
//                                    bottomRight:Radius.circular(15.0),
//                                ),
//                            ),
                        ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
                    Container(
                        width: double.infinity,
                        child: Center(
                            child:
                            GestureDetector(
                                onTap: (){
                                    Application.router.navigateTo(context, Routes.login);
                                    print('我有账号,直接登录');
                                },
                                child: Text(
                                    '我有账号,直接登录',
                                    style: TextStyle(
                                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                                        color: AppStyle.colorBegin,
                                    ),
                                ),
                            ),
                        ),
                    ),
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
    color: AppStyle.colorLight,
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
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class LoginPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {

        //假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334),设置字体大小根据系统的“字体大小”辅助选项来进行缩放,默认为false
        //默认设计稿为6p7p8p尺寸 width : 1080px , height:1920px , allowFontScaling:false
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

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
                        padding: EdgeInsets.all(0.0),
                        color: AppStyle.colorDark,
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    SizedBox(height: ScreenUtil.getInstance().setHeight(96),),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                            width: 200,
                                            child: Image(image: AssetImage(AssetUtil.image('icon.jpeg')),fit: BoxFit.fitWidth,),
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
                                    Text(
                                        'UWallet',
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance().setSp(72.0),
                                            fontWeight: FontWeight.w400,
                                            color: AppStyle.colorLight,
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
                                    Container(
                                        margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(64.0)),
                                        child: RegisterFromDemo(),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
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

    final loginFormKey = GlobalKey<FormState>();
    String phoneNumber='',password='';
    bool autoValidate = false;

    @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setInitValue();

  }

  Future setInitValue() async {
      phoneNumber = await UserInfoCache().getInfo(key: UserInfoCache.phoneNumber);

      password = await UserInfoCache().getInfo(key: UserInfoCache.loginPassword);

      String status = await UserInfoCache().getInfo(key: UserInfoCache.loginStatus);

      print('phone:$phoneNumber,password:$password,loginStatus:$status');

      if(status == '1'){
          print('自动登录');
          _login();
      }else{
          setState(() {
              phoneNumber = phoneNumber;
              password = password;
          });
      }
  }

    void _gotoIndex() async{
        Application.cache?.setInt(Application.SplashCacheKey, 0);
        Application.router.navigateTo(context, Routes.index,transition: TransitionType.native);
    }

    void _login(){

        showDialog<Null>(
            context: context, //BuildContext对象
            barrierDismissible: false,
            builder: (BuildContext context) {
                return new LoadingDialog( //调用对话框
                    text: '正在获取详情...',
                );
            });

        //请求登录数据
        HttpUtil().post(
            '${ApiConfig.baseUrl}${ApiConfig.loginUrl}',
            data: {
                'account':phoneNumber,
                'password':password,
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

            //登录成功缓存用户信息
            UserInfoCache().setUserInfo(userInfo: response['message']['user']);
            UserInfoCache().saveInfo(key: UserInfoCache.phoneNumber,value: phoneNumber);
            UserInfoCache().saveInfo(key: UserInfoCache.loginPassword,value: password);
            UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');

            //请求网络数据
            HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.sessionIdUrl}',).then((sessionResponse){

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
                UserInfoCache().saveInfo(key: UserInfoCache.sessionId,value: sessionResponse['message']);


                //请求网络数据
                HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.refreshUssUrl}').then((res){});

                _gotoIndex();//保存信息后退出登录页
            });

        });
    }

    void submitRegisterInfo (){

        if(loginFormKey.currentState.validate()){

            loginFormKey.currentState.save();

            debugPrint('phoneNumber:$phoneNumber');
            debugPrint('password:$password');

            _login();

        }else{
            setState(() {
                autoValidate = true;
            });
        }
    }

    String validatephoneNumber (value){
        if(value.isEmpty){
            return '手机号不能为空.';
        }

        if(!Application.isChinaPhoneLegal(value)){
            return '手机号格式不正确.';
        }
    }
    String validatePassword (value){
        if(value.isEmpty){
            return '密码不能为空.';
        }
    }

    @override
    Widget build(BuildContext context) {
        return Form(
            key: loginFormKey,
            child: Column(
                children: <Widget>[
                    TextFormField(
                        initialValue: phoneNumber,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            icon: Icon(
                                Icons.smartphone,
                                color: AppStyle.colorLight,
                            ),
                            labelText: '手机号',
                            labelStyle: TextStyle(
                                color: Colors.white,
                            ),
                            helperText: '',
                            helperStyle: TextStyle(
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
                        initialValue: password,
                        decoration: InputDecoration(
                            icon: Icon(
                                Icons.vpn_key,
                                color: AppStyle.colorLight,
                            ),
                            labelText: '密码',
                            labelStyle: TextStyle(
                                color: Colors.white,
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
//                    SizedBox( height: ScreenUtil.getInstance().setHeight(32.0),),
//                    Container(
//                        width: double.infinity,
//                        child: Row(
//                            children: <Widget>[
//                                Expanded(child: SizedBox(height: 1,)),
//                                GestureDetector(
//                                    onTap: (){
//                                        print('忘记密码');
//                                        Application.router.navigateTo(context, Routes.forgotPassword);
//                                    },
//                                    child: Text(
//                                        '忘记密码?',
//                                        style: TextStyle(
//                                            fontSize: ScreenUtil.getInstance().setSp(24.0),
//                                            color: AppStyle.colorLight,
//                                        ),
//                                    ),
//                                ),
//                            ],
//                        ),
//                    ),
                    SizedBox( height: ScreenUtil.getInstance().setHeight(32.0),),
                    Container(
                        width: double.infinity,
                        child: RaisedButton(
                            color: AppStyle.colorBegin,
                            child: Text(
                                '登录',
                                style: TextStyle(
                                    color: AppStyle.colorLight,
                                    fontSize: ScreenUtil.getInstance().setSp(30.0)
                                ),
                            ),
                            elevation: 0.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                            onPressed: submitRegisterInfo,
                            shape: StadiumBorder(),//球场形状
//                            RoundedRectangleBorder(
//                                borderRadius: BorderRadius.only(
//                                    topLeft:Radius.circular(15.0),
//                                    bottomRight:Radius.circular(15.0),
//                                ),
//                            ),
                        ),
                    ),
                    SizedBox( height: ScreenUtil.getInstance().setHeight(32.0),),
                    Container(
                        width: double.infinity,
                        child: Center(
                            child:
                            GestureDetector(
                                onTap: (){
                                    Application.router.navigateTo(context, Routes.register,transition: TransitionType.native);
                                    print('立即注册');
                                },
                                child: Text(
                                    '没有账号,立即注册',
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
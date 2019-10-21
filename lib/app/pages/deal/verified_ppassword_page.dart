import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class VerifiedPPasswordPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text('验证支付密码'),
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
                    child: SingleChildScrollView(
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
    String pPassword,btcNumber;
    bool autoValidate = false;

    void _gotoCrashBtcPage() async{
        Application.router.pop(context);
        Application.router.navigateTo(context, Routes.crashBtc,transition: TransitionType.native);

    }

    void verifiedPPassWord (){

        registerFormKey.currentState.save();

        if(registerFormKey.currentState.validate()){

            debugPrint('pPassword:$pPassword');

            verifiedPPasswordNow(pPassword: pPassword);

        }else{
            setState(() {
                autoValidate = true;
            });
        }
    }
    void verifiedPPasswordNow({String pPassword}){

        //显示加载动画
        showDialog<Null>(
            context: context, //BuildContext对象
            barrierDismissible: false,
            builder: (BuildContext context) {
                return LoadingDialog( //调用对话框
                    text: '正在获取详情...',
                );
            }
        );

        UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

            //请求网络数据
            HttpUtil().post(
                '${ApiConfig.baseUrl}${ApiConfig.verifiedPPasswordUrl}',
                data: {
                    'code':pPassword,
                    'type':'paypwd',
                    'obj':'paypwd',
                }
            ).then((response){
//        print(response.toString());
                //退出加载动画
                Navigator.pop(context); //关闭对话框
                if(response['error'] != 0){
                    Fluttertoast.showToast(
                        msg: response['message']['msg'],
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                }

                UserInfoCache().saveInfo(key: UserInfoCache.crashRandom,value:response['message']);
                _gotoCrashBtcPage();//保存信息后退出登录页

            });
        });
    }
    String validatePPassword (value){
        if(value.isEmpty){
            return '支付密码不能为空.';
        }
        if(value.length < 6){
            return '支付密码不能小于6位.';
        }
    }

    @override
    Widget build(BuildContext context) {
        return Form(
            key: registerFormKey,
            child: Column(
                children: <Widget>[
                    TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
//                            fillColor: AppStyle.colorLight,
                            icon: Icon(
                                Icons.vpn_key,
//                                color: AppStyle.colorSecondary,
                            ),
                            labelText: '支付密码',
                            labelStyle: TextStyle(
//                                color: Colors.white,
                            ),
                        ),
                        onSaved: (value){
                            pPassword = value;
                        },
                        validator: validatePPassword,
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
                                '确定',
                                style: TextStyle(
                                    color: AppStyle.colorBegin,
                                    fontSize: ScreenUtil.getInstance().setSp(30.0),
                                ),
                            ),
                            elevation: 2.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                            onPressed: verifiedPPassWord,
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
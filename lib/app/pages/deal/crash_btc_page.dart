import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class CrashBtcPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text('BTC申请提现'),
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
    String btcNumber='';
    TextEditingController _btcNumController = TextEditingController();
    bool autoValidate = false;

    void crashBTC (){

        debugPrint('btcNumber:${_btcNumController.text}');

        double haveNumber = double.parse(btcNumber);
        double crashNumber = double.parse(_btcNumController.text);

        if(crashNumber > haveNumber){
            //弹窗
            Fluttertoast.showToast(
                msg: "提现数量不得超出已有数量!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 2,
                backgroundColor: AppStyle.colorGreyDark,
                textColor: Colors.white,
                fontSize: 16.0
            );
            return;
        }

//        print('haveNumber = $haveNumber,crashNumber = $crashNumber,i ~/ j = ${crashNumber % 0.001}');

        if((crashNumber % 0.001) != 0){
            //弹窗
            Fluttertoast.showToast(
                msg: "提现最小单位为0.001!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 2,
                backgroundColor: AppStyle.colorGreyDark,
                textColor: Colors.white,
                fontSize: 16.0
            );
            return;
        }

        sendRequest(crashNum: _btcNumController.text);
    }


    void sendRequest({String crashNum}){

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
            UserInfoCache().getInfo(key: UserInfoCache.crashRandom).then((random){

                //请求网络数据
                HttpUtil().post(
                    '${ApiConfig.baseUrl}${ApiConfig.cashBtcUrl}',
                    data: {
                        'r':random,
                        'num':crashNum,
                    }
                ).then((response){
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

                    //弹窗
                    Fluttertoast.showToast(
                        msg: "提现成功!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );

                    //简单计时器
                    Timer(Duration(seconds: 2),(){
                        Application.router.pop(context);
                    });

                });
            });
        });
    }

@override
  void initState() {
    // TODO: implement initState
    super.initState();

    UserInfoCache().getInfo(key: UserInfoCache.btcNumber).then((onValue){
        setState(() {
          btcNumber = onValue;
        });
    });
  }
    @override
    Widget build(BuildContext context) {
        return Column(
            children: <Widget>[
                Container(
                    margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                    child: Row(
                        children: <Widget>[
                            Expanded(child: SizedBox(height: 1,)),
                            Text(
                                '已有数量:',
                                style: TextStyle(
                                    color: AppStyle.colorDark,
                                    fontSize: ScreenUtil.getInstance().setSp(32.0),
                                    fontWeight: FontWeight.w300,
                                ),
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                            Text(
                                btcNumber,
                                style: TextStyle(
                                    color: AppStyle.colorDark,
                                    fontSize: ScreenUtil.getInstance().setSp(40.0),
                                    fontWeight: FontWeight.w300,
                                ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                        ],
                    ),
                ),
                Form(
                    key: registerFormKey,
                    child: Column(
                        children: <Widget>[
                            TextField(
                                controller: _btcNumController,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10.0),
                                    icon: Icon(Icons.mode_edit,),
                                    labelText: '请输入提现数量)',
                                    helperText: '提现最小单位0.001.',
                                ),
                                inputFormatters: [
                                    WhitelistingTextInputFormatter(RegExp("[0-9.]")),//只允许输入小数
                                ],
                                autofocus: false,
                            ),

                            SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
                            Container(
                                width: double.infinity,
                                child: RaisedButton(
                                    child: Text(
                                        '提现',
                                        style: TextStyle(
                                            color: AppStyle.colorBegin,
                                            fontSize: ScreenUtil.getInstance().setSp(30.0),
                                        ),
                                    ),
                                    elevation: 2.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                                    onPressed: crashBTC,
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
                )
            ],
        );
    }
}
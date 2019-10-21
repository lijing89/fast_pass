import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {

  TextEditingController _feedBackController = TextEditingController();

  void sendRequest({String feedBackStr}){

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
            '${ApiConfig.baseUrl}${ApiConfig.feedBackUrl}',
            data: {
              'content':feedBackStr,
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
              msg: "反馈成功!",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('意见反馈'),
      ),
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox( height: ScreenUtil.getInstance().setHeight(32.0),),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: ScreenUtil.getInstance().setWidth(32.0),
                    right: ScreenUtil.getInstance().setWidth(32.0),
                  ),
                  child: Text(
                    '反馈内容:',
                    style: TextStyle(
                      color: AppStyle.colorGreyText,
                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox( height: ScreenUtil.getInstance().setHeight(32.0),),
                Card(
                    color: AppStyle.colorLight,
                    margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(32.0)),
                      child: TextField(
                        controller: _feedBackController,
                        maxLines: 8,
                        decoration: InputDecoration.collapsed(
                            hintText: "请输入反馈意见!",
                            hintStyle: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28.0))
                        ),
                      ),
                    )
                ),
                SizedBox( height: ScreenUtil.getInstance().setHeight(32.0),),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(32.0)),
                  child: RaisedButton(
                    color: AppStyle.colorBegin,
                    child: Text(
                      '提交意见',
                      style: TextStyle(
                          color: AppStyle.colorLight,
                          fontSize: ScreenUtil.getInstance().setSp(30.0)
                      ),
                    ),
                    elevation: 2.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                    onPressed: (){

                      print(_feedBackController.text);

                      if(_feedBackController.text == ''){

                        //弹窗
                        Fluttertoast.showToast(
                            msg: "反馈意见不能为空!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 2,
                            backgroundColor: AppStyle.colorGreyDark,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      sendRequest(feedBackStr:_feedBackController.text);
                    },
                    shape: StadiumBorder(),//球场形状
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}


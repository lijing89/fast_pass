import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/model/about_us_entity.dart';
import 'package:fast_pass/app/model/base_question_entity.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String aboutUsContent = ''; //关于我们
  String baseQuesionContent = ''; //常见问题内容
  String baseQuesionTitle = ''; //常见问题
  void initState() {
    super.initState();
    /*请求关于我们*/
    HttpUtil().get('${ApiConfig.aboutUrl}').then((res) {
      AboutUsEntity aboutUsEntity = AboutUsEntity.fromJson(res);
      setState(() {
        aboutUsContent = aboutUsEntity.message.content;
      });
    });
    /*请求常见问题*/
    HttpUtil().get('${ApiConfig.questionUrl}').then((res) {
      AboutUsEntity aboutUsEntity = AboutUsEntity.fromJson(res);
      setState(() {
        baseQuesionContent = aboutUsEntity.message.content;
        baseQuesionTitle = aboutUsEntity.message.title;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('关于我们'),
      ),
      body: Center(

        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          constraints: BoxConstraints(minWidth: double.infinity,minHeight: double.infinity),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 50.0,bottom: 50.0),
                child: Image(
                  image: AssetImage(AssetUtil.image('icon.jpeg')),
                  height: ScreenUtil.getInstance().setHeight(300.0),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding:EdgeInsets.fromLTRB(15, 10, 15, 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(16.0)),
                  color: Colors.white,
                ),
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Text(
                  aboutUsContent,
                  textAlign: TextAlign.left,
                  style:
                  TextStyle(fontSize: ScreenUtil.getInstance().setSp(26.0)),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20,right: 20),
                    width: ScreenUtil.getInstance().setWidth(8.0),
                    height: ScreenUtil.getInstance().setWidth(30.0),
                    color: AppStyle.colorBegin,
                  ),
                  Container(
                    padding:EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      baseQuesionTitle,
                      textAlign: TextAlign.left,
                      style:
                      TextStyle(fontSize: ScreenUtil.getInstance().setSp(32.0)),
                    ),
                  ),
                ],
              ),

              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(16.0)),
                  color: AppStyle.colorBegin,
                ),
                padding:EdgeInsets.fromLTRB(15, 20, 15, 30),

                constraints: BoxConstraints(minWidth: double.infinity),
                child: Text(
                  baseQuesionContent,
                  textAlign: TextAlign.left,
                  style:
                  TextStyle(fontSize: ScreenUtil.getInstance().setSp(26.0),color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class ModifyPasswordPage extends StatefulWidget {
  @override
  _ModifyPasswordPageState createState() => _ModifyPasswordPageState();
}

class _ModifyPasswordPageState extends State<ModifyPasswordPage> {

  String _headImageUrl = '';
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('修改密码'),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
            ItemView(
                '修改登录密码',Icon(AppIcon.right),(){
                  Application.router.navigateTo(context, Routes.modifyLoginPassword);
                }
            ),
            ItemView('修改支付密码', Icon(AppIcon.right),(){
              Application.router.navigateTo(context, Routes.modifyPaymentPassword);
            }),
            SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
          ],
        )
    );
  }
}
class ItemView extends StatelessWidget {
  String _title;
  Function _onTapFunction;
  Widget _rightWidget;
  ItemView(this._title,this._rightWidget,this._onTapFunction);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTapFunction,
      child: Container(
        width: double.infinity,
        height: ScreenUtil.getInstance().setWidth(100.0),
        padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(32.0),),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _title,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(32.0)
                  ),
                ),
                Expanded(child: SizedBox(height: 1,)),
                _rightWidget,
                SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
              ],
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
            Container(
              width: double.infinity,
              height: 1,
              color: AppStyle.colorGrey,
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(4.0),),
          ],
        ),
      ),
    );
  }
}
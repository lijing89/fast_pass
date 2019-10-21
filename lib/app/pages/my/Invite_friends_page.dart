import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';

class InviteFriendsPage extends StatefulWidget {
  @override
  _InviteFriendsPageState createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {

  String imageUrl = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

      //请求网络数据
      HttpUtil().get(
          '${ApiConfig.baseUrl}${ApiConfig.extensionUrl}',
      ).then((response){
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

        setState(() {
          imageUrl = response['message']['photoList'];
        });

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('邀请好友'),
        actions: <Widget>[
          IconButton(icon: Icon(AppIcon.down), onPressed: ()async{

            if(imageUrl == ''){

              //弹窗
              Fluttertoast.showToast(
                  msg: "网络慢了,请稍候!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 2,
                  backgroundColor: AppStyle.colorGreyDark,
                  textColor: Colors.white,
                  fontSize: 16.0
              );

              return;
            }

            //显示加载动画
            showDialog<Null>(
                context: context, //BuildContext对象
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return new LoadingDialog( //调用对话框
                    text: '保存中...',
                  );
                });

              var response = await http.get(imageUrl);

              debugPrint(response.statusCode.toString());

              var filePath = await ImagePickerSaver.saveFile(
                  fileData: response.bodyBytes);

              var savedFile= File.fromUri(Uri.file(filePath));
              Future<File>.sync(() => savedFile);

              //退出加载动画
              Navigator.pop(context); //关闭对话框

              //弹窗
              Fluttertoast.showToast(
                  msg: "图片已保存到相册!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 2,
                  backgroundColor: AppStyle.colorGreyDark,
                  textColor: Colors.white,
                  fontSize: 16.0
              );

          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: imageUrl == ''
              ? Container()
              : CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => new CircularProgressIndicator(strokeWidth: 1.0,),
            errorWidget: (context, url, error) => new Icon(AppIcon.warn_light),
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}

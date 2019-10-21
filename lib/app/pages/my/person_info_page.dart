import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/pages/my/modify_nickname_page.dart';

class PersonInfoPage extends StatefulWidget {
  @override
  _PersonInfoPageState createState() => _PersonInfoPageState();
}

class _PersonInfoPageState extends State<PersonInfoPage> {

  String _headImageUrl = '';
  File _image;
  String _nickName = '';
  Future getImage() async {

//    //弹窗
//    Fluttertoast.showToast(
//        msg: "功能暂未开放!",
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.CENTER,
//        timeInSecForIos: 2,
//        backgroundColor: AppStyle.colorGreyDark,
//        textColor: Colors.white,
//        fontSize: 16.0
//    );
//    return;

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(image == null )return;

    image = await ImageCropper.cropImage(sourcePath: image.path, ratioX: 1.0, ratioY: 1.0, maxWidth: 300, maxHeight: 300,);

    if(image == null )return;

    UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

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

      //请求网络数据
      HttpUtil().uploadheadImage(
          '${ApiConfig.baseUrl}${ApiConfig.uploadHeadUrl}',
          image: image,
      ).then((response){
        //退出加载动画
        Navigator.pop(context); //关闭对话框
        if(response['error'] != 0){
          Fluttertoast.showToast(
              msg: response['message'] == null ? '' : response['message'],
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
            msg: response['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0
        );

        setState(() {
          _image = image;
        });

        //上传成功之后更新缓存信息

        _refreshUserInfoAndSessionId();

      });

    });

  }

  _refreshUserInfoAndSessionId()async{
    await new Future.delayed(const Duration(seconds: 1), () async{

      String phoneNumber = await UserInfoCache().getInfo(key: UserInfoCache.phoneNumber);
      String loginPassword = await UserInfoCache().getInfo(key: UserInfoCache.loginPassword);

//      print('phoneNumber = $phoneNumber,loginPassword = $loginPassword');

      //请求登录数据
      HttpUtil().post(
          '${ApiConfig.baseUrl}${ApiConfig.loginUrl}',
          data: {
            'account':'$phoneNumber',
            'password':'$loginPassword',
          }).then((response){

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

        //请求网络数据
        HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.sessionIdUrl}',).then((response){
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
          UserInfoCache().saveInfo(key: UserInfoCache.sessionId,value: response['message']);
        });

        //登录成功缓存用户信息
        UserInfoCache().setUserInfo(userInfo: response['message']['user']);

      });

    });

  }

  //获取个人信息

  @override
  void initState(){
      super.initState();

      UserInfoCache().getUserInfo().then((onValue){

//        print(onValue.toString());

        setState(() {
          _nickName = onValue['name'];
          _headImageUrl = AppConfig.cdnImageUrl + onValue['head_pic'];
        });

      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人资料'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
          HeadImageItemView(
              '头像',
              getImage,_headImageUrl,_image
          ),
          ItemView('昵称', Container(
            child: Text(_nickName),
          ),()async{
//            Application.router.navigateTo(context, Routes.modifyNickname);
            //这个变量就是，执行push，等待pop后的刷新界面
            await Navigator.push(context,MaterialPageRoute(builder: (context) => ModifyNicknamePage()));

            UserInfoCache().getUserInfo().then((onValue){
              setState(() {
                _nickName = onValue['name'];
              });
            });

          }),
          SizedBox(height: ScreenUtil.getInstance().setWidth(64.0),),
        ],
      )
    );
  }
}
class HeadImageItemView extends StatelessWidget {
  String _title,_headImage;
  File _image;
  Function _onTapFunction;
  HeadImageItemView(this._title,this._onTapFunction,this._headImage,this._image);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTapFunction,
      child: Container(
        width: double.infinity,
        height: ScreenUtil.getInstance().setWidth(240),
        padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(32.0),),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        _title,
                        style: TextStyle(
                            fontSize: ScreenUtil.getInstance().setSp(32.0)
                        ),
                      ),
                      Expanded(child: SizedBox(height: 1,)),
                      _image == null ? Image.network(
                         _headImage == null ? '' : _headImage,
                        fit: BoxFit.fitHeight,
                      ) : Image.file(_image,fit: BoxFit.fitHeight,),
                      SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                    ],
                  ),
                )
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
        height: ScreenUtil.getInstance().setWidth(100),
        padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(32.0),),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1,color: AppStyle.colorGrey))
          ),
          child:
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
        ),
      ),
    );
  }
}

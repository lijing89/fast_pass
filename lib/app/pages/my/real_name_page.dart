import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class RealNameAuthenticationPage extends StatefulWidget {
  @override
  _RealNameAuthenticationPageState createState() => _RealNameAuthenticationPageState();
}

class _RealNameAuthenticationPageState extends State<RealNameAuthenticationPage> {

  final registerFormKey = GlobalKey<FormState>();
  String phoneNumber,name,cardNumber,verificationCode,authenticationStatus = '0';
  bool autoValidate = false;


  File _image1,_image2,_image3;

  Future getImage(int index) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 500,maxHeight: 500);

    setState(() {
      switch (index) {
        case 1:
          _image1 = image;
          break;
        case 2:
          _image2 = image;
          break;
        case 3:
          _image3 = image;
          break;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //获取缓存数据
    UserInfoCache().getUserInfo().then((onValue){
      setState(() {
        phoneNumber = onValue['mobile'];
        authenticationStatus = onValue['rz'];
      });
    });

  }

  void _sendRequestToRealName() async{

    debugPrint('name:$name');
    debugPrint('cardNumber:$cardNumber');
    debugPrint('verificationCode:$verificationCode');

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

      Map<String,dynamic> params = {
        'real_name':name,
        'idcard':cardNumber,
        'mobile_code':verificationCode,
      };

      //请求网络数据
      HttpUtil().uploadThreeImages(
          '${ApiConfig.baseUrl}${ApiConfig.realNameAuthenticationUrl}',
          image1: _image1,
          image2: _image2,
          image3: _image3,
          data: params
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
            msg: response['message'],
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
  void _getVerificationCode(){

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

  void submitRegistInfo (){

    if(registerFormKey.currentState.validate()){

      registerFormKey.currentState.save();

      if(_image1 == null){
        Fluttertoast.showToast(
            msg: '请选择有效证件正面照片',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
      if(_image2 == null){
        Fluttertoast.showToast(
            msg: '请选择有效证件背面照片',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
      if(_image3 == null){
        Fluttertoast.showToast(
            msg: '请选择手持证件照片',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }

      _sendRequestToRealName();//提交

    }else{
      setState(() {
        autoValidate = true;
      });
    }
  }

  String validatename (value){
    if(value.isEmpty){
      return '姓名不能为空.';
    }
  }
  String validateCardNumber (value){
    if(value.isEmpty){
      return '证件号码不能为空.';
    }
    if(!Application.isCardId(value)){
      return '请输入正确的证件号码.';
    }
  }
  String validateVerificationCode (value){
    if(value.isEmpty){
      return '验证码不能为空.';
    }
  }

  Widget topView (){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: ScreenUtil.getInstance().setWidth(50.0),
          color: Colors.white,
          child: Center(
            child: Text(
              '请务必填写真实信息,提交后不可修改',
              style: TextStyle(
                color: AppStyle.colorWarning,
                fontSize: ScreenUtil.getInstance().setSp(24.0),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: ScreenUtil.getInstance().setWidth(120.0),
          child: Center(
            child: Text(
              '已绑定手机号：$phoneNumber',
              style: TextStyle(
                color: AppStyle.colorDark,
                fontSize: ScreenUtil.getInstance().setSp(32.0),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget inputView (){
    if(authenticationStatus != '0')return Container(
      child: Text(
        '已通过认证！',
        style:TextStyle(fontSize: 20.0,color: AppStyle.colorSecondary)
        ,),);

    return Container(
      margin: EdgeInsets.only(
          left: ScreenUtil.getInstance().setWidth(32.0),
          right: ScreenUtil.getInstance().setWidth(32.0),
      ),
      child: Form(
        key: registerFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  fillColor: AppStyle.colorDark,
                  icon: Icon(
                    Icons.person,
//                    color: AppStyle.colorDark,
                  ),
                  labelText: '姓名',
                  labelStyle: TextStyle(
                    color: AppStyle.colorDark,
                  ),
                ),
                onSaved: (value){
                  name = value;
                },
                validator: validatename,
                autovalidate: autoValidate,
                style: TextStyle(
                    color: AppStyle.colorDark
                ),
              ),
              TextFormField(
                obscureText: false,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.credit_card,
//                    color: AppStyle.colorLight,
                  ),
                  labelText: '证件号码',
                  labelStyle: TextStyle(
                    color: AppStyle.colorDark,
                  ),
                ),
                onSaved: (value){
                  cardNumber = value;
                },
                validator: validateCardNumber,
                autovalidate: autoValidate,
                style: TextStyle(
                    color: AppStyle.colorDark
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
//                        color: AppStyle.colorLight,
                      ),
                      labelText: '验证码',
                      labelStyle: TextStyle(
                        color: AppStyle.colorDark,
                      ),
                    ),
                    onSaved: (value){
                      verificationCode = value;
                    },
                    validator: validateVerificationCode,
                    autovalidate: autoValidate,
                    style: TextStyle(
                        color: AppStyle.colorDark
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: SizedBox(height: 1,),),
                      Container(
                        height: ScreenUtil.getInstance().setWidth(32),
                        width: 1,
                        color: AppStyle.colorSecondary,
                      ),
                      SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                      LoginFormCode(countdown: 60,available: true,onTapCallback: (){
                        _getVerificationCode();
                      },),
                      SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                    ],
                  )
                ],
              )
            ],
          )
      ),
    );
  }

  Widget picturePicker(){
    if(authenticationStatus != '0')return Container();
      return Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setHeight(128),),
              Expanded(
                child: InkWell(
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        _image1 == null ? Image(image: AssetImage(
                            AssetUtil.image('selectPicture.png')),
                          fit: BoxFit.fitWidth,)
                            : Image.file(_image1),
                        Container(
                          height: ScreenUtil.getInstance().setWidth(60),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              '点击上传有效证件正面照片',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(28.0),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => getImage(1),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setHeight(128),),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setHeight(128),),
              Expanded(
                child: InkWell(
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        _image2 == null ? Image(
                          image: AssetImage(AssetUtil.image('selectPicture.png')),
                          fit: BoxFit.fitWidth,
                        ) : Image.file(_image2),
                        Container(
                          height: ScreenUtil.getInstance().setWidth(60),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              '点击上传有效证件背面照片',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(28.0),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => getImage(2),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setHeight(128),),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setHeight(128),),
              Expanded(
                child: InkWell(
                  child: Container(
                    color: Colors.white,
//                    height: ScreenUtil.getInstance().setWidth(400),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        _image3 == null ? Image(
                          image: AssetImage(AssetUtil.image('selectPicture.png')),
                          fit: BoxFit.fitWidth,
                        ) : Image.file(_image3),
                        Container(
                          height: ScreenUtil.getInstance().setWidth(60),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              '点击上传手持有效证件照片',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(28.0),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => getImage(3),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setHeight(128),),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setHeight(32),),
        ],
      );
  }

  Widget contentView(){
    print('authenticationStatus${authenticationStatus}');
    if(authenticationStatus != '0')return Container();
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16)),
          child: RaisedButton(
            color: AppStyle.colorBegin,
            child: Text(
              '提交审核',
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('实名认证'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(0.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              topView(),
              inputView(),
              picturePicker(),
              contentView(),
            ],
          ),
        ),
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
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:image_picker/image_picker.dart';
class FPBuySelectAddressPage extends StatefulWidget{
    @override
    _FPBuySelectAddressPageState createState() => _FPBuySelectAddressPageState();
}

class _FPBuySelectAddressPageState extends State<FPBuySelectAddressPage> with SingleTickerProviderStateMixin {
    final registerFormKey = GlobalKey<FormState>();
    ScrollController _scrollController = ScrollController();
    String phoneNumber= '',password='',name='',email='',changeCode = '',smsReqSn='',address='',putName='',putNumber='',imgCode='',imageNetString='',reqSn='';
    String verificationCode;
    int selterNumber;
    Map userMap = {};
    bool autoValidate = false,_isAvailable = true,
        _isEnable = false,//修改基本信息
        _citySelected = false,//修改收件地址
        _codeEnabel = false;//修改密码
    TextEditingController _phoneNumberController;
    TextEditingController _nameController;
    TextEditingController _emailController;
    TextEditingController _addressController;
    TextEditingController _putNameController;
    TextEditingController _putNumberController;

    TextEditingController _imageController;
    TextEditingController _yzmController;

    Map userAddress = {'province':'','city':'','district':'','addr':'','name':'','phone':''};

    List shdz = [];
    List fhdz = [];

    ///城市选择器
    String _city = '点我选择城市';
    _show(context) async{
        Result temp  = await CityPickers.showCityPicker(
            context: context,
            height: 400,
            cancelWidget: Text('取消', style: TextStyle()),
            confirmWidget: Text('确定', style: TextStyle())
        );
        setState(() {
            if(temp == null) return;
            _city = (temp.provinceName??'') + '  ' + (temp.cityName??'')+'  ' + (temp.areaName??'');
            userAddress['province'] = temp.provinceName??'';
            userAddress['city'] = temp.cityName??'';
            userAddress['district'] = temp.areaName??'';

        });
    }
    String validateVerificationCode (value){
        if(value.isEmpty){
            return '验证码不能为空.';
        }
    }
    @override
    void dispose() {
        super.dispose();
        _scrollController?.dispose();
        _phoneNumberController?.dispose();
        _nameController?.dispose();
        _emailController?.dispose();
        _addressController?.dispose();
        _putNameController?.dispose();
        _putNumberController?.dispose();
    }
    @override
    void initState() {
        super.initState();
        _phoneNumberController = TextEditingController(text: phoneNumber??'');
        _nameController = TextEditingController(text: name??'');
        _emailController = TextEditingController(text: email??'');
        // 对 scrollController 进行监听
        //获取用户信息
        getUserMessage();
    }
    getUserMessage(){
        ApiConfig().getAccount().then((onValue){
            if(onValue == null){return;}
            if(onValue['rspCode'] != '0000'){
                Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                return;
            }
            UserInfoCache().setUserInfo(userInfo: onValue);
            UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
            userMap = onValue;
            shdz = [];
            fhdz = [];
            if(mounted){
                setState(() {
                    _phoneNumberController = TextEditingController(text: userMap['phone']);
                    _nameController = TextEditingController(text: userMap['userName']);
                    _emailController = TextEditingController(text: userMap['email']);
                    for (var item in onValue['addrs']) {
                        if(item['type'] == '1'){
                            shdz.add(item);
                        }else{
                            fhdz.add(item);
                        }
                    }
                });
            }
        });
    }
    //打开相册
    Future getImage() async {
        var image = await ImagePicker.pickImage(source: ImageSource.gallery);
        //显示加载动画
        showDialog<Null>(
            context: context, //BuildContext对象
            barrierDismissible: false,
            builder: (BuildContext context) {
                return new LoadingDialog( //调用对话框
                    text: '正在上传头像...',
                );
            });
        setState(() {
            //设置头像
            ApiConfig().updateImage(image).then((onValue){
                if(onValue['rspCode'] != '0000'){
                    Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                }
                //修改头像
                ApiConfig().alterHead(onValue['imgUrl']).then((onValue1){
                    if(onValue['rspCode'] == '0000'){
                        showToast('上传成功');
                    }else{
                       Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                        return;
                    }
                });

            });
        });
    }

    bool  _getVerificationCode(){
        if(imgCode != ''&& imgCode != verificationCode){
            showToast("图形验证码不正确!");
            return false;
        }
        if(validatephoneNumber(phoneNumber) != null && _codeEnabel == false){
            //弹窗
            showToast("请输入正确的手机号,再获取验证码!");
            return false;
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
            UserInfoCache().getUserInfo().then((onValue){
                if(_codeEnabel){
                    phoneNumber = onValue['phone'];
                }
                //短信验证码
                ApiConfig().sendMessage(_isEnable?'4':'3', phoneNumber).then((response){
                    Navigator.pop(context);
                    if(response['rspCode'] == '0000'){
                        smsReqSn = response['reqSn'];
                        showToast("发送成功!");
                        return true;
                    }else{
                        showToast(response['rspDesc']);
                        return false;
                    }
                });
            });
        }
        return true;
    }

    getImageYz(int type){
        //获取图文验证码
        ApiConfig().obtainImage(type).then((onValue){
            if(onValue['rspCode'].toString() != '0000'){
                showToast(onValue['rspDesc']);
                return;
            }
            setState(() {
                imgCode = onValue['imgCode'];
                imageNetString = onValue['imgUrl'];
            });
        });
    }

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            child: Container(
                color: AppStyle.colorWhite,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                    children: <Widget>[
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('头像',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: GestureDetector(
                                            onTap: (){
                                                // if(_isEnable){
                                                getImage();
                                                // }
                                            },
                                            child: Container(
                                                alignment: Alignment.centerRight,
                                                child: ClipOval(
                                                    child: Container(
                                                        width: ScreenUtil.getInstance().setWidth(150.0),
                                                        height: ScreenUtil.getInstance().setWidth(150.0),
                                                        child: userMap.length??0 ==0? Image(image: AssetImage(AssetUtil.image('video@3x.png')),fit: BoxFit.fill,):CachedNetworkImage(
                                                            imageUrl: userMap['headImgUrl'],
                                                            placeholder: (context, url) => new ProgressView(),
                                                            errorWidget: (context, url, error) => new Icon(Icons.warning),
                                                            fit: BoxFit.fitWidth,
                                                        ),
                                                    ),
                                                ),
                                            )

                                        )
                                    )
                                ],
                            ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                            child: Row(
                                children: <Widget>[
                                    Column(
                                        children: <Widget>[
                                            Text('基本信息',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500)),
                                            SizedBox(height: 10),
                                            Container(width: 60,height: 3,color: Colors.black,)
                                        ],
                                    ),
                                    Expanded(child: SizedBox(height: 1,)),
                                    GestureDetector(
                                        onTap: (){
                                            if(_isEnable){
                                                if(name == ''&& email ==''&&phoneNumber == ''){
                                                    _isEnable = false;
                                                    showToast('无修改');
                                                    return;
                                                }
                                                ApiConfig().accountNumberChange(userName: name,email: email,phone: phoneNumber,
                                                    smsCode: changeCode,smsReqSn: smsReqSn).then((response){
                                                    if(response['rspCode'] == '0000'){
                                                        smsReqSn = response['reqSn'];
                                                        showToast('修改成功');
                                                        setState(() {

                                                            _isEnable = false;
                                                        });
                                                    }else{
                                                        showToast(response['rspDesc']);
                                                    }
                                                });
                                            }
                                            //修改
                                            if(!_isEnable){
                                                changeCode = '';
                                                verificationCode = '';
                                                getImageYz(4);
                                                _codeEnabel = false;
                                                _isEnable = true;
                                            }
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(right: 0),
                                            height: 37,
                                            width: 90,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(37),
                                                border: new Border.all(color: !_isEnable?AppStyle.colorPrimary:AppStyle.colorRed, width: 0.5), // 边色与边宽度
                                            ),
                                            child: Text(!_isEnable?'修改':'完成',style: TextStyle(fontSize: 16,color: !_isEnable?AppStyle.colorPrimary:AppStyle.colorRed))
                                        )
                                    )
                                ],
                            ),
                        ),
                        SizedBox( height: ScreenUtil.getInstance().setHeight(60.0),),
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('用户名',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: TextField(
                                            controller: _nameController,
                                            enabled: _isEnable,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    color: AppStyle.colorLightDarkText,
                                                    fontSize: 14,
                                                ),
                                                helperStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,

                                                ),

                                            ),
                                            style: TextStyle(
                                                color: AppStyle.colorPrimary
                                            ),
                                            onChanged: (value){
                                                //输入改变
                                                phoneNumber = value;
                                            },
                                            //完成编辑
                                            onEditingComplete:(){

                                            }

                                        ),
                                    )
                                ],
                            ),
                        ),
                        //邮箱
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('邮箱',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: TextField(
                                            controller: _emailController,
                                            enabled: _isEnable,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    color: AppStyle.colorLightDarkText,
                                                    fontSize: 14,

                                                ),
                                                helperStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,

                                                ),

                                            ),
                                            style: TextStyle(
                                                color: AppStyle.colorPrimary
                                            ),
                                            onChanged: (value){
                                                //输入改变
                                                phoneNumber = value;
                                            },
                                            //完成编辑
                                            onEditingComplete:(){

                                            }

                                        ),
                                    )
                                ],
                            ),
                        ),
                        //手机号
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('手机号',style: TextStyle(fontSize:16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: TextField(
                                            controller: _phoneNumberController,
                                            enabled: _isEnable,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    color: AppStyle.colorLightDarkText,
                                                    fontSize: 14,

                                                ),
                                                helperStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,

                                                ),

                                            ),
                                            style: TextStyle(
                                                color: AppStyle.colorPrimary
                                            ),
                                            onChanged: (value){
                                                //输入改变
                                                phoneNumber = value;
                                            },
                                            //完成编辑
                                            onEditingComplete:(){

                                            }

                                        ),
                                    )
                                ],
                            ),
                        ),
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('图文验证码',style: TextStyle(fontSize:16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: Container(
                                            // padding: EdgeInsets.all(20),
                                            child: Stack(
                                                alignment: Alignment(0 , 0),
                                                children: <Widget>[
                                                    TextField(
                                                        enabled: _isEnable,
                                                        decoration: InputDecoration(
                                                            labelStyle: TextStyle(
                                                                color: AppStyle.colorPrimary,
                                                            ),
                                                        ),
                                                        onChanged: (value){
                                                            //输入改变
                                                            verificationCode = value;
                                                        },
                                                        controller: _imageController,
                                                        style: TextStyle(
                                                            color: AppStyle.colorPrimary
                                                        ),
                                                    ),
                                                    Row(
                                                        children: <Widget>[
                                                            Expanded(child: SizedBox(height: 1,),),
                                                            Container(
                                                                height: ScreenUtil.getInstance().setWidth(32),
                                                                width: 1,
                                                                color: AppStyle.colorPrimary,
                                                            ),
                                                            SizedBox(width: ScreenUtil.getInstance().setWidth(16)),
                                                            GestureDetector(
                                                                onTap: (){
                                                                    //获取图形验证码
                                                                    getImageYz(4);
                                                                },
                                                                child: Container(
                                                                    height: 40,
                                                                    margin: EdgeInsets.only(bottom: 5),
                                                                    padding: EdgeInsets.only(bottom: 5),
                                                                    child: imageNetString == ''?Container():Image.network(
                                                                        imageNetString
                                                                    )
                                                                ),
                                                            ),
                                                            SizedBox(width: ScreenUtil.getInstance().setWidth(16),),

                                                        ],
                                                    ),
                                                ],
                                            ),
                                        ),
                                    )
                                ],
                            ),
                        ),
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('短信验证码',style: TextStyle(fontSize:16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: Container(
                                            child: Stack(
                                                alignment: Alignment(0 , 0),
                                                children: <Widget>[
                                                    Container(
                                                        child: TextField(
                                                            controller: _yzmController,
                                                            enabled: _isEnable,
                                                            decoration: InputDecoration(
                                                                labelStyle: TextStyle(
                                                                    color: AppStyle.colorPrimary,
                                                                ),
                                                            ),
                                                            onChanged: (value){
                                                                //输入改变
                                                                changeCode = value;
                                                            },
                                                            style: TextStyle(
                                                                color: AppStyle.colorPrimary
                                                            ),
                                                        ),
                                                    ),
                                                    Row(
                                                        children: <Widget>[
                                                            Expanded(child: SizedBox(height: 1,),),
                                                            Container(
                                                                height: ScreenUtil.getInstance().setWidth(32),
                                                                width: 1,
                                                                color: AppStyle.colorPrimary,
                                                            ),
                                                            SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                                            LoginFormCode(countdown: 60,available: _isAvailable,onTapCallback: _getVerificationCode,),
                                                            SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                                        ],
                                                    )
                                                ],
                                            ),
                                        ),
                                    )
                                ],
                            ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                            child: Row(
                                children: <Widget>[
                                    Column(
                                        children: <Widget>[
                                            Text('修改密码',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500)),
                                            SizedBox(height: 10),
                                            Container(width: 60,height: 3,color: Colors.black,)
                                        ],
                                    ),
                                    Expanded(child: SizedBox(height: 1,)),
                                    GestureDetector(
                                        onTap: (){
                                            if(_codeEnabel){
                                                if(password == ''){
                                                    _isEnable = false;
                                                    showToast('请输入新密码');
                                                    // _codeEnabel = false;
                                                    return;
                                                }
                                                ApiConfig().alterPWD(password).then((response){
                                                    if(response['rspCode'] == '0000'){
                                                        smsReqSn = response['reqSn'];
                                                        showToast('修改成功');
                                                        setState(() {
                                                            _isEnable = false;
                                                        });
                                                    }else{
                                                        showToast(response['rspDesc']);
                                                    }
                                                });
                                            }
                                            //修改
                                            if(!_codeEnabel){
                                                // getImageYz('3');
                                                changeCode = '';
                                                verificationCode = '';
                                                setState(() {
                                                    _isEnable = false;
                                                    _codeEnabel = true;
                                                });
                                            }
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(right: 0),
                                            height: 37,
                                            width: 90,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(37),
                                                border: new Border.all(color: !_codeEnabel?AppStyle.colorPrimary:AppStyle.colorRed, width: 0.5), // 边色与边宽度
                                            ),
                                            child: Text(!_codeEnabel?'修改':'完成',style: TextStyle(fontSize: 16,color: !_codeEnabel?AppStyle.colorPrimary:AppStyle.colorRed))
                                        )
                                    )
                                ],
                            ),
                        ),
                        //登录密码
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    // Expanded(
                                    //   flex: 3,
                                    //   child: Text('登录密码',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    // ),
                                    Expanded(
                                        flex: 1,
                                        child: TextField(
                                            enabled: _codeEnabel,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                                labelText: '请输入新密码',
                                                labelStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,
                                                    fontSize: 16,

                                                ),
                                                helperStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,

                                                ),

                                            ),
                                            style: TextStyle(
                                                color: AppStyle.colorPrimary
                                            ),
                                            onChanged: (value){
                                                //输入改变
                                                password = value;
                                            },
                                            //完成编辑
                                            onEditingComplete:(){

                                            }

                                        ),
                                    )
                                ],
                            ),
                        ),
                        // Container(
                        //   padding: EdgeInsets.all(20),
                        //   child: Stack(
                        //     alignment: Alignment(0 , 0),
                        //     children: <Widget>[
                        //         TextField(
                        //           enabled: _codeEnabel,
                        //             decoration: InputDecoration(
                        //                 labelText: '请输入右侧文字',
                        //                 labelStyle: TextStyle(
                        //                     color: AppStyle.colorPrimary,
                        //                 ),
                        //             ),
                        //             onChanged: (value){
                        //               //输入改变
                        //               verificationCode = value;
                        //             },
                        //             style: TextStyle(
                        //                 color: AppStyle.colorPrimary
                        //             ),
                        //         ),
                        //         Row(
                        //             children: <Widget>[
                        //                 Expanded(child: SizedBox(height: 1,),),
                        //                 Container(
                        //                     height: ScreenUtil.getInstance().setWidth(32),
                        //                     width: 1,
                        //                     color: AppStyle.colorPrimary,
                        //                 ),
                        //                 SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                        //                 GestureDetector(
                        //                   onTap: (){
                        //                     //获取图形验证码
                        //                     getImageYz('3');
                        //                   },
                        //                   child: Container(
                        //                   height: 40,
                        //                   margin: EdgeInsets.only(bottom: 5),
                        //                   padding: EdgeInsets.only(bottom: 5),
                        //                   child: imageNetString == ''?Container():Image.network(
                        //                               imageNetString
                        //                             )
                        //                 ),
                        //                 ),
                        //                 SizedBox(width: ScreenUtil.getInstance().setWidth(16),),

                        //             ],
                        //         ),
                        //     ],
                        // ),
                        // ),
                        // Stack(
                        //     alignment: Alignment(0 , 0),
                        //     children: <Widget>[
                        //         Container(
                        //           padding: EdgeInsets.all(20),
                        //           child: TextField(
                        //             enabled: _codeEnabel,
                        //             decoration: InputDecoration(
                        //                 labelText: '验证码',
                        //                 labelStyle: TextStyle(
                        //                     color: AppStyle.colorPrimary,
                        //                 ),
                        //             ),
                        //             onChanged: (value){
                        //             //输入改变
                        //             changeCode = value;
                        //           },
                        //             style: TextStyle(
                        //                 color: AppStyle.colorPrimary
                        //             ),
                        //         ),
                        //         ),
                        //         Row(
                        //             children: <Widget>[
                        //                 Expanded(child: SizedBox(height: 1,),),
                        //                 Container(
                        //                     height: ScreenUtil.getInstance().setWidth(32),
                        //                     width: 1,
                        //                     color: AppStyle.colorPrimary,
                        //                 ),
                        //                 SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                        //                 LoginFormCode(countdown: 60,available: _isAvailable,onTapCallback: _getVerificationCode,),
                        //                 SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                        //             ],
                        //         )
                        //     ],
                        // ),

                        Container(
                            padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                            child: Row(
                                children: <Widget>[
                                    Column(
                                        children: <Widget>[
                                            Text('收发货信息',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500)),
                                            SizedBox(height: 10),
                                            Container(width: 60,height: 3,color: Colors.black,)
                                        ],
                                    ),
                                    // Expanded(child: SizedBox(height: 1,)),
                                    // GestureDetector(
                                    //   onTap: (){
                                    //     //修改
                                    //     if(!_citySelected ){
                                    //       setState(() {
                                    //         _citySelected = true;
                                    //       });
                                    //     }
                                    //   },
                                    //   child: Container(
                                    //     alignment: Alignment.center,
                                    //     padding: EdgeInsets.only(right: 0),
                                    //     height: 37,
                                    //     width: 90,
                                    //   decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(37),
                                    //     border: new Border.all(color: !_citySelected?AppStyle.colorPrimary:AppStyle.colorRed, width: 0.5), // 边色与边宽度
                                    //   ),
                                    //   child: Text(!_citySelected?'修改':'完成',style: TextStyle(fontSize: 16,color: !_citySelected?AppStyle.colorPrimary:AppStyle.colorRed))
                                    // )
                                    // )
                                ],
                            ),
                        ),
                        //收货地址
                        SizedBox(height: 20),
                        Container(
                            padding: EdgeInsets.only(left: 20),
                            alignment: Alignment.bottomLeft,
                            child: Text('收货地址',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500,)),),

                        ListView.builder(
                            shrinkWrap:true,
                            physics:NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            itemCount: shdz.length??0,
                            itemBuilder: (BuildContext context, int position){
                                Map item = shdz[position];
                                return  Container(
                                    // color: AppStyle.colorBackground,
                                    padding: EdgeInsets.all(10),
                                    // margin: EdgeInsets.only(bottom: 10),
                                    child: Row(
                                        children: <Widget>[
                                            Expanded(
                                                flex: 9,
                                                child: Container(
                                                    child: Column(
                                                        children: <Widget>[
                                                            Container(
                                                                child: Row(
                                                                    children: <Widget>[
                                                                        Container(
                                                                            child: Text(item['name'],style: TextStyle(fontSize: 14,color: AppStyle.colorPrimary)),
                                                                        ),
                                                                        SizedBox(width: 10,),
                                                                        Container(
                                                                            child: Text(item['phone'],style: TextStyle(fontSize: 10,color: AppStyle.colorPrimary)),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                child: Text(item['province']+'  '+item['city']+'  '+item['district']+'  '+item['addr'],style: TextStyle(fontSize: 12,color: AppStyle.colorPrimary),maxLines: 4,),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Container(width: 0.5,height: 40,color: AppStyle.colorBackground,),
                                            Expanded(
                                                flex: 2,
                                                child: FlatButton(
                                                    child: new Text('编辑'),
                                                    onPressed: () {
                                                        setState(() {

                                                            selterNumber = position;
                                                            _citySelected = true;
                                                            _city = item['province']+'  '+item['city']+'  '+item['district'];
                                                            _putNumberController = TextEditingController(text: item['phone']);
                                                            _putNameController = TextEditingController(text: item['name']);
                                                            _addressController = TextEditingController(text: item['addr']);
                                                            userAddress['province'] = item['province'];
                                                            userAddress['city'] = item['city'];
                                                            userAddress['district'] = item['district'];
                                                            userAddress['phone'] = item['phone'];
                                                            userAddress['name'] = item['name'];
                                                            userAddress['addr'] = item['addr'];
                                                            userAddress['addId'] = item['addId'];
                                                            userAddress['type'] = item['type'];
                                                        });
                                                        //滚动
                                                        _scrollController.animateTo(_scrollController.position.maxScrollExtent,duration: Duration(milliseconds: 500),curve: Curves.decelerate);
                                                    },
                                                ),
                                            )
                                        ],
                                    ),
                                );
                            },
                        ),

                        //发货人
                        Container(
                            padding: EdgeInsets.only(left: 20),
                            alignment: Alignment.bottomLeft,
                            child: Text('发货地址',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500,)),),

                        ListView.builder(
                            shrinkWrap:true,
                            physics:NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            itemCount: fhdz.length??0,
                            itemBuilder: (BuildContext context, int position){
                                Map item = fhdz[position];
                                return  Container(
                                    // color: AppStyle.colorBackground,
                                    padding: EdgeInsets.all(10),
                                    // margin: EdgeInsets.only(bottom: 10),
                                    child: Row(
                                        children: <Widget>[
                                            Expanded(
                                                flex: 9,
                                                child: Container(
                                                    child: Column(
                                                        children: <Widget>[
                                                            Container(
                                                                child: Row(
                                                                    children: <Widget>[
                                                                        Container(
                                                                            child: Text(item['name'],style: TextStyle(fontSize: 14,color: AppStyle.colorPrimary)),
                                                                        ),
                                                                        SizedBox(width: 10,),
                                                                        Container(
                                                                            child: Text(item['phone'],style: TextStyle(fontSize: 10,color: AppStyle.colorPrimary)),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                child: Text(item['province']+'  '+item['city']+'  '+item['district']+'  '+item['addr'],style: TextStyle(fontSize: 12,color: AppStyle.colorPrimary),maxLines: 4,),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            Container(width: 0.5,height: 40,color: AppStyle.colorBackground,),
                                            Expanded(
                                                flex: 2,
                                                child: FlatButton(
                                                    child: new Text('编辑'),
                                                    onPressed: () {
                                                        setState(() {
                                                            selterNumber = position;
                                                            _citySelected = true;
                                                            _city = item['province']+'  '+item['city']+'  '+item['district'];
                                                            _putNumberController = TextEditingController(text: item['phone']);
                                                            _putNameController = TextEditingController(text: item['name']);
                                                            _addressController = TextEditingController(text: item['addr']);
                                                            userAddress['province'] = item['province'];
                                                            userAddress['city'] = item['city'];
                                                            userAddress['district'] = item['district'];
                                                            userAddress['phone'] = item['phone'];
                                                            userAddress['name'] = item['name'];
                                                            userAddress['addr'] = item['addr'];
                                                            userAddress['addId'] = item['addId'];
                                                            userAddress['type'] = item['type'];
                                                        });
                                                        //滚动
                                                        _scrollController.animateTo(_scrollController.position.maxScrollExtent,duration: Duration(milliseconds: 500),curve: Curves.decelerate);
                                                    },
                                                ),
                                            )
                                        ],
                                    ),
                                );
                            },
                        ),

                        //地址选择器
                        Container(
                            padding: EdgeInsets.only(left: 20,top: 20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Container(),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: GestureDetector(
                                            onTap: () {
                                                this._show(context);
                                            },
                                            child: Text(_city,style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                        ),
                                    )
                                ],
                            )
                        ),
                        //地址
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('地址',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: TextField(
                                            maxLines: 2,
                                            controller: _addressController,
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    color: AppStyle.colorLightDarkText,
                                                    fontSize: 14,

                                                ),
                                                helperStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,

                                                ),

                                            ),
                                            style: TextStyle(
                                                color: AppStyle.colorPrimary
                                            ),
                                            onChanged: (value){
                                                //输入改变
                                                phoneNumber = value;
                                                userAddress['addr'] = value;
                                            },
                                            //完成编辑
                                            onEditingComplete:(){
                                                print('aaa');
                                            }

                                        ),
                                    )
                                ],
                            ),
                        ),

                        //收发件人
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('收发件人',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: TextField(
                                            controller: _putNameController,
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    color: AppStyle.colorLightDarkText,
                                                    fontSize: 14,
                                                ),
                                                helperStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,

                                                ),

                                            ),
                                            style: TextStyle(
                                                color: AppStyle.colorPrimary
                                            ),
                                            onChanged: (value){
                                                //输入改变
                                                phoneNumber = value;
                                                userAddress['name'] = value;
                                            },
                                            //完成编辑
                                            onEditingComplete:(){

                                            }

                                        ),
                                    )
                                ],
                            ),
                        ),

                        //手机号
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text('手机号',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: TextField(
                                            controller: _putNumberController,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    color: AppStyle.colorLightDarkText,
                                                    fontSize: 14,

                                                ),
                                                helperStyle: TextStyle(
                                                    color: AppStyle.colorPrimary,

                                                ),

                                            ),
                                            style: TextStyle(
                                                color: AppStyle.colorPrimary
                                            ),
                                            onChanged: (value){
                                                //输入改变
                                                userAddress['phone'] = value;
                                            },
                                            //完成编辑
                                            onEditingComplete:(){

                                            }

                                        ),
                                    )
                                ],
                            ),
                        ),
                        Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    MaterialButton(
                                        color: AppStyle.colorPrimary,
                                        textColor: AppStyle.colorWhite,
                                        child: new Text(_citySelected ?'删除联系人':'添加为寄件人'),
                                        onPressed: () {
                                            if(alidate() == false){
                                                showToast('请完善信息');
                                                return;
                                            }
                                            if(_citySelected){
                                                //删除联系人
                                                ApiConfig().removePerson(userAddress['addId']).
                                                then((onValue){
                                                    if(onValue == null){return;}
                                                    if(onValue['rspCode'] != '0000'){
                                                        showToast(onValue['rspDesc']);

                                                        return;
                                                    }
                                                    getUserMessage();
                                                    userAddress = {};
                                                    selterNumber = null;
                                                    _citySelected = false;
                                                    _city = '点我选择地址';
                                                    _putNumberController = TextEditingController(text: '');
                                                    _putNameController = TextEditingController(text: '');
                                                    _addressController = TextEditingController(text: '');
                                                    showToast('删除成功');
                                                });
                                            }else{
                                                //添加寄件人
                                                ApiConfig().addPerson('2', userAddress['province'], userAddress['city'], userAddress['district'], userAddress['addr'], userAddress['name'], userAddress['phone']).
                                                then((onValue){
                                                    if(onValue == null){return;}
                                                    if(onValue['rspCode'] != '0000'){
                                                        showToast(onValue['rspDesc']);
                                                        return;
                                                    }
                                                    getUserMessage();
                                                    userAddress = {};
                                                    selterNumber = null;
                                                    _citySelected = false;
                                                    _city = '点我选择地址';
                                                    _putNumberController = TextEditingController(text: '');
                                                    _putNameController = TextEditingController(text: '');
                                                    _addressController = TextEditingController(text: '');
                                                    showToast('添加成功');
                                                });
                                            }
                                        },
                                    ),
                                    SizedBox(width: 20),
                                    MaterialButton(
                                        color: AppStyle.colorPrimary,
                                        textColor: AppStyle.colorWhite,
                                        child: new Text(_citySelected ?'  编辑完成  ':'添加为收件人'),
                                        onPressed: () {
                                            if(alidate() == false){
                                                showToast('请完善信息');
                                                return;
                                            }
                                            if(_citySelected){
                                                //修改
                                                ApiConfig().alterPerson(userAddress['addId'],userAddress['type'], userAddress['province'], userAddress['city'], userAddress['district'], userAddress['addr'], userAddress['name'], userAddress['phone']).
                                                then((onValue){
                                                    if(onValue == null){return;}
                                                    if(onValue['rspCode'] != '0000'){
                                                        showToast(onValue['rspDesc']);
                                                        return;
                                                    }
                                                    getUserMessage();
                                                    userAddress = {};
                                                    selterNumber = null;
                                                    _citySelected = false;
                                                    _city = '点我选择地址';
                                                    _putNumberController = TextEditingController(text: '');
                                                    _putNameController = TextEditingController(text: '');
                                                    _addressController = TextEditingController(text: '');
                                                    showToast('修改成功');
                                                });
                                            }else{
                                                //添加为收件人
                                                ApiConfig().addPerson('1', userAddress['province'], userAddress['city'], userAddress['district'], userAddress['addr'], userAddress['name'], userAddress['phone']).
                                                then((onValue){
                                                    if(onValue == null){return;}
                                                    if(onValue['rspCode'] != '0000'){
                                                        showToast(onValue['rspDesc']);
                                                        return;
                                                    }
                                                    getUserMessage();
                                                    userAddress = {};
                                                    selterNumber = null;
                                                    _citySelected = false;
                                                    _city = '点我选择地址';
                                                    _putNumberController = TextEditingController(text: '');
                                                    _putNameController = TextEditingController(text: '');
                                                    _addressController = TextEditingController(text: '');
                                                    showToast('添加成功');
                                                });
                                            }
                                        },
                                    )
                                ],
                            ),
                        ),
                        SizedBox(height: 20,)


                    ],
                ),
            )
        );
    }
    ///添加或修改验证
    bool alidate(){
        if(userAddress['phone'] == '' || Application.isChinaPhoneLegal(userAddress['phone']??'') == false){
            return false;
        }
        if(userAddress['name'] == ''){
            return false;
        }
        if(userAddress['addr'] == ''){
            return false;
        }
        return true;

    }

    String validatephoneNumber (value){
        if(value.isEmpty){
            return '手机号不能为空.';
        }
        if(!Application.isChinaPhoneLegal(value)){
            return '请输入正确的手机号.';
        }else{
            //请求网络验证手机号是否注册过
            _isAvailable = true;
            return null;
        }
    }
    String  validatePassword (value){
        if(value.isEmpty){
            return '密码不能为空.';
        }
        if(value.length < 6){
            return '密码不能少于6位.';
        }
        password = value;
    }
    String isEmail (value){
        if(value.isEmpty){
            return '邮箱不能为空.';
        }
        if(!Application.isEmail(value)){
            return '请输入正确的邮箱地址.';
        }else{
            //请求网络验证手机号是否注册过
            _isAvailable = true;
            return null;
        }
    }

}




/// 墨水瓶（`InkWell`）可用时使用的字体样式。
final TextStyle _availableStyle = TextStyle(
    fontSize: ScreenUtil.getInstance().setSp(32.0),
    color: AppStyle.colorPrimary,
);

/// 墨水瓶（`InkWell`）不可用时使用的样式。
final TextStyle _unavailableStyle = TextStyle(
    fontSize: ScreenUtil.getInstance().setSp(32.0),
    color: AppStyle.colorPrimary,
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
                bool isPass = widget.onTapCallback();
                if(isPass == false){
                    return;
                }
                _startTimer();
                inkWellStyle = _unavailableStyle;
                _verifyStr = '已发送$_seconds'+'s';
                setState(() {});
            } : null,
        ): InkWell(
            child: Text(
                '  获取验证码  ',
                style: _unavailableStyle,
            ),
        );
    }
}
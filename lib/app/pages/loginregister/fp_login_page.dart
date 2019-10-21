import 'dart:async';
import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:janalytics/janalytics.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'dart:math' as math;

class LoginRPage extends StatefulWidget{
  final String isLogin;
  
  const LoginRPage({Key key, this.isLogin}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginRPage> with SingleTickerProviderStateMixin{
  bool setLogin;
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool _isLogin = false;//是否登录
  bool _showBackTop = false;//是否显示到顶部按钮
  final Janalytics janalytics = new Janalytics();
  String claseIcon = 'menu@3x.png';
   @override
  void initState() {
    
    super.initState();
    // setInitValue();
    setLogin = widget.isLogin=='1'?true:false;
    janalytics.onPageStart(widget.runtimeType.toString());
  }

  @override
  void dispose() {
    janalytics.onPageEnd(widget.runtimeType.toString());
    super.dispose();
  }
//打开抽屉
openDrow(){
  Timer(Duration(milliseconds: 50),(){
                       setState(() {
      claseIcon = 'closedicon.png';
      });
                    });
}
 Future closeDrow() async{
   Timer(Duration(milliseconds: 50),(){
                       setState(() {
      claseIcon = 'menu@3x.png';
      });
                    });
  
}
@override
  Widget build(BuildContext context) {
    return Scaffold(
          key: _scaffoldkey,
          drawer: SmartDrawer(callback: (isOpen){
      if(!isOpen){
        closeDrow();
      }else{
        openDrow();
      }
      },),
          drawerScrimColor: Colors.transparent,
      appBar: myappbar(context, false, false,sckey: _scaffoldkey,menuIcon: claseIcon),
        body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Theme(
          data: Theme.of(context).copyWith(
                    primaryColor: Colors.white
                ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              // 触摸收起键盘
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(0.0),
              color: AppStyle.colorWhite,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: <Widget>[Stack(
                        // alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(0.0),
                            width: double.infinity,
                            child: Image(
                              image: AssetImage(AssetUtil.image('login_Group@3x.png')), 
                            ),
                          ),
                          
                          Container(
                                  width: ScreenUtil.getInstance().setWidth(180),
                                 height: 2,
                                  color: AppStyle.colorRed,
                                  margin: setLogin?EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(160),top: ScreenUtil.getInstance().setWidth(326)):EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(420),top: ScreenUtil.getInstance().setWidth(326)),
                                ),
                          Container(
                            margin: EdgeInsets.only(top: 120),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  // padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
                                  
                                  child: InkWell(
                                  child: Text(
                                    '登录',
                                     style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(32),color: AppStyle.colorWhite,fontWeight: FontWeight.w500),
                                  ),
                                  onTap: (){
                                    if(!setLogin){
                                      setState(() {
                                        setLogin = true;
                                      });
                                    }
                                  },
                                  ),
                                ),
                                SizedBox(width: ScreenUtil.getInstance().setSp(100),),
                                Container(
                                  color: AppStyle.colorBackground,
                                  height: 13,
                                  width: 1,
                                  alignment: Alignment.center,
                                ),
                                SizedBox(width: ScreenUtil.getInstance().setSp(100),),
                                Container(
                                  child: InkWell(
                                  child: Text(
                                    '注册',
                                     style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(32),color: AppStyle.colorWhite,fontWeight: FontWeight.w500),
                                  ),
                                  onTap: (){
                                    if(setLogin){
                                      setState(() {
                                        setLogin = false;
                                      });
                                    }
                                  },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          
                        ],
                      ),
                    Container(
                      child: setLogin?Container(child: LoginFromDemo()):Container(child: RegisterFromDemo(),padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(64.0)),),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        )
        
         
      );

  }
}

class LoginFromDemo extends StatefulWidget {
  
    @override
    _LoginFromDemoState createState() => _LoginFromDemoState();
}

class _LoginFromDemoState extends State<LoginFromDemo> {

    final loginFormKey = GlobalKey<FormState>();
    String phoneNumber='',password='',imageyanzhengma = '',messageCode = '',imageNetString = '',reqSn = '',imgCode = '';
    bool autoValidate = false;

    bool _isAvailable = true;

    bool _openVerb = false;
    int _buyIndex = 1;

     double a = 0.5;
    Color c = AppStyle.colorPrimary;
    double d = 0.5;
    Color e = AppStyle.colorPrimary;

    void _login(){

        showDialog<Null>(
            context: context, //BuildContext对象
            barrierDismissible: false,
            builder: (BuildContext context) {
                return new LoadingDialog( //调用对话框
                    text: '正在登录...',
                );
            });
        if(_openVerb){
          ApiConfig().verbUser('2',phone: phoneNumber,smsReqSn: reqSn,smsCode: messageCode).then((response){
             Navigator.pop(context); 
            if(response['rspCode'] == '0000'){
              UserInfoCache().setUserNo(userNo: {'userNo':response['userNo']});
              UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
                //获取用户信息
                ApiConfig().getAccount().then((onValue){
                  UserInfoCache().setUserInfo(userInfo: onValue);
                  
                  //推送别名
                  JPush jpush = new JPush();
                  jpush.setAlias(onValue['userNo']).then((map) {
                    print(map);
                    }).catchError((error) {});
                   
                  Fluttertoast.showToast(msg:'登录成功',
                  toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  Timer(Duration(seconds: 1),(){
                    Navigator.pop(context);
                  });
                });
                return;
            }else{
              //弹窗
                Fluttertoast.showToast(msg:response['rspDesc'], toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                );
            }
          });
        }else{
          ApiConfig().verbUser('1',userName: phoneNumber,pwd: password).then((response){
            
             Navigator.pop(context); 
            if(response['rspCode'] == '0000'){
              UserInfoCache().setUserNo(userNo: {'userNo':response['userNo']});
              UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
                //获取用户信息
                ApiConfig().getAccount().then((onValue){
                  if(response['rspCode'] != '0000'){return;}
                  UserInfoCache().setUserInfo(userInfo: onValue);
                  
                  //推送别名
                  JPush jpush = new JPush();
                  jpush.setAlias(onValue['userNo']).then((map) {
                    print(map);
                    }).catchError((error) {});
                  Fluttertoast.showToast(msg:'登录成功', toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                Timer(Duration(seconds: 2),(){
                    Navigator.pop(context);
                  });
                  
                });
                return;
            }else{
              //弹窗
              Fluttertoast.showToast(msg:response['rspDesc'], toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
            }
          });
        }
        

            //登录成功缓存用户信息
            // UserInfoCache().setUserInfo(userInfo: response['message']['user']);
            // UserInfoCache().saveInfo(key: UserInfoCache.phoneNumber,value: phoneNumber);
            // UserInfoCache().saveInfo(key: UserInfoCache.loginPassword,value: password);
            // UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');

            //请求网络数据
            // HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.sessionIdUrl}',).then((sessionResponse){

            //     if(response['error'] != 0){
            //         Fluttertoast.showToast(
            //             msg: response['message'],
            //             toastLength: Toast.LENGTH_SHORT,
            //             gravity: ToastGravity.CENTER,
            //             timeInSecForIos: 2,
            //             backgroundColor: AppStyle.colorGreyDark,
            //             textColor: Colors.white,
            //             fontSize: 16.0
            //         );
            //         return;
            //     }
            //     //注册成功保存 session id
            //     UserInfoCache().saveInfo(key: UserInfoCache.sessionId,value: sessionResponse['message']);


            //     //请求网络数据
            //     HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.refreshUssUrl}',sessionId:sessionResponse['message']).then((res){});

            //     _gotoIndex();//保存信息后退出登录页
            // });

        // });
    }

    void submitRegisterInfo (){

        if(loginFormKey.currentState.validate()){

            loginFormKey.currentState.save();
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
    String validateemailName (value){
        if(value.isEmpty){
            return '不能为空.';
        }
    }
    String validatePassword (value){
        if(value.isEmpty){
            return '密码不能为空.';
        }
    }
    bool _getVerificationCode(){

            loginFormKey.currentState.save();
            loginFormKey.currentState.validate();
            if(imageyanzhengma.length == 0){
              Fluttertoast.showToast(msg:"需输入图形验证码", toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
              getImageYz();
              return false;
            }else if(imgCode != imageyanzhengma){
              //弹窗
              Fluttertoast.showToast(msg:"图形验证码不正确,请重新输入", toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
              getImageYz();
              return false;
            }
        if(validatephoneNumber(phoneNumber) != null || validateImageVerificationCode(imageyanzhengma) != null){
            // loginFormKey.currentState.validate();//开启验证

            //弹窗
//            showToast("请输入正确,再获取验证码!");
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
            //请求网络数据
            ApiConfig().sendMessage('2', phoneNumber).then((response){
              Navigator.pop(context);
              if(response['rspCode'] == '0000'){
                    Fluttertoast.showToast(
                        msg:'发送成功',
                         toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    reqSn = response['reqSn'];
                    return true;
                }else{
                  Fluttertoast.showToast(
                        msg:response['rspDesc'], toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return false;
                }
            });
        }
        print('发送验证码');
        return true;
    }
    String validateVerificationCode (value){
        if(value.isEmpty){
            return '验证码不能为空.';
        }
    }
    String validateImageVerificationCode (value){
        if(value.isEmpty){
            return '图形验证码不能为空.';
        }
    }

    @override
  void initState() {
    super.initState();
  }

  getImageYz(){
    //获取图文验证码
    ApiConfig().obtainImage(2).then((onValue){
      print(onValue);
      if(onValue['rspCode'].toString() != '0000'){
        Fluttertoast.showToast( msg:onValue['rspDesc'],
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
        imgCode = onValue['imgCode'];
        
        imageNetString = onValue['imgUrl'];
      });
    });
  }



 Widget selectBuyBarView({BuildContext context,String title1,String title2}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: ScreenUtil.getInstance().setWidth(16.0),
        bottom: ScreenUtil.getInstance().setWidth(16.0),
      ),
      child: Column(
        children: <Widget>[
          Container(
            color: AppStyle.colorWhite,
            padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(4.0)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      if(_buyIndex == 1)return;
                      setState(() {
                        _buyIndex = 1;
                        setState(() {
                          _openVerb = !_openVerb;
                          if(_openVerb){
                           getImageYz();
                          }
                        });
                      });
                    },
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(84.0),
                          color: _buyIndex == 1 ? AppStyle.colorWhite : AppStyle.colorBackground,
                          child: Center(
                            child: Text(
                              title1,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        _buyIndex == 1 ?
                        Container(
                          width: ScreenUtil.getInstance().setWidth(16.0),
                          child:Image(image: AssetImage(AssetUtil.image('Path 14@3x.png')),fit: BoxFit.fitWidth,),
                        )
                            :
                        Container(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      if(_buyIndex == 2)return;
                      setState(() {
                        _buyIndex = 2;
                      });
                      setState(() {
                          _openVerb = !_openVerb;
                          if(_openVerb){
                           getImageYz();
                          }
                        });
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(84.0),
                          color: _buyIndex == 2 ? AppStyle.colorWhite : AppStyle.colorBackground,
                          child: Center(
                            child: Text(
                              title2,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        _buyIndex == 2 ?
                        Transform.rotate(
                          angle: math.pi/2,
                          child: Container(
                            width: ScreenUtil.getInstance().setWidth(16.0),
                            child:Image(image: AssetImage(AssetUtil.image('Path 14@3x.png')),fit: BoxFit.fitWidth,),
                          ),
                        )
                            :
                        Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    @override
    Widget build(BuildContext context) {
        return Form(
            key: loginFormKey,
            child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: ScreenUtil.getInstance().setWidth(180.0),
                        color: AppStyle.colorBackground,
                      ),
                      Container(
                        margin: EdgeInsets.only(top:  ScreenUtil.getInstance().setWidth(50.0),),
                        child: selectBuyBarView(context: context,title1: '使用密码',title2: '使用验证码'),
                      )
                      
                    ],
                  ),

                    Container(
                      padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(40.0),right: ScreenUtil.getInstance().setWidth(40.0)),
                      child: Column(
                        children: <Widget>[
                          SizedBox( height: ScreenUtil.getInstance().setHeight(100.0),),
                          TextFormField(
                             cursorColor: AppStyle.colorPrimary,
                        initialValue: phoneNumber,
                        keyboardType: _openVerb?TextInputType.phone:TextInputType.text,
                        decoration: InputDecoration(
                            labelText: _openVerb?'手机号':'用户名/Email',
                            labelStyle: TextStyle(
                                color: AppStyle.colorPrimary,
                            ),
                            helperText: '',
                            helperStyle: TextStyle(
                                color: Color(0xFFCBCBCB),
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color:Color(0xFFCBCBCB))
                            )
                        ),
                        onSaved: (value){
                            phoneNumber = value;
                        },
                        
                        validator: _openVerb?validatephoneNumber:validateemailName,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorPrimary
                        ),
                    ),
                    _openVerb?
                    Stack(
                        alignment: Alignment(0 , 0),
                        children: <Widget>[
                            TextFormField(
                              cursorColor: AppStyle.colorPrimary,
                              initialValue: imageyanzhengma,
                                obscureText: false,
                                decoration: InputDecoration(
                                    labelText: '请输入右侧文字',
                                    labelStyle: TextStyle(
                                        color: AppStyle.colorPrimary,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color:Color(0xFFCBCBCB),)
                                    )
                                ),
                                onSaved: (value){
                                    imageyanzhengma = value;
                                },
                                validator: validateImageVerificationCode,
                                autovalidate: autoValidate,
                                style: TextStyle(
                                    color: AppStyle.colorPrimary
                                ),
                            ),
                            Row(
                                children: <Widget>[
                                    Expanded(child: SizedBox(height: 1,),),
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                    GestureDetector(
                                      onTap: (){
                                        //获取图形验证码
                                        getImageYz();
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
                            )
                        ],
                    ):
                    Container(),
                    _openVerb?SizedBox( height: ScreenUtil.getInstance().setHeight(32.0),):Container(),
                    _openVerb?
                    Stack(
                        alignment: Alignment(0 , 0),
                        children: <Widget>[
                            TextFormField(
                              cursorColor: AppStyle.colorPrimary,
                                initialValue: messageCode,
                                obscureText: false,
                                decoration: InputDecoration(
                                    labelText: '验证码',
                                    labelStyle: TextStyle(
                                        color: AppStyle.colorPrimary,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color:Color(0xFFCBCBCB),)
                                    )
                                ),
                                onSaved: (value){
                                    messageCode = value;
                                },
                                validator: validateVerificationCode,
                                autovalidate: autoValidate,
                                style: TextStyle(
                                    color: Color(0xFFCBCBCB),
                                ),
                            ),
                            Row(
                                children: <Widget>[
                                    Expanded(child: SizedBox(height: 1,),),
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                    LoginFormCode(countdown: 60,available: _isAvailable,onTapCallback: _getVerificationCode,),
                                    
                                ],
                            )
                        ],
                    ):
                    TextFormField(
                      cursorColor: AppStyle.colorPrimary,
                        obscureText: true,
                        initialValue: password,
                        decoration: InputDecoration(
                            labelText: '登录密码',
                            labelStyle: TextStyle(
                                color: AppStyle.colorPrimary,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color:Color(0xFFCBCBCB),)
                            )
                        ),
                        onSaved: (value){
                            password = value;
                        },
                        validator: validatePassword,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorPrimary,
                        ),
                    ),
                    SizedBox( height: ScreenUtil.getInstance().setHeight(140.0),),
                    
                     Row(
                    children: <Widget>[
                      Expanded(flex: 2,
                       child: Container(),
                      ),
                      Expanded(flex: 2,
                      child: Container(
                          height: ScreenUtil.getInstance().setWidth(74),
                        width: ScreenUtil.getInstance().setWidth(168),
                        child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: a,
                                              color: c,
                                              style: BorderStyle.solid,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(37)),
                              ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        onHighlightChanged: (onPressed){
                          print(onPressed);
                          setState(() {
                            if(onPressed){
                              a= 2;
                            c = Colors.red;
                            }else{
                               a = 0.5;
                               c = AppStyle.colorPrimary;
                            }
                          });
                        },
                       child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '取消',
                              style: TextStyle(
                                  color: AppStyle.colorPrimary,
                                  fontSize: ScreenUtil.getInstance().setSp(26.0)
                              ),
                            ),

                          ),// 下部的影子
                      )
                      ),
                      ),
                      SizedBox(width: ScreenUtil.getInstance().setHeight(30)),
                      Expanded(
                        flex: 2,
                        child: Container(
                        child: MaterialButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                            
               side: BorderSide(
                 width: d,
                 color: e ,
                 style: BorderStyle.solid,
               ),
               borderRadius: BorderRadius.all(Radius.circular(37)),
             ),

clipBehavior: Clip.antiAliasWithSaveLayer,
                        onPressed: submitRegisterInfo,
                        onHighlightChanged: (onPressed){
                          setState(() {
                            if(onPressed){
                              d= 2;
                            e = AppStyle.colorRed;
                            }else{
                               d = 0.5;
                               e = c;
                            }
                          });
                        },
                       child: Container(
                         height: ScreenUtil.getInstance().setWidth(74),
                        width: ScreenUtil.getInstance().setWidth(168),
                            alignment: Alignment.center,
                            child: Text(
                              '登录',
                              style: TextStyle(
                                  color: AppStyle.colorWhite,
                                  fontSize: ScreenUtil.getInstance().setSp(26.0)
                              ),
                            ),

                          ),// 下部的影子
                      )
                      ),
                        
                       
                      ),
                      Expanded(flex: 2,
                        child: Container(),
                      ),

                    ],
                  ),

                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(100),),
                    
                ],
            ),
        );
    }
}



///注册
class RegisterFromDemo extends StatefulWidget {
    @override
    _RegisterFromDemoState createState() => _RegisterFromDemoState();
}

class _RegisterFromDemoState extends State<RegisterFromDemo> {

    bool _newValue = true;
    final registerFormKey = GlobalKey<FormState>();
    String phoneNumber,password,verificationCode,email,username,imagever = '';
    String imgCode = '';
    String reqSn = '';
    String imageNetString = '';
    bool autoValidate = false,_isAvailable = true;

    double a = 0.5;
    Color c = AppStyle.colorPrimary;
    double d = 0.5;
    Color e = AppStyle.colorPrimary;
    void _gotoHelpWord() async{
        Application.router.navigateTo(context, Routes.helpWord,transition: TransitionType.native);
    }



getImageYz(){
    //获取图文验证码
    ApiConfig().obtainImage(1).then((onValue){
      if(onValue['rspCode'].toString() != '0000'){
        Fluttertoast.showToast(msg:onValue['rspDesc'],
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
        imgCode = onValue['imgCode'];
        
        imageNetString = onValue['imgUrl'];
      });
    });
  }

    @override
  void initState() {
    super.initState();
    getImageYz();
  }
    void submitRegistInfo (){
        if(_newValue == false){
          Fluttertoast.showToast(msg:'需勾选同意用户服务条款和隐私保护条款', toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          return;
        }
        if(registerFormKey.currentState.validate()){
            registerFormKey.currentState.save();
            //显示加载动画
            showDialog<Null>(
                context: context, //BuildContext对象
                barrierDismissible: false,
                builder: (BuildContext context) {
                    return new LoadingDialog( //调用对话框
                        text: '正在获取详情...',
                    );
                });
                //注册
            ApiConfig().registerUser(username, email, phoneNumber, reqSn, verificationCode, password).then((response){
              Navigator.pop(context); //关闭对话框
                if(response['rspCode'] != '0000'){
                    Fluttertoast.showToast(msg:response['rspDesc'],
                     toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                }
                //登录
                ApiConfig().verbUser('1',userName: phoneNumber,pwd: password).then((onValue){
                  if(response['rspCode'] == '0000'){
                  UserInfoCache().setUserNo(userNo: {'userNo':response['userNo']});
                  UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
                //获取用户信息
                ApiConfig().getAccount().then((onValue1){
                  UserInfoCache().setUserInfo(userInfo: onValue1);
                 
                  JPush jpush = new JPush();
                  jpush.setAlias(onValue1['userNo']).then((map) {
                    print(map);
                    }).catchError((error) {});
                  Fluttertoast.showToast(msg:'注册成功',
                   toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                );
                  Timer(Duration(seconds: 2),(){
                    Navigator.pop(context);
                  });
                });
                return;
            }else{
              //弹窗
                Fluttertoast.showToast(msg:response['rspDesc'],
                 toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                );
            }
                });
            });

        }else{
            setState(() {
                autoValidate = true;
            });
        }
    }



    String validatephoneNumber (value){
        if(value.isEmpty){
            _isAvailable = false;
            return '手机号不能为空.';
        }
        if(!Application.isChinaPhoneLegal(value)){
            _isAvailable = false;
            return '手机号格式错误.';
        }
        print('yes');
        _isAvailable = true;
    }
    String validateImageVerificationCode (value){
        if(value.isEmpty){
            return '图形验证码不正确.';
        }
    }
    String  validatePassword (value){
        if(value.isEmpty){
            return '密码不能为空.';
        }
        if(value.length < 6){
            return '密码不能少于6位.';
        }
        if(!Application.passWord(value)){
          return '密码不能为纯数字或纯字母.';
        }
        password = value;
    }
    String isEmail (value){
        if(value.isEmpty){
            _isAvailable = false;
            return '邮箱不能为空.';
        }
       if(!Application.isEmail(value)){
           _isAvailable = false;
           return 'Email格式错误.';
       }else{
            //请求网络验证手机号是否注册过
            _isAvailable = true;
       }
    }
    String validateVerificationCode (value){
        if(value.isEmpty){
//          _isAvailable = false;
            return '验证码不能为空.';
        }
        _isAvailable = true;
    }
    String usernamevalidateVerificationCode (value){
        if(value.isEmpty){
          _isAvailable = false;
            return '名字不能为空.';
        }
        _isAvailable = true;
    }

    bool _getVerificationCode(){

        registerFormKey.currentState.save();//保存信息
        if(imagever.length == 0){
          Fluttertoast.showToast(msg:"需输入图形验证码",
           toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          getImageYz();
          return false;
        }else if(imgCode != imagever){
              //弹窗
            Fluttertoast.showToast(msg:"图形验证码不正确,请重新输入",
             toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
            getImageYz();
            return false;
            }
        if(validatephoneNumber(phoneNumber) != null || validateImageVerificationCode(imagever) != null){
            //弹窗
//            showToast("请输入正确,再获取验证码!");
        if(validatephoneNumber(phoneNumber) != null){
          Fluttertoast.showToast(msg:validatephoneNumber(phoneNumber),
           toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
        }
        _isAvailable = true;
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
             //请求验证码
            ApiConfig().sendMessage('1', phoneNumber).then((response){
              Navigator.pop(context);
              if(response['rspCode'] == '0000'){
                    Fluttertoast.showToast(msg:'发送成功',
                     toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    reqSn = response['reqSn'];
                    return true;
                }else{
                  Fluttertoast.showToast(msg:response['rspDesc'],
                   toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return false;
                }
            });

        }
        print('发送验证码');

        return true;
    }

    @override
  void dispose() {
    
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
        return Form(
            key: registerFormKey,
            child: Column(
                children: <Widget>[
                  SizedBox(height: ScreenUtil.getInstance().setHeight(80)),
                    TextFormField(
                      cursorColor: AppStyle.colorPrimary,
                      validator: usernamevalidateVerificationCode,
                      onSaved: (value){
                            username = value;
                        },
                      autovalidate: autoValidate,
                      decoration: InputDecoration(
                        fillColor: AppStyle.colorPrimary,
                        labelText: '用户名',
                        labelStyle: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(28),
                          color: AppStyle.colorPrimary,
                        ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:AppStyle.colorPrimary)
                          )
                      ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(40),),
                    TextFormField(
                      cursorColor: AppStyle.colorPrimary,
                      decoration: InputDecoration(
                        fillColor: AppStyle.colorPrimary,
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: AppStyle.colorPrimary,
                          fontSize: ScreenUtil.getInstance().setSp(28),
                        ),
                        helperStyle: TextStyle(
                                color: AppStyle.colorPrimary,
                            ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:AppStyle.colorPrimary)
                          )
                      ),
                      onSaved: (value){
                            email = value;
                        },
                        validator: isEmail,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorPrimary
                        ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(40),),
                    TextFormField(
                      cursorColor: AppStyle.colorPrimary,
                        obscureText: true,
                        initialValue: password,
                        decoration: InputDecoration(
                            labelText: '登录密码',
                            labelStyle: TextStyle(
                                color: AppStyle.colorPrimary,
                              fontSize: ScreenUtil.getInstance().setSp(28),
                            ),
                            helperStyle: TextStyle(
                                color: AppStyle.colorPrimary,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color:AppStyle.colorPrimary)
                            )
                        ),
                        onSaved: (value){
                            password = value;
                        },
                        validator: validatePassword,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorPrimary
                        ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(40),),
                    TextFormField(
                      cursorColor: AppStyle.colorPrimary,
                        decoration: InputDecoration(
                            fillColor: AppStyle.colorPrimary,
                            labelText: '手机号',
                            labelStyle: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(28),
                                color: AppStyle.colorPrimary,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color:AppStyle.colorPrimary)
                            )
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (value){
                            phoneNumber = value;
                        },
                        
                        validator: validatephoneNumber,
                        autovalidate: autoValidate,
                        style: TextStyle(
                            color: AppStyle.colorPrimary
                        ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(40),),
                    Stack(
                        alignment: Alignment(0 , 0),
                        children: <Widget>[
                            TextFormField(
                              cursorColor: AppStyle.colorPrimary,
                              initialValue: imagever,
                                obscureText: false,
                                decoration: InputDecoration(
                                    labelText: '请输入右侧文字',
                                    labelStyle: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(28),
                                        color: AppStyle.colorPrimary,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color:AppStyle.colorPrimary)
                                    )
                                ),
                                onSaved: (value){
                                    imagever = value;
                                },
                                validator: validateImageVerificationCode,
                                autovalidate: autoValidate,
                                style: TextStyle(
                                    color: AppStyle.colorPrimary
                                ),
                            ),
                            Row(
                                children: <Widget>[
                                    Expanded(child: SizedBox(height: 1,),),
                                   
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                    GestureDetector(
                                      onTap: (){
                                        //获取图形验证码
                                        getImageYz();
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
                            )
                        ],
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(30),),
                    Stack(
                        alignment: Alignment(0 , 0),
                        children: <Widget>[
                            TextFormField(
                              cursorColor: AppStyle.colorPrimary,
                                obscureText: false,
                                decoration: InputDecoration(
                                    labelText: '验证码',
                                    labelStyle: TextStyle(
                                        color: AppStyle.colorPrimary,
                                      fontSize: ScreenUtil.getInstance().setSp(28),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color:AppStyle.colorPrimary)
                                    )
                                ),
                                onSaved: (value){
                                    verificationCode = value;
                                },
                                validator: validateVerificationCode,
                                autovalidate: autoValidate,
                                style: TextStyle(
                                    color: AppStyle.colorPrimary
                                ),
                            ),
                            Row(
                                children: <Widget>[
                                    Expanded(child: SizedBox(height: 1,),),
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(16),),
                                    LoginFormCode(countdown: 60,available: _isAvailable,onTapCallback: _getVerificationCode,),
                                    
                                ],
                            )
                        ],
                    ),

                    SizedBox(height: ScreenUtil.getInstance().setHeight(20),),
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            _newValue = !_newValue;
                          });
                        },
                        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle,),
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _newValue
                ? Container(child: Image(image: AssetImage(AssetUtil.image('xieyiyes.png')),fit: BoxFit.fitWidth,),width: 20,height: 20,)
                : Image(image: AssetImage(AssetUtil.image('xieyino.png')),fit: BoxFit.fitWidth,width: 20,height: 20,)
          ),
                        ),
                      ),
                          Text(
                            '阅读并同意 ',
                            style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(26.0),
                              fontWeight: FontWeight.w600,
                              color: AppStyle.colorGreyText,
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              NavigatorUtil.push(
                                  context,
                                  WebViewState(
                                    title: '用户服务条款',
                                    url: 'https://kuaichuan.net:8443/fp-ops/tip/servicetip.html',
                                  ));
                            },
                            child: Text(
                              '用户服务条款',
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(26.0),
                                  fontWeight: FontWeight.w600,
                                  color: AppStyle.colorGreyText,
                                  decoration:TextDecoration.underline,
                                  fontStyle: FontStyle.italic
                              ),
                            ),
                          ),
                          Text(
                            ' 和 ',
                            style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(26.0),
                              fontWeight: FontWeight.w600,
                              color: AppStyle.colorGreyText,
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              print('goto 隐私保护条款');
                              NavigatorUtil.push(
                                  context,
                                  WebViewState(
                                    title: '隐私保护条款',
                                    url: 'https://kuaichuan.net:8443/fp-ops/tip/privacytip.html',
                                  ));
                            },
                            child: Text(
                              '隐私保护条款',
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(26.0),
                                  fontWeight: FontWeight.w600,
                                  color: AppStyle.colorGreyText,
                                  decoration:TextDecoration.underline,
                                  fontStyle: FontStyle.italic
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(140),),
                  Row(
                    children: <Widget>[
                      Expanded(flex: 2,
                       child: Container(),
                      ),
                      Expanded(flex: 2,
                      child: Container(
                          height: ScreenUtil.getInstance().setWidth(74),
                        width: ScreenUtil.getInstance().setWidth(168),
                        child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: a,
                                              color: c,
                                              style: BorderStyle.solid,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(37)),
                              ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        onHighlightChanged: (onPressed){
                          print(onPressed);
                          setState(() {
                            if(onPressed){
                              a= 2;
                            c = Colors.red;
                            }else{
                               a = 0.5;
                               c = AppStyle.colorPrimary;
                            }
                          });
                        },
                       child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '取消',
                              style: TextStyle(
                                  color: AppStyle.colorPrimary,
                                  fontSize: ScreenUtil.getInstance().setSp(26.0)
                              ),
                            ),

                          ),// 下部的影子
                      )
                      ),
                      ),
                      SizedBox(width: ScreenUtil.getInstance().setHeight(30)),
                      Expanded(
                        flex: 2,
                        child: Container(
                        child: MaterialButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                            
               side: BorderSide(
                 width: d,
                 color: e ,
                 style: BorderStyle.solid,
               ),
               borderRadius: BorderRadius.all(Radius.circular(37)),
             ),

clipBehavior: Clip.antiAliasWithSaveLayer,
                        onPressed: submitRegistInfo,
                        onHighlightChanged: (onPressed){
                          setState(() {
                            if(onPressed){
                              d= 2;
                            e = AppStyle.colorRed;
                            }else{
                               d = 0.5;
                               e = c;
                            }
                          });
                        },
                       child: Container(
                         height: ScreenUtil.getInstance().setWidth(74),
                        width: ScreenUtil.getInstance().setWidth(168),
                            alignment: Alignment.center,
                            child: Text(
                              '注册',
                              style: TextStyle(
                                  color: AppStyle.colorWhite,
                                  fontSize: ScreenUtil.getInstance().setSp(26.0)
                              ),
                            ),

                          ),// 下部的影子
                      )
                      ),
                      ),
                      Expanded(flex: 2,
                        child: Container(),
                      ),

                    ],
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(100),),
                ],
            ),
        );
    }
}

class NavigatorUtil {
  ///跳转到指定页面
  static push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
/// 墨水瓶（`InkWell`）可用时使用的字体样式。
final TextStyle _availableStyle = TextStyle(
    fontSize: ScreenUtil.getInstance().setSp(28.0),
    color: AppStyle.colorPrimary,
    fontWeight: FontWeight.w600
);

/// 墨水瓶（`InkWell`）不可用时使用的样式。
final TextStyle _unavailableStyle = TextStyle(
    fontSize: ScreenUtil.getInstance().setSp(28.0),
    color: AppStyle.colorPrimary,
    fontWeight: FontWeight.w600
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
    String _verifyStr = '发送手机验证码';

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
        return widget.available ? Container(
          
          width: ScreenUtil.getInstance().setWidth(280),
          height: ScreenUtil.getInstance().setWidth(74),
          child: InkWell(

            child: Container(
              alignment: Alignment.center,
              child: Text(
                '  $_verifyStr  ',
                style: inkWellStyle,
              ),
              decoration:BoxDecoration(
                  border: Border.all(color: AppStyle.colorGrey, width: 1.0),
                  borderRadius: BorderRadius.circular(20.0)),

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
          )
        ) : Container(
          decoration:BoxDecoration(
              border: Border.all(color: AppStyle.colorGrey, width: 1.0),
              borderRadius: BorderRadius.circular(20.0)),
          child: InkWell(
            child: Text(
              '发送手机验证码',
              style: _unavailableStyle,
            ),
          ),
        );
    }
}
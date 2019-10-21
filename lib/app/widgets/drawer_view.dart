import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/widgets/fp_dialog.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class DrawerView extends StatefulWidget {
  final BuildContext context;
  final bool isLogin;
  final Function closeFunc;
  DrawerView({@required this.context,@required this.isLogin,@required this.closeFunc});
  @override
  _DrawerViewState createState() => _DrawerViewState();
}

class _DrawerViewState extends State<DrawerView> {
  @override
  Widget build(BuildContext context) {

    Widget drawerListItem({String title,Color titleColor,double lineWidth,Function onTap,bool hasLine}){
      return GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: ScreenUtil.getInstance().setSp(26.0),
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
            hasLine
                ? Container(height: 1,width: lineWidth,color: AppStyle.colorGreyText,)
                : Container(),
            SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppStyle.colorWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: MediaQueryData.fromWindow(window).padding.top,width: double.infinity,color: AppStyle.colorPrimary,),
            Container(
              padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
              alignment: Alignment.centerRight,
              height: ScreenUtil.getInstance().setWidth(75.0),
              width: double.infinity,
              color: widget.isLogin ? AppStyle.colorPrimary : AppStyle.colorWhite,
              child: GestureDetector(
                onTap: widget.closeFunc,
                child: Icon(
                  Icons.close,
                  size: ScreenUtil.getInstance().setWidth(64.0),
                  color: widget.isLogin ? AppStyle.colorWhite : AppStyle.colorPrimary,
                ),
              ),
            ),
            widget.isLogin ?
            GestureDetector(
              onTap: (){
                //个人中心
                Navigator.pop(context);
                Application.cache?.setInt(Application.SplashCacheKey, 0);
                Application.router.navigateTo(context, Routes.IndividualCenterPage,clearStack: true,transition: TransitionType.native);
              },
              child: Container(
                width: double.infinity,
                height: ScreenUtil.getInstance().setWidth(210.0),
                color: AppStyle.colorPrimary,
                child: Column(
                  children: <Widget>[
                    Expanded(child: SizedBox(width: 1,),),
                    ClipOval(
                      child: Container(
                        width: ScreenUtil.getInstance().setWidth(64.0),
                        height: ScreenUtil.getInstance().setWidth(64.0),
                        child: Image(image: AssetImage(AssetUtil.image('video@3x.png')),fit: BoxFit.fill,),
                      ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                    Text(
                      '个人中心',
                      style: TextStyle(
                        color: AppStyle.colorWhite,
                        fontSize: ScreenUtil.getInstance().setSp(26.0),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Expanded(child: SizedBox(width: 1,),),
                  ],
                ),
              ),
            )
                :
            Container(
              width: double.infinity,
              height: ScreenUtil.getInstance().setWidth(210.0),
              color: AppStyle.colorWhite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: SizedBox(height: 1,),),
                      GestureDetector(
                        onTap: (){
                          //登录
                          Application.router.navigateTo(context, Routes.LoginRPage,transition: TransitionType.native);
                        },
                        child: Container(
                          height: ScreenUtil.getInstance().setWidth(60.0),
                          width: ScreenUtil.getInstance().setWidth(150.0),
                          decoration: BoxDecoration(
                              color: AppStyle.colorPrimary,
                              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(64.0)))
                          ),
                          child: Center(
                            child: Text(
                              '登陆',
                              style: TextStyle(
                                color: AppStyle.colorWhite,
                                fontSize: ScreenUtil.getInstance().setSp(26.0),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                      GestureDetector(
                        onTap: (){
                          //注册
                          Application.router.navigateTo(context, Routes.LoginRPage,transition: TransitionType.inFromRight);
                        },
                        child: Container(
                          height: ScreenUtil.getInstance().setWidth(60.0),
                          width: ScreenUtil.getInstance().setWidth(150.0),
                          decoration: BoxDecoration(
                              color: AppStyle.colorPrimary,
                              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(64.0)))
                          ),
                          child: Center(
                            child: Text(
                              '注册',
                              style: TextStyle(
                                color: AppStyle.colorWhite,
                                fontSize: ScreenUtil.getInstance().setSp(26.0),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox(height: 1,),),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    drawerListItem(
                        title: '首页',
                        titleColor: Color(0xFFCBCBCB),
                        lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                        hasLine: true,
                        onTap: (){
                          print('goto 首页');

                          Application.cache?.setInt(Application.SplashCacheKey, 0);
                          Application.router.navigateTo(context, Routes.home,transition: TransitionType.inFromRight);
                        }
                    ),
                    drawerListItem(
                        title: '运动鞋',
                        titleColor: Color(0xFFCBCBCB),
                        lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                        hasLine: true,
                        onTap: (){
                          Application.cache?.setInt(Application.SplashCacheKey, 0);
                          Application.router.navigateTo(context, Routes.sportsShoesPage,transition: TransitionType.inFromRight);
                        }
                    ),
                    drawerListItem(
                        title: '评测',
                        titleColor: Color(0xFFCBCBCB),
                        lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                        hasLine: true,
                        onTap: (){
                          Application.cache?.setInt(Application.SplashCacheKey, 0);
                          Application.router.navigateTo(context, Routes.informationAll,transition: TransitionType.inFromRight);
                        }
                    ),
                    drawerListItem(
                        title: '资讯',
                        titleColor: Color(0xFFCBCBCB),
                        lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                        hasLine: true,
                        onTap: (){
                          Application.cache?.setInt(Application.SplashCacheKey, 0);
                          Application.router.navigateTo(context, Routes.informationAll,transition: TransitionType.inFromRight);
                        }
                    ),
                    drawerListItem(
                        title: '视频',
                        titleColor: Color(0xFFCBCBCB),
                        lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                        hasLine: true,
                        onTap: (){
                          Application.cache?.setInt(Application.SplashCacheKey, 0);
                          Application.router.navigateTo(context, Routes.informationAll,transition: TransitionType.inFromRight);
                        }
                    ),
                    drawerListItem(
                        title: 'FAQ',
                        titleColor: Color(0xFFCBCBCB),
                        lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                        hasLine: false,
                        onTap: (){
                          // Application.cache?.setInt(Application.SplashCacheKey, 0);
                          Application.router.navigateTo(context, Routes.FQAPage,transition: TransitionType.inFromRight);
                        }
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: ScreenUtil.getInstance().setWidth(300.0),
              child: Column(
                children: <Widget>[
                  Expanded(flex: 1,child: SizedBox(width: 1,),),
                  GestureDetector(
                    onTap: (){
                      NavigatorUtil.push(
                          context,
                          WebViewState(
                            title: '协议',
                            url: 'http://www.baidu.com',
                          ));
                    },
                    child: ClipOval(
                      child: Container(
                        width: ScreenUtil.getInstance().setWidth(70.0),
                        height: ScreenUtil.getInstance().setWidth(70.0),
                        color: AppStyle.colorPink,
                        child: Center(
                          child: Text(
                            '买',
                            style: TextStyle(
                              color: AppStyle.colorWhite,
                              fontSize: ScreenUtil.getInstance().setSp(26.0),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(32.0),),
                  GestureDetector(
                    onTap: (){
                      NavigatorUtil.push(
                          context,
                          WebViewState(
                            title: '协议',
                            url: 'http://www.baidu.com',
                          ));
                    },
                    child: ClipOval(
                      child: Container(
                        width: ScreenUtil.getInstance().setWidth(70.0),
                        height: ScreenUtil.getInstance().setWidth(70.0),
                        color: AppStyle.colorSuccess,
                        child: Center(
                          child: Text(
                            '卖',
                            style: TextStyle(
                              color: AppStyle.colorWhite,
                              fontSize: ScreenUtil.getInstance().setSp(26.0),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 2,child: SizedBox(width: 1,),),
                ],
              ),
            ),
          ],
        ),
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


class SmartDrawer extends StatefulWidget {
  final double elevation;
  final Widget child;
  final String semanticLabel;
  final double widthPercent;
  final bool isIndex;
  ///add start
  final DrawerCallback callback;
  ///add end
  final bool isLogin;

  const SmartDrawer({
    Key key,
    this.elevation = 16.0,
    this.child,
    this.semanticLabel,
    this.widthPercent = 0.65,
    this.isIndex = false,
    ///add start
    this.callback, this.isLogin,
    ///add end
  })  : assert(widthPercent < 1.0 && widthPercent > 0.0),
        super(key: key);
  @override
  _SmartDrawerState createState() => _SmartDrawerState();
}

class _SmartDrawerState extends State<SmartDrawer> {
  String _logIn = '0';
  String imgUrl = '';

  bool sonMenu = false;
  @override
  void initState() {
    ///add start
    if(widget.callback!=null){
      widget.callback(true);
    }
    ///add end
    super.initState();
    WidgetsBinding bind = WidgetsBinding.instance;
    bind.addPostFrameCallback((callback) {
      UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
        if(onValue == '1'){
          UserInfoCache().getUserInfo().then((onV){
            setState(() {
              imgUrl = onV['headImgUrl'];
            });
          });
        }
        setState(() {
          _logIn = onValue;
        });
      });
    });
  }
  @override
  void dispose() {
    ///add start
    if(widget.callback!=null){
      widget.callback(false);
    }
    ///add end
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    String label = widget.semanticLabel;
    Widget drawerListItem({String title,Color titleColor,double lineWidth,Function onTap,bool hasLine}){
      return GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: ScreenUtil.getInstance().setSp(28.0),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
            hasLine
                ? Container(height: 1,width: lineWidth,color: Color(0xFFCBCBCB),margin: EdgeInsets.only(left: 30,right: 30),)
                : Container(),
            SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
          ],
        ),
      );
    }
    final double _width = MediaQuery.of(context).size.width * widget.widthPercent;
    return Container(
      margin: EdgeInsets.only(left: 0, top:56 + MediaQueryData.fromWindow(window).padding.top),
      color: Colors.transparent,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: label,
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(width: ScreenUtil.screenWidth),
          child: Material(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: widget.elevation,
            child: Container(
              // width: double.infinity,
              // height: double.infinity,
              color: Colors.transparent,
              margin: EdgeInsets.zero,
              child: Container(
                // width: double.infinity,
                // height: double.infinity,
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: _logIn == '1'?4:6,
                        child: Container(
                          height: double.infinity,
                          color: _logIn == '1' ? AppStyle.colorPrimary : AppStyle.colorWhite,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  left:ScreenUtil.getInstance().setWidth(16.0),
                                ),
                                alignment: Alignment.centerLeft,
                                height: ScreenUtil.getInstance().setWidth(75.0),
                                width: double.infinity,
                                color: _logIn == '1' ? AppStyle.colorPrimary : AppStyle.colorWhite,
                              ),
                              _logIn == '1' ?
                              GestureDetector(
                                onTap: (){
                                  //个人中心
                                  //Navigator.pop(context);
                                  // Application.cache?.setInt(Application.SplashCacheKey, 0);
                                  // Application.router.navigateTo(context, Routes.IndividualCenterPage,clearStack: true,transition: TransitionType.native);
                                  setState(() {

                                    sonMenu = !sonMenu;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: ScreenUtil.getInstance().setWidth(140.0),
                                  color: AppStyle.colorPrimary,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ClipOval(
                                        child: Container(
                                            width: ScreenUtil.getInstance().setWidth(64.0),
                                            height: ScreenUtil.getInstance().setWidth(64.0),
                                            child: imgUrl ==null? Image(image: AssetImage(AssetUtil.image('video@3x.png')),fit: BoxFit.fill,):CachedNetworkImage(
                                                imageUrl: imgUrl)
                                        ),
                                      ),
                                      SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                      Text(
                                        '个人中心',
                                        style: TextStyle(
                                          color: AppStyle.colorWhite,
                                          fontSize: ScreenUtil.getInstance().setSp(26.0),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  :
                              Container(
                                width: double.infinity,
                                height: ScreenUtil.getInstance().setWidth(80.0),
                                color: AppStyle.colorWhite,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(child: SizedBox(height: 1,),),
                                        GestureDetector(
                                          onTap: (){
                                            //登录
                                            Navigator.pop(context);
                                            String islog = '1';
                                            Application.router.navigateTo(context, '${Routes.LoginRPage}?isLogin=$islog',transition: TransitionType.native);
                                          },
                                          child: Container(
                                            height: ScreenUtil.getInstance().setWidth(74.0),
                                            width: ScreenUtil.getInstance().setWidth(168.0),
                                            decoration: BoxDecoration(
                                                color: AppStyle.colorPrimary,
                                                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(64.0)))
                                            ),
                                            child: Center(
                                              child: Text(
                                                '登录',
                                                style: TextStyle(
                                                  color: AppStyle.colorWhite,
                                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                                        GestureDetector(
                                          onTap: (){
                                            //注册
                                            Navigator.pop(context);
                                             String islog = '0';
                                            Application.router.navigateTo(context, '${Routes.LoginRPage}?isLogin=$islog',transition: TransitionType.native);
                                          },
                                          child: Container(
                                             height: ScreenUtil.getInstance().setWidth(74.0),
                                            width: ScreenUtil.getInstance().setWidth(168.0),
                                            decoration: BoxDecoration(
                                                color: AppStyle.colorPrimary,
                                                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(64.0)))
                                            ),
                                            child: Center(
                                              child: Text(
                                                '注册',
                                                style: TextStyle(
                                                  color: AppStyle.colorWhite,
                                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(child: SizedBox(height: 1,),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  color: AppStyle.colorWhite,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      SizedBox(height: ScreenUtil.getInstance().setWidth(10)),
                                      drawerListItem(
                                          title: '首页',
                                          titleColor: Color(0xFF4A4A4A),
                                          lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                                          hasLine: true,
                                          onTap: (){
                                            print('goto 首页');
                                            Navigator.pop(context);
                                            Application.cache?.setInt(Application.SplashCacheKey, 0);
                                            Application.router.navigateTo(context, Routes.home,clearStack: true,transition: TransitionType.native);
                                          }
                                      ),
                                      drawerListItem(
                                          title: '运动鞋',
                                          titleColor: Color(0xFF4A4A4A),
                                          lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                                          hasLine: true,
                                          onTap: (){
                                            Navigator.pop(context);
                                            Application.cache?.setInt(Application.SplashCacheKey, 0);
                                            Application.router.navigateTo(context, Routes.sportsShoesPage,clearStack: true,transition: TransitionType.native);
                                          }
                                      ),
                                      drawerListItem(
                                          title: '评测',
                                          titleColor: Color(0xFF4A4A4A),
                                          lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                                          hasLine: true,
                                          onTap: (){
                                            Navigator.pop(context);
                                            Application.cache?.setInt(Application.SplashCacheKey, 0);
                                            String index = '1';
                                            Application.router.navigateTo(context, '${Routes.informationAll}?index=$index',clearStack: true,transition: TransitionType.native);
                                          }
                                      ),
                                      drawerListItem(
                                          title: '资讯',
                                          titleColor: Color(0xFF4A4A4A),
                                          lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                                          hasLine: true,
                                          onTap: (){
                                            Navigator.pop(context);
                                            Application.cache?.setInt(Application.SplashCacheKey, 0);
                                            String index = '2';
                                            Application.router.navigateTo(context, '${Routes.informationAll}?index=$index',clearStack: true,transition: TransitionType.native);
                                          }
                                      ),
                                      drawerListItem(
                                          title: '视频',
                                          titleColor: Color(0xFF4A4A4A),
                                          lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                                          hasLine: true,
                                          onTap: (){
                                            Navigator.pop(context);
                                            Application.cache?.setInt(Application.SplashCacheKey, 0);
                                            String index = '3';
                                            Application.router.navigateTo(context, '${Routes.informationAll}?index=$index',clearStack: true,transition: TransitionType.native);
                                          }
                                      ),
                                      drawerListItem(
                                          title: 'FAQ',
                                          titleColor: Color(0xFF4A4A4A),
                                          lineWidth: ScreenUtil.getInstance().setWidth(350.0),
                                          hasLine: false,
                                          onTap: (){
                                            Navigator.pop(context);
                                            Application.cache?.setInt(Application.SplashCacheKey, 0);
                                            Application.router.navigateTo(context, Routes.FQAPage,transition: TransitionType.native);
                                          }
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                color: AppStyle.colorWhite,
                                height: ScreenUtil.getInstance().setWidth(349.0),
                                child: Column(
                                  children: <Widget>[
                                    Expanded(flex: 1,child: SizedBox(width: 1,),),
                                    
                                    GestureDetector(
                                      onTap: (){
                                        Application.router.navigateTo(context, '${Routes.buyTips}?id=0&type=1',transition: TransitionType.native);
                                      },
                                      child: ClipOval(
                                        child: Container(
                                          width: ScreenUtil.getInstance().setWidth(70.0),
                                          height: ScreenUtil.getInstance().setWidth(70.0),
                                          color: AppStyle.colorPink,
                                          child: Center(
                                            child: Text(
                                              '买',
                                              style: TextStyle(
                                                color: AppStyle.colorWhite,
                                                fontSize: ScreenUtil.getInstance().setSp(30.0),
                                                fontWeight: FontWeight.w600,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setHeight(32.0),),
                                    GestureDetector(
                                      onTap: (){
                                        Application.router.navigateTo(context, '${Routes.sellTips}?id=0&type=1',transition: TransitionType.native);
                                      },
                                      child: ClipOval(
                                        child: Container(
                                          width: ScreenUtil.getInstance().setWidth(70.0),
                                          height: ScreenUtil.getInstance().setWidth(70.0),
                                          color: AppStyle.colorSuccess,
                                          child: Center(
                                            child: Text(
                                              '卖',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                
                                                color: AppStyle.colorWhite,
                                                fontSize: ScreenUtil.getInstance().setSp(30.0),
                                                fontWeight: FontWeight.w600,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 2,child: SizedBox(width: 1,),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 4,
                          child: sonMenu == true ? Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    top: 8.0
                                ),
                                color: AppStyle.colorPrimary,
                                width: double.infinity,
                                child: Column(
                                  children: <Widget>[
                                    drawerListItem(
                                        title: '我的购买',
                                        titleColor: AppStyle.colorWhite,
                                        lineWidth: 0,
                                        hasLine: true,
                                        onTap: (){
                                          Navigator.pop(context);
                                          String action = '0';
                                          Application.router.navigateTo(context,
                                              '${Routes.IndividualCenterPage}?index=$action',
                                              transition: TransitionType.native);
                                        }
                                    ),
                                    drawerListItem(
                                        title: '我的出售',
                                        titleColor: AppStyle.colorWhite,
                                        lineWidth: 0,
                                        hasLine: true,
                                        onTap: (){
                                          Navigator.pop(context);
                                          String action = '1';
                                          Application.router.navigateTo(context,
                                              '${Routes.IndividualCenterPage}?index=$action',
                                              transition: TransitionType.native);
                                        }
                                    ),
                                    drawerListItem(
                                        title: '我的会员仓',
                                        titleColor: AppStyle.colorWhite,
                                        lineWidth: 0,
                                        hasLine: true,
                                        onTap: (){
                                          Navigator.pop(context);
                                          String action = '2';
                                          Application.router.navigateTo(context,
                                              '${Routes.IndividualCenterPage}?index=$action',
                                              transition: TransitionType.native);
                                        }
                                    ),
                                    drawerListItem(
                                        title: '设置',
                                        titleColor: AppStyle.colorWhite,
                                        lineWidth: 0,
                                        hasLine: true,
                                        onTap: (){
                                          Navigator.pop(context);
                                          String action = '3';
                                          Application.router.navigateTo(context,
                                              '${Routes.IndividualCenterPage}?index=$action',
                                              transition: TransitionType.native);
                                        }
                                    ),
                                    drawerListItem(
                                        title: '注销',
                                        titleColor: AppStyle.colorWhite,
                                        lineWidth: 0,
                                        hasLine: true,
                                        onTap: (){
                                          fpshowDiaLog(context, '', '确定要退出登录吗?', sureSelected);
                                        }
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: GestureDetector(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                      )
                                  )
                              ),
                            ],
                          ):Container(
                            child: GestureDetector(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                      )
                                  ),
                          )
                      )
                    ],
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }



sureSelected(){


    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            //调用对话框
            text: '正在注销登录...',
          );
        });
    ApiConfig().leaveLogin().then((response) {
      Navigator.pop(context);

      showToast( '登录已注销');
      UserInfoCache().setUserInfo(userInfo: {});
      UserInfoCache().setUserNo(userNo: {});
      UserInfoCache().saveInfo(
          key: UserInfoCache.loginStatus, value: '0');
      //删除别名
      JPush jpush = new JPush();
      jpush.deleteAlias().then((map) {
        print(map);
      }).catchError((error) {});

      setState(() {});
      Navigator.pop(context);
      if(widget.isIndex)Application.router.navigateTo(context, Routes.home,clearStack: true,transition: TransitionType.native,);
    });
}

}

get mydrawer => SmartDrawer(
    widthPercent: 0.65,
    child: Text('hhhh'),
    isLogin: false,
);

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

///自定义appbar  ispop 是否是返回按钮
AppBar myappbar(BuildContext context, bool ispop, bool isLogin,
    {GlobalKey<ScaffoldState> sckey, Function leaveLogIn,String image='',String menuIcon='menu@3x.png'}) {
  return  AppBar(
    leading: ispop
        ? IconButton(
            highlightColor: AppStyle.colorPrimary,
            splashColor: AppStyle.colorPrimary,
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        : IconButton(
            highlightColor: AppStyle.colorPrimary,
            splashColor: AppStyle.colorPrimary,
            icon: Container(
              height: 20,
              width: 20,
              child: Image(
                image: AssetImage(AssetUtil.image(menuIcon)),
              ),
            ),
            onPressed: () {
              sckey.currentState.openDrawer();
            },
          ),
    title: Center(
      child: Image(
        height: 37,
        image: AssetImage(AssetUtil.image('logoblcopy.png')),
      ),
    ),
    actions: <Widget>[
      isLogin
          ? Container(
              padding: EdgeInsets.only(right: 5),
              alignment: Alignment.center,
              child: PopupMenuButton(
                child: Container(
                  height: 30,
                  width: 30,
                  child: ClipOval(
                    child: Container(
                      child: image ==null? Image(image: AssetImage(AssetUtil.image('video@3x.png')),fit: BoxFit.fill,):CachedNetworkImage(
                        imageUrl: image),
                    ),
                  ),
                ),
                padding: EdgeInsets.all(0.0),
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<String>>[
                    // PopupMenuItem<String>(
                    //   child: Text(
                    //     "我的购买",
                    //     style: TextStyle(fontSize: 15),
                    //   ),
                    //   value: "0",
                    // ),
                    // PopupMenuItem<String>(
                    //   child: Text("我的出售", style: TextStyle(fontSize: 15)),
                    //   value: "1",
                    // ),
                    // PopupMenuItem<String>(
                    //   child: Text("设置", style: TextStyle(fontSize: 15)),
                    //   value: "3",
                    // ),
                    // PopupMenuItem<String>(
                    //   child: Text("注销登录", style: TextStyle(fontSize: 15)),
                    //   value: "2",
                    // ),
                  ];
                },
                onSelected: (String action) {
                  switch (action) {
                    case "0":
                      Application.router.navigateTo(context,
                          '${Routes.IndividualCenterPage}?index=$action',
                          transition: TransitionType.native);
                      break;
                    case "1":
                      Application.router.navigateTo(context,
                          '${Routes.IndividualCenterPage}?index=$action',
                          transition: TransitionType.native);

                      break;
                    case "2":
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
                        // if (response['rspCode'] != '0000') {
                        //     Fluttertoast.showToast(
                        //         msg: response['rspDesc'],
                        //         toastLength: Toast.LENGTH_SHORT,
                        //         gravity: ToastGravity.CENTER,
                        //         timeInSecForIos: 2,
                        //         backgroundColor: AppStyle.colorGreyDark,
                        //         textColor: Colors.white,
                        //         fontSize: 16.0);
                        //     return;
                        //   }
                        showToast( '登录已注销');
                        UserInfoCache().setUserInfo(userInfo: {});
                        UserInfoCache().saveInfo(
                            key: UserInfoCache.loginStatus, value: '0');
                            //删除别名
                            JPush jpush = new JPush();
                            jpush.deleteAlias().then((map) {
                              print(map);
                              }).catchError((error) {});

                        leaveLogIn(context);
                      });

                      break;
                    case "3":
                      Application.router.navigateTo(context,
                          '${Routes.IndividualCenterPage}?index=$action',
                          transition: TransitionType.native);

                      break;
                  }
                },
                onCanceled: () {
                  print("onCanceled");
                },
              ),
            )
          : Container(),
      Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 12, 0),
          child: GestureDetector(
            onTap: () {
              //搜索
              Application.router.navigateTo(context, Routes.search,
                  transition: TransitionType.native);
            },
            child: Container(
              height: 20,
              width: 20,
              child: Image(
                image: AssetImage(AssetUtil.image('search@3x.png')),
              ),
            ),
          ))
    ],
  );
}

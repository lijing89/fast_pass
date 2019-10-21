import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/pages/my/person_info_page.dart';

class MyIndexPage extends StatefulWidget {
  @override
  _MyIndexPageState createState() => _MyIndexPageState();
}

class _MyIndexPageState extends State<MyIndexPage> {

  String _userName = '',_phoneNum = '',_headImageUrl = '';

  Widget imageView (){
    return Container(
      margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
      child: ClipOval(
        child: Image.network(
          _headImageUrl == null ? '' : _headImageUrl,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  Widget topView(){
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Container(
          height: ScreenUtil.getInstance().setWidth(400.0),
          width: double.infinity,
          decoration: BoxDecoration(
//              color: AppStyle.colorLight
          ),
        ),
        Container(
            width: double.infinity,
            height: ScreenUtil.getInstance().setWidth(260.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetUtil.image('mybackground.png')),
                alignment: Alignment.topCenter,
//          repeat: ImageRepeat.repeatY,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.hardLight,
                ),
              ),
            )
        ),
        Column(
          children: <Widget>[
            SizedBox(width: 1,height: ScreenUtil.getInstance().setWidth(64.0),),
            Row(
              children: <Widget>[
                Expanded(child: SizedBox(height: 1,)),
                IconButton(
                  icon: Icon(AppIcon.settings),
                  iconSize: 24.0,
                  color: Colors.white,
                  onPressed: (){
//                    print('clicked setting btn');
                    Application.router.navigateTo(context, Routes.settingIndex);
                  },
                ),
                SizedBox(height: 1,width: ScreenUtil.getInstance().setWidth(32.0),),
              ],
            ),
            SizedBox(width: 1,height: ScreenUtil.getInstance().setWidth(32.0),),
            Row(
              children: <Widget>[
                SizedBox(height: 1,width: ScreenUtil.getInstance().setWidth(32.0),),
                Expanded(
                    child: InkWell(
                      child: Container(
                        height: ScreenUtil.getInstance().setWidth(200.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(32.0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 1,width: ScreenUtil.getInstance().setWidth(32.0),),
                            imageView (),
                            SizedBox(height: 1,width: ScreenUtil.getInstance().setWidth(32.0),),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(width: 1,height: ScreenUtil.getInstance().setWidth(32.0),),
                                Text(
                                  '用户 $_userName',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScreenUtil.getInstance().setSp(36.0)
                                  ),
                                ),
                                SizedBox(width: 1,height: ScreenUtil.getInstance().setWidth(32.0),),
                                Text(
                                  _phoneNum,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenUtil.getInstance().setSp(32.0)
                                  ),
                                ),
                                SizedBox(width: 1,height: ScreenUtil.getInstance().setWidth(32.0),),
                              ],
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            Icon(
                              AppIcon.right,
                              color: AppStyle.colorSecondary,
                            ),
                            SizedBox(height: 1,width: ScreenUtil.getInstance().setWidth(32.0),),
                          ],
                        ),
                      ),
                      onTap: (){
//                        print('click person info');
                        _goToUserInfo();
                      },
                    )
                ),
                SizedBox(height: 1,width: ScreenUtil.getInstance().setWidth(32.0),),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget buttonsView(){
    return Container(
      width: double.infinity,
      height: ScreenUtil.getInstance().setWidth(400.0),
      child: Row(
        children: <Widget>[
          SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
          Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(32.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ButtonDemo('我的团队', Icon(AppIcon.people,color: AppStyle.colorSecondary,), (){
//                          print('我的团队');
                          Application.router.navigateTo(context, Routes.team);
                        }),
                        ButtonDemo('意见反馈', Icon(AppIcon.creative,color: AppStyle.colorSecondary), (){
//                          print('意见反馈');
                          Application.router.navigateTo(context, Routes.feedback);
                        }),
                        ButtonDemo('实名认证', Icon(AppIcon.peoplelist,color: AppStyle.colorSecondary), (){
//                          print('实名认证');
                          Application.router.navigateTo(context, Routes.realName);
                        }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ButtonDemo('邀请好友', Icon(AppIcon.share,color: AppStyle.colorSecondary), (){
                          print('邀请好友');
                          Application.router.navigateTo(context, Routes.inviteFriends);
                        }),
                        ButtonDemo('关于我们', Icon(AppIcon.addressbook,color: AppStyle.colorSecondary,), (){
//                          print('关于我们');
                          Application.router.navigateTo(context, Routes.about);
                        }),
//                        ButtonDemo('常见问题', Icon(AppIcon.question,color: AppStyle.colorSecondary), (){
//                          print('常见问题');
//                          Application.router.navigateTo(context, Routes.problems);
//                        }),
//                        ButtonDemo('', Icon(AppIcon.notification,color: Colors.white), (){
////                          print('暂无');
//                        }),
                        ButtonDemo('', Icon(AppIcon.notification,color: Colors.white), (){
//                          print('暂无');
                        }),
                      ],
                    ),
                  ],
                ),
              )
          ),
          SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
        ],
      ),
    );
  }


  _goToUserInfo()async{
    //这个变量就是，执行push，等待pop后的刷新界面
    await Navigator.push(context,MaterialPageRoute(builder: (context) => PersonInfoPage()));

    PaintingBinding.instance.imageCache.clear();

    UserInfoCache().getUserInfo().then((onValue){
      setState(() {
        _userName = onValue['name'];
        _phoneNum = onValue['mobile'];
        _headImageUrl = AppConfig.cdnImageUrl + onValue['head_pic'];
      });
    });

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    UserInfoCache().getUserInfo().then((onValue){
      setState(() {
        _userName = onValue['name'];
        _phoneNum = onValue['mobile'];
        _headImageUrl = AppConfig.cdnImageUrl + onValue['head_pic'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(0.0),
        children : <Widget>[
          Column(
            children: <Widget>[
              topView(),
              SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
              buttonsView(),
            ],
          )
        ],
      ),
    );
  }
}


class ButtonDemo extends StatelessWidget {

  String _title;
  Icon _icon;
  Function _onPress;
  ButtonDemo(this._title,this._icon,this._onPress);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil.getInstance().setWidth(160.0),
      width: ScreenUtil.getInstance().setWidth(120.0),
      child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: ScreenUtil.getInstance().setWidth(110.0),
                  width: ScreenUtil.getInstance().setWidth(110.0),
                  child: _icon,
                ),
                SizedBox(height: ScreenUtil.getInstance().setWidth(4.0)),
                Text(
                  _title,
                  style:TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(29),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  onTap: (){
                    _onPress();
                  },
                ),
              ),
            ),
          ]
      ),
    );
  }
}
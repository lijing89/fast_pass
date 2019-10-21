
import 'dart:async';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:janalytics/janalytics.dart';

import 'information_tab_page.dart';
//咨询页
class informationAll extends StatefulWidget{
  
  final String index;

  const informationAll({Key key, this.index}) : super(key: key);
  @override
  _informationAllState createState() => _informationAllState();
}

class _informationAllState extends State<informationAll> with SingleTickerProviderStateMixin{
  TabController _controller;
  List<String> titleName = ['全部','测评','资讯','视频'];
  bool _isLogin = false;//是否登录
  bool _showBackTop = false;//是否显示到顶部按钮
  final Janalytics janalytics = new Janalytics();
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  String imgUrl = '';
  String claseIcon = 'menu@3x.png';
  
@override
  void initState() {
    janalytics.onPageStart(widget.runtimeType.toString());
    _controller = TabController(
          length: titleName.length, vsync: this); 
    super.initState();
//    UMengAnalytics.beginPageView("information");
    _controller.index = int.parse(widget.index);
    WidgetsBinding bind = WidgetsBinding.instance;
    bind.addPostFrameCallback((callback) {
      UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
        setState(() {
          _isLogin = onValue == '1'?true:false;
        });
        if(_isLogin){
       UserInfoCache().getUserInfo().then((onV){
         setState(() {
           imgUrl = onV['headImgUrl'];
         });
       });
        }
    });
    });
  }

@override
  void dispose() {
    _controller.dispose();
    super.dispose();
//    UMengAnalytics.endPageView('end_information');
    janalytics.onPageEnd(widget.runtimeType.toString());
  }
@override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
        setState(() {
          _isLogin = onValue == '1'?true:false;
        });
    });
    }
  }

///退出登录
leaveLogIn(BuildContext context){
  setState(() {
    _isLogin = false;
  });
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
  ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
  return Scaffold(
    drawer: SmartDrawer(callback: (isOpen){
      if(!isOpen){
        closeDrow();
      }else{
        openDrow();
      }
      },),
    drawerScrimColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    key: _scaffoldkey,
      appBar: myappbar(context, false, false,sckey: _scaffoldkey,leaveLogIn: leaveLogIn,image: imgUrl,menuIcon: claseIcon),
      body:  Column(
        children: <Widget>[
          Container(
          height: ScreenUtil.getInstance().setHeight(202),
          width: double.infinity,
          color: Colors.white,
          child: TabBar(
              
              controller: _controller,
              labelColor: Colors.black,
              indicatorColor: Color(0xffE3485F),
              indicatorSize: TabBarIndicatorSize.label,
              // indicator: UnderlineIndicator(
              //     strokeCap: StrokeCap.round,
              //     borderSide: BorderSide(
              //       color: Color(0xff2fcfbb),
              //       width: 3,
              //     ),
              //     insets: EdgeInsets.only(bottom: 10)),
              tabs: titleName.map((String tab) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(tab,
                style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(36)),
                ),
                );
                  
                  // );
              }).toList()
              ),
        ),
        Container(
         color: Colors.black26,
         height: 1,
        ),
        Flexible(
            child: TabBarView(
                controller: _controller,
                children: titleName.map((String tab) {
                  return informationTapPage(title:tab);
                }).toList()
                )
                )
        ],
      ),
    );
    
  }





}
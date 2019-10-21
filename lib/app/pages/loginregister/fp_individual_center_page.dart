

import 'package:fast_pass/app/pages/loginregister/fp_trabe_record_page.dart';
import 'package:fast_pass/app/pages/loginregister/fp_user_set_page.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/resources/user_info_cache.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:janalytics/janalytics.dart';

class IndividualCenterPage extends StatefulWidget {

  final String index;

  const IndividualCenterPage({Key key, this.index}) : super(key: key);
  @override
  _IndividualCenterPageState createState() => _IndividualCenterPageState();
}





class _IndividualCenterPageState extends State<IndividualCenterPage> with SingleTickerProviderStateMixin{
TabController _controller;
bool setLogin = true;
var _scaffoldkey = new GlobalKey<ScaffoldState>();
bool _isLogin = true;//是否登录
bool _showBackTop = false;//是否显示到顶部按钮
 String imgUrl = '';
final Janalytics janalytics = new Janalytics();
  List<Map> titleName = [{'name':'我的购买','image':'my_buy@3x.png'},{'name':'我的出售','image':'my_sell@3x.png'},{'name':'我的会员仓','image':'my_member@3x.png'},{'name':'设置','image':'Fill90@3x.png'}];
@override
  void initState() {
    _controller = TabController(
          length: titleName.length, vsync: this); 
    super.initState();
    _controller.index = int.parse(widget.index);
    janalytics.onPageStart(widget.runtimeType.toString());
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
  }
  
 
  @override
  void dispose() {
    super.dispose();
    janalytics.onPageEnd(widget.runtimeType.toString());
    _controller.dispose();
  }
  ///退出登录设置
leaveLogIn(BuildContext context){
  setState(() {
    _isLogin = false;
  });
}
@override
  Widget build(BuildContext context) {
    
    //假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334),设置字体大小根据系统的“字体大小”辅助选项来进行缩放,默认为false
    //默认设计稿为6p7p8p尺寸 width : 1080px , height:1920px , allowFontScaling:false
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          key: _scaffoldkey,
          drawer: mydrawer,
          drawerScrimColor: Colors.transparent,
      appBar: myappbar(context, true, _isLogin,sckey: _scaffoldkey,leaveLogIn: leaveLogIn,image: imgUrl),
        body: Theme(
          data: Theme.of(context).copyWith(
                    primaryColor: Colors.white
                ),
          child: Column(
        children: <Widget>[
          Container(
          height: ScreenUtil.getInstance().setWidth(164),
          width: double.infinity,
          color: AppStyle.colorBackground,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TabBar(
              controller: _controller,
              labelColor: Colors.black,
              indicatorColor: AppStyle.colorPrimary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: titleName.map((Map tab) {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(14),
                        child: Image(
                          height:  14,
                          width:  14,
                          image:AssetImage(AssetUtil.image(tab['image'])),
                        ),
                      ),
                      Text(tab['name'],
                style: TextStyle(fontSize: 13),
                maxLines: 1,
                ),
                
                    ],
                  ),
                );
              }).toList()
              ),
          )
        ),
        Flexible(
            child: Container(
              margin: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setWidth(20.0), ScreenUtil.getInstance().setWidth(20.0), ScreenUtil.getInstance().setWidth(20.0), 0),
              
              child: TabBarView(
                controller: _controller,
                children:[TrabeRecordPage(title: '我的购买'),TrabeRecordPage(title: '我的出售'),TrabeRecordPage(title: '我的会员仓'),UserSetPage()]

                ),
            )
                )
        ],
      ),
        ),
    ),
      );


  }
}
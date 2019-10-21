import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/fp_count.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/fp_dialog.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:janalytics/janalytics.dart';

class InformationDetailsState extends StatefulWidget {
  final String number;

  const InformationDetailsState({Key key, this.number}) : super(key: key);
  @override
  _InformationDetailsWeigthState createState() =>
      _InformationDetailsWeigthState();
}

class _InformationDetailsWeigthState extends State<InformationDetailsState>
    with SingleTickerProviderStateMixin {
  List ar = [];
  Map detail = {
  };
  List _recommend = [];
  List _newArticlesList = [];
  List _hotArticlesList = [];
  bool _isLogin = false; //是否登录
  bool _showBackTop = false; //是否显示到顶部按钮
  String imgUrl = '';
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  final Janalytics janalytics = new Janalytics();
  CountModule count = new CountModule('文章详情');
  @override
  void initState() {
    super.initState();
    count.openPage();
    WidgetsBinding bind = WidgetsBinding.instance;
    bind.addPostFrameCallback((callback) {
      //加载数据
      loaddata();
    });
  }
  loaddata(){
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
    //获取文章详情
      ApiConfig().consultDetail(widget.number).then((response) {
        if(response == null){return;}
        if(response['rspCode'] != '0000'){return;}
        if(response['rspCode'] == '1000'){//用户在其他设备登录
          showOneButtonDiaLog(context, '账号在其他设备登录', '如不是本人操作请及时修改密码', loginSelected);
        }
        //获取推荐内容
        ApiConfig().consultRecommend(widget.number).then((onValue) {
          if(onValue == null){return;}
          if(onValue['rspCode'] != '0000'){return;}
          setState(() {
            _recommend = onValue['list']??[];
          });
        });
        setState(() {
          //设置数据
          detail = response;
          ar = response['article'];
        });
      });
      //热门推荐
      ApiConfig().firstLink(listId:'1').then((response){
        if(response == null){return;}
        if(response['rspCode'] != '0000'){return;}
        ApiConfig().firstLink(listId:'2').then((onValue){
          if(onValue == null){return;}
          if(onValue['rspCode'] != '0000'){return;}
          if(mounted){
            setState(() {
            _newArticlesList=response['list'];
            _hotArticlesList=onValue['list'];
          });
          }
      });
      });
  }
  ///确定
  loginSelected(){
    loaddata();
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

///退出登录设置
leaveLogIn(BuildContext context){
  setState(() {
    _isLogin = false;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: mydrawer,
      drawerScrimColor: Colors.transparent,
      key: _scaffoldkey,
      backgroundColor: Color(0xFFF5F5F5),
      appBar: myappbar(context, true, false,sckey: _scaffoldkey,leaveLogIn: leaveLogIn,image: imgUrl),
      body: ar.length == 0
          ? LoadingDialog(
              //调用对话框
              text: '正在加载...',
            )
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.all(0),
                  child: ListView(
                    physics: ClampingScrollPhysics(), //禁止弹簧效果
                    padding: EdgeInsets.only(top: 87),
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            child: Text(
                              detail['title'],
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(fontSize: 24, color: Color(0xFF33333A)),
                            ),
                          ),
                           Container(
                                  padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  width: double.infinity,
                                  child: Text(
                                    detail['date'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12, color: Color(0xFF33333A)),
                                  ),
                                ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10,  10, 10, 20),
                            itemCount: ar.length,
                            itemBuilder: (BuildContext context, int position) {
                              return _items(context, position);
                            },
                          ),
                          recommendList(context),
                          bottomView(context:context,newList: _newArticlesList,hotList: _hotArticlesList),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 20.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppStyle.colorWhite,
                    ),
                    child: IconButton(
                      color: AppStyle.colorPrimary,
                      icon: Icon(
                        Icons.drag_handle,
                        size: 30.0,
                      ),
                      onPressed: () {
                        _scaffoldkey.currentState.openDrawer();
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  _items(BuildContext context, int position) {
    Map a = ar[position];
    if (a['type'] == 1) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        width: double.infinity,
        child: Text(
          a['content'],
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 12, color: Color(0xFF33333A)),
        ),
      );
    } else if (a['type'] == 2) {
      return Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: a['content'],
            placeholder: (context, url) => new CircularProgressIndicator(
              strokeWidth: 1.0,
            ),
            errorWidget: (context, url, error) => new Icon(Icons.warning),
            fit: BoxFit.fitWidth,
          ));
    } else if (a['type'] == 3) {
      return GestureDetector(
        onTap: () {
          String s = ar[position]['link'];
          NavigatorUtil.push(
              context,
              WebViewState(
                title: '',
                url: s,
              ));
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new CachedNetworkImage(
                  imageUrl: a['content'],
                  placeholder: (context, url) {
                    return Center(
                      child: new SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: new CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) => new Icon(Icons.warning),
                  fit: BoxFit.fitWidth,
                ),
                Container(
                  height: 50,
                  width: 50,
                  child: Icon(Icons.play_circle_outline),
                )
              ],
            )),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    janalytics.onPageEnd(widget.runtimeType.toString());
  }

  ///推荐
  Container recommendList(BuildContext context) {
    Widget articlesList({List articles}) {
      Widget _listViewBuilder(BuildContext context, int index) {
        return GestureDetector(
          onTap: () {},
          child: Container(
              padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(20.0)),
              color: AppStyle.colorBackground,
              child: GestureDetector(
                onTap: () {
                  String id = _recommend[index]['id'];
                  if (_recommend[index]['type'] == 2) {
                    Application.router.navigateTo(
                        context, '${Routes.informationDetail}?id=$id',
                        transition: TransitionType.native);
                  } else {
                    Application.router.navigateTo(
                        context, '${Routes.goodDetail}?id=$id',
                        transition: TransitionType.native);
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  color: Color(0x33333A),
                  child: Column(
                    children: <Widget>[
                       Container(height: 4,color: Color(0xFFCBCBCB),),
                        SizedBox(
                        width: double.infinity,
                        height: 20,
                      ),
              SizedBox(
                        width: double.infinity,
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        width: double.infinity,
                        child: Text(
                          _recommend[index]['title'],
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 20,
                      ),
                      Container(
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: _recommend[index]['imgUrl'],
                            placeholder: (context, url) => new ProgressView(),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.warning),
                            fit: BoxFit.fitWidth,
                          )),
                      SizedBox(
                        width: double.infinity,
                        height: 20,
                      ),
                     
                    ],
                  ),
                ),
              )),
        );
      }

      return ListView.builder(
          shrinkWrap: true, //解决无限高度问题
          physics: NeverScrollableScrollPhysics(), //禁用滑动事件
          itemCount: articles.length,
          itemBuilder: _listViewBuilder);
    }

    return  Container(
      width: double.infinity,
      color: AppStyle.colorBackground,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: ScreenUtil.getInstance().setWidth(40.0),
          ),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 60,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(left: 20,bottom: 20),
                width: ScreenUtil.getInstance().setWidth(200.0),
                height: 1,
                color: Color(0xFFCBCBCB),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(40.0),bottom: ScreenUtil.getInstance().setWidth(40.0),right: ScreenUtil.getInstance().setWidth(40.0)),
                child: Text(
               '相关推荐',
                style: TextStyle(
                  color: AppStyle.colorPrimary,
                  fontSize: ScreenUtil.getInstance().setSp(36.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              ),
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(right: 20,bottom: 20),
                width: ScreenUtil.getInstance().setWidth(200.0),
                height: 1,
                color: Color(0xFFCBCBCB),
              ),
            ],
          ),
          ),
          articlesList(articles: _recommend),
          SizedBox(
            height: ScreenUtil.getInstance().setWidth(40.0),
          ),
        ],
      ),
    );
  }

  Container bottomView({BuildContext context,List newList,List hotList}) {

    Widget articlesList({List articles}){

      Widget _listViewBuilder(BuildContext context,int index){
        return InkWell(
            onTap: (){
              String id = articles[index]['id'];
                  if (articles[index]['type'] == 2) {
                    Application.router.navigateTo(
                        context, '${Routes.informationDetail}?id=$id',
                        transition: TransitionType.native);
                  } else {
                    Application.router.navigateTo(
                        context, '${Routes.goodDetail}?id=$id',
                        transition: TransitionType.native);
                  }
            },
            child:Container(
              margin: EdgeInsets.only(top: ScreenUtil.getInstance().setWidth(24.0)),
              child: Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                  Icon(Icons.brightness_1,size: ScreenUtil.getInstance().setWidth(16.0),color: AppStyle.colorGreyText,),
                  SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                  Expanded(
                    child: //富文本
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          text: articles[index]['title'],
                          style: TextStyle(
                            color: AppStyle.colorGreyText,
                            fontSize: ScreenUtil.getInstance().setSp(26.0),
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w200,
                          ),
                          children: []),
                    ),
                  ),
                ],
              ),
            )
        );
      }
      if(articles.length == 0){
        return noDataContainer(text: '暂无数据',textColor: AppStyle.colorGreyText,leftPadding: 80.0);
      }
      return ListView.builder(
          shrinkWrap: true, //解决无限高度问题
          physics:NeverScrollableScrollPhysics(),//禁用滑动事件
          itemCount: articles.length,
          itemBuilder: _listViewBuilder
      );
    }

    return Container(
//      margin: EdgeInsets.only(
//        left:ScreenUtil.getInstance().setWidth(16.0),
//        right:ScreenUtil.getInstance().setWidth(16.0),
//      ),
      width: double.infinity,
      color: AppStyle.colorGreyDark,
      child: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setWidth(60.0),),
              Text(
                '新品发布',
                style: TextStyle(
                  color: AppStyle.colorGreyText,
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          articlesList(articles: newList),
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setWidth(60.0),),
              Text(
                '热门推荐',
                style: TextStyle(
                  color: AppStyle.colorGreyText,
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          articlesList(articles: hotList),
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
        ],
      ),
    );
  }

  Widget noDataContainer({String text,Color textColor,double leftPadding}){
    leftPadding = leftPadding??32.0;
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(16.0),
        right: ScreenUtil.getInstance().setWidth(16.0),
        bottom: ScreenUtil.getInstance().setWidth(16.0),
      ),
      width: double.infinity,
      height: ScreenUtil.getInstance().setWidth(80.0),
//      decoration: BoxDecoration(
//        image: DecorationImage(
//          image:  AssetImage(AssetUtil.image('test_img1@3x.png')),
//          fit: BoxFit.fitWidth,
//          alignment: Alignment.centerRight,
//        ),
//        border: Border.all(
//          color: AppStyle.colorWhite,
//          width: 0.5,
//        ),
//      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: ScreenUtil.getInstance().setWidth(leftPadding),),
          Icon(Icons.brightness_1,size: ScreenUtil.getInstance().setWidth(16.0),color: textColor,),
          SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  text: text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: ScreenUtil.getInstance().setSp(26.0),
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w200,
                  ),
                  children: []),
            ),
          ),
          SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
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

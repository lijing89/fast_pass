
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:fast_pass/app/pages/home/components/custom_floating_button.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:janalytics/janalytics.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

const APPBAR_SCROLL_OFFSET = 100;

///页面的滚动距离

///滚动的最大距离
///
class FPIndexPage extends StatefulWidget {
  @override
  _FPIndexPageState createState() => _FPIndexPageState();
}

class _FPIndexPageState extends State<FPIndexPage> {
  ///滚动图信息
  List _imagesList = [];
  ///商品信息
  Map _goodsData = {};
  Map _goodsPriceData = {};
  ///商品最新卖价信息
  Map _goodsNewSellData = {};
  Map _goodsNewSellPriceData = {};
  ///商品最新买价信息
  Map _goodsNewBuyData = {};
  Map _goodsNewBuyPriceData = {};
  ///视频信息
  List _videosList = [];
  ///文章信息
  List _articlesList = [];
  ///测评信息
  List _evaluationsList = [];
  ///新品发布
  List _newArticlesList = [];
  ///热门推荐
  List _hotArticlesList = [];

  double _appBarAlpha = 0;

  ScrollController _controller = ScrollController();

  SwiperController _swiperController = SwiperController();

  bool _isLogin = true;//是否登录
  bool _showBackTop = false;//是否显示到顶部按钮

  String _imgUrl = '';

  String _donwLoadUrl;
  String claseIcon = 'menu@3x.png';

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();
  var _scaffoldkey = new GlobalKey<ScaffoldState>();


   final JPush jpush = new JPush();
   final Janalytics jana = new Janalytics();
    String pushKey;
    String pushVal;
    //极光推送
    Future<void> initPlatformState() async {
        String platformVersion;
        jpush.getRegistrationID().then((rid) {
            print('我的极光推送'+rid);
        });
        jpush.setup(
            appKey: "37fc325701779afca0107e1a",
            channel: "developer-default",
            production: true,
            debug: false,
        );
        jpush.applyPushAuthority(new NotificationSettingsIOS(
            sound: true,
            alert: true,
            badge: true));
        try {
            jpush.addEventHandler(
              ///收到推送
                onReceiveNotification: (Map<String, dynamic> message) async {
                    // print("flutter onReceiveNotification: $message");
                },
                ///打开推送
                onOpenNotification: (Map<String, dynamic> message) async {
                  pushKey = message['extras']['jumpKey'];
                  pushVal = message['extras']['jumpVal'];
                  //060011 订单详情
                  //010014 寄存详情
                  //050002 文章详情
                  print("flutter onOpenNotification: $message");
                  if(pushKey == '#050002'){
                    Application.router.navigateTo(context, '${Routes.informationDetail}?id=$pushVal',
              transition: TransitionType.native);
                  }
                  if(pushKey == '#060011'){
                    ApiConfig().buySellDetail(pushVal).then((response) {
                      if (response == null) {
                        return;
                      }
                      if (response['rspCode'] != '0000') {
                        Fluttertoast.showToast(msg:response['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                        );
                        return;
                      }
                      String type = '1';
                      if(response['orderType'] == 1 || response['orderType'] == 3){
                        type = '2';
                      }else{
                        type = '1';
                      }
                      Application.router.navigateTo(context, '${Routes.OrderDetailPage}?name=$pushVal&type=$type',
                          transition: TransitionType.native);
                    });
              return;
              }
              if(pushKey == '#010014'){
                ApiConfig().depositDetail(pushVal).then((response) {
                  if (response == null) {
                    return;
                  }
                  if (response['rspCode'] != '0000') {
                    Fluttertoast.showToast(msg:response['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                  String type = response['status'];
                  Application.router.navigateTo(context, '${Routes.DepositDetailPage}?name=$pushVal&type=$type',
                      transition: TransitionType.native);

                });
              return;
              }
                },
                //收到消息
                onReceiveMessage: (Map<String, dynamic> message) async {
                    // print("flutter onReceiveMessage: $message");
                },
            );
            //iOS点击状态栏启动APP
            if(Platform.isIOS){
              jpush.getLaunchAppNotification().then((onValue){
              if(onValue.length == 0){return;}
              pushKey = onValue['extras']['jumpKey'];
              pushVal = onValue['extras']['jumpVal'];
              if(pushKey == '#050002'){
                    Application.router.navigateTo(context, '${Routes.informationDetail}?id=$pushVal',
              transition: TransitionType.native);
                  }
              if(pushKey == '#060011'){
                ApiConfig().buySellDetail(pushVal).then((response) {
                  if (response == null) {
                    return;
                  }
                  if (response['rspCode'] != '0000') {
                    Fluttertoast.showToast(msg:response['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                  }
                  String type = '1';
                  if(response['orderType'] == 1 || response['orderType'] == 3){
                    type = '2';
                  }else{
                    type = '1';
                  }
                  Application.router.navigateTo(context, '${Routes.OrderDetailPage}?name=$pushVal&type=$type',
                      transition: TransitionType.native);
                });
                return;
              }
              if(pushKey == '#010014'){
                ApiConfig().depositDetail(pushVal).then((response) {
                  if (response == null) {
                    return;
                  }
                  if (response['rspCode'] != '0000') {
                    Fluttertoast.showToast(msg:response['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                  String type = response['status'];
                  Application.router.navigateTo(context, '${Routes.DepositDetailPage}?name=$pushVal&type=$type',
                      transition: TransitionType.native);

                });
                return;
              }
            });
            }
        }
        on Exception {
            platformVersion = 'Failed to get platform version.';
        }
        ///极光统计
        jana.setup(
            appKey: "37fc325701779afca0107e1a",
            channel: "developer-default",
        );

    }

  ///滚动方法
  _onScroll(offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha > 1 && _appBarAlpha == 1) return;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      _appBarAlpha = alpha;
    });
  }
  ///消息按钮点击事件
  _searchBtnOnPressed(BuildContext context){
    print('search');
    Application.router.navigateTo(context, Routes.search,transition:TransitionType.native);
  }
  ///搜索点击事件
  _jumpToIndexView(BuildContext context){
    print('go IndexView');
  }
  ///跳转商品详情页
  _jumpToGoodDetailPage(BuildContext context,String id){
    print('_jumpToGoodDetailPage id = $id');
    Application.router.navigateTo(context, '${Routes.goodDetail}?id=$id',transition: TransitionType.native);
  }
  //刷新数据
  refreshGoodsList() async {
//    //显示加载动画
//    showDialog<Null>(
//        context: context, //BuildContext对象
//        barrierDismissible: false,
//        builder: (BuildContext context) {
//          return new LoadingDialog( //调用对话框
//            text: '加载中...',
//          );
//        });
    //简单计时器
    await refreshHomeArticlesData();

//    //退出加载动画
//    Navigator.pop(context); //关闭对话框


  }

  Future refreshHomeArticlesData() async {

    UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
      if(onValue == '1'){
        UserInfoCache().getUserInfo().then((onV){
          setState(() {
            _imgUrl = onV['headImgUrl']??'';
          });
        });
      }
      setState(() {
        _isLogin = onValue == '1'? true : false;
      });
    });
    //获取轮播图数据  列表编号。1
    var imagesData = await ApiConfig().wheelImage(listId:'1');
    if(imagesData.isNotEmpty && int.parse(imagesData['rspCode']) < 1000){
      _imagesList = [];
      _imagesList.addAll(imagesData['list']);
      _swiperController.startAutoplay();
    }
//    else return;

    //获取全部商品定制列表  列表编号。1首页流行单品，2首页最新卖价，3首页最新买价。可扩展。
    var goodsData = await ApiConfig().firstGoods(listId:'1');
    if(goodsData.isNotEmpty && int.parse(goodsData['rspCode']) < 1000){
      _goodsData = goodsData;
      var priceData = await getPrices(_goodsData['list']??[]);
      _goodsPriceData = priceData;
    }
    else return;

    var goodsNewSellData = await ApiConfig().firstGoods(listId:'2');
    if(goodsNewSellData.isNotEmpty && int.parse(goodsNewSellData['rspCode']) < 1000){
      _goodsNewSellData = goodsNewSellData;
      var priceData = await getPrices(_goodsNewSellData['list']??[]);
      _goodsNewSellPriceData = priceData;
    }
    else return;

    var goodsNewBuyData = await ApiConfig().firstGoods(listId:'3');
    if(goodsNewBuyData.isNotEmpty && int.parse(goodsNewBuyData['rspCode']) < 1000){
      _goodsNewBuyData = goodsNewBuyData;
      var priceData = await getPrices(_goodsNewBuyData['list']??[]);
      _goodsNewBuyPriceData = priceData;
    }
    else return;

    //获取图文验证码  列表编号。1首页资讯、2首页视频、3首页评测。
    var messagesData = await ApiConfig().firstMessage(listId:'1');
    if(messagesData.isNotEmpty && int.parse(messagesData['rspCode']) < 1000){
      _articlesList = [];
      _articlesList.addAll(messagesData['list']);
    }
    else return;

    var videosData = await ApiConfig().firstMessage(listId:'2');
    if(videosData.isNotEmpty && int.parse(videosData['rspCode']) < 1000){
      _videosList = [];
      _videosList.addAll(videosData['list']);
    }
    else return;

    var evaluationsData = await ApiConfig().firstMessage(listId:'3');
    if(evaluationsData.isNotEmpty && int.parse(evaluationsData['rspCode']) < 1000){
      _evaluationsList = [];
      _evaluationsList.addAll(evaluationsData['list']);
    }
    else return;

    var newArticlesData = await ApiConfig().firstLink(listId:'1');
    if(newArticlesData.isNotEmpty && int.parse(newArticlesData['rspCode']) < 1000){
      _newArticlesList = [];
      _newArticlesList.addAll(newArticlesData['list']);
    }
    else return;

    var hotArticlesData = await ApiConfig().firstLink(listId:'2');
    if(hotArticlesData.isNotEmpty && int.parse(hotArticlesData['rspCode']) < 1000){
      _hotArticlesList = [];
      _hotArticlesList.addAll(hotArticlesData['list']);
    }
    else return;

    setState(() {});

  }

  Future getPrices(List goods) async {

    print('goods = $goods');
    List<Map<dynamic, dynamic>> items = [];
    if(goods.isNotEmpty){
      for(Map item in goods){
        items.add({
          'id':item['id']
        });
      }
      return await ApiConfig().goodsLowHeight(items)??{};
    }
  }

  refreshLoginStatus(){
      var bool = ModalRoute.of(context).isCurrent;
      if (bool) {

        Timer(Duration(milliseconds: 500),(){
          setState(() {});
        });

      }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    refreshLoginStatus();
  }

  @override
  void initState(){
    super.initState();
//    //详情数据
//    HttpUtil().get(AppConfig.cdnImageUrl+'ucenterApi/index').then((response){
//      setState(() {
//        debugPrint(response.toString());
////            print('_detailImage = $_detailImage');
//      });
//    });

    // 对 scrollController 进行监听
    _controller.addListener(() {
      // _scrollController.position.pixels 获取当前滚动部件滚动的距离
      // window.physicalSize.height 获取屏幕高度
      // 当滚动距离大于 800 后，显示回到顶部按钮
      _onScroll(_controller.position.pixels);
      if(_showBackTop != _controller.position.pixels >= 200)setState(() => _showBackTop = _controller.position.pixels >= 200);
    });

    refreshHomeArticlesData();

    WidgetsBinding  widgetsBinding=WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback){
      // print("addPostFrameCallback be invoke");
      //  _getNewVersionAPP();
    });
    ///极光推送
    initPlatformState();
    // 页面统计事件，在initState方法中调用onPageStart
    jana.onPageStart(widget.runtimeType.toString());
  }
//执行版本更新的网络请求
  _getNewVersionAPP() async {
    ApiConfig().appVersion().then((response) {
      if (response != null) {
          _checkVersionCode(response["state"].toString(),response["upgradeInfo"]);
          if(response["state"] == '2'){
            _donwLoadUrl = response["url"];
          }
      }
    });
  }
 
  //检查版本更新的版本号
  _checkVersionCode(String va,String upgradeInfo) async {
    if (va == '1') {
      _showNewVersionAppDialog(va,upgradeInfo);
    }else if(va == '2'){
      _showNewVersionAppDialog(va,upgradeInfo);
    }
  }
 
 //弹出"版本更新"对话框
  _showNewVersionAppDialog(String va,String upgradeInfo) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Row(
              children: <Widget>[
                new Center(
                    child: new Text('快传',))
              ],
            ),
            content: Text(upgradeInfo),
            actions: <Widget>[
              va=='1'? FlatButton(
                child: new Text('下次再说'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ):Container(),
              new FlatButton(
                child: new Text('下载',),
                onPressed: () {
                  _launch();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
 
  _launch() async{
    if (Platform.isIOS) {
          final url = "https://itunes.apple.com/cn/app/id1477331941"; // id 后面的数字换成自己的应用 id 就行了
          if (await canLaunch(url)) {
            await launch(url, forceSafariVC: false);
          } else {
            throw 'Could not launch $url';
          }
      }else{
        checkPermission();
      }
  }
  // 获取安装地址
Future<String> get _apkLocalPath async {
  final directory = await getExternalStorageDirectory();
  return directory.path;
}
  // 下载
Future<void> executeDownload() async {
  final path = await _apkLocalPath;
  //下载
  final taskId = await FlutterDownloader.enqueue(
      url: _donwLoadUrl + '/app-release.apk',
      savedDir: path,
      showNotification: true,
      openFileFromNotification: true);
      FlutterDownloader.registerCallback((id, status, progress) {
    // 当下载完成时，调用安装
    if (taskId == id && status == DownloadTaskStatus.complete) {
      _installApk();
    }
  });
}
// 安装
Future<Null> _installApk() async {
  // 项目名
  const platform = const MethodChannel('快传');
  try {
    final path = await _apkLocalPath;
    // 调用app地址
    await platform.invokeMethod('install', {'path': path + '/app-release.apk'});
  } on PlatformException catch (_) {}
}

  Future checkPermission() async {

  // 申请权限

  Map<PermissionGroup, PermissionStatus> permissions =

      await PermissionHandler().requestPermissions([PermissionGroup.storage]);

  // 申请结果

  PermissionStatus permission =

      await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

  if (permission == PermissionStatus.granted) {

    Fluttertoast.showToast(msg: "权限申请通过");
    executeDownload();
  } else {
    Fluttertoast.showToast(msg: "权限申请被拒绝");
    Fluttertoast.showToast(
                msg: '获取权限失败,请到商店完成更新',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 2,
                backgroundColor: AppStyle.colorGreyDark,
                textColor: Colors.white,
                fontSize: 16.0
            );
  }

}
  
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _swiperController.stopAutoplay();
    _swiperController.dispose();
    // 页面统计事件，在需要统计页面的dispose方法里调用onPageEnd
    String a = widget.runtimeType.toString();
    jana.onPageEnd(widget.runtimeType.toString());
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
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

    //假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334),设置字体大小根据系统的“字体大小”辅助选项来进行缩放,默认为false
    //默认设计稿为6p7p8p尺寸 width : 1080px , height:1920px , allowFontScaling:false
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

    return Scaffold(
      drawer: SmartDrawer(callback: (isOpen){
      if(!isOpen){
        closeDrow();
        refreshHomeArticlesData();
      }else{
        openDrow();
      }
      },),
      drawerScrimColor: Colors.transparent,
      key: _scaffoldkey,
          body: _goodsData.length == 0
          ? LoadingDialog(
              //调用对话框
              text: '正在加载...',
            )
          : Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: EasyRefresh(
                    key: _easyRefreshKey,
                    behavior: ScrollOverBehavior(),
                    refreshHeader: ClassicsHeader(
                      key: _headerKey,
                      showMore: true,
                      refreshingText: '正在刷新...',
                      refreshText: '下拉刷新',
                      refreshReadyText: '释放刷新',
                      refreshedText: '刷新完成',
                      moreInfo: "上次更新于 %T",
//                                    moreInfo: "更新于",
                      bgColor: Colors.transparent,
                      textColor: Colors.black87,
                      moreInfoColor: Colors.black54,
                      //showMore: false,
                    ),
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    controller: _controller,
                    children: <Widget>[
                      headerView(context:context,imagesList: _imagesList),
                      titleButtonsView(context),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left:ScreenUtil.getInstance().setWidth(16.0),
                          right:ScreenUtil.getInstance().setWidth(16.0),
                        ),
                        child: Column(
                          children: <Widget>[
                            goodsGridView(goods: _goodsData,prices:_goodsPriceData),
                            goodsGridView(goods: _goodsNewBuyData,prices:_goodsNewBuyPriceData),
                            goodsGridView(goods: _goodsNewSellData,prices:_goodsNewSellPriceData),
                          ],
                        ),
                      ),
                      listViewTitle(
                          context: context,
                          title: '资讯视频',
                          titleColor: AppStyle.colorGreyText,
                          onTap: (){
                            print('资讯视频');
                            Application.router.navigateTo(context, '${Routes.informationAll}?index=2',transition:TransitionType.native);
                          }
                      ),
                      videoListView(context,_videosList),
                      Container(
                        padding: EdgeInsets.only(
                          top: 0.5,
                          bottom:ScreenUtil.getInstance().setWidth(16.0),
  //                        right:ScreenUtil.getInstance().setWidth(16.0),
                        ),
                        width: double.infinity,
                        color: Color(0xFF646464),
                        child: Column(
                          children: <Widget>[
                            listViewTitle(
                                context: context,
                                title: '评比测试',
                                titleColor: AppStyle.colorWhite,
                                onTap: (){
                                  print('评比测试');
                                  Application.router.navigateTo(context, '${Routes.informationAll}?index=1',transition:TransitionType.native);
                                }
                            ),
                            comparisonList(comparisons: _evaluationsList),
                          ],
                        ),
                      ),
                      bottomView(context:context,newList: _newArticlesList,hotList: _hotArticlesList),
                      // Container(
                      //   color: AppStyle.colorGreyDark,
                      //   alignment: Alignment.center,
                      //   child: Text('copyright©2019',style: TextStyle(color: Colors.white,)),
                      // ),
                      // Container(
                      //   padding: EdgeInsets.only(bottom: 30),
                      //   color: AppStyle.colorGreyDark,
                      //   alignment: Alignment.center,
                      //   child: Text('快传电子商务 版权所有',style: TextStyle(color: Colors.white,)),
                      // ),
                    ],
                  ),
                  onRefresh: () async {
                    await refreshGoodsList();
                  },
                ),
              ),
              Opacity(
                opacity: _appBarAlpha,
                child: barView(context,Theme.of(context).primaryColor,_isLogin),
              ),
              Positioned(
                bottom: 40.0,
                right: 20.0,
                child: CustomFloatingButton(
                  isHidden: !_showBackTop,
                  icon: AppIcon.top,
                  size: 30.0,
                  backgroundColor: AppStyle.colorLight,
                  iconColor: AppStyle.colorPink,
                  onPressed: () {
                    // scrollController 通过 animateTo 方法滚动到某个具体高度
                    // duration 表示动画的时长，curve 表示动画的运行方式，flutter 在 Curves 提供了许多方式
                    _controller.animateTo(
                        0.0, duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate);
                  },
                ),
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
              print('jump to good detail   ${articles[index]['id']}');
              if(articles[index]['type'] == 1){
                Application.router.navigateTo(context, '${Routes.goodDetail}?id=${articles[index]['id']}',transition: TransitionType.native);
              }else{
                Application.router.navigateTo(context, '${Routes.informationDetail}?id=${articles[index]['id']}',transition: TransitionType.native);
              }
            },
            child:Container(
              margin: EdgeInsets.only(top: ScreenUtil.getInstance().setWidth(24.0)),
              child: Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil.getInstance().setWidth(76.0),),
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
              SizedBox(width: ScreenUtil.getInstance().setWidth(68.0),),
              Text(
                '新品发布',
                style: TextStyle(
                  color: AppStyle.colorGreyText,
                  fontSize: ScreenUtil.getInstance().setSp(36.0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          articlesList(articles: newList),
          SizedBox(height: ScreenUtil.getInstance().setWidth(81.0),),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setWidth(60.0),),
              Text(
                '热门推荐',
                style: TextStyle(
                  color: AppStyle.colorGreyText,
                  fontSize: ScreenUtil.getInstance().setSp(36.0),
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

  Container videoListView(BuildContext context,List videosData) {
    if(videosData.isEmpty)return noDataContainer(text: '暂无数据',textColor: AppStyle.colorGreyText);
    return Container(
//      padding: EdgeInsets.only(
//        left:ScreenUtil.getInstance().setWidth(16.0),
//        right:ScreenUtil.getInstance().setWidth(16.0),
//      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: ScreenUtil.getInstance().setWidth(240.0),
              ),
              Container(
                width: double.infinity,
                height: ScreenUtil.getInstance().setWidth(991.0),
                color: Color(0xFF646464),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(
                    left:ScreenUtil.getInstance().setWidth(16.0),
                    right:ScreenUtil.getInstance().setWidth(16.0),
                  ),
                  width: double.infinity,
                  height: ScreenUtil.getInstance().setWidth(900.0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: videosData[0]['imgUrl']??'',
                          placeholder: (context, url) => new ProgressView(),
                          errorWidget: (context, url, error) => new Icon(AppIcon.warn_light),
                          fit: BoxFit.cover,
                        ),
//                      Image(image: AssetImage(AssetUtil.image('video@3x.png')),fit: BoxFit.cover,),
                      ),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil.getInstance().setWidth(180.0),
                        color: Colors.black.withOpacity(0.39),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text: videosData[0]['title'],
                                        style: TextStyle(
                                          color: AppStyle.colorWhite,
                                          fontSize: ScreenUtil.getInstance().setSp(28.0),
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        children: []),
                                  ),
                                  Text(
                                    videosData[0]['date'],
                                    style: TextStyle(
                                        fontSize: ScreenUtil.getInstance().setSp(24.0),
                                        color: AppStyle.colorGreyText
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(64.0),),
                            Icon(
                              Icons.play_circle_outline,
                              size: ScreenUtil.getInstance().setWidth(60.0),
                              color: AppStyle.colorWhite,
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: (){
                  Application.router.navigateTo(context, '${Routes.informationDetail}?id=${videosData[0]['id']}',transition:TransitionType.native);
                },
              ),
              Container(
                padding: EdgeInsets.only(
                  left:ScreenUtil.getInstance().setWidth(16.0),
                  right:ScreenUtil.getInstance().setWidth(16.0),
                ),
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Stack(
                          alignment: Alignment(0.9, 0.9),
                          children: <Widget>[
                            Container(
                              child: CachedNetworkImage(
                                imageUrl: videosData[1]['imgUrl']??'',
                                placeholder: (context, url) => new ProgressView(),
                                errorWidget: (context, url, error) => new Icon(AppIcon.warn_light),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Icon(
                              Icons.play_circle_outline,
                              size: ScreenUtil.getInstance().setWidth(60.0),
                              color: AppStyle.colorWhite,
                            ),
                          ],
                        ),
                        onTap: (){
                          Application.router.navigateTo(context, '${Routes.informationDetail}?id=${videosData[1]['id']}',transition:TransitionType.native);
                        },
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Stack(
                          alignment: Alignment(0.9, 0.9),
                          children: <Widget>[
                            Container(
                              child: CachedNetworkImage(
                                imageUrl: videosData[2]['imgUrl']??'',
                                placeholder: (context, url) => new ProgressView(),
                                errorWidget: (context, url, error) => new Icon(AppIcon.warn_light),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Icon(
                              Icons.play_circle_outline,
                              size: ScreenUtil.getInstance().setWidth(60.0),
                              color: AppStyle.colorWhite,
                            ),
                          ],
                        ),
                        onTap: (){
                          Application.router.navigateTo(context, '${Routes.informationDetail}?id=${videosData[2]['id']}',transition:TransitionType.native);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget titleButtonsView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top:ScreenUtil.getInstance().setWidth(18.0),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
          Expanded(
            child: InkWell(
              onTap: (){
                print('我想买');
                Application.router.navigateTo(context, '${Routes.buyTips}?id=0&type=1',transition: TransitionType.native);
              },
              child: Container(
                height: ScreenUtil.getInstance().setWidth(90.0),
                width: ScreenUtil.getInstance().setWidth(320.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(16.0))),
                  color: AppStyle.colorPink,
                ),
                child: Center(
                  child: Text(
                    '我想买',
                    style: TextStyle(
                      color: AppStyle.colorWhite,
                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
          Expanded(
            child: InkWell(
              onTap: (){
                print('我想卖');
                Application.router.navigateTo(context, '${Routes.sellTips}?id=0&type=1',transition: TransitionType.native);
              },
              child: Container(
                height: ScreenUtil.getInstance().setWidth(90.0),
                width: ScreenUtil.getInstance().setWidth(320.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(16.0))),
                  color: AppStyle.colorSuccess,
                ),
                child: Center(
                  child: Text(
                    '我想卖',
                    style: TextStyle(
                      color: AppStyle.colorWhite,
                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
        ],
      ),
    );
  }

  Widget barView(BuildContext context,Color backgroundColor,bool isLogin){
    return Container(
        height: MediaQueryData.fromWindow(window).padding.top + 56.0,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    child: Container(
                      height: ScreenUtil.getInstance().setWidth(64.0),
                      width: ScreenUtil.getInstance().setWidth(100.0),
                      decoration: BoxDecoration(
//                            color: Colors.red
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: 20,
                        width: 20,
                        child: Image(image: AssetImage(AssetUtil.image(claseIcon)),fit: BoxFit.fitWidth,),
                      ),
                    ),
                    onTap : () {
                      _scaffoldkey.currentState.openDrawer();
                    }
                ),
                Expanded(child: SizedBox(height: 1,)),
                GestureDetector(
                  onTap: () => _jumpToIndexView(context),
                  child: Container(
                    height: 37,
                    decoration: BoxDecoration(
//                            color: Colors.red
                    ),
                    alignment: Alignment.center,
                    child: Image(image: AssetImage(AssetUtil.image('logo-bl copy@3x.png')),fit: BoxFit.fitHeight,),
                  ),
                ),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      height: ScreenUtil.getInstance().setWidth(64.0),
                      child: isLogin ? ClipOval(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: CachedNetworkImage(
                            imageUrl: _imgUrl,
                            placeholder: (context, url) => new CircularProgressIndicator(strokeWidth: 1.0,),
                            errorWidget: (context, url, error) => new Icon(AppIcon.warn_light),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ) : Container(),
                    )
                ),
                GestureDetector(
                    child: Container(
                      height: ScreenUtil.getInstance().setWidth(64.0),
                      width: ScreenUtil.getInstance().setWidth(100.0),
                      decoration: BoxDecoration(
//                            color: Colors.red
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: 20,
                        width: 20,
                        child: Image(image: AssetImage(AssetUtil.image('search@3x.png')),fit: BoxFit.fitWidth,),
                      ),
                    ),
                    onTap : () => _searchBtnOnPressed(context),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget goodsGridView({Map goods,prices}){
      print('prices = $prices');
    List goodsList = goods['list']??[];
    List pricesList = prices['rspList']??[];
    if(goodsList.isEmpty)return noDataContainer(text: '暂无商品数据',textColor: AppStyle.colorPrimary,leftPadding: 16.0);
    Widget _gridViewBuilder(BuildContext context,int index){
      String buyString = pricesList[index]['buyingPrice']??'--';
      String sellString = pricesList[index]['sellingPrice']??'--';
//      String buyPrice = '¥${int.parse(buyString.replaceRange(0,1, '0'))/100}';
//      String sellPrice = '¥${int.parse(sellString.replaceRange(0,1, '0'))/100}';
      String buyPrice = buyString;
      String sellPrice = sellString;
      return Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
//                Expanded(
////                  flex: 3,
////                  child: Container(
////                    width: double.infinity,
////                    child: Center(
////                      child: CachedNetworkImage(
////                        imageUrl: goodsList[index]['imgUrl'],
////                        placeholder: (context, url) => new ProgressView(),
////                        errorWidget: (context, url, error) => new Icon(Icons.warning),
////                        fit: BoxFit.fitWidth,
////                      ),
////                    ),
////                  ),
////                ),
                Container(
                  width: ScreenUtil.getInstance().setWidth(340.0),
                  height: ScreenUtil.getInstance().setWidth(340.0),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: goodsList[index]['imgUrl'],
                      placeholder: (context, url) => new ProgressView(),
                      errorWidget: (context, url, error) => new Icon(Icons.warning),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                Container(
                  width: ScreenUtil.getInstance().setWidth(340.0),
                  height: ScreenUtil.getInstance().setWidth(280.0),
                  color: AppStyle.colorWhite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
                      Row(
                        children: <Widget>[
                          SizedBox(width: ScreenUtil.getInstance().setWidth(26.0),),
                          Expanded(
                              child: Container(
                                height: ScreenUtil.getInstance().setHeight(70.0),
                                child: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                      text: '${goodsList[index]['title']}',
                                      style: TextStyle(
                                        color: Color(0xFF4A4A4A),
                                        fontSize: ScreenUtil.getInstance().setSp(24.0),
                                        fontStyle: FontStyle.normal,
                                      ),
                                      children: []),
                                ),
                              )
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(72.0),),
                        ],
                      ),
                      SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: ScreenUtil.getInstance().setWidth(24.0),),
                          Container(
                            height: ScreenUtil.getInstance().setWidth(67.0),
                            width: ScreenUtil.getInstance().setWidth(4.4),
                            color: AppStyle.colorSuccess,
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                          Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    '最低卖价',
                                    style: TextStyle(
                                      color: AppStyle.colorSuccess,
                                      fontSize: ScreenUtil.getInstance().setSp(24.0),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                  Text(
                                    pricesList.isEmpty?'暂无':sellPrice??'',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: ScreenUtil.getInstance().setSp(30.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                          Container(
                            height: ScreenUtil.getInstance().setWidth(67.0),
                            width: ScreenUtil.getInstance().setWidth(4.4),
                            color: AppStyle.colorPink,
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                          Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    '最高买价',
                                    style: TextStyle(
                                      color: AppStyle.colorPink,
                                      fontSize: ScreenUtil.getInstance().setSp(24.0),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                  Text(
                                    pricesList.isEmpty?'暂无':buyPrice??'',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: ScreenUtil.getInstance().setSp(30.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                onTap: () {
                  print('jump to gifts detail view. ${goodsList[index]['title']}');
                  _jumpToGoodDetailPage(context,goodsList[index]['id']);
                },
              ),
            ),
          )
        ],
      );
    }
    return Column(
      children: <Widget>[
        SizedBox(height: ScreenUtil.getInstance().setWidth(90),),
        gridViewTitle(
            context: context,
            title: goods['listName'],
            titleColor: Color(0xFF4A4A4A),
            lineColor: AppStyle.colorGreyLine,
            onTap: (){
              print('${goods['listName']}');
              Application.router.navigateTo(context, Routes.sportsShoesPage,transition:TransitionType.native);
            }
        ),
        GridView.builder(
            shrinkWrap: true, //解决无限高度问题
            physics:NeverScrollableScrollPhysics(),//禁用滑动事件
            itemCount: goodsList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //横轴元素个数
              crossAxisCount: 2,
              //纵轴间距
              mainAxisSpacing: 4.0,
              //横轴间距
              crossAxisSpacing: 4.0,
              //子组件宽高长度比例
              childAspectRatio: 2.6/5,
            ),
            itemBuilder: _gridViewBuilder
        )
      ],
    );
  }

  Widget gridViewTitle({BuildContext context,String title,Function onTap,Color titleColor,Color lineColor}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: ScreenUtil.getInstance().setSp(32.0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(child: SizedBox(height: 1,)),
                Container(
                  width: ScreenUtil.getInstance().setWidth(60.0),
                  child: Image(image: AssetImage(AssetUtil.image('arrows@3x.png')),fit: BoxFit.fitWidth,),
                ),
                SizedBox(width: ScreenUtil.getInstance().setWidth(30.0),),
              ],
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(10.0),),
            Container(height: 1,width: ScreenUtil.getInstance().setWidth(716.0),color: lineColor,),
          ],
        ),
      ),
    );
  }

  Widget headerView({BuildContext context,List imagesList}) {
    if(imagesList.isEmpty)return barView(context,AppStyle.colorPrimary,_isLogin);
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: ScreenUtil.getInstance().setWidth(930),
          child:Image(image: AssetImage(AssetUtil.image('bj@3x.png')),fit: BoxFit.fitWidth,),
        ),
        barView(context,AppStyle.colorPrimary,_isLogin),
        Container(
          padding: EdgeInsets.fromLTRB(
              ScreenUtil.getInstance().setWidth(30),
              ScreenUtil.getInstance().setWidth(40),
              ScreenUtil.getInstance().setWidth(30),
              0
          ),
          width: double.infinity,
          height: ScreenUtil.getInstance().setWidth(930),
          child: Column(
            children: <Widget>[
              Expanded(flex:3,child: SizedBox(width: 1,)),
              Container(
                width: ScreenUtil.getInstance().setWidth(76.0),
                child: Image(image: AssetImage(AssetUtil.image('icon1@3x.png')),fit: BoxFit.fitWidth,),
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
              Text(
                '100%',
                style: TextStyle(
                  color: AppStyle.colorWhite,
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '全新正品运动鞋',
                style: TextStyle(
                  color: AppStyle.colorWhite,
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
              Container(
                width: ScreenUtil.getInstance().setWidth(76.0),
                child: Image(image: AssetImage(AssetUtil.image('icon2@3x.png')),fit: BoxFit.fitWidth,),
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
              Text(
                '平台官方鉴别真伪',
                style: TextStyle(
                  color: AppStyle.colorWhite,
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
              Container(
                width: ScreenUtil.getInstance().setWidth(76.0),
                child: Image(image: AssetImage(AssetUtil.image('icon3@3x.png')),fit: BoxFit.fitWidth,),
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
              Text(
                '买家卖家双向保障',
                style: TextStyle(
                  color: AppStyle.colorWhite,
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Expanded(flex:2,child: SizedBox(width: 1,)),
            ],
          ),
        ),
      ],
    );
//    return Stack(
//      alignment: Alignment.topCenter,
//      children: <Widget>[
//        Container(
////          padding: EdgeInsets.fromLTRB(
////              ScreenUtil.getInstance().setWidth(30),
////              ScreenUtil.getInstance().setWidth(40),
////              ScreenUtil.getInstance().setWidth(30),
////              0
////          ),
//          width: double.infinity,
//          height: ScreenUtil.getInstance().setWidth(930),
////          decoration: BoxDecoration(
//////              color: Colors.red,
////              image: DecorationImage(
////                image: AssetImage(AssetUtil.image('bj@3x.png')),
//////                image: AssetImage(AssetUtil.image('personalbg.png')),
////                fit: BoxFit.fitWidth,
////                alignment: Alignment.topLeft,
////              )
////          ),
//          child:Swiper(
//            itemBuilder: (BuildContext context,int index){
//              return GestureDetector(
//                onTap: (){
//                  print('type = ${imagesList[index]['type']},id = ${imagesList[index]['id']}');
//                  if(imagesList[index]['type']=='1'){
//                    Application.router.navigateTo(context, '${Routes.goodDetail}?id=${imagesList[index]['id']}',transition: TransitionType.native);
//                  }else{
//                    Application.router.navigateTo(context, '${Routes.informationDetail}?id=${imagesList[index]['id']}',transition:TransitionType.native);
//                  }
//                },
//                child: Image.network(imagesList[index]['imgUrl'],fit: BoxFit.cover,),
//              );
//            },
//            itemCount: imagesList.length,
//            pagination: new SwiperPagination(),
//            controller: _swiperController,
//            autoplayDelay: 5000,
//            autoplayDisableOnInteraction: true,
//          ),
//        ),
//        barView(context,AppStyle.colorPrimary.withOpacity(0.8),_isLogin),
////        Container(
////          padding: EdgeInsets.fromLTRB(
////              ScreenUtil.getInstance().setWidth(30),
////              ScreenUtil.getInstance().setWidth(40),
////              ScreenUtil.getInstance().setWidth(30),
////              0
////          ),
////          width: double.infinity,
////          height: ScreenUtil.getInstance().setWidth(930),
////          child: Column(
////            children: <Widget>[
////              Expanded(flex:4,child: SizedBox(width: 1,)),
////              Container(
////                width: ScreenUtil.getInstance().setWidth(70.0),
////                child: Image(image: AssetImage(AssetUtil.image('icon1@3x.png')),fit: BoxFit.fitWidth,),
////              ),
////              SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
////              Text(
////                '100%',
////                style: TextStyle(
////                  color: AppStyle.colorWhite,
////                  fontSize: ScreenUtil.getInstance().setSp(48.0),
////                  fontWeight: FontWeight.w600,
////                ),
////              ),
////              Text(
////                '全新正品运动鞋',
////                style: TextStyle(
////                  color: AppStyle.colorWhite,
////                  fontSize: ScreenUtil.getInstance().setSp(36.0),
////                  fontWeight: FontWeight.w600,
////                ),
////              ),
////              Expanded(flex:1,child: SizedBox(width: 1,)),
////              Container(
////                width: ScreenUtil.getInstance().setWidth(70.0),
////                child: Image(image: AssetImage(AssetUtil.image('icon2@3x.png')),fit: BoxFit.fitWidth,),
////              ),
////              SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
////              Text(
////                '平台官方鉴别真伪',
////                style: TextStyle(
////                  color: AppStyle.colorWhite,
////                  fontSize: ScreenUtil.getInstance().setSp(36.0),
////                  fontWeight: FontWeight.w600,
////                ),
////              ),
////              Expanded(flex:1,child: SizedBox(width: 1,)),
////              Container(
////                width: ScreenUtil.getInstance().setWidth(70.0),
////                child: Image(image: AssetImage(AssetUtil.image('icon3@3x.png')),fit: BoxFit.fitWidth,),
////              ),
////              SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
////              Text(
////                '买家卖家双向保障',
////                style: TextStyle(
////                  color: AppStyle.colorWhite,
////                  fontSize: ScreenUtil.getInstance().setSp(32.0),
////                  fontWeight: FontWeight.w600,
////                ),
////              ),
////              Expanded(flex:3,child: SizedBox(width: 1,)),
////            ],
////          ),
////        ),
//      ],
//    );
  }

  Widget listViewTitle({BuildContext context,String title,Function onTap,Color titleColor}) {
    return InkWell(
      onTap:onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
        ),
        height: ScreenUtil.getInstance().setWidth(110.0),
        child: Column(
          children: <Widget>[
            SizedBox(height:ScreenUtil.getInstance().setWidth(32.0) ,),
            Row(
              children: <Widget>[
                SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: ScreenUtil.getInstance().setSp(32.0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(child: SizedBox(height: 1,)),
                Container(
                  width: ScreenUtil.getInstance().setWidth(60.0),
                  child: Image(image: AssetImage(AssetUtil.image('arrows@3x.png')),fit: BoxFit.fitWidth,),
                ),
                SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget comparisonList({List comparisons}){

    Widget _listViewBuilder(BuildContext context,int index){
      return InkWell(
        onTap: (){
          print('jump to article detail   ${comparisons[index]['id']}');
          Application.router.navigateTo(context, '${Routes.informationDetail}?id=${comparisons[index]['id']}',transition:TransitionType.native);
        },
        child:Container(
          margin: EdgeInsets.only(
            left: ScreenUtil.getInstance().setWidth(16.0),
            right: ScreenUtil.getInstance().setWidth(16.0),
            bottom: ScreenUtil.getInstance().setWidth(16.0),
          ),
          width: double.infinity,
          height: ScreenUtil.getInstance().setWidth(192.0),
          decoration: BoxDecoration(
              image: DecorationImage(
                image:  NetworkImage(comparisons[index]['imgUrl']??''),
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
              ),
            border: Border.all(
              color: AppStyle.colorWhite,
              width: 0.5,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(child: SizedBox(width: 1,),),
              Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                  Icon(Icons.brightness_1,size: ScreenUtil.getInstance().setWidth(12.0),color: AppStyle.colorWhite,),
                  SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                  Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: comparisons[index]['title'],
                            style: TextStyle(
                              color: AppStyle.colorWhite,
                              fontSize: ScreenUtil.getInstance().setSp(28.0),
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                            ),
                            children: []),
                      ),
                  ),
                  SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                ],
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
              Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          text: comparisons[index]['date'],
                          style: TextStyle(
                            color: AppStyle.colorGreyText,
                            fontSize: ScreenUtil.getInstance().setSp(24.0),
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w200,
                          ),
                          children: []),
                    ),
                  ),
                  SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                ],
              ),
              Expanded(child: SizedBox(width: 1,),),
            ],
          ),
        ),
      );
    }
    if(comparisons.isEmpty)return noDataContainer(text: '暂无数据',textColor: Colors.white);
    return ListView.builder(
        shrinkWrap: true, //解决无限高度问题
        physics:NeverScrollableScrollPhysics(),//禁用滑动事件
        itemCount: comparisons.length,
        itemBuilder: _listViewBuilder
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

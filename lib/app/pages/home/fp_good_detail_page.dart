import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
//import 'package:sharesdk/sharesdk.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/dropdownMenu/dropdown_menu.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:janalytics/janalytics.dart';
import 'package:fast_pass/app/widgets/dash_line.dart';

class FPGoodDetailPage extends StatefulWidget {
  final String goodID;
  FPGoodDetailPage({@required this.goodID});
  @override
  _FPGoodDetailPageState createState() => _FPGoodDetailPageState();
}

class _FPGoodDetailPageState extends State<FPGoodDetailPage> {

  ///商品信息
  List _sizeList = [];
  ///商品购买记录展示信息
  List _buyRecordsList = [];
  ///商品销售记录展示信息
  List _sellRecordsList = [];
  ///商品交易记录展示信息
  List _tradeRecordsList = [];
  ///商品信息
  List _goods = [];
  ///尺码标准。1 US美码，2 UK英码，3 EUR欧码，4 JP毫米
  List _sizeTypeList = [
    {
      'value':'1',
      'title':'US美码',
    },
    {
      'value':'2',
      'title':'UK英码',
    },
    {
      'value':'3',
      'title':'EUR欧码',
    },
    {
      'value':'4',
      'title':'JP毫米',
    },
  ];
  bool _isShowSizeType = true;
  ///商品价格信息
  List _goodsprices = [];
  Map _goodDetailInfo= {};
  String _selectSize = '全部';
  String _sizeId = '';

  String _newHighestBuyPrice = '';
  String _newLowestSellPrice = '';
  String _newTradePrice = '暂无';

  double _appBarAlpha = 1;
  String _sizeValue = '3';
  ///新品发布
  List _newArticlesList = [];
  ///热门推荐
  List _hotArticlesList = [];

  ScrollController _scrollController = ScrollController();

  bool _isLogin = false;//是否登录
  bool _showBackTop = false;//是否显示到顶部按钮
  String imgUrl = '';
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  SwiperController _swiperController = SwiperController();

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();

  GlobalKey _stackKey = GlobalKey();
  GlobalKey _selectSizeKey = GlobalKey();
  GlobalKey _buyListKey = GlobalKey();
  GlobalKey _sellListKey = GlobalKey();
  GlobalKey _buyRecordKey = GlobalKey();
  GZXDropdownMenuController _selectSizeDropdownMenuSelectController = GZXDropdownMenuController();
  GZXDropdownMenuController _buyListDropdownMenuSelectController = GZXDropdownMenuController();
  GZXDropdownMenuController _sellListDropdownMenuSelectController = GZXDropdownMenuController();
  GZXDropdownMenuController _buyRecordsDropdownMenuSelectController = GZXDropdownMenuController();

  int _buyIndex = 1,_soldIndex = 1;
  final Janalytics janalytics = new Janalytics();
  _onTapSelectSizeGridViewItem(BuildContext context,int index){

  }

  shareGood(BuildContext context,{String title,image}){

    showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
                title:Row(
                  children: <Widget>[
                    Expanded(child: Container(
                      width: ScreenUtil.getInstance().setWidth(80.0),
                      height: 5,
                     child: MySeparator(color: AppStyle.colorGreyLine,height: 2,),),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20.0),),
                    Text(
                      '分享到',
                      style: TextStyle(
                        color: AppStyle.colorDark,
                        fontSize: ScreenUtil.getInstance().setSp(36.0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20.0),),
                    Expanded(child: Container(
                      width: ScreenUtil.getInstance().setWidth(80.0),
                      height: 5,
                      child: MySeparator(color: AppStyle.colorGreyLine,height: 2,),),
                    ),
                  ],
                ),
                content: Container(
                  height: ScreenUtil.getInstance().setWidth(320.0),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Expanded(child: SizedBox(width: 1,)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _share(title: title,image: image,url:'www.baidu.com',type:0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ClipOval(
                                    child: Image(image: AssetImage(AssetUtil.image('wechat.png')),fit: BoxFit.fitWidth,),
                                  ),
                                  SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                  Text(
                                    '微信好友',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(60.0),),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _share(title: title,image: image,url:'www.baidu.com',type:1),
                              child: Column(
                                children: <Widget>[
                                  ClipOval(
                                    child: Image(image: AssetImage(AssetUtil.image('friend.png')),fit: BoxFit.fitWidth,),
                                  ),
                                  SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                  Text(
                                    '朋友圈',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                        ],
                      ),
                      Expanded(child: SizedBox(width: 1,)),
                      Container(height: 1,width: double.infinity,color: AppStyle.colorGreyLine,),
                      Expanded(child: SizedBox(width: 1,)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text(
                            '取消',
                            style: TextStyle(
                              color: AppStyle.colorDark,
                              fontSize: ScreenUtil.getInstance().setSp(28.0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ),
            )
    );
//    userWeChatShare(context,title: goodInfo['title'],image: _goodDetailInfo['titleImgUrl'],type:0);
  }

  //初始化sharasdk
  //这里只添加微信分享功能来进行测试
  //请先在微信开放平台中申请微信分享权限 并使用生成的AppID和AppSecret。
//  initShareSDK() {
//      ShareSDKRegister register = ShareSDKRegister();
//      register.setupWechat(
//          "wxe5f5c4d986f28664", "583b01440c968caf7419c45f309c0d0b");
//      ShareSDK.regist(register);
//  }

  void _share({String title,image,url,int type}) {
    print('-----title = $title   -----image = $image   -----url = $url');
    var model = fluwx.WeChatShareWebPageModel(
        webPage: url,
        title: title,
        thumbnail: image,
        scene: type==0?fluwx.WeChatScene.SESSION:fluwx.WeChatScene.TIMELINE,
        transaction: "hh");
    fluwx.share(model);
  }

//  userWeChatShare(BuildContext context,{String title,text,image,int type}) {
//    SSDKMap params = SSDKMap()
//      ..setGeneral(
//          title,
//          text??'',
//          [],
//          image,
//          null,
//          null,
//          null,
//          null,
//          null,
//          SSDKContentTypes.image);
//
//    if(type == 0){
//      ShareSDK.share(ShareSDKPlatforms.wechatSession, params, (SSDKResponseState state, Map userdata, Map contentEntity, SSDKError error){
//        showAlert(state, error.rawData, context);
//      });
//    }else{
//      ShareSDK.share(ShareSDKPlatforms.wechatTimeline, params, (SSDKResponseState state, Map userdata, Map contentEntity, SSDKError error){
//        showAlert(state, error.rawData, context);
//      });
//    }
//  }
//
//  void showAlert(SSDKResponseState state, Map content, BuildContext context) {
//    String title = "失败";
//    switch (state) {
//      case SSDKResponseState.Success:
//        title = "成功";
//        break;
//      case SSDKResponseState.Fail:
//        title = "失败";
//        break;
//      case SSDKResponseState.Cancel:
//        title = "取消";
//        break;
//      default:
//        title = state.toString();
//        break;
//    }
//    showDialog(
//        context: context,
//        builder: (BuildContext context) =>
//          AlertDialog(
//              title: new Text(title),
//              content: new Text(content != null ? content.toString() : ""),
//              actions: <Widget>[
//                new FlatButton(
//                  child: new Text("OK"),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  },
//                )
//              ]
//          )
//    );
//  }

  //根据key和controller滚动到制定widget位置
  _animateToViewTop(GlobalKey key,ScrollController controller,Function whenCompleted){

    RenderBox box =key.currentContext.findRenderObject();
    Offset offset = box.localToGlobal(Offset.zero);

    double animateH = controller.offset
        + offset.dy
        - MediaQueryData.fromWindow(window).padding.top
        - 56.0;

    print('animateH = $animateH');
    controller
        .animateTo(animateH, duration:Duration(milliseconds:500), curve: Curves.decelerate)
        .whenComplete(whenCompleted);
  }

  ///扫描按钮点击事件
  _menuBtnOnPressed(BuildContext context){
    print('drawer');
    _scaffoldkey.currentState.openDrawer();
  }

  String getSizeTypeTitle(String value){
    if(value == null || value == '')return '';
    int index = int.parse(value) - 1;
    return _sizeTypeList[index]['title'];
  }

  //刷新数据
  Future refreshgoods() async {
//    //显示加载动画
//    showDialog<Null>(
//        context: context, //BuildContext对象
//        barrierDismissible: false,
//        builder: (BuildContext context) {
//          return new LoadingDialog( //调用对话框
//            text: '加载中...',
//          );
//        });

    var islog = await UserInfoCache().getInfo(key: UserInfoCache.loginStatus);
    setState(() {
    _isLogin = islog == '1'?true:false;
        });
    if(_isLogin){
      var onV = await  UserInfoCache().getUserInfo();
        imgUrl = onV['headImgUrl'];
        }
    var goodDetailData = await ApiConfig().goodsDetail(widget.goodID);
    if(goodDetailData.isNotEmpty && int.parse(goodDetailData['rspCode']) < 1000){
      _goodDetailInfo = goodDetailData;
      if(_goodDetailInfo['imgList'].isNotEmpty){
        _swiperController.startAutoplay();
      }
    }
    else return;

    var goodsData = await ApiConfig().recommend(widget.goodID);
    if(goodsData.isNotEmpty && int.parse(goodsData['rspCode']) < 1000){
      _goods = goodsData['list']??[];
      var priceData = await getPrices(_goods??[]);
      _goodsprices = priceData['rspList'];
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
    

    var sizeData = await ApiConfig().getSizeSellPriceList(comdiId:widget.goodID,sizeType: _sizeValue);

    if(sizeData.isNotEmpty && int.parse(sizeData['rspCode']) < 1000){
      _sizeList = [];
      _sizeList.addAll(sizeData['list']);
      _selectSize = '全部';
      _sizeId = '';
      await refreshPrices(goodId: widget.goodID,sizeId: _sizeId);
    }
    else return;
    if(mounted){
      setState(() {});
    }
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

  Future refreshPrices({String goodId,sizeId}) async {

    print('goodId = $goodId');
    var priceData = await ApiConfig().goodsLowHeight([{'id':goodId}])??{};
    if(priceData.isNotEmpty && int.parse(priceData['rspCode']) < 1000){
      List prices = priceData['rspList']??[];
      String buyString = prices[0]['buyingPrice'];
      String sellString = prices[0]['sellingPrice'];
      _newHighestBuyPrice = buyString;
      _newLowestSellPrice = sellString;
//      _newHighestBuyPrice = '¥${int.parse(buyString.replaceRange(0,1, '0'))/100}';
//      _newLowestSellPrice = '¥${int.parse(sellString.replaceRange(0,1, '0'))/100}';
    }
    else return;

    var tradeData = await ApiConfig().tradeTakeNotes(goodId,sizeId,'20','0')??{};
    if(tradeData.isNotEmpty && int.parse(tradeData['rspCode']) < 1000){
      List recordsList = tradeData['list']??[];
      print('recordsList = $recordsList');
      if(recordsList.isNotEmpty)_newTradePrice = recordsList[0]['price']??'';
//      _newTradePrice = '¥${int.parse(tradeString.replaceRange(0,1, '0'))/100}';
      _tradeRecordsList = [];
      _tradeRecordsList.addAll(tradeData['list']);
    }
    else return;

    setState(() {});
  }

  @override
  void initState(){
//    initShareSDK();
    super.initState();
//    //详情数据
//    HttpUtil().get(AppConfig.cdnImageUrl+'ucenterApi/index').then((response){
//      setState(() {
//        debugPrint(response.toString());
////            print('_detailImage = $_detailImage');
//      });
//    });
    //分享回调
    fluwx.responseFromShare.listen((response){
      //do something
    switch (response.errCode) {
      case 0:
        Fluttertoast.showToast(msg:'分享成功',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
        Navigator.pop(context);
        break;
      case -2:
        Fluttertoast.showToast(msg:'取消分享',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
        break;
      default:
        Fluttertoast.showToast(msg:'分享失败',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
        break;
    }
    });
    // 对 scrollController 进行监听
    _scrollController.addListener(() {
      // _scrollController.position.pixels 获取当前滚动部件滚动的距离
      // window.physicalSize.height 获取屏幕高度
      // 当滚动距离大于 800 后，显示回到顶部按钮
//      setState(() => _showBackTop = _scrollController.position.pixels >= 200);
    });

    refreshgoods();
    janalytics.onPageStart(widget.runtimeType.toString());
  }

  @override
  void deactivate() {
    super.deactivate();
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    _swiperController.stopAutoplay();
    _swiperController.dispose();
    _selectSizeDropdownMenuSelectController.dispose();
    _buyListDropdownMenuSelectController.dispose();
    _sellListDropdownMenuSelectController.dispose();
    _buyRecordsDropdownMenuSelectController.dispose();
    janalytics.onPageEnd(widget.runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: mydrawer,
      drawerScrimColor: Colors.transparent,
      key: _scaffoldkey,
      appBar: myappbar(context, true, false, sckey: _scaffoldkey,leaveLogIn:leaveLogIn,image: imgUrl),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child:  _goodDetailInfo.isEmpty
            ? LoadingDialog(
          //调用对话框
          text: '正在加载...',
        )
            : Stack(
            key: _stackKey,
            alignment: Alignment.topLeft,
            children: <Widget>[
              EasyRefresh(
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
                  controller: _scrollController,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                      child: Column(
                        children: <Widget>[
                          headerImageView(headImagesList: _goodDetailInfo['imgList']??[]),
                          goodInfoHeadView(context: context,goodInfo:_goodDetailInfo),
                          titleView(context:context,title:'购买流程'),
                          selectBuyBarView(context: context,title1: '砍价买',title2: '直接买'),
                          titleView(context:context,title:'出售流程'),
                          selectSoldBarView(context: context,title1: '竞价卖',title2: '立即卖'),
                          titleView(context:context,title:'相关推荐'),
                          goodsGridView(goods: _goods,prices: _goodsprices),
                        ],
                      ),
                    ),
                    bottomView(context:context,newList: _newArticlesList,hotList: _hotArticlesList),
                  ],
                ),
                onRefresh: () async {
                  await refreshgoods();
                },
              ),
              Positioned(
                bottom: 20.0,
                left: 20.0,
                child: Container(
                  decoration: BoxDecoration(
                    color:AppStyle.colorLight,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.drag_handle,size: 30.0,color: AppStyle.colorPrimary),
                    onPressed: () {
                      // scrollController 通过 animateTo 方法滚动到某个具体高度
                      // duration 表示动画的时长，curve 表示动画的运行方式，flutter 在 Curves 提供了许多方式
                      _menuBtnOnPressed(context);
                    },
                  ),
                ),
              ),
              buildSelstctSizeGzxDropDownMenu(),
              buildBuyListGzxDropDownMenu(),
              buildSellListGzxDropDownMenu(),
              buildBuyRecordsGzxDropDownMenu(),
            ]
        ),
      ),
    );
  }

  Widget sizeTypeView({String selectValue,List types}){
    List<Widget> items = [];
    items.add(SizedBox(height: ScreenUtil.getInstance().setWidth(4),));
    for(Map item in types){
      Color lineColor = selectValue == item['value'] ? AppStyle.colorSuccess : AppStyle.colorWhite;
      Color textColor = selectValue == item['value'] ? AppStyle.colorSuccess : AppStyle.colorDark;
      items.add(SizedBox(height: ScreenUtil.getInstance().setWidth(20),));
      items.add(
        GestureDetector(
          onTap: (){
            print('select type value = ${item['value']},type title = ${item['title']}');

            _sizeValue=item['value'];

            ApiConfig().getSizeSellPriceList(comdiId:widget.goodID,sizeType: _sizeValue).then((sizeData){


              if(sizeData.isNotEmpty && int.parse(sizeData['rspCode']) < 1000){
                _sizeList = [];
                _sizeList.addAll(sizeData['list']);
                _selectSize = '全部';
                _sizeId = '';
                _isShowSizeType = true;
                refreshPrices(goodId: widget.goodID,sizeId: _sizeId);
              }
              else return;

              setState(() {});

            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setWidth(44.0),),
              Container(height: ScreenUtil.getInstance().setWidth(22.0),width: ScreenUtil.getInstance().setWidth(2.0),color: lineColor,),
              SizedBox(width: ScreenUtil.getInstance().setWidth(22.0),),
              Text(
                item['title'],
                style: TextStyle(
                  color: textColor,
                  fontSize: ScreenUtil.getInstance().setSp(24.0),
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        )
      );
      items.add(SizedBox(height: ScreenUtil.getInstance().setWidth(20),));
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: ScreenUtil.getInstance().setWidth(70.0),),
            Expanded(child:
              Container(
                height: ScreenUtil.getInstance().setWidth(2.0),
                color: Color(0xFFE3E3E3),
              ),
            ),
            SizedBox(width: ScreenUtil.getInstance().setWidth(40.0),),
          ],
        )
      );
    }
    items.removeAt(items.length - 1);
    items.add(SizedBox(height: ScreenUtil.getInstance().setWidth(20),));
    return Container(
      color: AppStyle.colorWhite,
      width: ScreenUtil.getInstance().setWidth(320),
      child: Card(
        elevation: 2.0,
        child: Column(
          children: items,
        ),
      ),
    );
  }

  GZXDropDownMenu buildSelstctSizeGzxDropDownMenu() {
    return GZXDropDownMenu(
      // controller用于控制menu的显示或隐藏
      controller: _selectSizeDropdownMenuSelectController,
      // 下拉菜单显示或隐藏动画时长
      animationMilliseconds: 500,
      // 下拉菜单，高度自定义，你想显示什么就显示什么，完全由你决定，你只需要在选择后调用_selectSizeDropdownMenuSelectController.hide();即可
      menus: [
        GZXDropdownMenuBuilder(
            dropDownHeight: ScreenUtil.getInstance().setWidth(680.0),
            dropDownWidget: _buildSelectSizeContentWidget((selectValue,selectId) {
              _selectSizeDropdownMenuSelectController.hide();
              _selectSize = selectValue;
              _sizeId = selectId;
              setState(() {});
            })
        ),
      ],
    );
  }

  _buildSelectSizeContentWidget(void itemOnTap(String selectValue,selectId)) {

    Widget _gridViewBuilder(BuildContext context , int index){

      String sellString = _sizeList[index]['price'];
      String sellPrice = sellString;
//      String sellPrice = '¥${int.parse(sellString.replaceRange(0,1, '0'))/100}';

      return GestureDetector(
        onTap:() => itemOnTap(_sizeList[index]['title'],_sizeList[index]['id']),
        child: Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectSize == _sizeList[index]['title'] ? AppStyle.colorDark : AppStyle.colorGreyLine,
              width: _selectSize == _sizeList[index]['title'] ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _sizeList[index]['title'].trim(),
                maxLines: 1,
                style: TextStyle(
                  color: AppStyle.colorDark,
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w400,
                ),
              ),
//              Row(
//                children: <Widget>[
//                  SizedBox(width: ScreenUtil.getInstance().setWidth(40),),
//                  Transform.rotate(
//                    angle: math.pi*13/16,
//                    child: Container(
//                      width: ScreenUtil.getInstance().setWidth(80),
//                      height: 1,
//                      color: AppStyle.colorGreyLine,
//                    ),
//                  ),
//                ],
//              ),
//              Expanded(
//                  child: Container(
//                    child: Row(
//                      children: <Widget>[
//                        Expanded(child: SizedBox(height: 1,)),
//                        Text(
//                          sellPrice??'',
//                          style: TextStyle(
//                            color: AppStyle.colorGreyText,
//                            fontSize: ScreenUtil.getInstance().setSp(24.0),
//                            fontWeight: FontWeight.w400,
//                          ),
//                        ),
//                      ],
//                    ),
//                  )
//              ),
            ],
          ),
        ),
      );
    }
    return _sizeList.isEmpty
        ?noDataContainer(text: '暂无数据',textColor: AppStyle.colorDark,leftPadding: 80.0)
        :Card(
          elevation: 4.0,
          child: Container(
            color: AppStyle.colorBackground,
            child: Container(
//              margin: EdgeInsets.only(
//                left: ScreenUtil.getInstance().setWidth(16.0),
//                right: ScreenUtil.getInstance().setWidth(16.0),
//              ),
              padding: EdgeInsets.only(
                left: ScreenUtil.getInstance().setWidth(40.0),
                right: ScreenUtil.getInstance().setWidth(40.0),
              ),
              color: AppStyle.colorWhite,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: ScreenUtil.getInstance().setWidth(60.0),),
                    GestureDetector(
                      onTap: () => itemOnTap('全部','0'),
                      child: Container(
                        margin: EdgeInsets.only(
                          top:5.0,
                          bottom:5.0,
                          left:ScreenUtil.getInstance().setWidth(44.0),
                          right:ScreenUtil.getInstance().setWidth(44.0),
                        ),
                        alignment: Alignment.center,
                        height: ScreenUtil.getInstance().setWidth(80),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectSize == '全部' ? AppStyle.colorDark : AppStyle.colorGreyLine,
                            width: _selectSize == '全部' ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          '全部',
                          style: TextStyle(
                            color: AppStyle.colorDark,
                            fontSize: ScreenUtil.getInstance().setSp(32.0),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _isShowSizeType = !_isShowSizeType;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 5.0,right: 5.0),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(32.0),
                          bottom: ScreenUtil.getInstance().setWidth(32.0),
                          left: ScreenUtil.getInstance().setWidth(10.0),
                          right: ScreenUtil.getInstance().setWidth(10.0),
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              getSizeTypeTitle(_sizeValue),
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(24.0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Expanded(child: SizedBox(height: 1,),),
                            Text(
                              '选择尺码标准',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(24.0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            !_isShowSizeType
                                ? Transform.rotate(
                              angle: math.pi,
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                              ),
                            )
                                :Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            GridView.builder(
                                padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                                itemCount: _sizeList.length,
                                shrinkWrap: true, //解决无限高度问题
                                physics:NeverScrollableScrollPhysics(),//禁用滑动事件
                                //        shrinkWrap: true,
                                //        physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  //横轴元素个数
                                  crossAxisCount: 4,
                                  //纵轴间距
                                  mainAxisSpacing: ScreenUtil.getInstance().setWidth(40.0),
                                  //横轴间距
                                  crossAxisSpacing: ScreenUtil.getInstance().setWidth(18.0),
                                  //子组件宽高长度比例
                                  childAspectRatio: 73/48,
                                ),
                                itemBuilder: _gridViewBuilder
                            ),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: ScreenUtil.getInstance().setWidth(16.0),
                          child: Offstage(
                            offstage: _isShowSizeType,
                            child: sizeTypeView(selectValue: _sizeValue,types: _sizeTypeList),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  Widget selectSizeDropdownMenuHeader(){
    return Container(
      key: _selectSizeKey,
      child: GZXDropDownHeader( // 下拉菜单头部
        // 下拉的头部项，目前每一项，只能自定义显示的文字、图标、图标大小修改
        items: [
          GZXDropDownHeaderItem(_selectSize),
        ],
        width: ScreenUtil.getInstance().setWidth(170.0),
        // GZXDropDownHeader对应第一父级Stack的key
        stackKey: _stackKey,
        // controller用于控制menu的显示或隐藏
        controller: _selectSizeDropdownMenuSelectController,
        // 当点击头部项的事件，在这里可以进行页面跳转或openEndDrawer
        onItemTap: (index) {

          _animateToViewTop(_selectSizeKey, _scrollController, (){

            if (_selectSizeDropdownMenuSelectController.isShow) {
              _selectSizeDropdownMenuSelectController.hide();
            } else {

              //显示加载动画
              showDialog<Null>(
                  context: context, //BuildContext对象
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new LoadingDialog( //调用对话框
                      text: '正在获取详情...',
                    );
                  });

              ApiConfig().getSizeSellPriceList(comdiId:widget.goodID,sizeType: _sizeValue).then((onValue){

                //退出加载动画
                Navigator.pop(context); //关闭对话框

                if(onValue.isNotEmpty && int.parse(onValue['rspCode']) < 1000){
                  _sizeList = [];
                  _sizeList.addAll(onValue['list']);
                  refreshPrices(goodId: widget.goodID,sizeId: _sizeId);
                  setState(() {});
                }
                else return;

                _selectSizeDropdownMenuSelectController.show(index);

              });
            }

          });
        },
        // 头部的高度
        height: ScreenUtil.getInstance().setWidth(60.0),
        // 头部背景颜色
        color: Colors.transparent,
        // 头部边框宽度
        borderWidth: 1,
        // 头部边框颜色
        borderColor: Colors.transparent,
        // 分割线高度
        dividerHeight: 10,
        // 分割线颜色
        dividerColor: Color(0xFFeeede6),
        // 文字样式
        style: TextStyle(
            color: AppStyle.colorDark,
            fontSize: ScreenUtil.getInstance().setSp(40),
            fontWeight: FontWeight.w500
        ),
        // 下拉时文字样式
        dropDownStyle: TextStyle(
            fontSize: ScreenUtil.getInstance().setSp(40),
            color: AppStyle.colorDark,
            fontWeight: FontWeight.w500
        ),
        // 图标大小
        iconSize: 30,
        // 图标颜色
        iconColor: AppStyle.colorPrimary,
        // 下拉时图标颜色
        iconDropDownColor: Theme.of(context).primaryColor,
      ),
    );
  }

  GZXDropDownMenu buildBuyListGzxDropDownMenu() {
    return GZXDropDownMenu(
      // controller用于控制menu的显示或隐藏
      controller: _buyListDropdownMenuSelectController,
      // 下拉菜单显示或隐藏动画时长
      animationMilliseconds: 500,
      // 下拉菜单，高度自定义，你想显示什么就显示什么，完全由你决定，你只需要在选择后调用_Controller.hide();即可
      menus: [
        GZXDropdownMenuBuilder(
            dropDownHeight: ScreenUtil.getInstance().setWidth(680.0),
            dropDownWidget: _buildBuyListContentWidget((selectValue) {
              _buyListDropdownMenuSelectController.hide();
              setState(() {});
            })
        ),
      ],
    );
  }

  _buildBuyListContentWidget(void itemOnTap(String selectValue)) {

    List recodes = [];
    recodes.addAll(_buyRecordsList);

    Widget _gridViewBuilder(BuildContext context , int index){
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  recodes[index]['size']??'',
                  style: TextStyle(
                    color: Color(0xFF474747),
                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${recodes[index]['price']??''}',
                  style: TextStyle(
                    color: Color(0xFF474747),
                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${recodes[index]['amount']??''}',
                  style: TextStyle(
                    color: Color(0xFF474747),
                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return recodes.length == 1
        ?noDataContainer(text: '暂无数据',textColor: AppStyle.colorDark,leftPadding: 80.0)
        :Card(
          elevation: 4.0,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil.getInstance().setWidth(60.0),),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    '买价队列',
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                      color: Color(0xFF474747),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil.getInstance().setWidth(36.0),),
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil.getInstance().setWidth(40.0),
                    right: ScreenUtil.getInstance().setWidth(40.0),
                  ),
                  height: 1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFCECECE),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: ScreenUtil.getInstance().setWidth(26.0),
                    left:5.0,
                    right:5.0,
                  ),
                  decoration: BoxDecoration(
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Text(
                              '尺码',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(24.0),
                                fontWeight:FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                            Container(
                              height: 2,
                              width: ScreenUtil.getInstance().setWidth(44),
                              color: AppStyle.colorPink,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Text(
                              '出价',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(24.0),
                                fontWeight:FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                            Container(
                              height: 2,
                              width: ScreenUtil.getInstance().setWidth(44),
                              color: AppStyle.colorPink,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Text(
                              '数量',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(24.0),
                                fontWeight:FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                            Container(
                              height: 2,
                              width: ScreenUtil.getInstance().setWidth(44),
                              color: AppStyle.colorPink,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
                ListView.builder(
                    shrinkWrap: true, //解决无限高度问题
                    physics:NeverScrollableScrollPhysics(),//禁用滑动事件
                    padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                    itemCount: recodes.length,
                    //        shrinkWrap: true,
                    //        physics: NeverScrollableScrollPhysics(),
                    itemBuilder: _gridViewBuilder
                ),
              ],
            ),
          )
        );
  }

  Widget buyListDropdownMenuHeader(){
    return Container(
      key: _buyListKey,
      child: GZXDropDownHeader( // 下拉菜单头部
        // 下拉的头部项，目前每一项，只能自定义显示的文字、图标、图标大小修改
        items: [
          GZXDropDownHeaderItem('尺码:$_selectSize'),
        ],
        width: ScreenUtil.getInstance().setWidth(180.0),
        // GZXDropDownHeader对应第一父级Stack的key
        stackKey: _stackKey,
        // controller用于控制menu的显示或隐藏
        controller: _buyListDropdownMenuSelectController,
        // 当点击头部项的事件，在这里可以进行页面跳转或openEndDrawer
        onItemTap: (index) {
          _animateToViewTop(_buyListKey, _scrollController, (){

            if (_sellListDropdownMenuSelectController.isShow)_sellListDropdownMenuSelectController.hide();

            if (_buyListDropdownMenuSelectController.isShow) {
              _buyListDropdownMenuSelectController.hide();
            } else {
              //显示加载动画
              showDialog<Null>(
                  context: context, //BuildContext对象
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new LoadingDialog( //调用对话框
                      text: '正在获取详情...',
                    );
                  });

              ApiConfig().gooutPrice(comdiId:widget.goodID,sizeId: _sizeId,pageSize: '20',pageNum: '0').then((onValue){

                //退出加载动画
                Navigator.pop(context); //关闭对话框

                if(onValue.isNotEmpty && int.parse(onValue['rspCode']) < 1000){
                  _buyRecordsList = [];
                  if(onValue['list'] != null)_buyRecordsList.addAll(onValue['list']);
                  setState(() {});
                }
                else {
                  Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  return;
                }

                _buyListDropdownMenuSelectController.show(index);

              });
            }

          });
        },
        // 头部的高度
        height: ScreenUtil.getInstance().setWidth(60.0),
        // 头部背景颜色
        color: Colors.transparent,
        // 头部边框宽度
        borderWidth: 1,
        // 头部边框颜色
        borderColor: Colors.transparent,
        // 分割线高度
        dividerHeight: 10,
        // 分割线颜色
        dividerColor: Color(0xFFeeede6),
        // 文字样式
        style: TextStyle(
            color: AppStyle.colorWhite,
            fontSize: ScreenUtil.getInstance().setSp(24),
            fontWeight: FontWeight.w500
        ),
        // 下拉时文字样式
        dropDownStyle: TextStyle(
            fontSize: ScreenUtil.getInstance().setSp(24),
            color: AppStyle.colorWhite,
            fontWeight: FontWeight.w500
        ),
        // 图标大小
        iconSize: ScreenUtil.getInstance().setWidth(40),
        // 图标颜色
        iconColor: AppStyle.colorWhite,
        // 下拉时图标颜色
        iconDropDownColor: AppStyle.colorWhite,
      ),
    );
  }

  GZXDropDownMenu buildSellListGzxDropDownMenu() {
    return GZXDropDownMenu(
      // controller用于控制menu的显示或隐藏
      controller: _sellListDropdownMenuSelectController,
      // 下拉菜单显示或隐藏动画时长
      animationMilliseconds: 500,
      // 下拉菜单，高度自定义，你想显示什么就显示什么，完全由你决定，你只需要在选择后调用_Controller.hide();即可
      menus: [
        GZXDropdownMenuBuilder(
            dropDownHeight: ScreenUtil.getInstance().setWidth(680.0),
            dropDownWidget: _buildSellListContentWidget((selectValue) {
              _sellListDropdownMenuSelectController.hide();
              setState(() {});
            })
        ),
      ],
    );
  }

  _buildSellListContentWidget(void itemOnTap(String selectValue)) {

    List recodesSell = [];
    recodesSell.addAll(_sellRecordsList);

    Widget _gridViewBuilder(BuildContext context , int index){
      return Container(
        padding: EdgeInsets.only(
            bottom:ScreenUtil.getInstance().setWidth(30.0)
        ),
        decoration: BoxDecoration(
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  recodesSell[index]['size']??'',
                  style: TextStyle(
                    color: Color(0xFF474747),
                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${recodesSell[index]['price']??''}',
                  style: TextStyle(
                    color: Color(0xFF474747),
                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${recodesSell[index]['amount']??''}',
                  style: TextStyle(
                    color: Color(0xFF474747),
                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return recodesSell.length == 1
        ?noDataContainer(text: '暂无数据',textColor: AppStyle.colorDark,leftPadding: 80.0)
        :Card(
          elevation: 4.0,
          child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: ScreenUtil.getInstance().setWidth(60.0),),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      '卖价队列',
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                        color: Color(0xFF474747),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setWidth(36.0),),
                  Container(
                    margin: EdgeInsets.only(
                      left: ScreenUtil.getInstance().setWidth(40.0),
                      right: ScreenUtil.getInstance().setWidth(40.0),
                    ),
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFCECECE),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: ScreenUtil.getInstance().setWidth(26.0),
                      left:5.0,
                      right:5.0,
                    ),
                    decoration: BoxDecoration(
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              Text(
                                '尺码',
                                style: TextStyle(
                                  color: AppStyle.colorDark,
                                  fontSize: ScreenUtil.getInstance().setSp(24.0),
                                  fontWeight:FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                              Container(
                                height: 2,
                                width: ScreenUtil.getInstance().setWidth(44),
                                color: AppStyle.colorSuccess,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              Text(
                                '出价',
                                style: TextStyle(
                                  color: AppStyle.colorDark,
                                  fontSize: ScreenUtil.getInstance().setSp(24.0),
                                  fontWeight:FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                              Container(
                                height: 2,
                                width: ScreenUtil.getInstance().setWidth(44),
                                color: AppStyle.colorSuccess,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              Text(
                                '数量',
                                style: TextStyle(
                                  color: AppStyle.colorDark,
                                  fontSize: ScreenUtil.getInstance().setSp(24.0),
                                  fontWeight:FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
                              Container(
                                height: 2,
                                width: ScreenUtil.getInstance().setWidth(44),
                                color: AppStyle.colorSuccess,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setWidth(60.0),),
                  ListView.builder(
                      shrinkWrap: true, //解决无限高度问题
                      physics:NeverScrollableScrollPhysics(),//禁用滑动事件
                      itemCount: recodesSell.length,
                      //        shrinkWrap: true,
                      //        physics: NeverScrollableScrollPhysics(),
                      itemBuilder: _gridViewBuilder
                  ),
                ],
              ),
            ),
        );
  }

  Widget sellListDropdownMenuHeader(){
    return Container(
      key: _sellListKey,
      child: GZXDropDownHeader( // 下拉菜单头部
        // 下拉的头部项，目前每一项，只能自定义显示的文字、图标、图标大小修改
        items: [
          GZXDropDownHeaderItem('尺码:$_selectSize'),
        ],
        width: ScreenUtil.getInstance().setWidth(180.0),
        // GZXDropDownHeader对应第一父级Stack的key
        stackKey: _stackKey,
        // controller用于控制menu的显示或隐藏
        controller: _sellListDropdownMenuSelectController,
        // 当点击头部项的事件，在这里可以进行页面跳转或openEndDrawer
        onItemTap: (index) {
          _animateToViewTop(_sellListKey, _scrollController, (){

            if (_buyListDropdownMenuSelectController.isShow)_buyListDropdownMenuSelectController.hide();
            if (_sellListDropdownMenuSelectController.isShow) {
              _sellListDropdownMenuSelectController.hide();
            } else {
              //显示加载动画
              showDialog<Null>(
                  context: context, //BuildContext对象
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new LoadingDialog( //调用对话框
                      text: '正在获取详情...',
                    );
                  });

              ApiConfig().sellPrice(comdiId:widget.goodID,sizeId: _sizeId,pageSize: '20',pageNum: '0').then((onValue){

                //退出加载动画
                Navigator.pop(context); //关闭对话框

                if(onValue.isNotEmpty && int.parse(onValue['rspCode']) < 1000){
                  _sellRecordsList = [];
                  if(onValue['list'] != null)_sellRecordsList.addAll(onValue['list']);
                  setState(() {});
                }
                else {
                  showToast(onValue['rspDesc']??'');
                  return;
                }

                _sellListDropdownMenuSelectController.show(index);

              });
            }

          });
        },
        // 头部的高度
        height: ScreenUtil.getInstance().setWidth(60.0),
        // 头部背景颜色
        color: Colors.transparent,
        // 头部边框宽度
        borderWidth: 1,
        // 头部边框颜色
        borderColor: Colors.transparent,
        // 分割线高度
        dividerHeight: 10,
        // 分割线颜色
        dividerColor: Color(0xFFeeede6),
        // 文字样式
        style: TextStyle(
            color: AppStyle.colorWhite,
            fontSize: ScreenUtil.getInstance().setSp(24),
            fontWeight: FontWeight.w500
        ),
        // 下拉时文字样式
        dropDownStyle: TextStyle(
            fontSize: ScreenUtil.getInstance().setSp(24),
            color: AppStyle.colorWhite,
            fontWeight: FontWeight.w500
        ),
        // 图标大小
        iconSize: ScreenUtil.getInstance().setWidth(40),
        // 图标颜色
        iconColor: AppStyle.colorWhite,
        // 下拉时图标颜色
        iconDropDownColor: AppStyle.colorWhite,
      ),
    );
  }

  GZXDropDownMenu buildBuyRecordsGzxDropDownMenu() {
    return GZXDropDownMenu(
      // controller用于控制menu的显示或隐藏
      controller: _buyRecordsDropdownMenuSelectController,
      // 下拉菜单显示或隐藏动画时长
      animationMilliseconds: 500,
      // 下拉菜单，高度自定义，你想显示什么就显示什么，完全由你决定，你只需要在选择后调用_Controller.hide();即可
      menus: [
        GZXDropdownMenuBuilder(
            dropDownHeight: 40 * 8.0,
            dropDownWidget: _buildBuyRecordsContentWidget((selectValue) {
              _buyRecordsDropdownMenuSelectController.hide();
              setState(() {});
            })
        ),
      ],
    );
  }

  _buildBuyRecordsContentWidget(void itemOnTap(String selectValue)) {

    List recodes = [{'size':'尺码','price':'报价','time':'交易时间'}];
    recodes.addAll(_tradeRecordsList);

    Widget _gridViewBuilder(BuildContext context , int index){

      String tradeString = recodes[index]['price'];
      String tradePrice = tradeString;
//      String tradePrice = index == 0 ? tradeString : '¥${int.parse(tradeString.replaceRange(0,1, '0'))/100}';

      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppStyle.colorGreyLine,
            width: 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    recodes[index]['size']??'',
                    style: TextStyle(
                      color: AppStyle.colorDark,
                      fontSize: ScreenUtil.getInstance().setSp(36.0),
                      fontWeight: index == 0 ? FontWeight.w600: FontWeight.w400,
                    ),
                  ),
                ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  tradePrice??'',
                  style: TextStyle(
                    color: index == 0 ? AppStyle.colorDark : AppStyle.colorGreyText,
                    fontSize: index == 0 ? ScreenUtil.getInstance().setSp(36.0) : ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: index == 0 ? FontWeight.w600: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  '${recodes[index]['time']??''}',
                  style: TextStyle(
                    color: index == 0 ? AppStyle.colorDark : AppStyle.colorGreyText,
                    fontSize: index == 0 ? ScreenUtil.getInstance().setSp(36.0) : ScreenUtil.getInstance().setSp(24.0),
                    fontWeight: index == 0 ? FontWeight.w600: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return recodes.length == 1
        ?noDataContainer(text: '暂无数据',textColor: AppStyle.colorDark,leftPadding: 80.0)
        :Card(
          elevation: 4.0,
          child: SingleChildScrollView(
            child: ListView.builder(
                padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                itemCount: recodes.length,
  //        shrinkWrap: true,
  //        physics: NeverScrollableScrollPhysics(),
                itemBuilder: _gridViewBuilder
            ),
          )
        );
  }

  Widget buyRecordsDropdownMenuHeader(){
    return Container(
      key: _buyRecordKey,
      child: GZXDropDownHeader( // 下拉菜单头部
        // 下拉的头部项，目前每一项，只能自定义显示的文字、图标、图标大小修改
        items: [
          GZXDropDownHeaderItem('浏览交易记录'),
        ],
        width: ScreenUtil.getInstance().setWidth(260.0),
        // GZXDropDownHeader对应第一父级Stack的key
        stackKey: _stackKey,
        // controller用于控制menu的显示或隐藏
        controller: _buyRecordsDropdownMenuSelectController,
        // 当点击头部项的事件，在这里可以进行页面跳转或openEndDrawer
        onItemTap: (index) {
          _animateToViewTop(_buyRecordKey, _scrollController, (){

            if (_buyRecordsDropdownMenuSelectController.isShow) {
              _buyRecordsDropdownMenuSelectController.hide();
            } else {
              //显示加载动画
              showDialog<Null>(
                  context: context, //BuildContext对象
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new LoadingDialog( //调用对话框
                      text: '正在获取详情...',
                    );
                  });

              ApiConfig().tradeTakeNotes(widget.goodID,_sizeId,'20','0').then((onValue){

                //退出加载动画
                Navigator.pop(context); //关闭对话框

                if(onValue.isNotEmpty && int.parse(onValue['rspCode']) < 1000){
                  List recordsList = onValue['list']??[];
                  print('recordsList = $recordsList');
                  if(recordsList.length ==0){
                     Fluttertoast.showToast(
            msg: '无交易记录',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0
        );
                    return;}
                  String tradeString = recordsList[0]['price'];
                  _newTradePrice = tradeString;
//                  _newTradePrice = '¥${int.parse(tradeString.replaceRange(0,1, '0'))/100}';
                  _tradeRecordsList = [];
                  _tradeRecordsList.addAll(recordsList);
                  setState(() {});
                }
                else {
                  Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  return;
                }

                _buyRecordsDropdownMenuSelectController.show(index);

              });
            }

          });
        },
        // 头部的高度
        height: ScreenUtil.getInstance().setWidth(60.0),
        // 头部背景颜色
        color: Colors.transparent,
        // 头部边框宽度
        borderWidth: 1,
        // 头部边框颜色
        borderColor: Colors.transparent,
        // 分割线高度
        dividerHeight: 10,
        // 分割线颜色
        dividerColor: Color(0xFFeeede6),
        // 文字样式
        style: TextStyle(
            fontSize: ScreenUtil.getInstance().setSp(28.0),
            color: AppStyle.colorDark,
            fontWeight: FontWeight.w500
        ),
        // 下拉时文字样式
        dropDownStyle: TextStyle(
            fontSize: ScreenUtil.getInstance().setSp(28),
            color: AppStyle.colorDark,
            fontWeight: FontWeight.w500
        ),
        // 图标大小
        iconSize: ScreenUtil.getInstance().setWidth(60.0),
        // 图标颜色
        iconColor: AppStyle.colorPrimary,
        // 下拉时图标颜色
        iconDropDownColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Container goodInfoHeadView({BuildContext context,Map goodInfo}) {
    List<DropdownMenuItem> getListData(){
      List<DropdownMenuItem> items=new List();
      for(Map item in _sizeTypeList){
        DropdownMenuItem dropdownMenuItem=new DropdownMenuItem(
          child:new Text(item['title']),
          value: item['value'],
        );
        items.add(dropdownMenuItem);
      }
      return items;
    }
    return Container(
      width:double.infinity,
      margin: EdgeInsets.only(top: ScreenUtil.getInstance().setWidth(20.0)),
      color: AppStyle.colorWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(50.0),),
          Container(
            margin: EdgeInsets.only(right:ScreenUtil.getInstance().setWidth(50.0)),
            width: double.infinity,
            height: ScreenUtil.getInstance().setWidth(40.0),
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: (){
                shareGood(context,title: goodInfo['title'],image: _goodDetailInfo['titleImgUrl']);
              },
              child: Image(image: AssetImage(AssetUtil.image('arrows2@3x.png')),fit: BoxFit.fitHeight,),
            ),
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
          Row(
              children: <Widget>[
                SizedBox(width: ScreenUtil.getInstance().setWidth(74.0),),
                Expanded(
                  child: Text(
                    goodInfo['title']??'',
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(36.0),
                      color: Color(0xFF474747),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil.getInstance().setWidth(74.0),),
              ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(90.0),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: SizedBox(height: 1,)),
//              DropdownButton(
//                items: getListData(),
////                hint:new Text('下拉选择你想要的数据'),//当没有默认值的时候可以设置的提示
//                value: _sizeValue,//下拉菜单选择完之后显示给用户的值
//                onChanged: (T){//下拉菜单item点击之后的回调
//                  _sizeValue=T;
//
//                  ApiConfig().getSizeSellPriceList(comdiId:widget.goodID,sizeType: _sizeValue).then((sizeData){
//
//
//                    if(sizeData.isNotEmpty && int.parse(sizeData['rspCode']) < 1000){
//                      _sizeList = [];
//                      _sizeList.addAll(sizeData['list']);
//                      _selectSize = '全部';
//                      _sizeId = '';
//                      refreshPrices(goodId: widget.goodID,sizeId: _sizeId);
//                    }
//                    else return;
//
//                    setState(() {});
//
//                  });
//                },
//                elevation: 24,//设置阴影的高度
//                style: new TextStyle(//设置文本框里面文字的样式
//                    color: AppStyle.colorPrimary,
//                ),
////              isDense: false,//减少按钮的高度。默认情况下，此按钮的高度与其菜单项的高度相同。如果isDense为true，则按钮的高度减少约一半。 这个当按钮嵌入添加的容器中时，非常有用
////            iconSize: 50.0,//设置三角标icon的大小
//              ),
              Text(
                '尺码选择: ',
                style: TextStyle(
                  color: Color(0xFF474747),
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontWeight: FontWeight.w300,
                ),
              ),
              selectSizeDropdownMenuHeader(),
              Expanded(child: SizedBox(height: 1,)),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: ScreenUtil.getInstance().setWidth(16.0)),
                  height: ScreenUtil.getInstance().setWidth(528.0),
                  decoration: BoxDecoration(
                    color: AppStyle.colorSuccess,
                    borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(20.0)))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: AppStyle.colorWhite,
                        height: ScreenUtil.getInstance().setWidth(194.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                Text(
                                  '最低卖价 ',
                                  style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(28.0),
                                    color: AppStyle.colorSuccess,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: ScreenUtil.getInstance().setWidth(80),
                              child:
                              Row(
                                children: <Widget>[
                                  SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                  Text(
                                    _newLowestSellPrice??'--',
                                    style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(56.0),
                                      color: AppStyle.colorSuccess,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            print('买买买');
                            if(!_isLogin){
                               String islog = '1';
                                            Application.router.navigateTo(context,'${Routes.LoginRPage}?isLogin=$islog',transition: TransitionType.native);
                              return;
                            }
                            UserInfoCache().setMapInfo(key: UserInfoCache.buyInfo, map: {
                              'id':widget.goodID,
                              'selectSize':_selectSize =='全部'?'':_selectSize,
                              'sizeValue':_sizeValue,
                              'goodName':goodInfo['title']??'',
                              'sizeId':_selectSize =='全部'?'':_sizeId,
                            });

                            Application.router.navigateTo(context, '${Routes.buyTips}?id=${widget.goodID}&type=${'1'}',transition: TransitionType.native);
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                    Text(
                                      '砍价买 ',
                                      style: TextStyle(
                                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                                        color: AppStyle.colorWhite,
                                      ),
                                    ),
                                    Expanded(child: SizedBox(height: 1,)),
                                  ],
                                ),
                                Container(
                                  height: ScreenUtil.getInstance().setWidth(80),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                      Text(
                                        '直接买',
                                        style: TextStyle(
                                          fontSize: ScreenUtil.getInstance().setSp(60.0),
                                          color: AppStyle.colorWhite,
                                        ),
                                      ),
                                      Expanded(child: SizedBox(height: 1,)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil.getInstance().setWidth(80.0),
                        padding: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(20),
                          bottom: ScreenUtil.getInstance().setWidth(20),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(ScreenUtil.getInstance().setWidth(20)),
                            bottomRight: Radius.circular(ScreenUtil.getInstance().setWidth(20)),
                          ),
                          color: AppStyle.colorDark.withOpacity(0.2),
                        ),
                        child:GestureDetector(
                          onTap: (){
                            print('查看卖价列表');
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: ScreenUtil.getInstance().setWidth(28),),
                              Text(
                                '卖价队列',
                                style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(24.0),
                                  color: AppStyle.colorWhite,
                                ),
                              ),
                              Expanded(child: SizedBox(height: 1,)),
                              Container(height: ScreenUtil.getInstance().setWidth(30.0),width: 1,color: AppStyle.colorWhite,),
                              Expanded(child: SizedBox(height: 1,)),
                              sellListDropdownMenuHeader(),
                              SizedBox(width: ScreenUtil.getInstance().setWidth(8),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setWidth(34.0),),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: ScreenUtil.getInstance().setWidth(16.0)),
                  height: ScreenUtil.getInstance().setWidth(528.0),
                  decoration: BoxDecoration(
                      color: AppStyle.colorPink,
                      borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(20.0)))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: AppStyle.colorWhite,
                        height: ScreenUtil.getInstance().setWidth(194.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                Text(
                                  '最高买价 ',
                                  style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(28.0),
                                    color: AppStyle.colorPink,
                                  ),
                                ),
                                Expanded(child: SizedBox(height: 1,)),
                              ],
                            ),
                            Container(
                              height: ScreenUtil.getInstance().setWidth(80),
                              child:
                              Row(
                                children: <Widget>[
                                  SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                  Expanded(
                                    child: Text(
                                      _newHighestBuyPrice??'',
                                      style: TextStyle(
                                        fontSize: ScreenUtil.getInstance().setSp(56.0),
                                        color: AppStyle.colorPink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                            onTap: (){
                              print('卖卖卖');
                              if(!_isLogin){
                                 String islog = '1';
                                 Application.router.navigateTo(context, '${Routes.LoginRPage}?isLogin=$islog',transition: TransitionType.native);
                                return;
                              }
                              UserInfoCache().setMapInfo(key: UserInfoCache.sellInfo, map: {
                                'id':widget.goodID,
                                'selectSize':_selectSize =='全部'?'':_selectSize,
                                'sizeValue':_sizeValue,
                                'goodName':goodInfo['title']??'',
                                'sizeId':_selectSize =='全部'?'':_sizeId,
                              });
                              Application.router.navigateTo(context, '${Routes.sellTips}?id=${widget.goodID}&type=1',transition: TransitionType.native);
                            },
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                      Text(
                                        '竞价卖 ',
                                        style: TextStyle(
                                          fontSize: ScreenUtil.getInstance().setSp(28.0),
                                          color: AppStyle.colorWhite,
                                        ),
                                      ),
                                      Expanded(child: SizedBox(height: 1,)),
                                    ],
                                  ),
                                  Container(
                                    height: ScreenUtil.getInstance().setWidth(80),
                                    child:
                                    Row(
                                      children: <Widget>[
                                        SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                                        Text(
                                          '立即卖',
                                          style: TextStyle(
                                            fontSize: ScreenUtil.getInstance().setSp(60.0),
                                            color: AppStyle.colorWhite,
                                          ),
                                        ),
                                        Expanded(child: SizedBox(height: 1,)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil.getInstance().setWidth(80.0),
                        padding: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(20),
                          bottom: ScreenUtil.getInstance().setWidth(20),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(ScreenUtil.getInstance().setWidth(20)),
                            bottomRight: Radius.circular(ScreenUtil.getInstance().setWidth(20)),
                          ),
                          color: AppStyle.colorDark.withOpacity(0.2),
                        ),
                        child:GestureDetector(
                          onTap: (){
                            print('查看买价列表');
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: ScreenUtil.getInstance().setWidth(28),),
                              Text(
                                '买价队列',
                                style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(24.0),
                                  color: AppStyle.colorWhite,
                                ),
                              ),
                              Expanded(child: SizedBox(height: 1,)),
                              Container(height: ScreenUtil.getInstance().setWidth(30.0),width: 1,color: AppStyle.colorWhite,),
                              Expanded(child: SizedBox(height: 1,)),
                              buyListDropdownMenuHeader(),
                              SizedBox(width: ScreenUtil.getInstance().setWidth(8),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
          Container(
            margin: EdgeInsets.only(
              left: ScreenUtil.getInstance().setWidth(33.0),
              right: ScreenUtil.getInstance().setWidth(33.0),
            ),
            height: 1,
            width: double.infinity,
            color: AppStyle.colorGreyLine,
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[

                      Row(
                        children: <Widget>[
                          SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                          Text(
                            '最新成交价 ',
                            style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(28.0),
                              color: AppStyle.colorDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(child: SizedBox(height: 1,)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
                          Expanded(
                            child: Text(
                              _newTradePrice,
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(60.0),
                                color: AppStyle.colorDark,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(height: ScreenUtil.getInstance().setWidth(100.0),width: 1,color: AppStyle.colorGreyLine,),
                SizedBox(width: ScreenUtil.getInstance().setWidth(70.0),),
                buyRecordsDropdownMenuHeader(),
                SizedBox(width: ScreenUtil.getInstance().setWidth(70.0),),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
          Container(
            margin: EdgeInsets.only(
              left: ScreenUtil.getInstance().setWidth(33.0),
              right: ScreenUtil.getInstance().setWidth(33.0),
            ),
            height: 1,
            width: double.infinity,
            color: AppStyle.colorGreyLine,
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(120.0),),
          Container(
            margin: EdgeInsets.only(
              left: ScreenUtil.getInstance().setWidth(33.0),
              right: ScreenUtil.getInstance().setWidth(33.0),
            ),
            height: 1,
            width: double.infinity,
            color: AppStyle.colorGreyLine,
          ),
          Container(
            padding: EdgeInsets.only(
              top: ScreenUtil.getInstance().setWidth(32.0),
              bottom: ScreenUtil.getInstance().setWidth(32.0),
            ),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              '100%全新正品 平台鉴定服务   ',
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(50.0),
                  color: AppStyle.colorDark,
                  fontWeight: FontWeight.w400
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: ScreenUtil.getInstance().setWidth(33.0),
              right: ScreenUtil.getInstance().setWidth(33.0),
            ),
            height: 1,
            width: double.infinity,
            color: AppStyle.colorGreyLine,
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
          goodInfoItem(title: '品牌',content: goodInfo['brand']??''),
          SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
          goodInfoItem(title: '系列',content: goodInfo['series']??''),
          SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
          goodInfoItem(title: '性别',content: goodInfo['crowd']??''),
          SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
          goodInfoItem(title: '上市时间',content: goodInfo['date']??''),
          SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
          goodInfoItem(title: '货号',content: goodInfo['sn']??''),
          SizedBox(height: ScreenUtil.getInstance().setWidth(20.0),),
          goodInfoItem(title: '牌价',content: goodInfo['price']??''),
          SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
        ],
      ),
    );
  }

  Widget goodInfoItem({String title,content}) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: ScreenUtil.getInstance().setWidth(50.0),),
            //富文本
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  text: '$title :  ',
                  style: TextStyle(
                    color: AppStyle.colorDark,
                    fontSize: ScreenUtil.getInstance().setSp(28.0),
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                        text: content,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                        children: [])
                  ]),
            ),
          ],
        );
  }

  Widget selectBuyBarView({BuildContext context,String title1,String title2}) {
    return Container(
      width: double.infinity,
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
                      print('title1 = $title1 , title 2 = $title2,index = $_buyIndex');
                      if(_buyIndex == 0)return;
                      setState(() {
                        _buyIndex = 0;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _buyIndex == 0 ? AppStyle.colorWhite : AppStyle.colorBackground,
                          child: Center(
                            child: Text(
                              title1,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        _buyIndex == 0 ?
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
                      print('title1 = $title1 , title 2 = $title2,index = $_buyIndex');
                      if(_buyIndex == 1)return;
                      setState(() {
                        _buyIndex = 1;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _buyIndex == 1 ? AppStyle.colorWhite : AppStyle.colorBackground,
                          child: Center(
                            child: Text(
                              title2,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        _buyIndex == 1 ?
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
          SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
          _buyIndex == 0
              ? Container(
                  height: ScreenUtil.getInstance().setWidth(456.0),
                  child: Image(image: AssetImage(AssetUtil.image('Group 9@3x.png')),fit: BoxFit.fitHeight,),
                )
              : Container(
                  height: ScreenUtil.getInstance().setWidth(456.0),
                  child: Image(image: AssetImage(AssetUtil.image('Group 8@3x.png')),fit: BoxFit.fitHeight,),
                ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
        ],
      ),
    );
  }
  Widget selectSoldBarView({BuildContext context,String title1,String title2}) {
    return Container(
      width: double.infinity,
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
                      print('title1 = $title1 , title 2 = $title2,index = $_soldIndex');
                      if(_soldIndex == 0)return;
                      setState(() {
                        _soldIndex = 0;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _soldIndex == 0 ? AppStyle.colorWhite : AppStyle.colorBackground,
                          child: Center(
                            child: Text(
                              title1,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        _soldIndex == 0 ?
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
                      print('title1 = $title1 , title 2 = $title2,index = $_soldIndex');
                      if(_soldIndex == 1)return;
                      setState(() {
                        _soldIndex = 1;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _soldIndex == 1 ? AppStyle.colorWhite : AppStyle.colorBackground,
                          child: Center(
                            child: Text(
                              title2,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        _soldIndex == 1 ?
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
          SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
          _soldIndex == 0
          ? Container(
                height: ScreenUtil.getInstance().setWidth(456.0),
            child: Image(image: AssetImage(AssetUtil.image('Group 91@3x.png')),fit: BoxFit.fitHeight,),
            )
          : Container(
            height: ScreenUtil.getInstance().setWidth(456.0),
            child: Image(image: AssetImage(AssetUtil.image('Group 81@3x.png')),fit: BoxFit.fitHeight,),
            ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
        ],
      ),
    );
  }

  Container titleView({BuildContext context,String title}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: ScreenUtil.getInstance().setWidth(80.0),
        bottom: ScreenUtil.getInstance().setWidth(60.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: Container(height: 1,color: AppStyle.colorGreyLine,)),
          Text(
            '   $title   ',
            style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(36.0),
                fontWeight: FontWeight.w600,
                color: AppStyle.colorDark
            ),
          ),
          Expanded(child: Container(height: 1,color: AppStyle.colorGreyLine,)),
        ],
      ),
    );
  }

  Widget headerImageView({@required List headImagesList}) {
    if (headImagesList.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: ScreenUtil.getInstance().setWidth(667.0),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return CachedNetworkImage(
              imageUrl: headImagesList[index],
              placeholder: (context, url) => new CircularProgressIndicator(strokeWidth: 1.0,),
              errorWidget: (context, url, error) => new Icon(Icons.warning),
              fit: BoxFit.cover,
            );
          },
          controller: _swiperController,
          itemCount: headImagesList.length,
          itemWidth: double.infinity,
          layout: SwiperLayout.DEFAULT,
          pagination: SwiperCustomPagination(
              builder: (BuildContext context, SwiperPluginConfig config) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: EdgeInsets.only(
                      bottom: ScreenUtil.getInstance().setSp(40.0),
//                      left: ScreenUtil.getInstance().setSp(20.0),
//                      right: ScreenUtil.getInstance().setSp(20.0)
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(16.0)),
                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setSp(60.0)),
                      color: AppStyle.colorWhite.withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[//shape_left@3x.png
                        GestureDetector(
                          child: Container(
                            width: ScreenUtil.getInstance().setWidth(60.0),
                            height: ScreenUtil.getInstance().setWidth(30.0),
                            child: Image(image: AssetImage(AssetUtil.image('shape_left@3x.png')),fit: BoxFit.fitWidth,),
                          ),
                          onTap : (){
                            int next = config.activeIndex == 0 ?  config.itemCount - 1 : config.activeIndex -1;
                            print('next = $next');
                          },
                        ),
                        SizedBox(width: ScreenUtil.getInstance().setWidth(36.0),),
                        RichText(
                          text: TextSpan(
                              text: config.activeIndex < 10 ? '0${config.activeIndex + 1}' : '  ${config.activeIndex + 1}',
                              style: TextStyle(
                                color: AppStyle.colorDark,
                                fontSize: ScreenUtil.getInstance().setSp(50.0),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                    text: config.itemCount < 10 ? ' /  0${config.itemCount}' : '  ${config.itemCount}',
                                    style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(36.0),
                                      color: AppStyle.colorDark,
                                    )),
                              ]),
                        ),
                        SizedBox(width: ScreenUtil.getInstance().setWidth(36.0),),
                        GestureDetector(
                          child: Container(
                            width: ScreenUtil.getInstance().setWidth(60.0),
                            height: ScreenUtil.getInstance().setWidth(30.0),
                            child: Image(image: AssetImage(AssetUtil.image('Shape_right @3x.png')),fit: BoxFit.fitWidth,),
                          ),
                          onTap : (){
                            int next = config.activeIndex == config.itemCount - 1 ?  0 : config.activeIndex + 1;
                            print('next = $next');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          autoplayDelay: 3000,
          autoplayDisableOnInteraction: true,
        ),
      );
    }
    return Container();
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

//  Widget barView(BuildContext context,Color backgroundColor,bool isLogin){
//    return Container(
//        height: MediaQueryData.fromWindow(window).padding.top + 56.0,
//        decoration: BoxDecoration(
//          color: backgroundColor,
//        ),
//        child: Center(
//          child: Padding(
//            padding: EdgeInsets.only(
//              top: MediaQueryData.fromWindow(window).padding.top,
//            ),
//            child: Row(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                GestureDetector(
//                  child: Container(
//                    height: ScreenUtil.getInstance().setWidth(64.0),
//                    width: ScreenUtil.getInstance().setWidth(100.0),
//                    decoration: BoxDecoration(
////                            color: Colors.red
//                    ),
//                    alignment: Alignment.center,
//                    child: Container(
//                      height: 20,
//                      width: 20,
//                      child: Icon(
//                        Icons.arrow_back_ios,
//                        color: AppStyle.colorWhite,
//                        size: ScreenUtil.getInstance().setWidth(50.0),
//                      ),
//                    ),
//                  ),
//                  onTap : () => Application.router.pop(context),
//                ),
//                Expanded(child: SizedBox(height: 1,)),
//                GestureDetector(
//                  onTap: () => _jumpToIndexView(context),
//                  child: Container(
//                    height: 37,
//                    decoration: BoxDecoration(
////                            color: Colors.red
//                    ),
//                    alignment: Alignment.center,
//                    child: Image(image: AssetImage(AssetUtil.image('logo-bl copy@3x.png')),fit: BoxFit.fitHeight,),
//                  ),
//                ),
//                Expanded(
//                    child: Container(
//                      alignment: Alignment.centerRight,
//                      height: ScreenUtil.getInstance().setWidth(64.0),
//                      child: isLogin ? ClipOval(
//                        child: Container(
//                          width: ScreenUtil.getInstance().setWidth(64.0),
//                          height: ScreenUtil.getInstance().setWidth(64.0),
//                          child: Image(image: AssetImage(AssetUtil.image('video@3x.png')),fit: BoxFit.fill,),
//                        ),
//                      ) : Container(),
//                    )
//                ),
//                GestureDetector(
//                  child: Container(
//                    height: ScreenUtil.getInstance().setWidth(64.0),
//                    width: ScreenUtil.getInstance().setWidth(100.0),
//                    decoration: BoxDecoration(
////                            color: Colors.red
//                    ),
//                    alignment: Alignment.center,
//                    child: Container(
//                      height: 20,
//                      width: 20,
//                      child: Image(image: AssetImage(AssetUtil.image('search@3x.png')),fit: BoxFit.fitWidth,),
//                    ),
//                  ),
//                  onTap : () => _searchBtnOnPressed(context),
//                ),
//              ],
//            ),
//          ),
//        )
//    );
//  }

  Widget goodsGridView({List goods,prices}){

    print('goods = ${goods.toString()}');
    print('prices = ${prices.toString()}');

    if(goods.isEmpty)return noDataContainer(text: '暂无商品数据',textColor: AppStyle.colorPrimary,leftPadding: 16.0);
    Widget _gridViewBuilder(BuildContext context,int index){
      String buyString = prices[index]['buyingPrice']??'--';
      String sellString = prices[index]['sellingPrice']??'--';
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
                      imageUrl: goods[index]['imgUrl'],
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
                                      text: '${goods[index]['title']}',
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
                                    prices.isEmpty?'暂无':sellPrice??'',
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
                                    prices.isEmpty?'暂无':buyPrice??'',
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
                  print('jump to gifts detail view. ${goods[index]['title']}');
                  Application.router.navigateTo(context, '${Routes.goodDetail}?id=${goods[index]['id']}',transition: TransitionType.native);
                },
              ),
            ),
          )
        ],
      );
    }
    return GridView.builder(
        shrinkWrap: true, //解决无限高度问题
        physics:NeverScrollableScrollPhysics(),//禁用滑动事件
        itemCount: goods.length,
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

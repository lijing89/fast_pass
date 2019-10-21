import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:fast_pass/app/pages/home/components/custom_floating_button.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';

class FPSearchPage extends StatefulWidget {
  @override
  _FPSearchPageState createState() => _FPSearchPageState();
}

class _FPSearchPageState extends State<FPSearchPage> {
  ///商品信息
  Map _goodsInfo = {};
  List _goodsPriceList = [];
  int _goodsNum = 6;
  ///文章信息
  List _articleList = [];
  int _articsNum = 6;

  ///新品发布
  List _newArticlesList = [];
  ///热门推荐
  List _hotArticlesList = [];

  double _appBarAlpha = 1;

  ScrollController _controller = ScrollController();

  bool _isLogin = false;//是否登录
  bool _showBackTop = false;//是否显示到顶部按钮

  var _scaffoldkey = new GlobalKey<ScaffoldState>();

  final _textController = TextEditingController();

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();

  ///消息按钮点击事件
  _searchBtnOnPressed(BuildContext context){
    search();
  }
  ///搜索点击事件
  _jumpToIndexView(BuildContext context){
    //跳转且设置跳转页为首页
    Application.cache?.setInt(Application.SplashCacheKey, 0);
    Application.router.navigateTo(context, Routes.home,transition:TransitionType.native);
  }
  //刷新数据
  Future search({String key})async{
    /*
key	ans..128	m	-	搜索的关键字（全字匹配）
comdiPageSize	n..3	m	r	商品分页每页数量。0表示不搜索商品
comdiPageNum	n..2	c	r	商品分页页码。当comdiPageSize=0是无意义
comdiCount	n..3	-	c	关键字匹配的商品数量
comdiList	list	-	c	商品列表。如果没有内容，返回长度为0的list。
[item]id	an..128	-	m	商品编号。
[item]imgUrl	ans..128	-	m	图片路径。
[item]title	ans..64	-	m	标题。
articlePageSize	n..3	m	r	文章分页每页数量。0表示不搜索文章
articlePageNum	n..2	c	r	文章分页页码。当articlePageSize=0是无意义
articleCount	n..3	-	c	关键字匹配的文章数量
articleList	list	-	c	文章列表。如果没有内容，返回长度为0的list。
[item]type	n1..2	-	m	文章类型文字描述。
[item]id	an..128	-	m	文章编号。
[item]imgUrl	ans..128	-	m	图片路径。
[item]title	ans..64	-	m	标题。
[item]date	ans..64	-	m	文章发布日期。
    * */
    var data = await ApiConfig().search(
        key:key,
        comdiPageSize:_goodsNum,
        comdiPageNum:0,
        articlePageSize:_articsNum,
        articlePageNum:0
    );
    if(data.isNotEmpty && int.parse(data['rspCode']??'0') < 1000){
      _goodsInfo = data;
      //获取商品的最低卖价和最高买价
      List<Map<dynamic, dynamic>> items = [];
      List goodsList = data['comdiList']??[];
      if(goodsList.isNotEmpty){
        for(Map item in goodsList){
          items.add({'id':item['id']});
        }
        var newPricesData = await ApiConfig().goodsLowHeight(items);

        if(newPricesData.isNotEmpty && int.parse(newPricesData['rspCode']) < 1000){
          _goodsPriceList = [];
          _goodsPriceList = newPricesData['rspList'];
        }
      }
    }else return;
    var newArticlesData = await ApiConfig().firstLink(listId:'1');

    if(newArticlesData.isNotEmpty && int.parse(newArticlesData['rspCode']) < 1000){
      _newArticlesList = [];
      _newArticlesList.addAll(newArticlesData['list']);
    }else return;

    var hotArticlesData = await ApiConfig().firstLink(listId:'2');
    if(hotArticlesData.isNotEmpty && int.parse(hotArticlesData['rspCode']) < 1000){
      _hotArticlesList = [];
      _hotArticlesList.addAll(hotArticlesData['list']);
    }else return;

    setState(() {});
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
      setState(() => _showBackTop = _controller.position.pixels >= 200);
    });
    // _textController.addListener(() {
    //   print('input ${_textController.text}');
    //   if(_textController.text != '')search(key: _textController.text);
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
    _textController.dispose();
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
              drawer: mydrawer,
              drawerScrimColor: Colors.transparent,
              key: _scaffoldkey,
              body: Stack(
                alignment: Alignment.topLeft,
                children: <Widget>[
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: ScreenUtil.getInstance().setWidth(160),
                        ),
                        Expanded(
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
                                  _textController.text==''?Container():Container(
                                    padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                                    child: buildContentView(context: context,info: _goodsInfo),
                                  ),
                                  _textController.text==''?Container():addGoodsView(context:context),
                                  _textController.text==''?Container():comparisonList(info: _goodsInfo),
                                  _textController.text==''?Container():bottomView(context:context,newList: _newArticlesList,hotList: _hotArticlesList),
                                ],
                              ),
                              onRefresh: () async {
                                await search();
                              },
                            ),
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: _appBarAlpha,
                    child: barView(context,Theme.of(context).primaryColor,_isLogin),
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
                          _scaffoldkey.currentState.openDrawer();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        );
  }

  Widget addGoodsView({BuildContext context}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: ScreenUtil.getInstance().setWidth(32),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '没有您要找的商品?试试',
              style: TextStyle(
                color: AppStyle.colorDark,
                fontSize: ScreenUtil.getInstance().setSp(28.0),
                fontWeight: FontWeight.w300,
              ),
            ),
            GestureDetector(
              onTap: (){
                print('跳转商品收录页');
                Application.router.navigateTo(context, Routes.newIncludedCommodities,transition: TransitionType.native);
              },
              child: Text(
                '提交商品收录申请',
                style: TextStyle(
                  color: AppStyle.colorBlue,
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil.getInstance().setWidth(32),),
      ],
    );
  }

  Widget buildContentView({BuildContext context,Map info}) {
    List goodsList = info['comdiList']??[];
    int goodsCount =  info['comdiCount']??0;
    int articlesCount =  info['articleCount']??0;
    return Column(
      children: <Widget>[
        SizedBox(height: ScreenUtil.getInstance().setWidth(60.0),),
        titleListItem(
            title: '$goodsCount 篇相关主题在商品拦目中',
            onTap: (){
//              if(goodsCount == 0){
//                showToast('在商品拦目中暂无相关主题');
//                return;
//              }
              print('$goodsCount 相关主题在评测文章');
              Application.router.navigateTo(context, '${Routes.searchGoods}?key=${_textController.text}',transition: TransitionType.native);
            },
            rightWidget: Container(
                width: ScreenUtil.getInstance().setWidth(20.0),
                height: ScreenUtil.getInstance().setWidth(20.0),
                child: Transform.rotate(
                  angle: math.pi *3/2,
                  child: Image(image: AssetImage(AssetUtil.image('Path 6@3x.png')),fit: BoxFit.fitWidth,),
                )
            )
        ),
        titleListItem(
            title: '$articlesCount 篇相关主题在评测文章中',
            onTap: (){
//              if(articlesCount == 0){
//                showToast('在评测文章中暂无相关主题');
//                return;
//              }
              print('$articlesCount 相关主题在评测文章');
              Application.router.navigateTo(context, '${Routes.searchArticles}?key=${_textController.text}',transition: TransitionType.native);
            },
            rightWidget: Container(
                width: ScreenUtil.getInstance().setWidth(20.0),
                height: ScreenUtil.getInstance().setWidth(20.0),
                child: Transform.rotate(
                  angle: math.pi *3/2,
                  child: Image(image: AssetImage(AssetUtil.image('Path 6@3x.png')),fit: BoxFit.fitWidth,),
                )
            )
        ),
        SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
        goodsGridView(goods: goodsList,prices: _goodsPriceList),
      ],
    );
  }

  Widget titleListItem({String title,Function onTap,Widget rightWidget}){
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(60.0),),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
              Text(
                title,
                style: TextStyle(
                  color: AppStyle.colorDark,
                  fontSize: ScreenUtil.getInstance().setSp(26.0),
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
              rightWidget,
              Expanded(child: SizedBox(height: 1,)),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
          Container(height: 1,width: double.infinity,color: AppStyle.colorGreyText,),
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
                        child: Icon(
                            Icons.arrow_back_ios,
                            color: AppStyle.colorWhite,
                            size: 20,
                        ),
                      ),
                    ),
                    onTap : () => Application.router.pop(context),
                ),
                SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
                Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                        color: AppStyle.colorWhite,
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 16.0,),
                          Expanded(
                              child: Container(
                                alignment: Alignment.topCenter,
                                height:36,
                                child: TextField(
                                  cursorColor: AppStyle.colorPrimary,
                                  autofocus: true,
                                  controller: _textController,
//                                  maxLines: 1,//最大行数
                                  style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(32.0),
                                      color: AppStyle.colorPrimary,
                                  ),//输入文本的样式
                                  enabled: true,//是否禁用
                                  decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: AppStyle.colorPrimary,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color:Colors.transparent)
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:Colors.transparent)
                            )

                        ),
                                ),
                                
                              )
                          ),
                          SizedBox(width: 10.0,),
                          GestureDetector(
                            child: Container(
                              height: 37,
                              width: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(62.0))),
                                color: AppStyle.colorPrimary,
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
                          SizedBox(width: 2.0,),
                        ],
                      ),
                    ),
                ),
                SizedBox(width: 18.0,),
              ],
            ),
          ),
        )
    );
  }

  Widget goodsGridView({List goods,prices}){

    if(goods.isEmpty)return noDataContainer(text: '暂无商品信息',textColor: AppStyle.colorPrimary,leftPadding: 0.0);
    Widget _gridViewBuilder(BuildContext context,int index){

      String buyString = prices[index]['buyingPrice'];
      String sellString = prices[index]['sellingPrice'];
      String buyPrice = buyString;
      String sellPrice = sellString;
//      String buyPrice = '¥${int.parse(buyString.replaceRange(0,1, '0'))/100}';
//      String sellPrice = '¥${int.parse(sellString.replaceRange(0,1, '0'))/100}';

      return Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
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

  Widget comparisonList({Map info}){

    List articlesList = info['articleList']??[];
    if(articlesList.isEmpty)return noDataContainer(text: '暂无文章信息',textColor: AppStyle.colorPrimary,leftPadding: 32.0);
    Widget _listViewBuilder(BuildContext context,int index){
      return InkWell(
        onTap: (){
          print('jump to article detail   ${articlesList[index]['id']}');
          Application.router.navigateTo(context, '${Routes.informationDetail}?id=${articlesList[index]['id']}',transition: TransitionType.native);
        },
        child:Container(
          margin: EdgeInsets.only(
            top: ScreenUtil.getInstance().setWidth(16.0),
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppStyle.colorWhite
          ),
          child: Column(
            children: <Widget>[
//              Expanded(child: SizedBox(width: 1,),),
              SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
              Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                  Container(
                    height: ScreenUtil.getInstance().setWidth(26.0),
                    width: ScreenUtil.getInstance().setWidth(10.0),
                    color: AppStyle.colorDark,
                  ),
                  SizedBox(width: ScreenUtil.getInstance().setWidth(10.0),),
                  Text(
                    '评测',
                    style: TextStyle(
                      color: AppStyle.colorGreyText,
                      fontSize: ScreenUtil.getInstance().setSp(26.0),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
              Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                  Expanded(
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          text: articlesList[index]['title'],
                          style: TextStyle(
                            color: AppStyle.colorDark,
                            fontSize: ScreenUtil.getInstance().setSp(50.0),
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w200,
                          ),
                          children: []),
                    ),
                  ),
                ],
              ),
//              Expanded(child: SizedBox(width: 1,),),
              SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
        padding: EdgeInsets.only(
          right: ScreenUtil.getInstance().setWidth(16.0),
          bottom: ScreenUtil.getInstance().setWidth(16.0),
        ),
        shrinkWrap: true, //解决无限高度问题
        physics:NeverScrollableScrollPhysics(),//禁用滑动事件
        itemCount: articlesList.length,
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

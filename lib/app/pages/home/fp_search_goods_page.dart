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

import 'package:fast_pass/app/pages/loginregister/gzx_filter_goods_page.dart';
import 'package:fast_pass/app/pages/home/components/custom_floating_button.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';

class FPSearchGoodsPage extends StatefulWidget {
  final String keyString;
  FPSearchGoodsPage({@required this.keyString});
  @override
  _FPSearchGoodsPageState createState() => _FPSearchGoodsPageState();
}

class _FPSearchGoodsPageState extends State<FPSearchGoodsPage> with SingleTickerProviderStateMixin{
  bool setLogin = true;
  bool _isLogin = true;//是否登录
  bool _showBackTop = false;//是否显示到顶部按钮
  String dorpdown = '最新卖家报价';
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool _isHidden = true;

  Map searchMap = {'brandId':'','sizeId':'','size':'','priceRange':'','crowdID':'','orderType':''};


  List items;
  int page = 0;
  int pageSize = 20;
  int listid = 0;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
  new GlobalKey<RefreshFooterState>();
  bool _loadMore = true;
  List _goods = [];
  List _goodsPrices = [];

  @override
  void initState() {
    super.initState();
//    UMengAnalytics.beginPageView('sportShoes');
    print('keyString = ${widget.keyString}');
    pullRefresh();
  }
  @override
  void dispose() {
    super.dispose();
//    UMengAnalytics.endPageView('end_sportShoes');
  }
  @override
  Widget build(BuildContext context) {
    //假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334),设置字体大小根据系统的“字体大小”辅助选项来进行缩放,默认为false
    //默认设计稿为6p7p8p尺寸 width : 1080px , height:1920px , allowFontScaling:false
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
    return Scaffold(
      key: _scaffoldkey,
      drawer: mydrawer,
      drawerScrimColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          highlightColor: AppStyle.colorPrimary,
          splashColor: AppStyle.colorPrimary,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('"${widget.keyString}"相关商品栏目'),
      ),
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
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
          refreshFooter: ClassicsFooter(
            key: _footerKey,
            showMore: true,
            loadText: '上拉加载',
            moreInfo: "更新于 %T",
            loadingText: '正在加载...',
            loadedText: '加载完成',
            noMoreText: '正在加载... ', //没有更多数据啦！
            loadReadyText: '释放加载',
//                                    moreInfo: "更新于",
            bgColor: Colors.transparent,
            textColor: Colors.black87,
            moreInfoColor: Colors.black54,
            //showMore: false,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _goods.length,
            itemBuilder: (BuildContext context, int position){
              return _items(context,position);
            },
          ),
          onRefresh: () async {
            setState(() {
              page = 0;
              _easyRefreshKey.currentState.waitState(() {
                setState(() {
                  _loadMore = true;
                });
              });
            });
            await pullRefresh();
          },
          loadMore: _loadMore
              ? () async {
            setState(() {
              page += 1;
            });
            await loadMore();
          }
              : null,
        ),
      ),
    );
  }

  Future pullRefresh() async {

    var data = await ApiConfig().search(
        key:widget.keyString,
        comdiPageSize:pageSize,
        comdiPageNum:page,
        articlePageSize:0,
        articlePageNum:0
    );
    List goods = data['comdiList'];
    _goods=[];
    _goods.addAll(goods);

    //获取商品的最低卖价和最高买价
    List<Map<dynamic, dynamic>> items = [];
    List goodsList = data['comdiList']??[];
    if(goodsList.isNotEmpty){
      for(Map item in goodsList){
        items.add({'id':item['id']});
      }
      var newPricesData = await ApiConfig().goodsLowHeight(items);

      if(newPricesData.isNotEmpty && int.parse(newPricesData['rspCode']) < 1000){
        _goodsPrices = [];
        _goodsPrices = newPricesData['rspList'];
      }
    }
    setState(() {});
  }

  Future loadMore() async {

    var data = await ApiConfig().search(
        key:widget.keyString,
        comdiPageSize:pageSize,
        comdiPageNum:page,
        articlePageSize:0,
        articlePageNum:0
    );

    //获取商品的最低卖价和最高买价
    List<Map<dynamic, dynamic>> items = [];
    List goodsList = data['comdiList']??[];
    if(goodsList.isNotEmpty){
      for(Map item in goodsList){
        items.add({'id':item['id']});
      }
      var newPricesData = await ApiConfig().goodsLowHeight(items);

      if(newPricesData.isNotEmpty && int.parse(newPricesData['rspCode']) < 1000){
        _goodsPrices.addAll(newPricesData['rspList']);
      }
    }


    _goods.addAll(data['comdiList']);

    //请求成功 刷新页面
     if(data['comdiList'].length < pageSize){
       Fluttertoast.showToast(msg:'没有更多数据啦!',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);

       _easyRefreshKey.currentState.waitState(() {
           setState(() {
               _loadMore = false;
           });
       });
     }else{
         setState(() {});
     }
  }

 fitPrices({List prices}){

    List temp = [];
    for(Map good in _goods){

      for(Map price in prices){
        if(price['id'] == good['id']){
          good['sellingPrice'] = price['sellingPrice'];
          good['buyingPrice'] = price['buyingPrice'];
        }
      }
      temp.add(good);
    }

    _goods = temp;

 }

//列表cell
  Widget _items(BuildContext context,int position){
    Map d = _goods[position];
    Map p = _goodsPrices[position];

    return Container(
      height: ScreenUtil.getInstance().setWidth(300),
      width: double.infinity,
      child: GestureDetector(
        onTap: (){
          //商品详情
          String id = d['id'];
          Application.router.navigateTo(context, '${Routes.goodDetail}?id=$id',transition: TransitionType.native);
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setWidth(52.0), ScreenUtil.getInstance().setWidth(20.0), ScreenUtil.getInstance().setWidth(26.0), 0),
                  child: CachedNetworkImage(
                    imageUrl: d['imgUrl'],
                    placeholder: (context, url) => new ProgressView(),
                    errorWidget: (context, url, error) => new Icon(Icons.warning),
                    fit: BoxFit.fitWidth,
                  )
              ),
            ),
            Expanded(
              flex: 11,
              child: Container(
                alignment: Alignment.center,
                color: AppStyle.colorWhite,
                margin: EdgeInsets.fromLTRB(0, 10, 0,0),
                // padding: EdgeInsets.fromLTRB(0, 0, 0, 23),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(40.0)),
                      child: Text(

                        d['title'],
                        style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(24),color:  Color(0xFF4A4A4A)),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                    ),
                    Container(

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(40.0),),
                            Container(
                              height: ScreenUtil.getInstance().setWidth(100.0),
                              width: 1,
                              color: AppStyle.colorSuccess,
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '最低卖价',
                                    style: TextStyle(
                                      color: AppStyle.colorSuccess,
                                      fontSize: ScreenUtil.getInstance().setSp(24.0),
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                Container(
                                  child: Text(
                                    '${p['sellingPrice']}',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: ScreenUtil.getInstance().setSp(32.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(40.0),),
                            Container(
                              height: ScreenUtil.getInstance().setWidth(100.0),
                              width: 1,
                              color: AppStyle.colorPink,
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '最高买价',
                                    style: TextStyle(
                                      color: AppStyle.colorPink,
                                      fontSize: ScreenUtil.getInstance().setSp(24.0),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                Container(
                                  child: Text(
                                    '${p['buyingPrice']}',
                                    style: TextStyle(
                                      color: AppStyle.colorDark,
                                      fontSize: ScreenUtil.getInstance().setSp(32.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                    ),

                  ],

                ),
              ),
            ),

          ],
        ),
      ),
    );

  }


  Widget _siftBar(BuildContext context){
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 43,
          color: AppStyle.colorWhite,
        ),
        Container(
          child: Row(
            children: <Widget>[

              Row(
                children: <Widget>[
                  Container(
                    // height: 20,
                    padding: EdgeInsets.only(left: 10),
                    margin: EdgeInsets.only(right: 10),
                    child: Text('排序:',
                      style: TextStyle(fontSize: 12,color: AppStyle.colorPrimary),
                    ),
                  ),
                  DropdownButton(
                    value: dorpdown,
                    onChanged: (String newValue){
                      setState(() {
                        dorpdown = newValue;
                      });
                    },
                    items: <String>['综合排序','销量','浏览量','最新卖家出价','最新买家出价','最新成交','最低卖家出价','最高买家出价','上市时间'].map<DropdownMenuItem<String>>((String value){
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,style: TextStyle(fontSize: 12,color: AppStyle.colorPrimary)),
                      );
                    }).toList(),
                  )
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: 1,
                ),
              ),

              GestureDetector(
                onTap: (){
                  //清除
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 13, 10, 13),
                  child: Text('清除全部',
                    style: TextStyle(fontSize: 12,color: Color(0xFF2D9633)),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 19,
                padding: EdgeInsets.all(12),
                color: AppStyle.colorBackground,
              ),
              GestureDetector(
                onTap: (){
                  // _itemOnTap(index: 1,context: context);
                  _scaffoldkey.currentState.openEndDrawer();
                },
                child: Container(
                  height: 20,
                  width: 20,
                  margin: EdgeInsets.fromLTRB(20, 11, 20, 11),
                  child: Image(
                    image: AssetImage(AssetUtil.image('filtrate@3x.png')),
                  ),

                ),
              ),

            ],
          ),
        )
      ],
    );
  }
}

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

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:janalytics/janalytics.dart';

class FPSearchArticlesPage extends StatefulWidget {
  final String keyString;
  FPSearchArticlesPage({@required this.keyString});
  @override
  _FPSearchArticlesPageState createState() => _FPSearchArticlesPageState();
}

class _FPSearchArticlesPageState extends State<FPSearchArticlesPage> with SingleTickerProviderStateMixin{
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
  final Janalytics janalytics = new Janalytics();
  void _pushDetail(BuildContext context,String id){
    Application.router.navigateTo(context, '${Routes.informationDetail}?id=$id',
        transition: TransitionType.native);
  }

  @override
  void initState() {
    super.initState();
//    UMengAnalytics.beginPageView('sportShoes');
    print('keyString = ${widget.keyString}');
    pullRefresh();
    janalytics.onPageStart(widget.runtimeType.toString());
  }
  @override
  void dispose() {
    super.dispose();
//    UMengAnalytics.endPageView('end_sportShoes');
    janalytics.onPageEnd(widget.runtimeType.toString());
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
        title: Text('"${widget.keyString}"相关测评文章'),
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
            shrinkWrap: true, //解决无限高度问题
            itemCount: _goods.length,
            itemBuilder: (BuildContext context, int position) {
              return _item(context, position);
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
        comdiPageSize:0,
        comdiPageNum:0,
        articlePageSize:pageSize,
        articlePageNum:page
    );
    List goods = data['articleList'];
    if(goods ==null) return;
    _goods=[];
    _goods.addAll(goods);

    //获取商品的最低卖价和最高买价
    List<Map<dynamic, dynamic>> items = [];
    List goodsList = data['articleList']??[];
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
        comdiPageSize:0,
        comdiPageNum:0,
        articlePageSize:pageSize,
        articlePageNum:page
    );

    _goods.addAll(data['articleList']);

    //请求成功 刷新页面
    if(data['articleList'].length < pageSize){
      showToast('没有更多数据啦!');

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
  _item(BuildContext context, int position) {
    Map a = _goods[position];
    if (a['imgUrl'] != null) {
      return GestureDetector(
        onTap: () {
          _pushDetail(context ,a['id']);
        },
        child:  Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          color: Color(0x33333A),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                width: double.infinity,
                child: Text(
                  a['date'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(24), color: AppStyle.colorPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                width: double.infinity,
                child: Text(
                  a['title'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(48), color: Colors.black),
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
                    imageUrl: a['imgUrl'],
                    placeholder: (context, url) => new ProgressView(),
                    errorWidget: (context, url, error) =>
                    new Icon(Icons.warning),
                    fit: BoxFit.fitWidth,
                  )
              ),
              SizedBox(
                width: double.infinity,
                height: 20,
              ),
              Container(
                // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: 3,
                width: double.infinity,
                color: Color(0xffcbcbcb),
              ),
            ],
          ),
        ),
      );
    } else if (a['imgUrl'] == null) {
      return GestureDetector(
        onTap: () {
          _pushDetail(context ,a['id']);
        },
        child: Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
            padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          width: double.infinity,
                          child: Text(
                            a['title'],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          )),
                      // Container(
                      //     padding: EdgeInsets.fromLTRB(0, 10, 20, 0),
                      //     width: double.infinity,
                      //     child: Text(
                      //       a['jianjie'],
                      //       textAlign: TextAlign.left,
                      //       style: TextStyle(
                      //           fontSize: 12, color: Color(0xff666666)),
                      //       maxLines: 2,
                      //       overflow: TextOverflow.ellipsis,
                      //     ))
                    ],
                  ),
                ),
                SizedBox(
                  width: 27,
                ),
                Container(
                  width: 15,
                  height: 3,
                  color: Color(0xff474747),
                ),
              ],
            )),
      );
    }
    //  else if (a['type'] == '3') {
    //   return GestureDetector(
    //     onTap: () {
    //       _pushDetail(context ,'id');
    //     },
    //     child: Container(
    //       padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
    //       color: Color(0x33333A),
    //       child: Column(
    //         children: <Widget>[
    //           Container(
    //             padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
    //             height: 3,
    //             width: double.infinity,
    //             color: Color(0xffcbcbcb),
    //           ),
    //           Container(
    //             padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
    //             width: double.infinity,
    //             child: Text(
    //               a['title'],
    //               textAlign: TextAlign.left,
    //               style: TextStyle(fontSize: 24, color: Colors.black),
    //               maxLines: 2,
    //               overflow: TextOverflow.ellipsis,
    //             ),
    //           ),
    //           SizedBox(
    //             width: double.infinity,
    //             height: 10,
    //           ),
    //           Container(
    //             width: double.infinity,
    //             child: Text(
    //               a['jianjie'],
    //               textAlign: TextAlign.left,
    //               style: TextStyle(fontSize: 14, color: Colors.black),
    //               maxLines: 10,
    //               overflow: TextOverflow.ellipsis,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // } else {
    //   return GestureDetector(
    //     onTap: () {
    //       _pushDetail(context ,'id');
    //     },
    //     child: Container(
    //         margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
    //         padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
    //         color: Colors.white,
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Container(
    //               width: 15,
    //               height: 3,
    //               color: Color(0xff474747),
    //             ),
    //             SizedBox(
    //               width: 27,
    //             ),
    //             Expanded(
    //               child: Column(
    //                 children: <Widget>[
    //                   Container(
    //                       padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
    //                       width: double.infinity,
    //                       child: Text(
    //                         a['title'],
    //                         textAlign: TextAlign.left,
    //                         style: TextStyle(fontSize: 20, color: Colors.black),
    //                         maxLines: 2,
    //                         overflow: TextOverflow.ellipsis,
    //                       )),
    //                   Container(
    //                       padding: EdgeInsets.fromLTRB(0, 10, 20, 0),
    //                       width: double.infinity,
    //                       child: Text(
    //                         a['jianjie'],
    //                         textAlign: TextAlign.left,
    //                         style: TextStyle(
    //                             fontSize: 12, color: Color(0xff666666)),
    //                         maxLines: 2,
    //                         overflow: TextOverflow.ellipsis,
    //                       ))
    //                 ],
    //               ),
    //             )
    //           ],
    //         )),
    //   );
    // }
    return Container(
      child: Text(a['type']),
    );
  }

}

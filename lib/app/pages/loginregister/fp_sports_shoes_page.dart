import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_pass/app/pages/loginregister/gzx_filter_goods_page.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:janalytics/janalytics.dart';
//import 'package:flutter_umeng_analytics/flutter_umeng_analytics.dart';

class SportsShoesPage extends StatefulWidget{

  @override
  _SportsShoesPageState createState() => _SportsShoesPageState();
}

class _SportsShoesPageState extends State<SportsShoesPage> with SingleTickerProviderStateMixin{
  bool setLogin = true;
  bool _isLogin = true;//是否登录
  bool _showBackTop = false;//是否显示到顶部按钮
  List<Map> _fruits = [{'title':'综合排序','color':Colors.red},{'title':'销量','color':Colors.black},{'title':'浏览量','color':Colors.black},{'title':'最新卖家报价','color':Colors.black},{'title':'最新买家出价','color':Colors.black},{'title':'最新成交','color':Colors.black},{'title':'最低卖家报价','color':Colors.black},{'title':'最高买家出价','color':Colors.black},{'title':'上市时间','color':Colors.black}];
  Map NS = {};
  bool openSel = false;
  bool sift = false;
  String imgUrl = '';
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _selectedFruit;
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool _isHidden = true;
  Timer _time;
  Map searchMap = {};
  List items;
  int page = 0;
  int pageSize = 20;
  String claseIcon = 'menu@3x.png';
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  bool _loadMore = true;
  List<dynamic> li = [];
  //价格数据
  Map _dataMap = {};
  final Janalytics janalytics = new Janalytics();
//筛选确定按钮
 _sureFunc(){
   pullRefresh();
 }
 

  @override
  void initState() {
    super.initState();
    janalytics.onPageStart(widget.runtimeType.toString());
    NS = _fruits[0];
    searchMap['orderType'] = '1';
    pullRefresh();

    ///定时刷新列表价格
    startTimer();
  }
  void startTimer(){
    //设置30m刷新一次
    const period = const Duration(seconds: 10);
    _time = Timer.periodic(period, (callback){
      //请求商品价格
        List b = [];
        String sizeid = DataList.getInstance().searchMap['sizeId']??null;
        for (var item in li) {
          b.add({'id':item['id'],'sizeId':sizeid});
        }
        ApiConfig().goodsLowHeight(b).then((onValue){
          if(onValue== null){
        return;
      }
        if(onValue['rspCode'] != '0000'){
            if (_time != null) {
              _time.cancel();
              _time = null;
              }
            return;
        }
        for (var item in onValue['rspList']??[]) {
          _dataMap[item['id'].toString()] = item;
        }
        
        for (var item in li) {
          Map dic = _dataMap[item['id']];
          if(dic == null){continue;}
          item['sellingPrice'] = dic['sellingPrice'];
          item['buyingPrice'] = dic['buyingPrice'];
        }
        //请求成功 刷新页面
        //是否在树种
        if(mounted){
          setState(() {
          });
        }
        });
    });

  }
  @override
  void dispose() {
    janalytics.onPageEnd(widget.runtimeType.toString());
    if (_time != null) {
    _time.cancel();
    _time = null;
    }
    super.dispose();
//    UMengAnalytics.endPageView('end_sportShoes');
  }
  @override
  void deactivate() {
    if (_time != null) {
      _time.cancel();
      _time = null;
      }
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
        setState(() {
          _isLogin = onValue == '1'?true:false;
          startTimer();
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
          key: _scaffoldkey,
          drawer:  SmartDrawer(callback: (isOpen){
      if(!isOpen){
        closeDrow();
      }else{
        openDrow();
      }
      },),
          drawerScrimColor: Colors.transparent,
          appBar: myappbar(context, false, false, sckey: _scaffoldkey,leaveLogIn: leaveLogIn,image: imgUrl,menuIcon: claseIcon),
          body: Column(
            children: <Widget>[

              Container(
                width: double.infinity,
                height: 55,
                child: _siftBar(context),
              ),
              Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      MediaQuery.removePadding(
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
                          itemCount: li.length,
                          itemBuilder: (BuildContext context, int position){
                            return _items(context,position);
                          },
                        ),
            onRefresh: () async {
              setState(() {
                page = 1;
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
                      openSel?GestureDetector(
                        onTap: (){
                          setState(() {
                            openSel = false;
                          });
                        },
                        child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent
                      ),
                      ):Container(),
                   openSel?Container(                      
                        height: ScreenUtil.getInstance().setHeight(660),
                        width:  ScreenUtil.getInstance().setHeight(320),
                        color: AppStyle.colorWhite,
                        child: Container(
                          child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _fruits.length,
                          itemBuilder: (BuildContext context, int position){
                            return selectedButton(position);
                          },
                        ),
                        ),
                      ):Container(),
                      sift?GestureDetector(
                        onTap: (){
                          setState(() {
                            sift = false;
                          });
                        },
                        child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent
                      ),
                      ):Container(),
                      sift?
                      Container(
                        margin: EdgeInsets.only(left: 0,right: MediaQuery.of(context).size.width/1.8),
                        child: GZXFilterGoodsPage(sureFunc: _sureFunc),
                      ):Container()
                      
                    ],
                  )
              ),
            ],
          ),
        );
  }

Widget selectedButton(int position){
Map a = _fruits[position];
String title = a['title'];
Color color = a['color'];
return GestureDetector(
  onTap: (){
    NS['color'] = Colors.black;
    a['color'] = Colors.red;
    setState(() {
      NS = a;
      openSel = false;
    });
    searchMap['orderType'] = (position +1).toString();
    _selectedFruit = title;
    pullRefresh();
  },
  child: Column(
        children: <Widget>[
          Container(
        child: Row(
          children: <Widget>[
            SizedBox(width: ScreenUtil.getInstance().setHeight(50)),
            color == Colors.black?Container():Container(
              margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(20)),
              padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(20)),
              height: ScreenUtil.getInstance().setHeight(22),
              width: 1,
              color: AppStyle.colorRed,
            ),
            SizedBox(width: ScreenUtil.getInstance().setHeight(22)),
            Container(
              margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(20)),
              child: Text(title,style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(24),color:color),
            ),
            )
          ],
        ),
      ),
      SizedBox(height: ScreenUtil.getInstance().setHeight(20)),
      Container(
        margin: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(74),right: ScreenUtil.getInstance().setHeight(40)),
        color: AppStyle.colorBackground,
        height: 1,
      )
        ],
      )
);
}

Future pullRefresh() async {
    var islog = await UserInfoCache().getInfo(key: UserInfoCache.loginStatus);
    setState(() {
    _isLogin = islog == '1'?true:false;
        });

         if(_isLogin){
    var onV = await UserInfoCache().getUserInfo();
          imgUrl = onV['headImgUrl'];
        }
    ApiConfig().goodsSift(searchMap['orderType'], DataList.getInstance().searchMap['sizeType'], pageSize.toString(),page.toString(),brandId: DataList.getInstance().searchMap['brandId'],sizeId: DataList.getInstance().searchMap['sizeId'],priceRange: DataList.getInstance().searchMap['priceRange'],crowdId: DataList.getInstance().searchMap['crowdId']).then((response){
      if(response == null){
        return;
      }
        if(response['rspCode'] != '0000'){
            Fluttertoast.showToast(
                msg: response['rspDesc'],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 2,
                backgroundColor: AppStyle.colorGreyDark,
                textColor: Colors.white,
                fontSize: 16.0
            );
            return;
        }
         //请求成功 刷新页面
        if(mounted){
          setState(() {
            li = response['list'];
          });
        }
        
    });
  }

  Future loadMore() async {
    ApiConfig().goodsSift(searchMap['orderType'], DataList.getInstance().searchMap['sizeType'],page.toString(), pageSize.toString(),brandId: DataList.getInstance().searchMap['brandId'],sizeId: DataList.getInstance().searchMap['sizeId'],priceRange: DataList.getInstance().searchMap['priceRange'],crowdId: DataList.getInstance().searchMap['crowdId']).then((response){
      if(response == null){
        return;
      }
        if(response['rspCode'] != '0000'){
            Fluttertoast.showToast(
                msg: response['rspDesc'],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 2,
                backgroundColor: AppStyle.colorGreyDark,
                textColor: Colors.white,
                fontSize: 16.0
            );
            return;
        }
      //请求成功 刷新页面
      if(response['list'].length < pageSize){
          showToast('没有更多数据啦!');
          _easyRefreshKey.currentState.waitState(() {
              setState(() {
                  _loadMore = false;
              });
          });
      }else{
        //请求成功 刷新页面
          setState(() {
              li.addAll(response['list']);
          });
        
      }
    });
  }



//列表cell
  Widget _items(BuildContext context,int position){
    Map d = li[position];
    
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
                margin: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setWidth(24.0), ScreenUtil.getInstance().setWidth(20.0), ScreenUtil.getInstance().setWidth(26.0), 0),
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
                      height: ScreenUtil.getInstance().setWidth(140.0),
                      alignment: Alignment.topLeft,
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
                                  '${d['sellingPrice']}',
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
                                  '${d['buyingPrice']}',
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

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List fruits) {
    List<DropdownMenuItem<String>> items = List();
    for (String fruit in fruits) {
      items.add(DropdownMenuItem(value: fruit, child: Text(fruit,style: TextStyle(fontSize: 12,color: AppStyle.colorPrimary))
        ));
    }
    return items;
  }

  void changedDropDownItem(String selectedFruit) {
    setState(() {
      _selectedFruit = selectedFruit;
      // searchMap['orderType'] = (_fruits.indexOf(selectedFruit)+1).toString();
    });
    pullRefresh();
  }

  Widget _siftBar(BuildContext context){
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 55,
          color: AppStyle.colorWhite,
        ),
        Container(
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  setState(() {
                    sift = !sift;
                  });

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
              Container(
                width: 1,
                height: 19,
                padding: EdgeInsets.all(12),
                color: AppStyle.colorBackground,
              ),
              GestureDetector(
                onTap: (){
                  //清除
                  DataList.getInstance().setSelected();
                  pullRefresh();
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 13, 10, 13),
                  child: Text('全部清除',
                    style: TextStyle(fontSize: 12,color: Color(0xFF2D9633)),
                  ),
                ),
              ),
              
              Expanded(
                child: SizedBox(
                  height: 1,
                ),
              ),
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
                  GestureDetector(
                    onTap: (){
                      //展示
                      setState(() {
                        openSel = !openSel;
                      });
                    },
                    child: Container(
                    child: Row(
                      children: <Widget>[
                        Text(NS['title'],
                      style: TextStyle(fontSize: 12,color: AppStyle.colorPrimary),
                    ),
                    SizedBox(width: 20,),
                    Container(
                      width: 10,
                      height: 10,
                      child: Image(
                    image: AssetImage(AssetUtil.image('icon_down@3x.png')),
                  ),
                  
                    ),
                    SizedBox(width: 20,),
                      ],
                    ),
                  )
                  )
                  // DropdownButton(
                  //   value: _selectedFruit,
                  //   items: _dropDownMenuItems,
                  //   onChanged: changedDropDownItem,
                  // )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}




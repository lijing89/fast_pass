import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/model/deal_uss_model_entity.dart';
import 'package:fast_pass/app/model/deal_btc_model_entity.dart';

class DealIndexPage extends StatefulWidget {
  @override
  _DealIndexPageState createState() => _DealIndexPageState();
}

class _DealIndexPageState extends State<DealIndexPage> {
    int _index = 0;
    List<DealUssModelMessageLogData> _ussOneList = [];
    List<DealUssModelMessageLogData> _ussTwoList = [];
    List<DealUssModelMessageLogData> _ussMarketList = [];
    List<DealBtcModelMessageLogData> _btcList = [];
    DealUssModelEntity _ussOneModel;
    DealUssModelEntity _ussTwoModel;
    DealUssModelEntity _ussMarketModel;
    DealBtcModelEntity _btcModel;
    ScrollController _listViewController = ScrollController();


    bool _isShowOne = false;
    bool _isShowTwo = false;
    bool _isShowMarket = false;
    bool _isShowBTC = false;
    int page = 1;
    int pageSize = 20;


    GlobalKey<EasyRefreshState> _easyRefreshKey =
    new GlobalKey<EasyRefreshState>();
    GlobalKey<RefreshHeaderState> _headerKey =
    new GlobalKey<RefreshHeaderState>();
    GlobalKey<RefreshFooterState> _footerKey =
    new GlobalKey<RefreshFooterState>();
    bool _loadMore = true;

    Widget crashBtn(){
        if(_index == 0){

            return IconButton(
                    icon: Icon(
                        AppIcon.add1,
                        size: ScreenUtil.getInstance().setWidth(50.0),
                        color: AppStyle.colorPrimary,
                    ),
                    onPressed: (){},
                );
        }

        return IconButton(
            icon: Icon(
                AppIcon.add1,
                size: ScreenUtil.getInstance().setWidth(50.0),
                color: AppStyle.colorLight,
            ),
            onPressed: (){
                print('BTC提现');
                Application.router.navigateTo(context, Routes.verifiedPPassword);
            },
        );

    }

    Widget buttonBar(){

        Color buttonColorOne,buttonColorTwo,textColorOne,textColorTwo;

        if(_index == 0){
            buttonColorOne = AppStyle.colorBegin;
            textColorOne = AppStyle.colorDark;
            buttonColorTwo = AppStyle.colorDark;
            textColorTwo = AppStyle.colorBegin;

        }else{
            buttonColorOne = AppStyle.colorDark;
            textColorOne = AppStyle.colorBegin;
            buttonColorTwo = AppStyle.colorBegin;
            textColorTwo = AppStyle.colorDark;
        }

        return Container(
            padding:EdgeInsets.only(top: 20.0),
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppStyle.colorPrimary
            ),
            height: ScreenUtil.getInstance().setWidth(160.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(10.0),),
                            IconButton(
                                icon: Icon(
                                    AppIcon.add1,
                                    size: ScreenUtil.getInstance().setWidth(50.0),
                                    color: AppStyle.colorPrimary,
                                ),
                                onPressed: null,
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            Container(
                                height: ScreenUtil.getInstance().setWidth(80.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppStyle.colorSecondary,
                                        width: 1.0
                                    )
                                ),
                                child: RaisedButton(
                                    child: Text('USS'),
                                    onPressed: (){
                                        if(_index != 0){
                                            setState(() {
                                                _index = 0;

                                                _isShowOne = false;
                                                _isShowTwo = false;
                                                _isShowMarket = false;
                                                _isShowBTC = false;

                                            });
                                        }
                                    },
                                    splashColor: Colors.white54,
                                    textColor: textColorOne,
                                    color: buttonColorOne,
                                ),
                            ),
                            Container(
                                height: ScreenUtil.getInstance().setWidth(80.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppStyle.colorSecondary,
                                        width: 1.0
                                    )
                                ),

                                child: RaisedButton(
                                    child: Text('BTC'),
                                    onPressed: (){
                                        if(_index != 1){
                                            setState(() {
                                                _index = 1;
                                                _isShowOne = false;
                                                _isShowTwo = false;
                                                _isShowMarket = false;
                                                _isShowBTC = true;
                                            });
                                        }
                                    },
                                    splashColor: Colors.white54,
                                    textColor: textColorTwo,
                                    color: buttonColorTwo,
                                ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            crashBtn(),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(10.0),),
                        ],
                    ),
                    SizedBox(height: 5.0,)
                ],
            ),
        );
    }

    Widget rightIcon(int index){
        bool showIcon = false;
        if(index == 1)showIcon = _isShowOne;
        if(index == 2)showIcon = _isShowTwo;
        if(index == 3)showIcon = _isShowMarket;

        if(showIcon){
            return Icon(AppIcon.arrow_up_fill);
        }
        return Icon(AppIcon.down);
    }

    Widget listTitleView({String title,int index,onTapFunc}){
        return InkWell(
            onTap: onTapFunc,
            child: Container(
                color: AppStyle.colorLight,
                child: Column(
                    children: <Widget>[
                        SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                        Row(
                            children: <Widget>[
                                SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                                Container(
                                    width: ScreenUtil.getInstance().setWidth(8.0),
                                    height: ScreenUtil.getInstance().setWidth(30.0),
                                    color: AppStyle.colorBegin,
                                ),
                                SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                                Text(
                                    title,
                                    style: TextStyle(
//                                        color: AppStyle.colorLight,
                                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                                        fontWeight: FontWeight.w400
                                    ),
                                ),
                                Expanded(child: SizedBox(height: 1,)),
                                rightIcon(index),
                                SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                            ],
                        ),
                        SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                    ],
                ),
            ),
        );
    }

    Widget USSListView({@required List<DealUssModelMessageLogData> dataSource,bool isShow}){//USS释放记录

        if(isShow == false)return Container();

        Widget _itemBuilder(BuildContext context , int index){
            return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                    SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
                    Row(
                        children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Text(
                                        '释放USS数量:${dataSource[index].freeUss}',
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance().setSp(28.0),
                                            fontWeight: FontWeight.w300
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                    Text(
                                        'USS价格:${dataSource[index].ussPrice}',
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance().setSp(28.0),
                                            fontWeight: FontWeight.w300
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                ],
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Text(
                                        '兑换BTC数量:${dataSource[index].freeBtc}',
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance().setSp(28.0),
                                            fontWeight: FontWeight.w300
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                    Text(
                                        'USS价格:${dataSource[index].bitPrice}',
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance().setSp(28.0),
                                            fontWeight: FontWeight.w300
                                        ),
                                    ),
                                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                                ],
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                        ],
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                    Row(
                        children: <Widget>[
                            Expanded(child: SizedBox(height: 1,)),
                            Text(
                                '释放时间:${dataSource[index].freeTime}',
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                                    fontWeight: FontWeight.w300
                                ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                        ],
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                    Row(
                        children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                            Expanded(child: Container(height: 1,color: AppStyle.colorGrey,)),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                        ],
                    ),
                ],
            );
        }

        if(dataSource.isEmpty)return Container(
            margin: EdgeInsets.all(5.0),
            child: Center(
                child: Text(
                    '暂无数据',
                    style: TextStyle(
                        color: AppStyle.colorDark,
                    ),
                ),
            ),
        );

        return ListView.builder(
            shrinkWrap: true, //解决无限高度问题
            physics:NeverScrollableScrollPhysics(),//禁用滑动事件
            itemBuilder: _itemBuilder,
            itemCount: dataSource.length,
        );
    }

    Widget statusWidget(DealBtcModelMessageLogData item){

        Color textColor;
        String statusString;
        switch (item.status) {
            case '0':
                statusString = '申请中';
                textColor = AppStyle.colorSecondary;
                break;
            case '1':
                statusString = '同意';
                textColor = AppStyle.colorInfo;
                break;
            case '2':
                statusString = '拒绝';
                textColor = AppStyle.colorDanger;
                break;
            case '3':
                statusString = '完成';
                textColor = AppStyle.colorSuccess;
                break;
        }
        return Text(
            statusString,
            style: TextStyle(
                color: textColor,
                fontSize: ScreenUtil.getInstance().setSp(28.0),
                fontWeight: FontWeight.w300
            ),
        );
    }

    Widget BTCListView({@required List<DealBtcModelMessageLogData> dataSource}){//BTC提现记录

        Widget _itemBuilder(BuildContext context , int index){
            return Column(
                children: <Widget>[
                    SizedBox(height: ScreenUtil.getInstance().setWidth(32.0),),
                    Row(
                        children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                            Text(
                                '提现数量:${dataSource[index].btcNum}',
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(28.0),
                                    fontWeight: FontWeight.w300
                                ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            statusWidget(dataSource[index]),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                        ],
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                    Row(
                        children: <Widget>[
                            Expanded(child: SizedBox(height: 1,)),
                            Text(
                                '提现时间:${dataSource[index].ctime}',
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                                    fontWeight: FontWeight.w300
                                ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                        ],
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                    Row(
                        children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                            Expanded(child: Container(height: 1,color: AppStyle.colorGrey,)),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                        ],
                    ),
                ],
            );
        }

        return ListView.builder(
            shrinkWrap: true, //解决无限高度问题
            physics:NeverScrollableScrollPhysics(),//禁用滑动事件
            itemBuilder: _itemBuilder,
            itemCount: _btcList.length,
        );
    }

    Widget listView(BuildContext context){
        if(_index == 0){//USS释放记录
            return Column(
                children: <Widget>[
                    listTitleView(title: 'USS释放记录 - 0.5‰',index: 1,onTapFunc: (){
                        _isShowOne = !_isShowOne;
                        print(_isShowOne);
                        _isShowTwo = false;
                        _isShowMarket = false;
                        _ussOneList = [];
                        _ussTwoList = [];
                        _ussMarketList = [];
                        if(_isShowOne == true){
                            refreshUssRecordOne(callback: (response){

                                if(response['error'] != 0){
                                    Fluttertoast.showToast(
                                        msg: response['message'],
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIos: 2,
                                        backgroundColor: AppStyle.colorGreyDark,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
                                    return;
                                }
                                _ussOneModel = DealUssModelEntity.fromJson(response);

                                //请求成功 刷新页面
                                setState(() {
                                    _ussOneList = _ussOneModel.message.log.data;
                                });
                            });
                        }else{
                            setState(() {
                                _isShowOne = false;
                            });
                        }
                        _listViewController.animateTo(0.0,duration: Duration(seconds: 1),curve: Interval(0.0, 0.2,curve: Curves.easeIn));
                    }),
                    USSListView(dataSource: _ussOneList,isShow: _isShowOne),
                    listTitleView(title: 'USS释放记录 - 1‰',index: 2,onTapFunc: (){
                        _isShowOne = false;
                        _isShowTwo = !_isShowTwo;
                        _isShowMarket = false;
                        _ussOneList = [];
                        _ussTwoList = [];
                        _ussMarketList = [];
                        if(_isShowTwo == true){
                            refreshUssRecordTwo(callback: (response){

                                if(response['error'] != 0){
                                    Fluttertoast.showToast(
                                        msg: response['message'],
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIos: 2,
                                        backgroundColor: AppStyle.colorGreyDark,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
                                    return;
                                }
                                _ussTwoModel = DealUssModelEntity.fromJson(response);

                                //请求成功 刷新页面
                                setState(() {
                                    _ussTwoList = _ussTwoModel.message.log.data;
                                });
                            });
                        }else{
                            setState(() {
                                _isShowTwo = false;
                            });
                        }
                        _listViewController.animateTo(0.0,duration: Duration(seconds: 1),curve: Interval(0.0, 0.2,curve: Curves.easeIn));
                    }),
                    USSListView(dataSource: _ussTwoList,isShow: _isShowTwo),
                    listTitleView(title: 'USS释放记录 - 市场奖励',index: 3,onTapFunc: (){
                        _isShowOne = false;
                        _isShowTwo = false;
                        _isShowMarket = !_isShowMarket;
                        _ussOneList = [];
                        _ussTwoList = [];
                        _ussMarketList = [];
                        if(_isShowMarket == true){
                            refreshUssRecordMark(callback: (response){

                                if(response['error'] != 0){
                                    Fluttertoast.showToast(
                                        msg: response['message'],
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIos: 2,
                                        backgroundColor: AppStyle.colorGreyDark,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
                                    return;
                                }
                                _ussMarketModel = DealUssModelEntity.fromJson(response);

                                //请求成功 刷新页面
                                setState(() {
                                    _ussMarketList = _ussMarketModel.message.log.data;
                                });
                            });
                        }else{
                            setState(() {
                                _isShowMarket = false;
                            });
                        }
                        _listViewController.animateTo(0.0,duration: Duration(seconds: 1),curve: Interval(0.0, 0.2,curve: Curves.easeIn));
                    }),
                    USSListView(dataSource: _ussMarketList,isShow: _isShowMarket),
                ],
            );
        }else{//BTC提现记录
            return Column(
                children: <Widget>[
                    listTitleView(title: '提现记录'),
                    BTCListView(dataSource: _btcList),
                ],
            );
        }
    }

    Future refreshUssRecordOne({callback})async{

        UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

            //请求网络数据uss1
            HttpUtil().get(
                '${ApiConfig.baseUrl}${ApiConfig.ussReleaseRecordOneUrl}',
                queryParameters: {
                    'page':page,
                    'pageSize':pageSize,
                },
            ).then(callback);
        });
    }

    Future refreshUssRecordTwo({callback})async{

        UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

            //请求网络数据uss1
            HttpUtil().get(
                '${ApiConfig.baseUrl}${ApiConfig.ussReleaseRecordTwoUrl}',
                queryParameters: {
                    'page':page,
                    'pageSize':pageSize,
                },
            ).then(callback);
        });
    }

    Future refreshUssRecordMark({callback})async{

        UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

            //请求网络数据uss1
            HttpUtil().get(
                '${ApiConfig.baseUrl}${ApiConfig.ussReleaseMarketUrl}',
                queryParameters: {
                    'page':page,
                    'pageSize':pageSize,
                },
            ).then(callback);
        });
    }

    Future refreshBtcRecord({callback})async{

        var sess  = await UserInfoCache().getInfo(key: UserInfoCache.sessionId);

        //请求网络数据uss1
        var response =  await HttpUtil().get(
            '${ApiConfig.baseUrl}${ApiConfig.btcCashRecordUrl}',
            queryParameters: {
                'page':page,
                'pageSize':pageSize,
            },
        );
        callback(response);
    }

    Future pullRefresh() async{

        if(_isShowOne == true)await refreshUssRecordOne(callback: (response){
//            print(response.toString());

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _ussOneModel = DealUssModelEntity.fromJson(response);

            //请求成功 刷新页面
            setState(() {
                _ussOneList = _ussOneModel.message.log.data;
            });

        });

        if(_isShowTwo == true)await refreshUssRecordTwo(callback: (response){

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _ussTwoModel = DealUssModelEntity.fromJson(response);

            //请求成功 刷新页面
            setState(() {
                _ussTwoList = _ussTwoModel.message.log.data;
            });

        });

        if(_isShowMarket == true)await refreshUssRecordMark(callback: (response){

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _ussMarketModel = DealUssModelEntity.fromJson(response);

            //请求成功 刷新页面
            setState(() {
                _ussMarketList = _ussMarketModel.message.log.data;
            });

        });

        if(_isShowBTC == true)await refreshBtcRecord(callback:(response){

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _btcModel = DealBtcModelEntity.fromJson(response);

            //请求成功 刷新页面
            setState(() {
                _btcList = _btcModel.message.log.data;
            });

        });
    }

    Future loadMore() async{

        if(_isShowOne == true)await refreshUssRecordOne(callback: (response){

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _ussOneModel = DealUssModelEntity.fromJson(response);

            //请求成功 刷新页面

            if(_ussTwoModel.message.log.data.length < pageSize){

                showToast('没有更多数据啦!');

                _easyRefreshKey.currentState.waitState(() {
                    setState(() {
                        _loadMore = false;
                    });
                });
            }else{
                print('page:$page,pageSize:$pageSize,listLength:${_ussOneList.length}');
                setState(() {
                    _ussOneList.addAll(_ussOneModel.message.log.data);
                });
            }
        });

        if(_isShowTwo == true)await refreshUssRecordTwo(callback: (response){

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _ussTwoModel = DealUssModelEntity.fromJson(response);

            //请求成功 刷新页面
            if(_ussTwoModel.message.log.data.length < pageSize){
                showToast('没有更多数据啦!');
                _easyRefreshKey.currentState.waitState(() {
                    setState(() {
                        _loadMore = false;
                    });
                });
            }else{
                print('page:$page,pageSize:$pageSize,listLength:${_ussTwoList.length}');
                setState(() {
                    _ussTwoList.addAll(_ussTwoModel.message.log.data);
                });
            }

        });

        if(_isShowMarket == true)await refreshUssRecordMark(callback: (response){

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _ussMarketModel = DealUssModelEntity.fromJson(response);

            //请求成功 刷新页面
            if(_ussMarketModel.message.log.data.length < pageSize){
                showToast('没有更多数据啦!');
                _easyRefreshKey.currentState.waitState(() {
                    setState(() {
                        _loadMore = false;
                    });
                });
            }else{
                print('page:$page,pageSize:$pageSize,listLength:${_ussMarketList.length}');
                setState(() {
                    _ussMarketList.addAll(_ussMarketModel.message.log.data);
                });
            }

        });

        if(_isShowBTC == true)await refreshBtcRecord(callback:(response){

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _btcModel = DealBtcModelEntity.fromJson(response);

            //请求成功 刷新页面
            if(_btcModel.message.log.data.length < pageSize){
                showToast('没有更多数据啦!');
                _easyRefreshKey.currentState.waitState(() {
                    setState(() {
                        _loadMore = false;
                    });
                });
            }else{
                print('page:$page,pageSize:$pageSize,listLength:${_ussOneList.length}');
                setState(() {
                    _btcList.addAll(_btcModel.message.log.data);
                });
            }

        });
    }

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

        //请求网络数据btc
        HttpUtil().get(
            '${ApiConfig.baseUrl}${ApiConfig.btcCashRecordUrl}',
            queryParameters: {
                'page':page,
                'pageSize':pageSize,
            },
        ).then((response){
//            print(response.toString());

            if(response['error'] != 0){
                Fluttertoast.showToast(
                    msg: response['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 2,
                    backgroundColor: AppStyle.colorGreyDark,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                return;
            }
            _btcModel = DealBtcModelEntity.fromJson(response);

            //请求成功 刷新页面
            setState(() {
                _btcList = _btcModel.message.log.data;
            });

        });

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(0.0),
            child: Column(
                children: <Widget>[
                    buttonBar(),
                    Expanded(
                        child: Container(
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
                                    noMoreText: '正在加载... ',//没有更多数据啦！
                                    loadReadyText: '释放加载',
//                                    moreInfo: "更新于",
                                    bgColor: Colors.transparent,
                                    textColor: Colors.black87,
                                    moreInfoColor: Colors.black54,
                                    //showMore: false,
                                ),
                                child: ListView(
                                    controller: _listViewController,
                                    padding: EdgeInsets.all(0.0),
                                    children: <Widget>[
                                        Column(
                                            children: <Widget>[
                                                Container(
                                                    color: Colors.white,

                                                    child: listView(context),
                                                ),
                                            ],
                                        )
                                    ],
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
                    ),
                ],
            ),
        ),
    );
  }
}

void showToast(String title){
    //弹窗
    Fluttertoast.showToast(
        msg: title,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: AppStyle.colorGreyDark,
        textColor: Colors.white,
        fontSize: 16.0
    );
}
import 'dart:async';
import 'package:fake_alipay/fake_alipay.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/dash_line.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DepositDetailPage extends StatefulWidget {
  final String name;
  final String type;
  const DepositDetailPage({Key key, this.name, this.type}) : super(key: key);

  @override
  _DepositDetailPageState createState() => _DepositDetailPageState();
}

class _DepositDetailPageState extends State<DepositDetailPage>
    with SingleTickerProviderStateMixin {
  List<Widget> _lisWidet = [];
  Map _dataMap = {};
  Map goodsMessage = {};
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool _isLogin = false; //是否登录


  List l1 = []; //价格信息
  List l2 = []; //关联订单
  List l3 = []; //关联订单
  List l4 = []; //仓储信息
  List l5 = []; //出仓收货信息
  List l6 = []; //使用提示

  Alipay alipay = Alipay();
  StreamSubscription<AlipayResp> _pay;
  StreamSubscription<AlipayResp> _auth;

  @override
  void initState() {
    super.initState();
    _pay = alipay.payResp().listen(_listenPay);
    WidgetsBinding bind = WidgetsBinding.instance;
    bind.addPostFrameCallback((callback) {
      //加载数据
      loodData();
    });
  }

   @override
  void dispose() {
    if (_pay != null) {
      _pay.cancel();
    }
    if (_auth != null) {
      _auth.cancel();
    }
    
    super.dispose();
  }
  void _listenPay(AlipayResp resp) {
    String content = 'pay: ${resp.resultStatus} - ${resp.result}';
    print(content);
    
  }

  void _listenAuth(AlipayResp resp) {
    String content = 'pay: ${resp.resultStatus} - ${resp.result}';
    print(content);
    showToast(content);
  }
  //加载数据
  loodData() {
    ApiConfig().depositDetail(widget.name).then((response) {
      if (response == null) {
        return;
      }
      if (response['rspCode'] != '0000') {
        showToast(response['rspDesc']);
        return;
      }

      //获取商品信息 名称图片等
      ApiConfig().goodsDetail(response['comdiId']).then((onValue){
        if(response['rspCode'] != '0000'){
          showToast(response['rspDesc']
          );
          return;
        }
        setState(() {
          goodsMessage = onValue;
        });

      });

        l1.add({'content':(response['buyPrice']??'--').toString(),'title':'买入价格'});
        l1.add({'content':(response['sellPrice']??'--').toString(),'title':'卖出价格'});

        l2.add({'content':response['buyOrderNo']??'--','title':'订单号'});
        l2.add({'content':response['buyTime']??'--','title':'买入时间'});

        l3.add({'content':response['sellOrderNo']??'--','title':'订单号'});
        l3.add({'content':response['sellTime']??'--','title':'卖出时间'});

        l4.add({'content':response['putTime']??'--','title':'入仓时间'});
        l4.add({'content':response['takeTime']??'--','title':'出仓时间'});

        l5.add({'content':response['name']??'--','title':'名字'});
        l5.add({'content':response['phone']??'--','title':'手机号码'});
        l5.add({'content':response['province']??'--','title':'收货地址'});

        String a = response['statusTips'];
        List array = a.split(',');
        l6.addAll(array);

      setState(() {
        _dataMap = response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: mydrawer,
        drawerScrimColor: Colors.transparent,
        key: _scaffoldkey,
        backgroundColor: AppStyle.colorWhite,
        appBar: myappbar(context, true, true, sckey: _scaffoldkey),
        body: _dataMap.length == 0
            ? LoadingDialog(
                //调用对话框
                text: '正在加载...',
              )
            : Container(
              width: double.infinity,
              height: double.infinity,
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _name(context, '我的会员仓'),
                          Container(
                              margin: EdgeInsets.all(
                                  ScreenUtil.getInstance().setHeight(20)),
                              padding: EdgeInsets.all(
                                  ScreenUtil.getInstance().setHeight(20)),
                              color: Color(0xFFF8F2EA),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(
                          ScreenUtil.getInstance().setHeight(20)),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '寄存编号:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFA49685),
                                          ),
                                          // textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Expanded(
                                          child: Container(
                                             padding: EdgeInsets.all(
                          ScreenUtil.getInstance().setHeight(20)),
                                        child: Text(
                                          widget.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFA49685),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ))
                                    ],
                                  ),
                                  SizedBox(
                                    height:
                                        ScreenUtil.getInstance().setHeight(20),
                                  ),
                                  l1.length>0? Container(
                                    padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                                  margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                                  color: Color(0xFFF8F2EA),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    children: <Widget>[
                                     getRow(context, '价格信息'),
                        SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l4.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l4);
                            },
                        )
                                      

                                    ],
                                  ),
                                ):Container(),
                              _dataMap['buyOrderNo'] != null? Container(
                                    padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                                  margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                                  color: Color(0xFFF8F2EA),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    children: <Widget>[
                                      getRow(context, '关联订单'),
                                       SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l4.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l4);
                            },
                        )

                                    ],
                                  ),
                                ):Container(),
                                  _dataMap['sellOrderNo'] != null? Container(
                                    padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                                  margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                                  color: Color(0xFFF8F2EA),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    children: <Widget>[
                                      getRow(context, '关联订单'),
                                      SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l4.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l4);
                            },
                        )

                                    ],
                                  ),
                                ):Container(),
                                l4.length>0? Container(
                                    padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                                  margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                                  color: Color(0xFFF8F2EA),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    children: <Widget>[
                                      getRow(context, '仓储信息'),
                                      SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l4.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l4);
                            },
                        )

                                    ],
                                  ),
                                ):Container(),
                                  _dataMap['phone'] != null? Container(
                                    padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                                  margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                                  color: Color(0xFFF8F2EA),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    children: <Widget>[
                                      getRow(context, '出仓收货信息'),
                                       SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l4.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l4);
                            },
                        )

                                    ],
                                  ),
                                ):Container(),

                                  widget.type == '1'
                                      ? SizedBox(
                                          height: ScreenUtil.getInstance()
                                              .setHeight(20),
                                        )
                                      : Container(),
                                  widget.type == '1'
                                      ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          RaisedButton(
                                           color: AppStyle.colorWhite,
                            shape:new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)) ,
                                          child: Container(
                              alignment: Alignment.center,
                              width: ScreenUtil.getInstance().setHeight(160),
                              child:  Text(
                              '    出售    ',
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(28),
                                color: AppStyle.colorPrimary,
                                
                              ),
                              
                            ),
                            ),
                                          onPressed: () {
                                            //出售
                                             UserInfoCache().setMapInfo(key: UserInfoCache.sellInfo, map: {
                                                   'id':_dataMap['comdiId'],
                                                   'selectSize':_dataMap['sizeId'],
                                                   'sizeValue':_dataMap['sizeName'],
                                                   'goodName':_dataMap['comdiName'],
                                                   'sizeId':_dataMap['sizeId'],
                                               });
                                             String id = _dataMap['comdiId'];
                                             Application.router.navigateTo(context, '${Routes.sellTips}?id=$id&type=${'2'}',transition: TransitionType.native);
                                          },
                                        ),
                                        SizedBox(width: ScreenUtil.getInstance().setHeight(40),),
                                          RaisedButton(
                                          color: AppStyle.colorWhite,
                            shape:new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)) ,
                                          child: Container(
                                             alignment: Alignment.center,
                              width: ScreenUtil.getInstance().setHeight(160),
                                            child: Text(
                                            '    出仓    ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:  AppStyle.colorPrimary,
                                            ),
                                          ),
                                          ),
                                          onPressed: () {
                                            //出仓
                                          Application.router.navigateTo(context, '${Routes.GoingStarehousePage}?number=${widget.name}',transition: TransitionType.native);

                                          },
                                        )
                                        ],
                                      )
                                      : Container(),
                                  SizedBox(
                                    height:
                                        ScreenUtil.getInstance().setHeight(20),
                                  ),
                                  l6.length>0? Container(
                                    padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                                    margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                                    color: Color(0xFFF8F2EA),
                                    child: ListView(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      children: <Widget>[
                                        getRow(context, '使用提示'),
                                        SizedBox(height: 20),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          itemCount: l6.length,
                                          itemBuilder: (BuildContext context, int position) {
                                            return getMissageRow(context, position,l6);
                                          },
                                        )

                                      ],
                                    ),
                                  ):Container(),
                                ],
                              )),
                          Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil.getInstance().setHeight(20),
                        right: ScreenUtil.getInstance().setHeight(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                       
                          Container(
                            width: 120,
                            height: 120,
                            child: _dataMap.length == 0?Container():Image.network(goodsMessage['titleImgUrl']??''),
                          ),
                        
                        SizedBox(
                          width: ScreenUtil.getInstance().setHeight(10),
                        ),
                        Expanded(
                          child: Container(
                            height: 120,
                            color: Color(0xFFF8F2EA),
                            padding: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(10),right: ScreenUtil.getInstance().setHeight(10)),
                            child: Column(
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(50),left: ScreenUtil.getInstance().setHeight(40),right: ScreenUtil.getInstance().setHeight(10)),
                                child: Text(                                                                                                                                                                                                                                    
                                  '商品名称:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFA49685),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 10,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width:  ScreenUtil.getInstance().setHeight(10),),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(50),right: ScreenUtil.getInstance().setHeight(10)),
                                child: Text(
                                  goodsMessage['title']??'--',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFA49685),
                                  ),
                                  maxLines: 10,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              )
                                  
                                ],
                              ),
                              // SizedBox(
                              //   height: ScreenUtil.getInstance().setHeight(10),
                              // ),
                              Expanded(
                                child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                  margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(10),left: ScreenUtil.getInstance().setHeight(40),right: ScreenUtil.getInstance().setHeight(10)),

                                child: Text(
                                  '交易尺码:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFA49685),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 10,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width:  ScreenUtil.getInstance().setHeight(10),),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(14),right: ScreenUtil.getInstance().setHeight(10)),
                                child: Text(
                                  (_dataMap['sizeName']??0).toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFA49685),
                                  ),
                                ),
                              ),
                              )
                              
                                ],
                              ),
                              )
                            ],
                          ),
                          )
                        ),
                        
                      ],
                    ),
                  ),
                          Container(
                            // color: AppStyle.colorBackground,
                            padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(20)),
                            // margin: EdgeInsets.only(bottom: 10),

                            child: _dataMap['name'] == null
                                ? Container()
                                : Container(
                                  padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(60)),
                              color: Color(0xFFF8F2EA),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                               getRow(context, '收货地址'),
                                              SizedBox(height: 3,),
                                              Container(
                                                padding: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(40),right: ScreenUtil.getInstance().setHeight(40),top: ScreenUtil.getInstance().setHeight(40)),
                                                child: Row(
                                                  children: <Widget>[
                                                     
                                                    Container(
                                                      child: Text(
                                                          _dataMap['name'] ??
                                                              '--',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color(0xFFA49685),)),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      child: Text(
                                                          _dataMap['phone'] ??
                                                              '--',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color(0xFFA49685),)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                padding: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(40),right: ScreenUtil.getInstance().setHeight(40)),

                                                child: Text(
                                                  _dataMap['province'] +
                                                      '  ' +
                                                      _dataMap['city'] +
                                                      '  ' +
                                                      _dataMap['district'] +
                                                      '  ' +
                                                      _dataMap['addr'],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFFA49685),),
                                                  maxLines: 4,
                                                ),
                                              ),
                                              SizedBox(height: ScreenUtil.getInstance().setHeight(40),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                          ),
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
              ));
  }

  Widget getRow(BuildContext context, String name){
 return Row(
      children: <Widget>[
        Container(
          width: ScreenUtil.getInstance().setHeight(15),
          height: ScreenUtil.getInstance().setHeight(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(10.0))),
            border: new Border.all(color: Color(0xFFA49685), width: 1),
        ),
        ),
        SizedBox(width: ScreenUtil.getInstance().setHeight(20),),
        Container(
          width: ScreenUtil.getInstance().setHeight(180),
          child: Text(
            name,
            style: TextStyle(
                fontSize: ScreenUtil.getInstance().setHeight(24),
                color: Color(0xFFA49685),
                fontWeight: FontWeight.w500
              ),
          ),
        ),
        Expanded(
          child: Container(
          child: MySeparator(color: Color(0xFFA49685),height: 2,),
        ),
        ),
        Container(
          width: ScreenUtil.getInstance().setHeight(15),
          height: ScreenUtil.getInstance().setHeight(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(10.0))),
            border: new Border.all(color: Color(0xFFA49685), width: 1),
        ),
        ),
      ],
    );
}
  Widget getMissageRow(BuildContext context,int position, List list){
    String a = list[position];
    return Container(
      padding: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),top: 4,right: ScreenUtil.getInstance().setHeight(20)),
            width: 10,
            height: 4,
            color: Color(0xFFA49685),
      ),

          Expanded(
            flex: 20,
            child: Container(
              margin: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(20)),
              child: Text(
                a,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA49685),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget getOrderRow(BuildContext context,int position, List list){
    Map a = list[position];
    return Container(
      padding: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(10)),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.only(left:  ScreenUtil.getInstance().setHeight(20)),
              child: Text(
                a['title'],
                style: TextStyle(
                 fontSize: 14,
              color:Color(0xFFA49685),
              fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              child: Text(
                a['content'],
                style: TextStyle(
                 fontSize: 14,
              color:Color(0xFFA49685),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//我的购买? 我的出售?
  Widget _name(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(
          right: ScreenUtil.getInstance().setHeight(20),
          left: ScreenUtil.getInstance().setHeight(20),
          bottom: ScreenUtil.getInstance().setHeight(20),
          top: ScreenUtil.getInstance().setHeight(40)),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 20,
          color: AppStyle.colorPrimary,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  //名称
  Widget _title(BuildContext context, String title, List<Map> list) {
    _lisWidet.add(
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppStyle.colorPrimary,
        ),
      ),
    );

    List<Widget> all = list.map((Map dic) {
      return Container(
          child: Expanded(
        flex: 1,
        child: Row(
          children: <Widget>[
            Container(
              child: Text(
                dic['name'] + ':',
                style: TextStyle(
                  fontSize: 14,
                  color: AppStyle.colorPrimary,
                ),
              ),
            ),
            Container(
              child: Text(
                dic['number'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppStyle.colorPrimary,
                ),
              ),
            )
          ],
        ),
      ));
    }).toList();
    _lisWidet.addAll(all);

    return Container(child: Column(children: _lisWidet));
  }
}

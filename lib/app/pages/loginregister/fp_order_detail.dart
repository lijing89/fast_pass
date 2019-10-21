import 'dart:async';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/dash_line.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/fp_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class OrderDetailPage extends StatefulWidget {
  final String name;
  final String type;
  const OrderDetailPage({Key key, this.name, this.type}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with SingleTickerProviderStateMixin {
  List<Widget> _lisWidet = [];
  Map _dataMap = {};
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool _isLogin = false; //是否登录

  String time = '';
  String timeMsg = '';

  int day = 0;

  Timer timer;
  static const duration = const Duration(seconds: 1);
  int fen = 0;
  int miao = 0;
  int shi =0;
  String _buttonString = '    免责取消    ';
  //订单详情分类
  List l1 = []; //交易信息
  List l2 = []; //付款信息
  List l3 = []; //违约扣款
  List l4 = []; //补偿金
  List l5 = []; //收款信息
  List l6 = []; //订单详情
  List l7 = [];

  List _historyList = [];
  bool _openHistory = false;

   ///快递单号
  String expressPostNumber = '';
  Map _itemAddress = {};
  TextEditingController _expressPostNumberController;

  AnimationController _animationController;
  String get hoursString {
    Duration duration = _animationController.duration * _animationController.value;
    return '${(duration.inHours)..toString().padLeft(2, '0')}';
  }

  String get minutesString {
    Duration duration = _animationController.duration * _animationController.value;
    return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  String get secondsString {
    Duration duration = _animationController.duration * _animationController.value;
    return '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose(){
    super.dispose();
    _animationController.dispose();
    timer?.cancel();

  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(hours: 0, minutes: 0, seconds: 0));
    _animationController.reverse(from: _animationController.value == 0.0 ? 1.0 : _animationController.value);

    //加载数据
      Timer(Duration(milliseconds: 500),(){
      loodData();
    });
  }
  //正计时方法
  void handleTick() {
    miao = miao + 1;
    if(miao >60){
      miao = 00;
      fen = fen + 1;
    }
    if(fen > 60){
      fen = 00;
      shi = shi +1;
    }
    if(shi > 23){
      shi = 00;
      day = day + 1;
    }
      setState(() {

      });
  }
  //加载数据
  loodData(){
    ApiConfig().buySellDetail(widget.name).then((response){
      if(response == null){
        return;
      }
        if(response['rspCode'] != '0000'){
            Fluttertoast.showToast(msg:response['rspDesc'],
            toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
            );
            return;
        }
        if(response['timerDirection'] == 1){
          //正计时
          var timerBaselineStamp =  DateTime.fromMillisecondsSinceEpoch(response['timerBaselineStamp']);
          var timerSysTimeStamp =  DateTime.fromMillisecondsSinceEpoch(response['timerSysTimeStamp']);
          var cha =  timerSysTimeStamp.difference(timerBaselineStamp);
          String timeString = cha.toString();
          if(cha.toString().startsWith('-')){
            timeString = timeString.substring(1);
          }
          List timeArr = timeString.split('.');
          List timeArr1 = timeArr[0].toString().split(':');


          day = int.parse(timeArr1[0]) ~/ 24;
          if(day > 0){
            int b = int.parse(timeArr1[0]) % 24;
            timeArr1[0] = b.toString();
          }
          shi = int.parse(timeArr1[0]);
          fen = int.parse(timeArr1[1]);
          miao = int.parse(timeArr1[2]);
          if(timer == null){
            timer = Timer.periodic(duration, (Timer t){
              handleTick();
            });
          }

        }else if(response['timerDirection'] == 2 && response['timerBaselineStamp'] != null && response['timerSysTimeStamp'] != null){

          //倒计时
          var timerBaselineStamp =  DateTime.fromMillisecondsSinceEpoch(response['timerBaselineStamp']);
          var timerSysTimeStamp =  DateTime.fromMillisecondsSinceEpoch(response['timerSysTimeStamp']);
          if(timerSysTimeStamp.compareTo(timerBaselineStamp) == 1){

          }

          if(widget.type == '1'){
            timeMsg = '免责取消倒计时';
          }else{
            timeMsg = '确认发货倒计时';
          }
          var cha =  timerBaselineStamp.difference(timerSysTimeStamp);
          String timeString = cha.toString();
          if(cha.toString().startsWith('-')){
            timeString = timeString.substring(1);
          }
          List timeArr = timeString.split('.');
          List timeArr1 = timeArr[0].toString().split(':');


          day = int.parse(timeArr1[0]) ~/ 24;
          if(day > 0){
            timeArr1[0] = (int.parse(timeArr1[0]) % 24).toString();
          }
          int hours = int.parse(timeArr1[0]);
          int minutes = int.parse(timeArr1[1]);
          int seconds = int.parse(timeArr1[2]);
          _animationController.duration =  Duration(hours: hours, minutes: minutes, seconds: seconds);
          _animationController.reverse(from: _animationController.value == 0.0 ? 1.0 : _animationController.value);

        }else{
          //不显示

        }

           l1.addAll(response['tradeInfo']??[]);
           l2.addAll(response['orderInfo']??[]);
           l3.addAll(response['breakInfo']??[]);
           l4.addAll(response['addInfo']??[]);
           l5.addAll(response['payInfo']??[]);
           l6.addAll(response['tradeTips']??[]);

        //获取商品信息 名称图片等
        ApiConfig().goodsDetail(response['comdiId'].toString()).then((onValue){
          if(onValue == null){
            return;
          }
          if(onValue['rspCode'] != '0000'){
            Fluttertoast.showToast(msg:onValue['rspDesc'],
            toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
            );
            return;
        }

        response['title'] = onValue['title']??'--';
        response['titleImgUrl'] = onValue['titleImgUrl']??'--';
//           l1.addAll(response['tradeInfo']??[]);
//           l2.addAll(response['orderInfo']??[]);
//           l3.addAll(response['breakInfo']??[]);
//           l4.addAll(response['addInfo']??[]);
//           l5.addAll(response['payInfo']??[]);
//           l6.addAll(response['tradeTips']??[]);

           switch(response['allowCancelOrder']){
                case 0:
                  _buttonString = '';
                break;
                case 1:
                  _buttonString = '免责取消';

                break;
                case 2:
                  _buttonString = '违约取消';
                break;
                case 3:
                if(widget.type == '1'){
                   _buttonString = '立即付款';
                }else{
                   _buttonString = '';
                }
                break;
                case 4:
                if(widget.type == '1'){
                  _buttonString = '';
                }else{
                  _buttonString = '确认发货';
                }
                break;
                case 5:
                  _buttonString = '';
                break;
                case 6:
                  if(widget.type == '1'){
                  _buttonString = '';
                  }else{
//                    _buttonString = '修改运单号';
                    _buttonString = '';
                  }
                break;
              }
         setState(() {
            _dataMap= response;
          });

          ApiConfig().makeEnquiriesSize(response['sizeId'].toString()).then((onValueSize) {
            if (onValue == null) {
              return;
            }
            if (onValue['rspCode'] != '0000') {
              Fluttertoast.showToast(msg:onValue['rspDesc'],
              toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
              );
              return;
            }
            setState(() {
              _dataMap['sizeName'] = onValueSize['yardEur'];

            });
          });
        });
    });
  }


  @override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
        UserInfoCache().getMapInfo(key: UserInfoCache.buyInfo).then((onValue){
          print(onValue.toString());
          if(onValue == null || onValue.length ==0 ){
            showCupertinoDialog(context);
            return;
          }
            _itemAddress = onValue;
          _expressPostNumberController = TextEditingController(text: expressPostNumber);
          showCupertinoDialog(context);
          UserInfoCache().setMapInfo(key: UserInfoCache.buyInfo, map: {});
        });
    }
  }
  ///正计时widget
  Widget _calculateByTime() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          day >0?ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              child: Text(
                '${day.toString()}${'天'}',
                style: TextStyle(
                  color: Color(0xFFA49685),
                  fontSize: ScreenUtil.getInstance().setSp(32)
                ),
              ),
            ),
          ):Container(),
          day >0?SizedBox(width: 10):Container(),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              child: Text(
              shi.toString().length==2?shi.toString():'${'0'}${shi.toString()}',

                style: TextStyle(
                  color: Color(0xFFA49685),
                  fontSize: ScreenUtil.getInstance().setSp(32)
                ),
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              color: Color(0xFFA49685),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              child: Text(
                fen.toString().length==2?fen.toString():'${'0'}${fen.toString()}',
                style: TextStyle(
                   color: Color(0xFFA49685),
                  fontSize: ScreenUtil.getInstance().setSp(32)
                ),
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              color: Color(0xFFA49685),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              child: Text(
                miao.toString().length==2?miao.toString():'${'0'}${miao.toString()}',
                style: TextStyle(
                   color: Color(0xFFA49685),
                  fontSize: ScreenUtil.getInstance().setSp(32)
                ),
              ),
            ),
          )
        ],
      )
    );

  }

//倒计时widget
  Widget _buildRecommendedCard() {
    if(hoursString == '0' && minutesString == '0' && secondsString == '0' && day == 0){
      loodData();
      return Container();
    }
    return Container(
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (_, Widget child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                 day >0?ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      child: Text(
                        '${day.toString()}${'天'}',
                        style: TextStyle(
                            color: Color(0xFFA49685),
                            fontSize: ScreenUtil.getInstance().setSp(32)
                        ),
                      ),
                    ),
                  ):Container(),
                  day >0?SizedBox(width: 10):Container(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      child: Text(
                        hoursString.length==2?hoursString:'${'0'}$hoursString',
                        style: TextStyle(
                            color: Color(0xFFA49685),
                            fontSize: ScreenUtil.getInstance().setSp(32)
                        ),
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      color:Color(0xFFA49685),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      child: Text(
                        minutesString.length==2?minutesString:'${'0'}$minutesString',
                        style: TextStyle(
                            color: Color(0xFFA49685),
                            fontSize: ScreenUtil.getInstance().setSp(32)
                        ),
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      color: Color(0xFFA49685),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      child: Text(
              secondsString.length==2?secondsString:'${'0'}$secondsString',
                        style: TextStyle(
                            color: Color(0xFFA49685),
                            fontSize: ScreenUtil.getInstance().setSp(32)
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
      );

  }

  cancelOrder(){
    //取消订单
      showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
            return new LoadingDialog( //调用对话框
                text: '正在申请取消订单...',
            );
        });
      ApiConfig().cancelOrder(widget.name).then((response){
        Navigator.pop(context);
      if(response == null){
        return;
      }
        if(response['rspCode'] != '0000'){
            Fluttertoast.showToast(msg:response['rspDesc'],
            toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
            );
            return;
        }
        loodData();
        Fluttertoast.showToast(msg:'交易已取消',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      });
  }
  //按钮点击事件
  selectedButton(BuildContext context){
    switch(_dataMap['allowCancelOrder']){
      case 0:

      break;
      case 1:
      fpshowDiaLog(context, '', '确定取消交易吗?', cancelOrder);
      break;
      case 2:
      fpshowDiaLog(context, '', '确定违约取消交易吗?', cancelOrder);
      break;
      case 3:
      Application.router.navigateTo(context,'${Routes.buyPay}?id=${_dataMap['comdiId']}&orderId=${_dataMap['orderNo']}',transition: TransitionType.native);
      break;
      case 4:
        getUserMessage();
      break;
      case 5:
        
      break;
      case 6:
        changeNumber(context);
      break;
    }
  }
  //获取收件地址
  getUserMessage(){
    ApiConfig().getAccount().then((onValue){
      if(onValue == null){return;}
      if(onValue['rspCode'] != '0000'){
        Fluttertoast.showToast(msg:onValue['rspDesc'],
        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
        );
        return;
      }
      UserInfoCache().setUserInfo(userInfo: onValue);
      UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
      List fhdz = [];
      for (var item in onValue['addrs']??[]) {
        if(item['type'] == '2'){
          fhdz.add(item);
        }
      }
      if(fhdz.length > 0){
        _itemAddress = fhdz[0];
      }
      
      if(mounted){
        _expressPostNumberController = TextEditingController(text: expressPostNumber);
        showCupertinoDialog(context);
      }
    });

  }

  changeNumber(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(

          content: Card(
            elevation: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text('修改运单号'),
                    ),
                    Expanded(flex: 1, child: Container(),),
                    IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.blue,
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        })
                  ],
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: '请顺丰运单号',
                        filled: true,
                        fillColor: Colors.grey.shade50),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }
  
 void showCupertinoDialog(BuildContext context) {
    showDialog(
  // 传入 context
  context: context,
  // 构建 Dialog 的视图
  builder: (_) => Scaffold(
    backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppStyle.colorWhite,
                border: Border.all(
                  width: 1,
                  color: AppStyle.colorPrimary
                  
                ),
              ),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                          padding: EdgeInsets.only(left: 10),
                        child: Text(
                          '确认发货',
                          style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(30)),
                          ),
                      ),
                      Expanded(flex: 1, child: Container(),),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.blue,
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        })
                      ],
                      ),
                      
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 60,
                        child: TextField(
                          controller: _expressPostNumberController,
                        decoration: InputDecoration(
                          labelText: '顺丰运单号',
                          labelStyle: TextStyle(
                            color: Colors.pink,
                            fontSize: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.pink,
                            ),
                          ),
                        ),
                          onChanged: (value){
                            expressPostNumber = value;
                          },
                      )
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 14),
                        child: Text('发货地址:',
                        style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(26)),
                          ),
                      ),
                      Expanded(flex: 1, child: Container(),),
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text('可能用于货品退回,请准确填写',style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(26)),
                          ),
                      ),
                      ],
                      ),
            _itemAddress.length >0? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  border: Border.all(
                    color: AppStyle.colorBackground,
                    width: 1,
                  )
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: GestureDetector(
                      onTap: (){
                      },
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text(_itemAddress['name'],style: TextStyle(fontSize: 18,color: AppStyle.colorPrimary)),
                                ),
                                SizedBox(width: 10,),
                                Container(
                                  child: Text(_itemAddress['phone'],style: TextStyle(fontSize: 14,color: AppStyle.colorPrimary)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Text(_itemAddress['province']+'  '+_itemAddress['city']+'  '+_itemAddress['district']+'  '+_itemAddress['addr'],style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary),maxLines: 4,),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 0.8,height: 40,color: AppStyle.colorBackground,),
                  Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          child: new Text('修改'),
                          onPressed: () {

                            Navigator.pop(context);
                            Application.router.navigateTo(context, '${Routes.AddressManagePage}?number=${'2'}',transition: TransitionType.native);

                          },
                        ),
                      )
                  )
                ],
              ),
            ):Center(
              child: Container(
                margin: EdgeInsets.only(top: 20,bottom: 50),
                width: 200,
                height: 40,
                child: RaisedButton(
                           color: AppStyle.colorWhite,
                            shape:new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)) ,
                            child: Container(
                              alignment: Alignment.center,
                              width: ScreenUtil.getInstance().setHeight(200),
                              child:  Text(
                              '添加发货地址',
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(28),
                                color: AppStyle.colorPrimary,
                                
                              ),
                              ),
                            ),
                            elevation: 2.0,/// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                  onPressed: (){
                    Navigator.pop(context);
                    Application.router.navigateTo(context, '${Routes.AddressManagePage}?number=${'2'}',transition: TransitionType.native);
                  },
                ),
              ),
            ),
                      _itemAddress.length >0?Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 20,bottom: 50),
                        width: 200,
                        height: 40,
                        child: RaisedButton(
                           color: AppStyle.colorWhite,
                            shape:new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)) ,
                            child: Container(
                              alignment: Alignment.center,
                              width: ScreenUtil.getInstance().setHeight(200),
                              child:  Text(
                              '确定',
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(28),
                                color: AppStyle.colorPrimary,
                                
                              ),
                              ),
                            ),
                            elevation: 2.0,// 下部的影子，该值越大，影子越清楚，为0时，不会有影子，和RaisedButton是一样的
                            onPressed: (){
                            //确认发货并刷新数据
                              surdSend(context);
                            },
                        ),
                    ),
                      ):Container()
                      
                    ],
                  ),
            )
          ],
        ),
        )
      ),
);
  }

  ///确认发货网络请求
void surdSend(BuildContext context){
    if(expressPostNumber.length != 12){
      Fluttertoast.showToast(msg:'请正确填写顺丰单号',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }

    ApiConfig().sureSend(_dataMap['orderNo'], expressPostNumber, _itemAddress['province'], _itemAddress['city'], _itemAddress['district'], _itemAddress['addr'], _itemAddress['name'], _itemAddress['phone']).then((onValue){
      if(onValue == null){
        return;
      }
      if(onValue['rspCode'] != '0000'){
        Fluttertoast.showToast(msg:onValue['rspDesc'],
        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
        );
        return;
      }
      Navigator.pop(context);
      Fluttertoast.showToast(msg:'已确认发货',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      loodData();
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: mydrawer,
        key: _scaffoldkey,
        drawerScrimColor: Colors.transparent,
        backgroundColor: AppStyle.colorWhite,
        appBar: myappbar(context, true, false, sckey: _scaffoldkey),
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
              Container(
                child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _name(context,widget.type == '1'?'我的购买订单':'我的出售订单'),
                 !_openHistory?Container(
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
                              '订单号:'+widget.name,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFA49685),
                              ),
                              // textAlign: TextAlign.left,
                            ),
                          ),
                      Expanded(
                        child: Container(),
                      ),
                         Container(

                           margin: EdgeInsets.only(top: 20),
                           alignment: Alignment.center,
                          width: 120,
                          height:40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setHeight(37)),
                            border: new Border.all(color: Color(0xFFB7AB9B), width: 1),
                            color: Colors.white
                          ),
                          child: GestureDetector(
                          onTap: () {
                            showDialog<Null>(
                              context: context, //BuildContext对象
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                  return new LoadingDialog( //调用对话框
                                      text: '正在加载...',
                                  );
                              });
                            //查看所有记录
                            ApiConfig().typeOrderHistory(_dataMap['orderNo']).then((onValue){
                              Navigator.pop(context);
                              if(onValue == null){return;}
                              if(onValue['rspCode'] != '0000'){
                                    Fluttertoast.showToast(msg:onValue['rspDesc'],toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                                    return;
                                }
                                _historyList = onValue['list']??[];
                                if(_historyList == []){
                                  Fluttertoast.showToast(msg:'无记录',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                                  return;
                                }
                                setState(() {
                                  _openHistory = true;
                                });
                            });
                          },
                          child: Container(
                            child: Text(
                              '查看状态记录',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFA49685),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          )
                        ),
                        )
                    ],
                  ),
                          
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: ScreenUtil.screenWidthDp/3,
                                  child:  Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _dataMap['prevStatus'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFA49685),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.getInstance()
                                            .setHeight(40),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _dataMap['currentStatus'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppStyle.colorPrimary,
                                              fontWeight: FontWeight.w500
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.getInstance()
                                            .setHeight(40),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _dataMap['nextStatus'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFA49685),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: ScreenUtil.getInstance().setHeight(20),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                    width: 20,
                                    height: 110,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.center,
                                          child: MyVerticalSeparator(color: Color(0xFFA49685),height: 3,width: 1,),
                                        ),
                                        Container(
                                          alignment: Alignment.topCenter,
                                          width: 20,
                                          height: 20,
                                          child: Container(
                                            child: Image(image: AssetImage(AssetUtil.image('orderread_icon.png')),fit: BoxFit.fitWidth,)
                                          )
                                        ),
                                        Container(

                                          width: 20,
                                          height: 20,
                                          margin: EdgeInsets.only(top: 45),
                                          child:  Image(image: AssetImage(AssetUtil.image('ordermessage_icon.png')),fit: BoxFit.fitWidth,)
                                          
                                        ),
                                        Container(
                                           margin: EdgeInsets.only(top: 100,left:  5),
                                            width: 10,
                                            height: 10,
                                            
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF8F2EA),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            border: new Border.all(color: Color(0xFFA49685), width: 1),
                                          ),
                                            ),
                                      ],
                                    )
                                    ),
                                SizedBox(
                                  width: ScreenUtil.getInstance().setHeight(20),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 50),
                                  width: ScreenUtil.screenWidthDp/3,
                                  child: Text(
                                    _dataMap['currentStatusInfo'],
                                    style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(24),
                                      color: Color(0xFFA49685),
                                    ),
                                    maxLines: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          timeMsg != ''?Container(
                            child: Text(
                              timeMsg,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFA49685),
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 10,
                            ),
                          ):Container(),
                          SizedBox(height:20),
                      _dataMap['timerDirection'] == 2 ? Center(
                            child: _buildRecommendedCard(),
                          ):Container(),
                          _dataMap['timerDirection'] == 1 ? Center(
                            child: _calculateByTime(),
                          ):Container(),
                          SizedBox(
                            height: 10,
                          ),
                          _buttonString !=''? GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(40.0))),
                                            border: new Border.all(color: Color(0xFFA49685), width: 1),
                                            color: Colors.white,
                                          ),
                              alignment: Alignment.center,
                              width: 120,
                              height: 40,
                              child:  Text(
                              _buttonString,
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(28),
                                color: AppStyle.colorPrimary,
                                fontWeight: FontWeight.w500
                              ),
                              
                            ),
                            ),
                            onTap: () {
                               selectedButton(context);
                            },
                          ):Container(),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(20),
                          ),
                        ],
                      )
                      ):Container(
                      margin: EdgeInsets.all(
                          10),
                      padding: EdgeInsets.all(
                          10),
                      decoration: BoxDecoration(
                        border: new Border.all(color: Color(0xFFF8F2EA), width: 5),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                       Container(
                         padding: EdgeInsets.all(
                          10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '状态记录',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFA49685),
                              ),
                              // textAlign: TextAlign.left,
                            ),
                          ),
                      Expanded(
                        child: Container(),
                      ),
                         Container(
                           alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          margin: EdgeInsets.only(right: 20,top: 10),
                          child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _openHistory = false;
                            });
                          },
                          child: Container(
                            child: Icon(Icons.close,color: AppStyle.colorPrimary,)
                          )
                        ),
                        )
                    ],
                  ),
                          
                          SizedBox(
                                  height: 10,
                                ),
                          Container(
                            alignment: Alignment.topCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(top: 2),
                                  width: ScreenUtil.screenWidthDp/3,
                                  child:  ListView.builder(
                                    shrinkWrap:true,
                                    physics:NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                    itemCount: _historyList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                    Map dic = _historyList[index];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          dic['title'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFA49685),
                                          ),
                                        ),
                                      ),
                                     index != _historyList.length-1? SizedBox(
                                        height: 20,
                                      ):Container()
                                      ],
                                    );
                                  },
                                    
                                  )
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                
                                Container(
                                  alignment: Alignment.topCenter,
                                    width: 20,
                                    height: 50*(double.parse((_historyList.length-1).toString())),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(top: 4),
                                          alignment: Alignment.center,
                                          child: MyVerticalSeparator(color: Color(0xFFA49685),height: 3,width: 1,),
                                        ),
                                        Container(
                                          width: 20,
                                          height: 20,
                                          child: Container(
                                            child: Image(image: AssetImage(AssetUtil.image('orderread_icon.png')),fit: BoxFit.fitWidth,)
                                          )
                                        ),
                                      ],
                                    )
                                    ),
                                SizedBox(
                                  width: 10,
                                ),

                                Container(
                                  padding: EdgeInsets.only(top: 3),
                                  width: ScreenUtil.screenWidthDp/3,
                                  child:  ListView.builder(
                                    shrinkWrap:true,
                                    physics:NeverScrollableScrollPhysics(),
                                    itemCount: _historyList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                    Map dic = _historyList[index];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                        margin: EdgeInsets.only(bottom: 2),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          dic['time']??'',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFA49685),
                                          ),
                                        ),
                                      ),
                                     index != _historyList.length-1? SizedBox(
                                        height: 20,
                                      ):Container()
                                      ],
                                    );
                                  },
                                    
                                  )
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      )
                      ),
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
                            child: _dataMap.length == 0?Container():Image.network(_dataMap['titleImgUrl'])
                          ),
                        SizedBox(
                          width: ScreenUtil.getInstance().setHeight(10),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            height: 120,
                            color: Color(0xFFF8F2EA),
                            padding: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(10),right: ScreenUtil.getInstance().setHeight(10)),
                            child: Column(
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                margin: EdgeInsets.only(top: 25,left: ScreenUtil.getInstance().setHeight(40),right: ScreenUtil.getInstance().setHeight(10)),
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
                                margin: EdgeInsets.only(top: 25,right: ScreenUtil.getInstance().setHeight(10)),
                                child: Text(
                                  _dataMap['title']??'--',
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
                  l1.length>0? Container(
                    padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(60)),
                    margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                    color: Color(0xFFF8F2EA),
                    child: ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: <Widget>[
                        getRow(context, '交易信息'),
                        SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l1.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l1);
                            },
                        ),
                      ],
                    ),
                  ):Container(),
                  l2.length>0? Container(
                      padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                    margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                    color: Color(0xFFF8F2EA),
                    child: ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: <Widget>[
                        getRow(context, '订单详情'),
                        SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l2.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l2);
                            },
                        )

                      ],
                    ),
                  ):Container(),
                  l3.length>0? Container(
                      padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                    margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                    color: Color(0xFFF8F2EA),
                    child: ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: <Widget>[
                        getRow(context, '违约信息'),
                       SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l3.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l3);
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
                        getRow(context, '收货地址'),
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
                  l5.length>0? Container(
                      padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                    margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                    color: Color(0xFFF8F2EA),
                    child: ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: <Widget>[
                        getRow(context, '付款信息'),
                        SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l5.length,
                            itemBuilder: (BuildContext context, int position) {
                              return getOrderRow(context, position,l5);
                            },
                        )

                      ],
                    ),
                  ):Container(),
                  l6.length>0? Container(
                     padding: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(20)),
                    margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),right: ScreenUtil.getInstance().setHeight(20)),
                    color: Color(0xFFF8F2EA),
                    child: ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: <Widget>[
                        getRow(context, '交易提示'),
                        SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: l6.length,
                            itemBuilder: (BuildContext context, int position) {
                              return tradePrompt(context, position,l6);
                            },
                        ),
                        SizedBox(height: ScreenUtil.getInstance().setHeight(100),)

                      ],
                    ),
                  ):Container(),
                ],
              ),
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
        )
        );
  }

///交易提示
Widget tradePrompt(BuildContext context,int position, List list){
  Map a = list[position];

  return Container(
    padding: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(10)),
    margin: EdgeInsets.only(bottom: 15),
    child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            // padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(20)),
            margin: EdgeInsets.only(left:ScreenUtil.getInstance().setHeight(20),top: 4,right: ScreenUtil.getInstance().setHeight(20)),
            width: 10,
            height: 4,
            color: Color(0xFFA49685),
      ),
      Expanded(
        child: Container(
        child: Text(
          a['content'],
          style: TextStyle(
              fontSize: 14,
              color: Color(0xFFA49685),
              
            ),
            softWrap: true, 
        ),
      ),
      )
        ],
      ),
  );
}

  Widget getMissageRow(BuildContext context,int position, List list){
    String a = list[position];
    return Container(
      padding: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Container(
                color: Color(0xFFA49685),
                width: ScreenUtil.getInstance().setHeight(10),
                height: ScreenUtil.getInstance().setHeight(5),
              ),
            ),
          ),

          Expanded(
            flex: 20,
            child: Container(
              margin: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(20)),
              child: Text(
                a,
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setHeight(28),
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
          a['content']??'--',
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
          width: ScreenUtil.getInstance().setHeight(140),
          child: Text(
            name,
            style: TextStyle(
                fontSize: 14,
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

//我的购买? 我的出售?
  Widget _name(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(right: ScreenUtil.getInstance().setHeight(20),left: ScreenUtil.getInstance().setHeight(20),bottom: ScreenUtil.getInstance().setHeight(20),top: ScreenUtil.getInstance().setHeight(40)),
      child: Text(
              name,
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(44),
                color: AppStyle.colorPrimary,
                fontWeight: FontWeight.w600,
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




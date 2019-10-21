import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/model/assets_model_entity.dart';

class AssetsIndexPage extends StatefulWidget {
  @override
  _AssetsIndexPageState createState() => _AssetsIndexPageState();
}

class _AssetsIndexPageState extends State<AssetsIndexPage> {

  String _totalValue = '0',_enableValue = '0',_ussAddress;
  String _ussNum = '0',_ussPrice = '0',_ussTotal = '0';
  String _btcNum = '0',_btcPrice = '0',_btcTotal = '0';

  AssetsModelEntity _assetsModel;

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();

  void setViewData(AssetsModelEntity model){
    double btc = double.parse(model.message.btc);
    double btcPrice = double.parse(model.message.btcPrice);
    double ussTwo = double.parse(model.message.ussTwo);
    double ussOne = double.parse(model.message.ussOne);
    double ussPrice = double.parse(model.message.ussPrice);
    double big = double.parse(model.message.big);
    _totalValue = ((ussOne + ussTwo) * ussPrice * big).toStringAsFixed(2);
    _enableValue = (btc * btcPrice).toStringAsFixed(2);
    _ussNum = (ussOne + ussTwo).toString();
    _ussPrice = ussPrice.toString();
    _ussTotal = ((ussOne + ussTwo) * ussPrice * big).toStringAsFixed(2);
    _btcNum = btc.toString();
    UserInfoCache().saveInfo(key: UserInfoCache.btcNumber,value: _btcNum);
    _btcPrice = btcPrice.toString();
    _btcTotal = (btc * btcPrice).toStringAsFixed(2);
    _ussAddress = model.message.address;
  }

  Future refreshAssetsView()async{

//    //显示加载动画
//    showDialog<Null>(
//        context: context, //BuildContext对象
//        barrierDismissible: false,
//        builder: (BuildContext context) {
//          return new LoadingDialog( //调用对话框
//            text: '正在获取详情...',
//          );
//        }
//    );

    UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

      //刷新uss状态
      HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.refreshUssUrl}').then((res){});

      //请求网络数据
      HttpUtil().get(
        '${ApiConfig.baseUrl}${ApiConfig.assetsUrl}',
      ).then((response){
//        print(response.toString());
//        //退出加载动画
//        Navigator.pop(context); //关闭对话框
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
        _assetsModel = AssetsModelEntity.fromJson(response);

        //请求成功 刷新页面
        setState(() {
          setViewData(_assetsModel);
        });

      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


//    //显示加载动画
//    showDialog<Null>(
//        context: context, //BuildContext对象
//        barrierDismissible: false,
//        builder: (BuildContext context) {
//          return new LoadingDialog( //调用对话框
//            text: '正在获取详情...',
//          );
//        }
//    );
  
    UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){

      //刷新uss状态
      HttpUtil().get('${ApiConfig.baseUrl}${ApiConfig.refreshUssUrl}').then((res){});

      //请求网络数据
      HttpUtil().post(
        '${ApiConfig.baseUrl}${ApiConfig.assetsUrl}',
      ).then((response){
        print(response.toString());
        //退出加载动画
//      Navigator.pop(context); //关闭对话框
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
        _assetsModel = AssetsModelEntity.fromJson(response);

        //请求成功 刷新页面
        setState(() {
          setViewData(_assetsModel);
        });

      });
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget topMessageView (){
    return Container(
      width: double.infinity,
      height: ScreenUtil.getInstance().setWidth(320.0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
          Expanded(
              child: Container(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(16.0)),
                            child: Container(
                              width: double.infinity,
                              height: ScreenUtil.getInstance().setWidth(260.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppStyle.colorBegin,
                                    AppStyle.colorEnd,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Expanded(child: SizedBox(width: 1,)),
                        Row(
                          children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '总资产估值(≈¥)',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(32.0),
                                      color: AppStyle.colorGrey,
                                      fontWeight: FontWeight.w300
                                  ),
                                ),
                                Text(
                                  _totalValue,
                                  style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(52.0),
                                      color: AppStyle.colorGrey,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '可提现资产(≈¥)',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(32.0),
                                      color: AppStyle.colorGrey,
                                      fontWeight: FontWeight.w300
                                  ),
                                ),
                                Text(
                                  _enableValue,
                                  style: TextStyle(
                                      fontSize: ScreenUtil.getInstance().setSp(52.0),
                                      color: AppStyle.colorGrey,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                          ],
                        ),
                        Expanded(child: SizedBox(width: 1,)),
                      ],
                    ),
                  ],
                ),
              )
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(0.0),),
        ],
      ),
    );
  }
  Widget UssMessageView (){
    return InkWell(
      onTap: (){
        if(_ussAddress == null)return;

          Clipboard.setData(ClipboardData(text: _ussAddress));
          //弹窗
          Fluttertoast.showToast(
              msg: "USS地址已复制到剪贴板!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 2,
              backgroundColor: AppStyle.colorGreyDark,
              textColor: Colors.white,
              fontSize: 16.0
          );

      },
      child: Container(
        width: double.infinity,
        height: ScreenUtil.getInstance().setWidth(280.0),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
            Expanded(
                child: Container(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(16.0)),
                              child: Container(
                                width: double.infinity,
                                height: ScreenUtil.getInstance().setWidth(260.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppStyle.colorBegin,
                                      AppStyle.colorEnd,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Expanded(child: SizedBox(width: 1,)),
                          Row(
                            children: <Widget>[
                              SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                              Text(
                                'USS',
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(52.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              Expanded(child: SizedBox(height: 1,)),
                              Text(
                                '点击复制地址',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(24.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                            ],
                          ),
                          Expanded(child: SizedBox(width: 1,)),
                          Row(
                            children: <Widget>[
                              SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                              Text(
                                '总数',
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(28.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              Text(
                                _ussNum,
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(32.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Expanded(child: SizedBox(height: 1,)),
                              Text(
                                '单价',
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(28.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              Text(
                                _ussPrice,
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(32.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Expanded(child: SizedBox(height: 1,)),
                              Text(
                                '总价值(≈¥)',
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(28.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              Text(
                                _ussTotal,
                                style: TextStyle(
                                    fontSize: ScreenUtil.getInstance().setSp(32.0),
                                    color: AppStyle.colorGrey,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Expanded(child: SizedBox(height: 1,)),
                              SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                            ],
                          ),
                          Expanded(child: SizedBox(width: 1,)),
                        ],
                      ),
                    ],
                  ),
                )
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(0.0),),
          ],
        ),
      ),
    );
  }
  Widget BtcMessageView (){
    return Container(
      width: double.infinity,
      height: ScreenUtil.getInstance().setWidth(280.0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
          Expanded(
              child: Container(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(16.0)),
                            child: Container(
                              width: double.infinity,
                              height: ScreenUtil.getInstance().setWidth(260.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppStyle.colorBegin,
                                    AppStyle.colorEnd,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Expanded(child: SizedBox(width: 1,)),
                        Row(
                          children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                            Text(
                              'BTC',
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(52.0),
                                  color: AppStyle.colorGrey,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                          ],
                        ),
                        Expanded(child: SizedBox(width: 1,)),
                        Row(
                          children: <Widget>[
                            SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                            Text(
                              '总数:',
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                                  color: AppStyle.colorGrey,
                                  fontWeight: FontWeight.w300
                              ),
                            ),
                            Text(
                              _btcNum,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                                  color: AppStyle.colorGrey,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            Text(
                              '单价:',
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                                  color: AppStyle.colorGrey,
                                  fontWeight: FontWeight.w300
                              ),
                            ),
                            Text(
                              _btcPrice,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                                  color: AppStyle.colorGrey,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            Text(
                              '总价值(≈¥):',
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                                  color: AppStyle.colorGrey,
                                  fontWeight: FontWeight.w300
                              ),
                            ),
                            Text(
                              _btcTotal,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                                  color: AppStyle.colorGrey,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            Expanded(child: SizedBox(height: 1,)),
                            SizedBox(width: ScreenUtil.getInstance().setWidth(48.0),),
                          ],
                        ),
                        Expanded(child: SizedBox(width: 1,)),
                      ],
                    ),
                  ],
                ),
              )
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(0.0),),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(
            '资产',
          style: TextStyle(
          ),
        ),
        leading:Text(''),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(0.0),
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
            padding: EdgeInsets.all(0.0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  topMessageView(),
//              Container(
//                color: Colors.white,
//                child: ButtonsView(),
//              ),
//              SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
                  Container(
                    color: Colors.white,
                    child: ListTitleView(),
                  ),
                  UssMessageView(),
                  BtcMessageView(),
                ],
              )
            ],
          ),
          onRefresh: () async {
            await refreshAssetsView ();
          },
        ),
      ),
    );
  }
}

class ButtonsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
        Expanded(
          child: FlatButton.icon(
            icon: Icon(
              AppIcon.pay,
              size: 24.0,
            ),
            label: Text(
              '划转',
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w300
              ),
            ),
            onPressed: (){
              print('clicked 划转');

              UserInfoCache().getUserInfo().then((onValue){
                print(onValue.toString());
              });
              UserInfoCache().getInfo(key: UserInfoCache.phoneNumber).then((onValue){
                print('phone:$onValue');
              });
              UserInfoCache().getInfo(key: UserInfoCache.loginPassword).then((onValue){
                print('password:$onValue');
              });
              UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
                print('loginStatus:$onValue');
              });
              UserInfoCache().getInfo(key: UserInfoCache.sessionId).then((onValue){
                print('session_id:$onValue');
              });
            },
            textColor: AppStyle.colorDark,
          ),
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
        Container(
          height: 16.0,
          width: 2.0,
          color: AppStyle.colorGrey,
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
        Expanded(
          child: FlatButton.icon(
            icon: Icon(
              AppIcon.form,
              size: 24.0,
            ),
            label: Text(
              '账单',
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(32.0),
                  fontWeight: FontWeight.w300
              ),
            ),
            onPressed: (){
              print('clicked 账单');
            },
            textColor: AppStyle.colorDark,
          ),
        ),
        SizedBox(width: ScreenUtil.getInstance().setWidth(32.0),),
      ],
    );
  }
}
class ListTitleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
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
              '资产明细',
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontWeight: FontWeight.w400
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
      ],
    );
  }
}

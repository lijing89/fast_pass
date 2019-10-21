import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/dash_line.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';

class FPSellPricePage extends StatefulWidget {
  final String id;
  FPSellPricePage({this.id});
  @override
  _FPSellPricePageState createState() => _FPSellPricePageState();
}

class _FPSellPricePageState extends State<FPSellPricePage> {

  int _sellIndex = 2;// 1竞价卖、2立即卖
  String _selectSize = '';
  String _sizeId = '0';
  String _goodName = '';
  String _newHighestBuyPrice = '--',_newLowestSellPrice = '--';
  String _sizeValue = '3';
  Map _goodDetailInfo= {};
  int _price = 0;
//  SwiperController _swiperController = SwiperController();
  TextEditingController _priceController = TextEditingController(text: '0');

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();

  double _BZJ = 0.0;

  Map _computePricesInfo = {};

  String _payMoney = '0',_expressPrice = '0';

  _validatorAndToNext(BuildContext context){

//    if(_sellIndex == 1 && _priceController.text == '0'){
//      //弹窗
//      showToast("当前商品还没有卖家报价，请您先通过“竞价卖”出价，然后等待买家匹配。");
//      return;
//    }
    if(_sellIndex == 2 && _price == 0){
      //弹窗
      showToast("当前商品还没有卖家报价，请您先通过“竞价卖”出价，然后等待买家匹配。");
      return;
    }



    ApiConfig().createSellOrder(comdiId:widget.id,
        sizeId:_sizeId,
        orderType:_sellIndex,
        orderAmt:_sellIndex == 1?int.parse(_priceController.text)*100:_price*100,
        deposit:0,
    ).then((orderData){

      UserInfoCache().setMapInfo(key: UserInfoCache.sellInfo, map: {
        'id':widget.id,
        'goodName':_goodName,
        'selectSize':_selectSize,
        'price':_sellIndex == 1?int.parse(_priceController.text)*100:_price*100,
        'BZJ':_BZJ.toStringAsFixed(2),
        'sizeValue':_sizeValue,
        'sizeId':_sizeId,
        'sellType':_sellIndex,
        'priceTips':orderData['priceTips'],
        'orderTime':DateTime.now().millisecondsSinceEpoch,
      });

      if(orderData.isNotEmpty && int.parse(orderData['rspCode']) < 1000){
        Navigator.pop(context);
        Application.router.navigateTo(context,'${Routes.sellPay}?id=${widget.id}&orderId=${orderData['orderNo']}',transition: TransitionType.native);
      }
      else {
        showToast(orderData['rspDesc']);
      }

    });
//    Application.router.navigateTo(context,'${Routes.sellPay}?id=${widget.id}',transition: TransitionType.native);
  }


  //刷新数据
  Future refreshGoodsList() async {

    var onValue = await UserInfoCache().getMapInfo(key: UserInfoCache.sellInfo);
    print('buyInfo = ${onValue.toString()}');
    _selectSize = onValue['selectSize'];
    _sizeValue = onValue['sizeValue'];
    _goodName = onValue['goodName'];
    _sizeId = onValue['sizeId'];
    setState(() {});

    String priceStr = _priceController.text==''?'0':_priceController.text;

    var computePriceData = await ApiConfig().computePrice(comdiId:widget.id,sizeId: _sizeId,type: _sellIndex==1?1:3,deposit: 0,offer: int.parse(priceStr)*100);

    if(computePriceData.isNotEmpty && int.parse(computePriceData['rspCode']) < 1000){
//      print('<------------');
      _computePricesInfo = computePriceData;
      _price = ((computePriceData['price']??0) / 100) ~/ 1;
      if(_price == 0){
        _sellIndex = 1;
        showToast('当前商品还没有买家出价，请您先通过“竞价卖”报价，然后等待买家匹配。');
      }
    } else {
//      print('------------>');
      showToast(computePriceData['rspDesc']);
      _computePricesInfo = {};
      _price = 0;
      _sellIndex = 1;
    }

    var goodDetailData = await ApiConfig().goodsDetail(widget.id);
    if(goodDetailData.isNotEmpty && int.parse(goodDetailData['rspCode']) < 1000){
      _goodDetailInfo = goodDetailData;
//      if(_goodDetailInfo['imgList'].isNotEmpty){
//        _swiperController.startAutoplay();
//      }
    }
    else return;

    await refreshPrices(goodId: widget.id,sizeId: _sizeId);
    setState(() {});

  }

  Future refreshPrices({String goodId,sizeId}) async {

    print('goodId = $goodId');
    var priceData = await ApiConfig().goodsLowHeight([{'id':goodId,'sizeId':sizeId}])??{};
    if(priceData.isNotEmpty && int.parse(priceData['rspCode']) < 1000){
      List pricesList = priceData['rspList']??[];
      String buyString = pricesList[0]['buyingPrice'];
      String sellString = pricesList[0]['sellingPrice'];
      _newHighestBuyPrice = buyString;
      _newLowestSellPrice = sellString;
//      _newHighestBuyPrice = '¥${int.parse(buyString.replaceRange(0,1, '0'))/100}';
//      _newLowestSellPrice = '¥${int.parse(sellString.replaceRange(0,1, '0'))/100}';
    }
    else return;

    setState(() {});
  }

/*
type	n1	m	r	计算类型。1竞价卖、2砍价买、3立即卖、4立即买
comdiId	ans..16	m	r	商品编号。
sizeId	ans..16	o	r	尺码编号。
deposit	n1	m	r	0不寄存、1从会员仓出售或买入到会员仓。
offer	n1..8	c	r	报价（单位分）。type=1和2时必填。type为其它值时无意义。
* */
  refreshPriceCompute({String comdiId,sizeId,int type, deposit,int offer}){

    ApiConfig().computePrice(comdiId:comdiId,sizeId: sizeId,type: type==1?1:3,deposit: deposit,offer: offer).then((computePriceData){


      if(computePriceData.isNotEmpty && int.parse(computePriceData['rspCode']) < 1000){
        _computePricesInfo = computePriceData;
        _price = ((computePriceData['price']??0) / 100) ~/ 1;
      } else {
        showToast(computePriceData['rspDesc']);
        _computePricesInfo = {};
        _price = 0;
      }

      setState(() {});

    });
  }


  @override
  void initState(){
    super.initState();
    refreshGoodsList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _priceController.dispose();
//    _swiperController.stopAutoplay();
//    _swiperController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print('go to select size page id = ${widget.id}');
    _BZJ = int.parse(_priceController.text) * 10 / 100;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              barView(context,Theme.of(context).primaryColor),
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
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      dashLineAndStep(context),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: ScreenUtil.getInstance().setWidth(80.0),
                          bottom: ScreenUtil.getInstance().setWidth(80.0),
                        ),
                        color: AppStyle.colorDartBg,
                        child: Column(
                          children: <Widget>[
                            goodInfoItem(title: '商品名称',content: _goodName),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
                            goodInfoItem(title: '交易尺码',content: '${Application.sizeValueTitle(_sizeValue)} $_selectSize'),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
                            goodInfoItem(title: '最低卖价',content: _newLowestSellPrice??'--'),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
                            goodInfoItem(title: '最高卖价',content: _newHighestBuyPrice??'--'),
                          ],
                        ),
                      ),
                      headerImageView(headImage: _goodDetailInfo['titleImgUrl']),
                      selectBuyBarView(context: context,title1: '竞价卖',title2: '立即卖'),
                      Container(
                        margin: EdgeInsets.only(
                          left: ScreenUtil.getInstance().setWidth(16.0),
                          right: ScreenUtil.getInstance().setWidth(16.0),
                        ),
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: ScreenUtil.getInstance().setWidth(100.0)),
                            priceInputView(sellIndex: _sellIndex,sellPrice: _price),
                            computePricesView(computeInfo: _computePricesInfo),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(160.0)),
                          ],
                        ),
                      ),
                      bottomButtonsView(context),
                    ],
                  ),
                  onRefresh: () async {
                    await refreshGoodsList();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerImageView({@required String headImage}) {
    if (headImage != null) {
      return Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: ScreenUtil.getInstance().setWidth(400.0),
          color: AppStyle.colorWhite,
          child: CachedNetworkImage(
            imageUrl: headImage,
            placeholder: (context, url) => new CircularProgressIndicator(strokeWidth: 1.0,),
            errorWidget: (context, url, error) => new Icon(AppIcon.warn_light),
            fit: BoxFit.cover,
          )

//        Swiper(
//          itemBuilder: (BuildContext context, int index) {
//            return CachedNetworkImage(
//              imageUrl: headImagesList[index],
//              placeholder: (context, url) => new CircularProgressIndicator(strokeWidth: 1.0,),
//              errorWidget: (context, url, error) => new Icon(Icons.warning),
//              fit: BoxFit.fitWidth,
//            );
//          },
//          controller: _swiperController,
//          itemCount: headImagesList.length,
//          itemWidth: double.infinity,
//          layout: SwiperLayout.DEFAULT,
//          pagination: SwiperPagination(),
//          autoplayDelay: 3000,
//          autoplayDisableOnInteraction: true,
//        ),
      );
    }
    return Container();
  }

  Widget computePricesView({Map computeInfo}){

    String computeTips = computeInfo['tips']??'';
    List items = computeInfo['list']??[];

    if (computeInfo.isEmpty)return SizedBox(height: ScreenUtil.getInstance().setWidth(120.0));

    List<Widget> views = [];
    views.add(SizedBox(height: ScreenUtil.getInstance().setWidth(120.0)));
    if(items.isNotEmpty){
      for(int i=0;i<items.length-1;i++){
        views.add(priceInfoItem(title: items[i]['title'],content: items[i]['price']));
        if(items[i]['title'] == '')_expressPrice = '${double.parse(items[i]['price'].replaceRange(0,1, '0'))}';
      }
      _payMoney = items[items.length-1]['price'];//'${double.parse(items[items.length-1]['price'].replaceRange(0,1, '0'))}';
    }

    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(16.0),
        right: ScreenUtil.getInstance().setWidth(16.0),
      ),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          computeTips != ''
              ? lowestTip(title: computeTips)
              : Container(),
          views.isEmpty
              ?Container()
              :Column(children: views,),
          MySeparator(color: AppStyle.colorPrimary,height: 2,),
          SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
          items.isEmpty
              ?Container()
              :priceInfoItem(title: items[items.length-1]['title'],content: items[items.length-1]['price']),
          lowestTip(title: '说明: 保证金将在交易成功后原路退回'),
          SizedBox(height: ScreenUtil.getInstance().setWidth(120.0)),
        ],
      ),
    );
  }

  Container lowestTip({String title}) {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil.getInstance().setWidth(20.0),
      ),
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          color: AppStyle.colorGreyText,
          fontSize: ScreenUtil.getInstance().setSp(24.0),
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Container priceInputView({int sellIndex,sellPrice}) {
    return Container(
      color: AppStyle.colorPrimary,
      height: ScreenUtil.getInstance().setWidth(100.0),
      child: Row(
        children: <Widget>[
          Text(
            '  ¥',
            style: TextStyle(
              color: AppStyle.colorLight,
              fontSize: ScreenUtil.getInstance().setSp(48.0),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w600,
            ),
          ),
//          SizedBox(width: ScreenUtil.getInstance().setWidth(100.0),),
//          Text(
//            '出售价格',
//            style: TextStyle(
//              color: AppStyle.colorWhite,
//              fontSize: ScreenUtil.getInstance().setSp(28.0),
//              fontStyle: FontStyle.normal,
//              fontWeight: FontWeight.w400,
//            ),
//          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              height: ScreenUtil.getInstance().setWidth(100.0),
              child: sellIndex == 2
                  ?Text(
                      sellPrice==0?'--':'$sellPrice',
                      style: TextStyle(
                        color: AppStyle.colorWhite,
                        fontSize: ScreenUtil.getInstance().setSp(64.0),
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  :TextField(
                    controller: _priceController,
                    maxLines: 1,//最大行数
                    decoration: InputDecoration(
                        border: InputBorder.none,
    //                    labelText: '购卖价格',
    //                    labelStyle: TextStyle(
    //                      color: AppStyle.colorWhite,
    //                      fontSize: ScreenUtil.getInstance().setSp(32.0)
    //                    )
                    ),
                    textAlign: TextAlign.end,//文本对齐方式
                    style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(64.0), color: Colors.white),//输入文本的样式式
                    onChanged: (text) {//内容改变的回调
                      print('change $text');
//                      if(text == '')_priceController.value = TextEditingValue(text: '0');
//                      setState(() {});
                      String number = _priceController.text=='' ? '0': _priceController.text;
                      if(_priceController.text!='')refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _sellIndex,deposit: 0,offer: int.parse(number)*100);
                    },
                    onSubmitted: (text) {//内容提交(按回车)的回调
                      print('submit $text');
                      int price = int.parse(text);
                      _priceController.value = TextEditingValue(text: '$price');
                    },
                    inputFormatters: <TextInputFormatter> [
                      WhitelistingTextInputFormatter.digitsOnly, //只能输入数
    //                                      WhitelistingTextInputFormatter(RegExp(
    //                                          "[.]|[0-9]")), //只能输入汉字或者字母或数
                    ],
                    keyboardType: TextInputType.number,
                    enabled: true,//是否禁用
                  ),
            ),
          ),
          SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
        ],
      ),
    );
  }

  Widget selectBuyBarView({BuildContext context,String title1,String title2}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(16.0),
        right: ScreenUtil.getInstance().setWidth(16.0),
      ),
      margin: EdgeInsets.only(
        top: ScreenUtil.getInstance().setWidth(40.0),
        bottom: ScreenUtil.getInstance().setWidth(22.0),
      ),
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
                      print('title1 = $title1 , title 2 = $title2,index = $_sellIndex');
                      if(_sellIndex == 1)return;
                      setState(() {
                        _sellIndex = 1;
                      });
                      refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _sellIndex,deposit: 0,offer: int.parse(_priceController.text)*100);
                    },
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _sellIndex == 1 ? AppStyle.colorWhite : AppStyle.colorBackground,
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
                        _sellIndex == 1 ?
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
                      print('title1 = $title1 , title 2 = $title2,index = $_sellIndex');
                      if(_sellIndex == 2)return;
                      setState(() {
                        _sellIndex = 2;
                      });
                      refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _sellIndex,deposit: 0,offer: int.parse(_priceController.text)*100);
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _sellIndex == 2 ? AppStyle.colorWhite : AppStyle.colorBackground,
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
                        _sellIndex == 2 ?
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
              text: '$title:  ',
              style: TextStyle(
                color: AppStyle.colorLight,
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
        SizedBox(width: ScreenUtil.getInstance().setWidth(80.0),),
      ],
    );
  }

  Widget priceInfoItem({String title,content}) {
    return Container(
      padding: EdgeInsets.only(
        bottom: ScreenUtil.getInstance().setWidth(40.0),
      ),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: ScreenUtil.getInstance().setWidth(50.0),),
          Text(
            '$title ：',
            style: TextStyle(
              color: AppStyle.colorDark,
              fontSize: ScreenUtil.getInstance().setSp(28.0),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(child: SizedBox(height: 1,)),
          Text(
            content,
            style: TextStyle(
              color: AppStyle.colorDark,
              fontSize: ScreenUtil.getInstance().setSp(28.0),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: ScreenUtil.getInstance().setWidth(20.0),),
        ],
      ),
    );
  }

  Widget bottomButtonsView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left:ScreenUtil.getInstance().setWidth(16.0),
        right:ScreenUtil.getInstance().setWidth(16.0),
      ),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Application.router.pop(context);
                },
                child: Container(
                  width: ScreenUtil.getInstance().setWidth(168.0),
                  height: ScreenUtil.getInstance().setWidth(74.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(74.0)),
                      border: Border.all(
                        color: AppStyle.colorGreyText,
                        width: 0.5,
                      )
                  ),
                  child: Center(
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                        fontWeight: FontWeight.w600,
                        color: AppStyle.colorDark,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setWidth(30.0),),
              GestureDetector(
                onTap: () => _validatorAndToNext(context),
                child: Container(
                  width: ScreenUtil.getInstance().setWidth(218.0),
                  height: ScreenUtil.getInstance().setWidth(74.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(74.0)),
                    color: AppStyle.colorPink,
                  ),
                  child: Center(
                    child: Text(
                      '下一步',
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                        fontWeight: FontWeight.w600,
                        color: AppStyle.colorWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(160.0),),
        ],
      ),
    );
  }

  Widget dashLineAndStep(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil.getInstance().setWidth(80.0),
      ),
      color: AppStyle.colorPrimary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Container(color: AppStyle.colorPink,height: 2,),),
              SizedBox(width: 5,),
              Container(
                height: ScreenUtil.getInstance().setWidth(24.0),
                width: ScreenUtil.getInstance().setWidth(24.0),
                decoration: BoxDecoration(
                  color: AppStyle.colorWhite,
                  border: Border.all(
                    color: AppStyle.colorPink,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(24.0)),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(child: Container(color: AppStyle.colorPink,height: 2,),),
              SizedBox(width: 5,),
              Container(
                height: ScreenUtil.getInstance().setWidth(24.0),
                width: ScreenUtil.getInstance().setWidth(24.0),
                decoration: BoxDecoration(
                  color: AppStyle.colorWhite,
                  border: Border.all(
                    color: AppStyle.colorPink,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(24.0)),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(child: MySeparator(color: Colors.white,height: 2,),),
              SizedBox(width: 5,),
              Container(
                height: ScreenUtil.getInstance().setWidth(24.0),
                width: ScreenUtil.getInstance().setWidth(24.0),
                decoration: BoxDecoration(
                  color: AppStyle.colorWhite,
                  borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(24.0)),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(child: MySeparator(color: Colors.white,height: 2,),),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(20),),
          Row(
            children: <Widget>[
              Expanded(flex: 1,child: Container(height: 1,)),
              Expanded(flex: 2,child: Container(height: 1,)),
              Expanded(flex: 2,child: Container(
                height: 30,
                child: Center(
                  child: Text(
                    '选择出售方式',
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(24.0),
                      color: AppStyle.colorWhite,
                    ),
                  ),
                ),
              )),
              Expanded(flex: 2,child: Container(height: 1,)),
              Expanded(flex: 1,child: Container(height: 1,)),
            ],
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(30),),
        ],
      ),
    );
  }

  Widget barView(BuildContext context,Color backgroundColor){
    return Container(
        height: MediaQueryData.fromWindow(window).padding.top + 56.0,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top,
              left:  ScreenUtil.getInstance().setWidth(40.0),
              right:  ScreenUtil.getInstance().setWidth(40.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Application.router.navigateTo(context,Routes.home,clearStack:true,transition: TransitionType.native);
                  },
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
//                            color: Colors.red
                    ),
                    alignment: Alignment.center,
                    child: Image(image: AssetImage(AssetUtil.image('logo-bl copy@3x.png')),fit: BoxFit.fitHeight,),
                  ),
                ),
                Expanded(child: SizedBox(height: 1,)),
                GestureDetector(
                  onTap: (){
                    NavigatorUtil.push(
                        context,
                        WebViewState(
                          title: 'FAQ',
                          url: 'http://www.baidu.com',
                        ));
                  },
                  child: Container(
                    child: Text(
                      'FAQ',
                      style: TextStyle(
                          color: AppStyle.colorLight
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

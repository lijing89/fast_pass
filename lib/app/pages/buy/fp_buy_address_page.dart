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

class FPBuyAddressPage extends StatefulWidget {
  final String id;
  FPBuyAddressPage({this.id});
  @override
  _FPBuyAddressPageState createState() => _FPBuyAddressPageState();
}

class _FPBuyAddressPageState extends State<FPBuyAddressPage> {

  int _buyIndex = 2;// 1砍价买 2直接买
  TextEditingController _priceController = TextEditingController(text: '0');
  TextEditingController _addressDetailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();

  bool _isSaveInFP = false;
  String _selectSize = '';
  String _sizeId = '0';
  String _goodName = '';
  String _newHighestBuyPrice = '',_newLowestSellPrice = '';
  int _price = 0;
  String _sizeValue = '1';
  Map _goodDetailInfo= {};
//  SwiperController _swiperController = SwiperController();

  ///城市选择器
  String _city = '点我选择城市';
  String _province = '';
  String _citySelect = '';
  String _district = '',_payMoney = '0',_expressPrice = '0';
  Map _computePricesInfo = {};

  Future initData()async{

    var sizeValue = await UserInfoCache().getMapInfo(key: UserInfoCache.buyInfo);
    print('sizeValue = ${sizeValue.toString()}');
    _selectSize = sizeValue['selectSize'];
    _sizeValue = sizeValue['sizeValue'];
    _sizeId = sizeValue['sizeId'];

    var accountInfo = await ApiConfig().getAccount();
    if(accountInfo == null){return;}
    if(accountInfo['rspCode'] != '0000'){
      Fluttertoast.showToast(msg:accountInfo['rspDesc'],
       toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 2,
          backgroundColor: AppStyle.colorGreyDark,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    if(mounted){
      for (var item in accountInfo['addrs']) {
        if(item['type'] == '1'){
          _city = '${item['province']} ${item['city']} ${item['district']}';
          _province = item['province'];
          _citySelect = item['city'];
          _district = item['district'];
          _addressDetailController = TextEditingController(text: item['addr']);
          _phoneNumberController = TextEditingController(text: item['phone']);
          _nameController = TextEditingController(text: item['name']);
          break;
        }
      }
    }


    var goodDetailData = await ApiConfig().goodsDetail(widget.id);
    if(goodDetailData.isNotEmpty && int.parse(goodDetailData['rspCode']) < 1000){
      _goodDetailInfo = goodDetailData;
      _goodName = goodDetailData['title'];
//      if(_goodDetailInfo['imgList'].isNotEmpty){
//        _swiperController.startAutoplay();
//      }
    }
    else return;

    String priceStr = _priceController.text==''?'0':_priceController.text;
    refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _buyIndex,deposit: _isSaveInFP?1:0,offer: int.parse(priceStr)*100);

    await refreshPrices(goodId: widget.id,sizeId: _sizeId);

    setState(() {});
  }
  //刷新数据
  Future refreshGoodsList() async {

    var onValue = await UserInfoCache().getMapInfo(key: UserInfoCache.buyInfo);
    print('buyInfo = ${onValue.toString()}');
    if(onValue['name'] != '' && onValue['name'] != null){
      _city = '${onValue['province']} ${onValue['city']} ${onValue['district']}';
      _province = onValue['province'];
      _citySelect = onValue['city'];
      _district = onValue['district'];
      _addressDetailController = TextEditingController(text: onValue['addr']);
      _phoneNumberController = TextEditingController(text: onValue['phone']);
      _nameController = TextEditingController(text: onValue['name']);
    }
    if(mounted){
      setState(() {});
    }
    String priceStr = _priceController.text==''?'0':_priceController.text;
    refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _buyIndex,deposit: _isSaveInFP?1:0,offer: int.parse(priceStr)*100);


    var goodDetailData = await ApiConfig().goodsDetail(widget.id);
    if(goodDetailData.isNotEmpty && int.parse(goodDetailData['rspCode']) < 1000){
      _goodDetailInfo = goodDetailData;
      _goodName = goodDetailData['title'];
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
      String buyString = pricesList[0]['buyingPrice']??'--';
      String sellString = pricesList[0]['sellingPrice']??'--';
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

    ApiConfig().computePrice(comdiId:comdiId,sizeId: sizeId,type: type==1?2:4,deposit: deposit,offer: offer).then((computePriceData){


      if(computePriceData.isNotEmpty && int.parse(computePriceData['rspCode']) < 1000){
          _computePricesInfo = computePriceData;
          _price = ((computePriceData['price']??0) / 100) ~/ 1;
      } else {
        Fluttertoast.showToast(msg:computePriceData['rspDesc'],
         toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0);
        _computePricesInfo = {};
//        _price = 0;
      }
      setState(() {});
    });
  }

  _show(context) async{
    Result temp  = await CityPickers.showCityPicker(
        context: context,
        height: 400,
        cancelWidget: Text('取消', style: TextStyle()),
        confirmWidget: Text('确定', style: TextStyle())
    );
    setState(() {
      if(temp == null) return;
      _province = temp.provinceName;
      _citySelect = temp.cityName;
      _district = temp.areaName;
      _city = (temp.provinceName??'') + '  ' + (temp.cityName??'')+'  ' + (temp.areaName??'');
    });
  }
  _validatorAndToNext(BuildContext context){

//    if(_buyIndex == 1 && _priceController.text == '0'){
//      //弹窗
//      showToast("请输入购买价格!");
//      return;
//    }
    if(_buyIndex == 2 && _price == 0){
      //弹窗
      Fluttertoast.showToast(msg:"不能直接购买!",
       toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
      );
      return;
    }

//    if(int.parse(_priceController.text) >= _price){
      print('_price = $_price,_priceController.text = ${_priceController.text}');
//      //弹窗
//      showToast("出价不可高于商品最低卖价 ¥$_price，请选择直接买!");
//      return;
//    }

    if(_city == '点我选择城市' && !_isSaveInFP){
      //弹窗
      Fluttertoast.showToast(msg:"请选择城市!",
       toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    if(_addressDetailController.text == '' && !_isSaveInFP){
      //弹窗
      Fluttertoast.showToast(msg:"请输入街道和门牌号!",
       toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    if(_nameController.text == '' && !_isSaveInFP){
      //弹窗
      Fluttertoast.showToast(msg:"请输入收货人姓名!",
       toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    if(!Application.isPhoneNumber(_phoneNumberController.text) && !_isSaveInFP){
      //弹窗
      Fluttertoast.showToast(msg:"请输入正确的手机号码!", toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    ApiConfig().createBuyOrder(comdiId:widget.id,
        sizeId:_sizeId,
        orderType:_buyIndex,
        orderAmt:_buyIndex == 1?int.parse(_priceController.text)*100:_price*100,
        deposit:_isSaveInFP?1:0,
        province:_province,
        city:_citySelect,
        district:_district,
        addr:_addressDetailController.text,
        name:_nameController.text,
        phone:_phoneNumberController.text
    ).then((orderData){
      print(orderData);
      UserInfoCache().setMapInfo(key: UserInfoCache.buyInfo, map: {
        'id':widget.id,
        'selectSize':_selectSize,
        'price':_buyIndex == 1?int.parse(_priceController.text)*100:_price*100,
        'expressPrice':_expressPrice,
        'payMoney':_payMoney,
        'name':_nameController.text,
        'phone':_phoneNumberController.text,
        'address':'$_city ${_addressDetailController.text}',
        'buyType':_buyIndex,
        '_isSaveInFP':_isSaveInFP ? '1' : '0' ,
        'sizeValue':_sizeValue,
        'goodName':_goodName,
        'sizeId':_sizeId,
        'orderTime':DateTime.now().millisecondsSinceEpoch,
      });
      if(orderData.isNotEmpty && int.parse(orderData['rspCode']) < 1000){
        Navigator.pop(context);
        Application.router.navigateTo(context,'${Routes.buyPay}?id=${widget.id}&orderId=${orderData['orderNo']}',transition: TransitionType.native);
      }
      else {
        Fluttertoast.showToast(msg:orderData['rspDesc'], toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0);
      }

    });
  }
  @override
  void initState(){
    super.initState();
    initData();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      refreshGoodsList();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _priceController.dispose();
    _addressDetailController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
//    _swiperController.stopAutoplay();
//    _swiperController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            goodInfoItem(title: '最低卖价',content: _newLowestSellPrice),
                            SizedBox(height: ScreenUtil.getInstance().setWidth(30.0),),
                            goodInfoItem(title: '最高买价',content: _newHighestBuyPrice),
                          ],
                        ),
                      ),
                      headerImageView(headImage: _goodDetailInfo['titleImgUrl']),
                      selectBuyBarView(context: context,title1: '砍价买',title2: '直接买'),
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
                            priceInputView(buyIndex : _buyIndex,buyPrice: _price),
                            computePricesView(computeInfo: _computePricesInfo),
                          ],
                        ),
                      ),
                      _isSaveInFP
                          ?Container()
                          :addressEditView(context),
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
                            GestureDetector(
                              onTap: (){
                                _isSaveInFP = !_isSaveInFP;
                                refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _buyIndex,deposit: _isSaveInFP?1:0,offer: int.parse(_priceController.text)*100);
                                setState(() {});
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: ScreenUtil.getInstance().setWidth(40.0),
                                  right: ScreenUtil.getInstance().setWidth(40.0),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _isSaveInFP ? AppStyle.colorPrimary : AppStyle.colorGreyLine,
                                      width: _isSaveInFP ? 2 : 1,
                                    )
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '存放于快传会员货仓 (免快递费) ',
                                  style: TextStyle(
                                    color: AppStyle.colorDark,
                                    fontSize: ScreenUtil.getInstance().setSp(32.0),
                                    fontStyle: FontStyle.normal,
                                    fontWeight: _isSaveInFP ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
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

  Widget computePricesView({Map computeInfo}){

      String computeTips = computeInfo['tips']??'';
      List items = computeInfo['list'];

      if (computeInfo.isEmpty)return SizedBox(height: ScreenUtil.getInstance().setWidth(120.0));

      List<Widget> views = [];
      views.add(SizedBox(height: ScreenUtil.getInstance().setWidth(120.0)));
      for(int i=0;i<items.length-1;i++){
          views.add(priceInfoItem(title: items[i]['title'],content: items[i]['price']));
          if(items[i]['title'] == '')_expressPrice = '${double.parse(items[i]['price'].replaceRange(0,1, '0'))}';
      }
      _payMoney = items[items.length-1]['price'];//'${double.parse(items[items.length-1]['price'].replaceRange(0,1, '0'))}';

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
                  priceInfoItem(title: items[items.length-1]['title'],content: items[items.length-1]['price']),
                  lowestTip(title: '说明: 保证金将在交易成功后原路退回'),
                  SizedBox(height: ScreenUtil.getInstance().setWidth(120.0)),
              ],
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

  Container addressEditView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(16.0),
        right: ScreenUtil.getInstance().setWidth(16.0),
      ),
      padding: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(30.0),
        right: ScreenUtil.getInstance().setWidth(30.0),
      ),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(120.0)),
          Row(
            children: <Widget>[
              Text(
                '收货地:',
                style: TextStyle(
                  color: AppStyle.colorDark,
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(child: SizedBox(height: 1,)),
            ],
          ),
          //地址选择器
          Container(
            padding: EdgeInsets.only(
              top: ScreenUtil.getInstance().setWidth(80.0),
            ),
            child: GestureDetector(
              onTap: () {this._show(context);
              },
              child: Column(
                children: <Widget>[
                  Text(
                      _city,
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(32.0),
                          color: AppStyle.colorDark,
                          fontWeight: FontWeight.w500
                      )
                  ),
                  SizedBox(height:ScreenUtil.getInstance().setWidth(20.0) ,),
                  Container(width: double.infinity,height: 1,color: Color.fromRGBO(195, 195, 195, 1.0),),
                ],
              ),
            ),
          ),
          SizedBox(height:ScreenUtil.getInstance().setWidth(40.0) ,),
          Theme(
            data: new ThemeData(
              hintColor: Color.fromRGBO(195, 195, 195, 1.0),
              primaryColor: AppStyle.colorPrimary,
            ),
            child: TextField(
              cursorColor: AppStyle.colorPrimary,
              controller: _addressDetailController,
              maxLines: 1,//最大行数
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: '街道和门牌号',
                labelStyle: TextStyle(
                  color: AppStyle.colorPrimary,
                  fontSize:ScreenUtil.getInstance().setSp(28.0),
                ),
                focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:AppStyle.colorPrimary)
                          )
              ),
              style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28.0)),//输入文本的样式式
              onChanged: (text) {//内容改变的回调
              },
              onSubmitted: (text) {//内容提交(按回车)的回调
              },
              enabled: true,//是否禁用
            ),
          ),
          SizedBox(height:ScreenUtil.getInstance().setWidth(40.0) ,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Theme(
                  data: new ThemeData(
                    hintColor: Color.fromRGBO(195, 195, 195, 1.0),
                    primaryColor: AppStyle.colorPrimary,
                  ),
                  child: TextField(
                    cursorColor: AppStyle.colorPrimary,
                    controller: _nameController,
                    maxLines: 1,//最大行数
                    decoration:
                    InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '收货人姓名',
                        labelStyle: TextStyle(
                          color: AppStyle.colorPrimary,
                          fontSize:ScreenUtil.getInstance().setSp(28.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:AppStyle.colorPrimary)
                          )
                    ),
                    style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28.0)),//输入文本的样式式
                    onChanged: (text) {//内容改变的回调
                    },
                    onSubmitted: (text) {//内容提交(按回车)的回调
                    },
                    enabled: true,//是否禁用
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setWidth(10.0)),
              Expanded(
                flex: 2,
                child: Theme(
                  data: new ThemeData(
                    hintColor: Color.fromRGBO(195, 195, 195, 1.0),
                    primaryColor: AppStyle.colorPrimary,
                  ),
                  child: TextField(
                    cursorColor: AppStyle.colorPrimary,
                    controller: _phoneNumberController,
                    maxLines: 1,//最大行数
                    decoration:
                    InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '手机号码',
                        labelStyle: TextStyle(
                          color: AppStyle.colorPrimary,
                          fontSize:ScreenUtil.getInstance().setSp(28.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:AppStyle.colorPrimary)
                          )
                    ),
                    style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28.0)),//输入文本的样式式
                    onChanged: (text) {//内容改变的回调
                    },
                    onSubmitted: (text) {//内容提交(按回车)的回调
                    },
                    inputFormatters: <TextInputFormatter> [
                      WhitelistingTextInputFormatter.digitsOnly, //只能输入数
//                                      WhitelistingTextInputFormatter(RegExp(
//                                          "[.]|[0-9]")), //只能输入汉字或者字母或数
                    ],
                    enabled: true,//是否禁用
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height:ScreenUtil.getInstance().setWidth(100.0) ,),
          GestureDetector(
            onTap: (){
              Application.router.navigateTo(context, '${Routes.AddressManagePage}?number=${'1'}',transition: TransitionType.native);
            },
            child: Container(
              height: ScreenUtil.getInstance().setWidth(80),
              width: double.infinity,
              alignment: Alignment.center,
              margin: EdgeInsets.all(ScreenUtil.getInstance().setWidth(32.0)),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppStyle.colorPrimary,
                  width: 1,
                ),
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil.getInstance().setWidth(10))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '选择其他收货地址',
                    style: TextStyle(
                      color: AppStyle.colorPrimary,
                      fontSize: ScreenUtil.getInstance().setSp(28.0),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(width: ScreenUtil.getInstance().setWidth(16.0),),
                  Icon(Icons.arrow_right,size: 30,),
                ],
              ),
            ),
          ),
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

  Container priceInputView({int buyIndex,buyPrice}) {
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
//            '购买价格',
//            style: TextStyle(
//              color: AppStyle.colorWhite,
//              fontSize: ScreenUtil.getInstance().setSp(28.0),
//              fontStyle: FontStyle.normal,
//              fontWeight: FontWeight.w400,
//            ),
//          ),
          Expanded(
            child: Container(
              height: ScreenUtil.getInstance().setWidth(100.0),
              alignment: Alignment.centerRight,
              child: buyIndex == 2
                ?Text(
                    buyPrice==0?'--':'$buyPrice',
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
//                    labelText: '购买价格',
//                    labelStyle: TextStyle(
//                      color: AppStyle.colorWhite,
//                      fontSize: ScreenUtil.getInstance().setSp(32.0)
//                    )
                ),
                textAlign: TextAlign.end,//文本对齐方式
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(64.0),
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                ),//输入文本的样式式
                onChanged: (text) {//内容改变的回调
                  print('change $text');
//                  if(text == '')_priceController.value = TextEditingValue(text: '0');
//                  setState(() {});
                  String number = _priceController.text=='' ? '0': _priceController.text;
                  if(_priceController.text!='')refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _buyIndex,deposit: _isSaveInFP?1:0,offer: int.parse(number)*100);
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
                      print('title1 = $title1 , title 2 = $title2,index = $_buyIndex');
                      if(_buyIndex == 1)return;
                      setState(() {
                        _buyIndex = 1;
                      });
                      refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _buyIndex,deposit: _isSaveInFP?1:0,offer: int.parse(_priceController.text)*100);
                    },
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _buyIndex == 1 ? AppStyle.colorWhite : AppStyle.colorBackground,
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
                        _buyIndex == 1 ?
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
                      if(_buyIndex == 2)return;
                      setState(() {
                        _buyIndex = 2;
                        refreshPriceCompute(comdiId: widget.id,sizeId: _sizeId,type: _buyIndex,deposit: _isSaveInFP?1:0,offer: int.parse(_priceController.text)*100);
                      });
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.getInstance().setWidth(76.0),
                          color: _buyIndex == 2 ? AppStyle.colorWhite : AppStyle.colorBackground,
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
                        _buyIndex == 2 ?
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
                    '选择购买方式',
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

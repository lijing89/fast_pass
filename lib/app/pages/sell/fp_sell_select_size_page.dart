import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:fast_pass/app/pages/home/components/custom_floating_button.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/dash_line.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';

class FPSellSelectSizePage extends StatefulWidget {
  final String id;
  FPSellSelectSizePage({this.id});
  @override
  _FPSellSelectSizePageState createState() => _FPSellSelectSizePageState();
}

class _FPSellSelectSizePageState extends State<FPSellSelectSizePage> {
  ///商品信息
  String _selectSize = '0';
  String _sizeId = '0';
  String _goodName = '';
  String _newHighestBuyPrice = '--',_newLowestSellPrice = '--';
  String _sizeValue = '';
  bool isAgreed = true;

  Map _goodDetailInfo= {};

//  SwiperController _swiperController = SwiperController();

  List _sizeList = [];

  GlobalKey<EasyRefreshState> _easyRefreshKey =
  new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
  new GlobalKey<RefreshHeaderState>();

  _onTapGridViewItem(BuildContext context,int index){
    _selectSize = _sizeList[index]['title'];
    _sizeId = _sizeList[index]['id'];
    setState(() {});
    refreshPrices(goodId: widget.id,sizeId: _sizeId);
  }
  _onTapNextPage(BuildContext context){
    if(_selectSize == ''){
      Fluttertoast.showToast(msg:'请选择尺码',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    UserInfoCache().setMapInfo(key: UserInfoCache.sellInfo, map: {
      'id':widget.id,
      'selectSize':_selectSize,
      'sizeValue':_sizeValue,
      'goodName':_goodName,
      'sizeId':_sizeId,
    });
    print('跳转到选择地址页 with id = ${widget.id},size = $_selectSize');
    Navigator.pop(context);
    Application.router.navigateTo(context, '${Routes.sellPrice}?id=${widget.id}',transition: TransitionType.native);
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

    var goodDetailData = await ApiConfig().goodsDetail(widget.id);
    if(goodDetailData.isNotEmpty && int.parse(goodDetailData['rspCode']) < 1000){
      _goodDetailInfo = goodDetailData;
//      if(_goodDetailInfo['imgList'].isNotEmpty){
//        _swiperController.startAutoplay();
//      }
    }
    else return;

    var sizeData = await ApiConfig().getSizeSellPriceList(comdiId:widget.id,sizeType: _sizeValue);

    if(sizeData.isNotEmpty && int.parse(sizeData['rspCode']) < 1000){
      _sizeList = [];
      _sizeList.addAll(sizeData['list']);
      await refreshPrices(goodId: widget.id,sizeId: _sizeId);
    }
    else return;
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

  @override
  void initState(){
    super.initState();
    refreshGoodsList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//    _swiperController.stopAutoplay();
//    _swiperController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print('go to select size page id = ${widget.id}');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppStyle.colorWhite,
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
                          goodInfoItem(title: '最高买价',content: _newHighestBuyPrice),
                        ],
                      ),
                    ),
                    headerImageView(headImage: _goodDetailInfo['titleImgUrl']),
                    Container(height: ScreenUtil.getInstance().setWidth(20.0),color: Color.fromRGBO(243, 243, 243, 1.0),),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(80.0)),
                    titleSize(context),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(80.0)),
                    GridView.builder(
                        padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
                        itemCount: _sizeList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //横轴元素个数
                          crossAxisCount: 3,
                          //纵轴间距
                          mainAxisSpacing: ScreenUtil.getInstance().setWidth(40.0),
                          //横轴间距
                          crossAxisSpacing: ScreenUtil.getInstance().setWidth(18.0),
                          //子组件宽高长度比例
                          childAspectRatio: 106/48,
                        ),
                        itemBuilder: _gridViewBuilder
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setWidth(120.0)),
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

  Container titleSize(BuildContext context) {
    //尺码标准。1 US美码，2 UK英码，3 EUR欧码，4 JP毫米
    List<DropdownMenuItem> getListData(){
      List<DropdownMenuItem> items=new List();
      DropdownMenuItem dropdownMenuItem1=new DropdownMenuItem(
        child:new Text('US美码'),
        value: '1',
      );
      items.add(dropdownMenuItem1);
      DropdownMenuItem dropdownMenuItem2=new DropdownMenuItem(
        child:new Text('UK英码'),
        value: '2',
      );
      items.add(dropdownMenuItem2);
      DropdownMenuItem dropdownMenuItem3=new DropdownMenuItem(
        child:new Text('EUR欧码'),
        value: '3',
      );
      items.add(dropdownMenuItem3);
      DropdownMenuItem dropdownMenuItem4=new DropdownMenuItem(
        child:new Text('JP毫米'),
        value: '4',
      );
      items.add(dropdownMenuItem4);
      return items;
    }
    return Container(
      width: double.infinity,
      color: AppStyle.colorWhite,
      padding: EdgeInsets.only(
        left: ScreenUtil.getInstance().setWidth(30.0),
        right: ScreenUtil.getInstance().setWidth(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '请选择交易尺码:',
                style: TextStyle(
                  color: AppStyle.colorDark,
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(child: SizedBox(height: 1,)),
              DropdownButton(
                items: getListData(),
//                hint:new Text('下拉选择你想要的数据'),//当没有默认值的时候可以设置的提示
                value: _sizeValue,//下拉菜单选择完之后显示给用户的值
                onChanged: (T){//下拉菜单item点击之后的回调
                  _sizeValue=T;

                  ApiConfig().getSizeSellPriceList(comdiId:widget.id,sizeType: _sizeValue).then((sizeData){


                    if(sizeData.isNotEmpty && int.parse(sizeData['rspCode']) < 1000){
                      _sizeList = [];
                      _sizeList.addAll(sizeData['list']);
                      _selectSize = _sizeList[0]['title'];
                      _sizeId = _sizeList[0]['id'];
                      refreshPrices(goodId: widget.id,sizeId: _sizeId);
                    }
                    else return;

                    setState(() {});

                  });
                },
                elevation: 24,//设置阴影的高度
                style: new TextStyle(//设置文本框里面文字的样式
                  color: AppStyle.colorPrimary,
                ),
//              isDense: false,//减少按钮的高度。默认情况下，此按钮的高度与其菜单项的高度相同。如果isDense为true，则按钮的高度减少约一半。 这个当按钮嵌入添加的容器中时，非常有用
//            iconSize: 50.0,//设置三角标icon的大小
              ),
            ],
          ),
          SizedBox(height: 9,),
          Text(
            _selectSize??'',
            style: TextStyle(
              color: AppStyle.colorDark,
              fontSize: ScreenUtil.getInstance().setSp(40.0),
              fontWeight: FontWeight.w500,
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

  Widget bottomButtonsView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(16.0)),
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
                onTap: () => _onTapNextPage(context),
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
          SizedBox(height: ScreenUtil.getInstance().setWidth(100.0),),
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
              Expanded(flex: 2,child: Container(
                height: 30,
                child: Center(
                  child: Text(
                    '选择商品尺码',
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(24.0),
                      color: AppStyle.colorWhite,
                    ),
                  ),
                ),
              )),
              Expanded(flex: 2,child: Container(height: 1,)),
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

  Widget _gridViewBuilder(BuildContext context , int index){

    String priceString = _sizeList[index]['price'];
    String price = priceString;
//    String price = '¥${int.parse(priceString.replaceRange(0,1, '0'))/100}';

    return GestureDetector(
      onTap:() => _onTapGridViewItem(context,index),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectSize == _sizeList[index]['title'] ? AppStyle.colorDark : AppStyle.colorGreyLine,
            width: _selectSize == _sizeList[index]['title'] ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _sizeList[index]['title'].trim(),
              maxLines: 1,
              style: TextStyle(
                color: AppStyle.colorDark,
                fontSize: ScreenUtil.getInstance().setSp(36.0),
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: <Widget>[
                SizedBox(width: ScreenUtil.getInstance().setWidth(40),),
                Transform.rotate(
                  angle: math.pi*13/16,
                  child: Container(
                    width: ScreenUtil.getInstance().setWidth(80),
                    height: 1,
                    color: AppStyle.colorGreyLine,
                  ),
                ),
              ],
            ),
            Expanded(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: SizedBox(height: 1,)),
                      Text(
                        price,
                        style: TextStyle(
                          color: AppStyle.colorPrimary,
                          fontSize: ScreenUtil.getInstance().setSp(24.0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}

class NavigatorUtil {
  ///跳转到指定页面
  static push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
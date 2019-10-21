

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrabeRecordPage extends StatefulWidget {

  final String title;

  const TrabeRecordPage({Key key, this.title}) : super(key: key);
  @override
  _TrabeRecordPageState createState() => _TrabeRecordPageState();
}





class _TrabeRecordPageState extends State<TrabeRecordPage> with AutomaticKeepAliveClientMixin ,SingleTickerProviderStateMixin{
  TabController _controller;
  List<String> titleName = ['进行中','出价中','历史记录'];
@override
  void initState() {
    if(widget.title == '我的会员仓'){
      titleName = ['寄存中','投递中','历史记录'];
    }
    if(widget.title == '我的出售'){
      titleName = ['进行中','报价中','历史记录'];
    }
    _controller = TabController(
          length: titleName.length, vsync: this); 
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
        children: <Widget>[
          Container(
          height: ScreenUtil.getInstance().setSp(145.0),
          width: double.infinity,
          color: Colors.white,
          child: TabBar(
              controller: _controller,
              labelColor: Colors.black,
              indicatorColor: Color(0xff474747),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: titleName.map((String tab) {
                return Container(
                  alignment: Alignment.center,
                    child:  Text(tab,
                style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28.0)),
                maxLines: 1,
                ),
                );
              }).toList()
              ),
        ),
        Container(
         color: AppStyle.colorWhite,
         height: 3,
         child: Container(
           margin: EdgeInsets.only(left: 20,right: 20),
           color: AppStyle.colorBackground
         ),
        ),
        Flexible(
            child: TabBarView(
                controller: _controller,
                children: titleName.map((String tab) {
                  return TrabeRecordCellPage(name: tab,titles:widget.title);
                }).toList()
                )
                )
        ],
      ),
    );

  }

  @override
  bool get wantKeepAlive => true;
}




///记录item
class TrabeRecordCellPage extends StatefulWidget{
  final String name;
  final String titles;
  const TrabeRecordCellPage({Key key, this.name, this.titles}) : super(key: key);
@override
 _TrabeRecordCellPageState createState() => _TrabeRecordCellPageState();

}

class _TrabeRecordCellPageState extends State<TrabeRecordCellPage> with  AutomaticKeepAliveClientMixin ,SingleTickerProviderStateMixin {
  List items;
  int type = 1;
  int status = 1;
  int listid = 0;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  List arr = [
  ];
  @override
  void initState() {
    super.initState();
    if(widget.titles == '我的购买'){
      type = 1;
    }else if(widget.titles == '我的出售'){
      type = 2;
    }else if(widget.titles == '我的会员仓'){
      type = 3;
    }
    if(widget.name == '进行中' || widget.name == '投递中'){
      status = 2;
    }else if(widget.name == '出价中' || widget.name == '寄存中'|| widget.name == '报价中'){
      status = 1;
    }else if(widget.name == '历史记录'){
      status = 3;
    }
    pullRefresh();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: MediaQuery.removePadding(
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
              bgColor: Colors.transparent,
              textColor: Colors.black87,
              moreInfoColor: Colors.black54,
            ),
            child: ListView.builder(
                itemCount: arr.length,
                itemBuilder: (BuildContext context, int position){
                  if(widget.name == '出价中' || widget.name == '寄存中'|| widget.name == '报价中'){
                       return  _item(context,arr[position]);
                  }
                  if(widget.name == '进行中' || widget.name == '投递中'){
                       return  _itemProceed(context,arr[position]);
                  }
                  if(widget.name == '历史记录'){
                       return  _itemProceed(context,arr[position]);
                  }
                  return null;
                },
            ),
            onRefresh: () async {
              await pullRefresh();
            },
          ),
        ),
      ),
    );
  }

  Future pullRefresh() async {
    if(type == 3){
      //我的会员仓
      ApiConfig().enquiriesDeposit(status.toString()).then((response){
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
          arr = response['list'];
        });
        }
      });
    }else{
      ApiConfig().buySellList(type.toString(), status.toString()).then((response){
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
         if(response['list'] == null){return;}
        //请求成功 刷新页面
        if(mounted){
        setState(() {
          arr = response['list'];
        });
        }
    });
    }
  }


///进行中 投递中
Widget _itemProceed(BuildContext context,Map dic){
  return GestureDetector(
    onTap: (){
      if(type == 3){
        String title = dic['depositId'];
        Application.router.navigateTo(context, Routes.DepositDetailPage+'?name=$title&type=$type',transition: TransitionType.native);
      }else{
        String title = dic['orderNo'];
        Application.router.navigateTo(context, Routes.OrderDetailPage+'?name=$title&type=$type',transition: TransitionType.native);
      }
    },
    child: Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(40),bottom: ScreenUtil.getInstance().setHeight(10)),
          margin: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                  dic['title']??'--',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28),color: AppStyle.colorPrimary),
                  textAlign: TextAlign.start,
                ),
                )
              ),
              Expanded(
                flex: 2,
                child: Text(
                  dic['orderAmt']??'--',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28),color: Colors.black),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Image(
                  width: ScreenUtil.getInstance().setHeight(20),
                  height: ScreenUtil.getInstance().setHeight(20),
                  image: AssetImage(AssetUtil.image('icon_right@3x.png')),
                ),
                )
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
                margin: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(20)),
                height: ScreenUtil.getInstance().setHeight(50),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE9EC),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: <Widget>[
                    Image(
                      width: ScreenUtil.getInstance().setHeight(36),
                      image: AssetImage(AssetUtil.image('Group_9_9@3x.png')),
                    ),
                    SizedBox(width: 4,),
                    Text(type==3?dic['depositStatus']:dic['orderStatus']??'--',
                      style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(ScreenUtil.getInstance().setHeight(34)),color: AppStyle.colorLightDarkText),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setHeight(18),),
                  ],
                ),
              ),
              Expanded(child: Container()),
          ],
        ),
        
              SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
              Container(
                margin: EdgeInsets.only(left: ScreenUtil.getInstance().setHeight(20)),
                width: ScreenUtil.getInstance().setHeight(94),
                height: 4,
                color: AppStyle.colorPrimary,
              )
      ],
    ),
  ),
  );
}

///出价中,寄存中
  Widget _item(BuildContext context,Map dic){
    return GestureDetector(
      onTap: (){
        if(type == 3){
          String title = dic['depositId'];
          String JC = '1';
          Application.router.navigateTo(context, Routes.DepositDetailPage+'?name=$title&type=$JC',transition: TransitionType.native);
      }else{
        String title = dic['orderNo'];
        Application.router.navigateTo(context, Routes.OrderDetailPage+'?name=$title&type=$type',transition: TransitionType.native);
      }
      },
      child: Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Container(
            padding: EdgeInsets.fromLTRB(ScreenUtil.getInstance().setSp(30), 0, ScreenUtil.getInstance().setSp(30), 0),
            child: Column(
              crossAxisAlignment:CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                Text(
                  dic['title']??'--',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28),color: AppStyle.colorPrimary),
                ),
                
                SizedBox(height: ScreenUtil.getInstance().setHeight(20)),
                
                Container(
                  child: Text(
                  dic['orderTime']??'--',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(24),color: AppStyle.colorLightDarkText),
                ),
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                Container(
                  width: ScreenUtil.getInstance().setHeight(94),
                  height: 4,
                  color: AppStyle.colorPrimary,
                )
              ],
            ),
          ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Text(
                  dic['orderAmt']??'--',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28),color: Colors.black),
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(20)),
                Container(
                  child: Text(
                  dic['price']??'--',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28),color: Colors.black),
                ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 6),
              child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil.getInstance().setHeight(20)),
                Image(
                  width: ScreenUtil.getInstance().setHeight(20),
                  image: AssetImage(AssetUtil.image('icon_right@3x.png')),
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(28)),
                Image(
                  width: ScreenUtil.getInstance().setHeight(20),
                  image: AssetImage(AssetUtil.image('icon_down_long@3x.png')),
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(20)),
              ],
            ),
            )
          )
          
        ],
      ),
    ),
    );
  }
   @override
  bool get wantKeepAlive => true;
}
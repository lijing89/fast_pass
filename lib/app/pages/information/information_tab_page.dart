import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/widgets/custom_drop_down_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class informationTapPage extends StatefulWidget {
  final String title;

  const informationTapPage({Key key, this.title}) : super(key: key);
  @override
  _informationTapPageState createState() => _informationTapPageState();
}

class _informationTapPageState extends State<informationTapPage>
    with AutomaticKeepAliveClientMixin ,SingleTickerProviderStateMixin {
  List data = [];
  List items;
  int page = 0;
  int pageSize = 20;
  int listid = 0;
  ScrollController _scrollController = ScrollController();
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  bool _loadMore = true;
  @override
  void initState() {
    // _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // _loadData(loadMore: true);
      }
      
    });
    super.initState();
    if (widget.title == '全部') {
      listid = 0;
    }
    if (widget.title == '资讯') {
      listid = 1;
    }
    if (widget.title == '视频') {
      listid = 2;
    }
    if (widget.title == '测评') {
      listid = 3;
    }
    pullRefresh();
  }
  

  @override
  Widget build(BuildContext context) {
    return data.length == 0
          ? LoadingDialog(
              //调用对话框
              text: '正在加载...',
            )
          : Scaffold(
            backgroundColor: Colors.white,
      body: Container(
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
              itemCount: data.length,
              itemBuilder: (BuildContext context, int position) {
                return _item(context, position);
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
      ),
    );
  }

  Future pullRefresh() async {
    ApiConfig().consultList(listid, pageSize, page).then((response){
        if(response['rspCode'] != '0000'){
            showToast(response['rspDesc']);
            return;
        }
        //请求成功 刷新页面
        if(mounted){
          setState(() {
            data = response['list'];
          });
        }
    });
  }

  Future loadMore() async {
    ApiConfig()
        .consultList(listid, pageSize, page)
        .then((response) {
      if (response['rspCode'] != '0000') {
        Fluttertoast.showToast(
            msg: response['rspDesc'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 2,
            backgroundColor: AppStyle.colorGreyDark,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      //请求成功 刷新页面
      if(response['list'].length < pageSize){
          Fluttertoast.showToast(msg:'没有更多数据啦!',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
          _easyRefreshKey.currentState.waitState(() {
              setState(() {
                  _loadMore = false;
              });
          });
      }else{
          if(mounted){
            setState(() {
              data.addAll(response['list']);
          });
          }
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
  void _pushDetail(BuildContext context,String id){
    Application.router.navigateTo(context, '${Routes.informationDetail}?id=$id',
              transition: TransitionType.native);
    
  }
  @override
  bool get wantKeepAlive => true;

  _item(BuildContext context, int position) {
    Map a = data[position];
    if (a['imgUrl'] != null) {
      return GestureDetector(
        onTap: () {
          _pushDetail(context ,a['id']);
        },
        child:  Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          color: Color(0xFFF5F5F5),
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

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/widgets/fp_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FPSellTipsPage extends StatefulWidget {
  final String id;
  final String type;
  FPSellTipsPage({this.id, this.type = '1'});
  @override
  _FPSellTipsPageState createState() => _FPSellTipsPageState();
}

class _FPSellTipsPageState extends State<FPSellTipsPage> {

  bool _lodaing = true;
  bool _isAgree = true;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:Container(
        width: double.infinity,
        height: double.infinity,
        color: AppStyle.colorPrimary,
        padding: EdgeInsets.zero,
        child: Stack(
          children: <Widget>[
            Container(
              color: AppStyle.colorWhite,
              margin: EdgeInsets.only(
                left: ScreenUtil.getInstance().setWidth(20.0),
                right: ScreenUtil.getInstance().setWidth(20.0),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQueryData.fromWindow(window).padding.top + 56.0,),
                  Expanded(
                    child: Container(
                      child: WebView(
                        initialUrl: 'https://kuaichuan.net:8443/fp-ops/tip/selltip.html',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (WebViewController webViewController) {
//                        _controller.complete(webViewController);
                        },
                        // javascriptChannels: <JavascriptChannel>[
                        //     _toasterJavascriptChannel(context),
                        // ].toSet(),
                        navigationDelegate: (NavigationRequest request) {
//                        if (request.url.startsWith('https//:player.youku.com/embed/XNDEyNDIwNjQ1Ng')) {
//                            print('blocking navigation to $request}');
//                            return NavigationDecision.prevent;
//                        }

                          print('allowing navigation to $request');
                          return NavigationDecision.navigate;
                        },
                        onPageFinished: (String url) {
                          print('Page finished loading: $url');
                          setState(() {
                            _lodaing = false;
                          });
                        },
                      ),
                    ),
                  ),
                  _lodaing
                      ? Container()
                      :Container(
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    width: ScreenUtil.getInstance().setWidth(750),
                    padding: EdgeInsets.only(
                    ),
                    child: Column(
                      children: <Widget>[
                        widget.id == '0'?Container():Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                                value: _isAgree,
                                checkColor: AppStyle.colorDanger,
                                activeColor: Color(0xFFF5F5F5),
                                onChanged: (value){
                                  setState(() {
                                    _isAgree = value;
                                  });
                                }
                            ),
                            Text(
                              '阅读并同意 用户服务条款 和 隐私保护条款',
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(26.0),
                                fontWeight: FontWeight.w600,
                                color: AppStyle.colorGreyText,
                              ),
                            ),
                          ],
                        ),
                        widget.id == '0'?Container():SizedBox(height: ScreenUtil.getInstance().setHeight(80.0),),
                        Container(
                          width: ScreenUtil.getInstance().setWidth(750),
                          height: ScreenUtil.getInstance().setHeight(120.0),
                          color: Color(0xFFF5F5F5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              widget.id == '0'?Container():GestureDetector(
                                onTap: (){
                                  Application.router.pop(context);
                                },
                                child: Container(
                                  width: ScreenUtil.getInstance().setWidth(168.0),
                                  height: ScreenUtil.getInstance().setWidth(74.0),
                                  decoration: BoxDecoration(
                                      color: AppStyle.colorWhite,
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
                              widget.id == '0'?Container():SizedBox(width: ScreenUtil.getInstance().setWidth(30.0),),
                              GestureDetector(
                                onTap: (){
                                  print('go to select size page id = ${widget.id}');
                                  if(widget.id == '0'){
                                    Application.router.pop(context);
                                    return;
                                  }
                                  if(!_isAgree){
                                    showToast('请勾选同意');
                                    return;
                                  }
                                  if(widget.type == '1'){
                                    Navigator.pop(context);
                                    Application.router.navigateTo(context, '${Routes.sellSelectSize}?id=${widget.id}',transition: TransitionType.native);
                                  }else{
                                    Navigator.pop(context);
                                    Application.router.navigateTo(context, '${Routes.sellPrice}?id=${widget.id}',transition: TransitionType.native);
                                  }

                                },
                                child: Container(
                                  width: ScreenUtil.getInstance().setWidth(218.0),
                                  height: ScreenUtil.getInstance().setWidth(74.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(74.0)),
                                    color: AppStyle.colorPink,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.id == '0'?'了解并返回':'了解并同意',
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            barView(context,Theme.of(context).primaryColor),
            _lodaing
                ? Center(
              child: LoadingDialog( //调用对话框
                text: '正在加载...',
              ),
            )
                :Container(),
//            Positioned(
//              bottom:ScreenUtil.getInstance().setWidth(16.0),
//              left: 0,
//              child: _lodaing
//                  ? Container()
//                  :Container(
//                alignment: Alignment.center,
//                color: Colors.transparent,
//                width: ScreenUtil.getInstance().setWidth(750),
//                padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(32.0)),
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  children: <Widget>[
//                    widget.id == '0'?Container():Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Checkbox(
//                            value: _isAgree,
//                            checkColor: AppStyle.colorWarning,
//                            activeColor: AppStyle.colorWhite,
//                            onChanged: (value){
//                              setState(() {
//                                _isAgree = value;
//                              });
//                            }
//                        ),
//                        SizedBox(width: ScreenUtil.getInstance().setWidth(30.0),),
//                        Text(
//                          '阅读并同意 用户服务条款 和 隐私保护条款',
//                          style: TextStyle(
//                            fontSize: ScreenUtil.getInstance().setSp(26.0),
//                            fontWeight: FontWeight.w600,
//                            color: AppStyle.colorGreyText,
//                          ),
//                        ),
//                      ],
//                    ),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        widget.id == '0'?Container():GestureDetector(
//                          onTap: (){
//                            Application.router.pop(context);
//                          },
//                          child: Container(
//                            width: ScreenUtil.getInstance().setWidth(168.0),
//                            height: ScreenUtil.getInstance().setWidth(74.0),
//                            decoration: BoxDecoration(
//                                color: AppStyle.colorWhite,
//                                borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(74.0)),
//                                border: Border.all(
//                                  color: AppStyle.colorGreyText,
//                                  width: 0.5,
//                                )
//                            ),
//                            child: Center(
//                              child: Text(
//                                '取消',
//                                style: TextStyle(
//                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
//                                  fontWeight: FontWeight.w600,
//                                  color: AppStyle.colorDark,
//                                ),
//                              ),
//                            ),
//                          ),
//                        ),
//                        widget.id == '0'?Container():SizedBox(width: ScreenUtil.getInstance().setWidth(30.0),),
//                        GestureDetector(
//                          onTap: (){
//                            print('go to select size page id = ${widget.id}');
//                            if(widget.id == '0'){
//                              Application.router.pop(context);
//                              return;
//                            }
//                            if(!_isAgree){
//                              showToast('请勾选同意');
//                              return;
//                            }
//                            if(widget.type == '1'){
//                              Navigator.pop(context);
//                              Application.router.navigateTo(context, '${Routes.sellSelectSize}?id=${widget.id}',transition: TransitionType.native);
//                            }else{
//                              Navigator.pop(context);
//                              Application.router.navigateTo(context, '${Routes.sellPrice}?id=${widget.id}',transition: TransitionType.native);
//                            }
//
//                          },
//                          child: Container(
//                            width: ScreenUtil.getInstance().setWidth(218.0),
//                            height: ScreenUtil.getInstance().setWidth(74.0),
//                            decoration: BoxDecoration(
//                              borderRadius: BorderRadius.circular(ScreenUtil.getInstance().setWidth(74.0)),
//                              color: AppStyle.colorPink,
//                            ),
//                            child: Center(
//                              child: Text(
//                                widget.id == '0'?'了解并返回':'了解并同意',
//                                style: TextStyle(
//                                  fontSize: ScreenUtil.getInstance().setSp(28.0),
//                                  fontWeight: FontWeight.w600,
//                                  color: AppStyle.colorWhite,
//                                ),
//                              ),
//                            ),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ],
//                ),
//              ),
//            ),
          ],
        ),
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
  List<Widget> contentViews({@required List contents}){

    if(contents.isEmpty)return [Container(
        height: 200,
        width: double.infinity,
        child: Center(
          child: Text('暂无数据'),
        ),
    )];

    List<Widget> contentViews = [];
    for(Map item in contents){
      contentViews.add(Container(
        margin: EdgeInsets.only(
          left: ScreenUtil.getInstance().setWidth(40.0),
          right: ScreenUtil.getInstance().setWidth(40.0),
          bottom: ScreenUtil.getInstance().setWidth(80.0),
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item['title'],
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(32.0),
                fontWeight: FontWeight.w500,
                color: AppStyle.colorDark,
              ),
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(40.0),),
            Text(
              item['content'],
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(24.0),
                fontWeight: FontWeight.w400,
                color: AppStyle.colorDark,
              ),
            ),
          ],
        ),
      ));
    }
    return contentViews;
  }
}

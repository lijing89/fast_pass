import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_umeng_analytics/flutter_umeng_analytics.dart';

import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';

import 'package:fast_pass/app/providers/cart_provider.dart';
import 'package:fast_pass/app/providers/gift_provider.dart';
import 'package:fast_pass/app/pages/home/fp_index_page.dart';
import 'package:fast_pass/app/resources/app_style.dart';

class App extends StatefulWidget {
    App({Key key}) : super(key: key);
    @override
    _AppState createState() => _AppState();
}

class _AppState extends State<App> {
   
    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        if (Platform.isAndroid) {
            //设置Android头部的导航栏透明
            SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
            SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        }
        return MultiProvider(
            providers:[
                ChangeNotifierProvider(builder: (_) => CartProvider()),
                ChangeNotifierProvider(builder: (_) => GiftProvider()),
            ],
            child: OKToast(
                /// set toast style, optional
                child:MaterialApp(
                    title: '快传',
                    theme: ThemeData(
                        platform: TargetPlatform.iOS,
                        primaryColor: AppStyle.colorPrimary,
                        scaffoldBackgroundColor: AppStyle.colorBackground,
                    ),

                    home: FPIndexPage(),
                    debugShowCheckedModeBanner: false,
                ),
            ),
        );
    }
}



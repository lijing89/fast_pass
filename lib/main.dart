import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simple_cache/simple_cache.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// 注册缓存对象
  Application.cache = await SimpleCache.getInstance();
  /// 注册路由
  final Router router = Router();
  Routes.configureRoutes(router);
  Application.router = router;

  /// 强制竖屏
  ///
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  print('fluwx register');
//
  await fluwx.registerWxApi(
      appId: "wxe5f5c4d986f28664",
      doOnAndroid: true,
      doOnIOS: true,
      // enableMTA:false,
     universalLink: 'https://kuaichuan.net/'
  );

  var result = await fluwx.isWeChatInstalled();

  print('fluwx register $result');

  /// 运行
  runApp(App());

  FlutterStatusbarcolor.setStatusBarWhiteForeground(true);

}


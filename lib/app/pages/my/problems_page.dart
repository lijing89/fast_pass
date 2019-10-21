import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';

class ProblemsPage extends StatefulWidget {
  @override
  _ProblemsPageState createState() => _ProblemsPageState();
}

class _ProblemsPageState extends State<ProblemsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('问题反馈'),
      ),
      body: Center(
        child: Text('问题反馈'),
      ),
    );
  }
}

import 'package:fast_pass/app/widgets/fp_webview.dart';
import 'package:flutter/material.dart';

class FQAPage extends StatefulWidget{
@override
  _FQAPageState createState() =>_FQAPageState();
}

class _FQAPageState extends State<FQAPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(0),
        child: WebViewState(url: 'https://v.qq.com/x/page/l0830qezclh.html',title: 'FAQ',)
      )
    );
  }
}
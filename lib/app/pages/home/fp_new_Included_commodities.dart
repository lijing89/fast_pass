import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:fast_pass/app/widgets/fp_dialog.dart';

class FPNewIncludedCommoditiesPage extends StatefulWidget {
  @override
  _FPNewIncludedCommoditiesPageState createState() => _FPNewIncludedCommoditiesPageState();
}

class _FPNewIncludedCommoditiesPageState extends State<FPNewIncludedCommoditiesPage> with SingleTickerProviderStateMixin{

  TextEditingController _nameController = TextEditingController();

  TextEditingController _brandController = TextEditingController();

  TextEditingController _sizeController = TextEditingController();

  TextEditingController _colorController = TextEditingController();

  TextEditingController _otherController = TextEditingController();


  Future uploadRequest({BuildContext context}) async {

    String name = _nameController.text??'';
    String brand = _brandController.text??'';
    String size = _sizeController.text??'';
    String color = _colorController.text??'';
    String other = _otherController.text??'';
    if(name == ''){
      Fluttertoast.showToast(msg:'请输入商品名称信息',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    if(brand == ''){
      Fluttertoast.showToast(msg:'请输入品牌和系列信息',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    if(size == ''){
      Fluttertoast.showToast(msg:'请输入款式和尺码信息',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    if(color == ''){
      Fluttertoast.showToast(msg:'请输入颜色信息',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
      return;
    }
    //显示加载动画
    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog( //调用对话框
            text: '正在获取详情...',
          );
        });
    var response = await ApiConfig().uploadNewIncluded(
      comdiName:name,
      comdiBrand:brand,
      styleSize: size,
      color: color,
      desc: other
    );
    //退出加载动画
    Navigator.pop(context); //关闭对话框

    if(response == null){return;}
    if(response['rspCode'] != '0000'){return;}
    if(response['rspCode'] == '1000'){//用户在其他设备登录
      showOneButtonDiaLog(context, '账号在其他设备登录', '如不是本人操作请及时修改密码', (){});
    }
    showToast('已提交商品收录申请,我们会尽快处理的!');
    //简单计时器
    Timer(Duration(seconds: 2),(){
      Application.router.pop(context);
    });

  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: mydrawer,
      appBar: AppBar(
        leading: IconButton(
          highlightColor: AppStyle.colorPrimary,
          splashColor: AppStyle.colorPrimary,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('提交商品收录申请'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: ScreenUtil.getInstance().setWidth(80.0),
          right: ScreenUtil.getInstance().setWidth(80.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
              Text(
                '提交您的商品信息，以便我们可以发现并收录它。',
                style: TextStyle(
                  color: AppStyle.colorGreyText,
                  fontSize: ScreenUtil.getInstance().setSp(28.0),
                  fontWeight: FontWeight.w300,
                ),
              ),
              titleInputView(title: '商品名称',controller: _nameController),
              titleInputView(title: '品牌和系列',controller: _brandController),
              titleInputView(title: '款式和尺码',controller: _sizeController),
              titleInputView(title: '颜色',controller: _colorController),
              titleInputView(title: '其他介绍',lineNum:4,controller: _otherController),
              SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
              GestureDetector(
                onTap: (){
                  uploadRequest(context: context);
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
                      '提交申请',
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(28.0),
                        fontWeight: FontWeight.w600,
                        color: AppStyle.colorWhite,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.getInstance().setWidth(80.0),),
            ],
          ),
        ),
      ),
    );
  }


  Widget titleInputView({String title,int lineNum,TextEditingController controller}){
    lineNum = lineNum??1;
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
          Text(
            title,
            style: TextStyle(
              color: AppStyle.colorPrimary,
              fontSize: ScreenUtil.getInstance().setSp(28.0),
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: ScreenUtil.getInstance().setWidth(16.0),),
          TextField(
            controller: controller,
            maxLines: lineNum,//最大行数
            decoration: InputDecoration(
              border: OutlineInputBorder()
            ),
            textAlign: TextAlign.start,//文本对齐方式
            style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(28.0), color: AppStyle.colorPrimary),//输入文本的样式
            onChanged: (text) {//内容改变的回调
              print('change $text');
            },
            onSubmitted: (text) {//内容提交(按回车)的回调
              print('submit $text');
            },
            enabled: true,//是否禁用
          ),
        ],
      ),
    );
  }
}

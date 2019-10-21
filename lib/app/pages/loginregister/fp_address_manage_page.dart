import 'package:city_pickers/city_pickers.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/fp_count.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:fast_pass/app/widgets/app_bar.dart';
import 'package:fast_pass/app/widgets/drawer_view.dart';
import 'package:flutter/material.dart';

class AddressManagePage extends StatefulWidget {
  final String number;

  const AddressManagePage({Key key, this.number = '1'}) : super(key: key);
  @override
  _AddressManagePageState createState() =>
      _AddressManagePageState();
}

class _AddressManagePageState extends State<AddressManagePage>
    with SingleTickerProviderStateMixin {
  List ar = [];
  Map detail = {
  };
  bool _isLogin = false; //是否登录
  String imgUrl = '';
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  Map userMap = {};
  List shdz = [];
  ///城市选择器
  String _city = '选择城市';
  Map userAddress = {'province':'','city':'','district':'','addr':'','name':'','phone':''};
  CountModule count = new CountModule('地址管理');
   TextEditingController _addressController;
  TextEditingController _putNameController;
  TextEditingController _putNumberController;
  bool _citySelected = false;//修改收件地址
  final registerFormKey = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();
  String phoneNumber= '',password='',name='',email='',changeCode = '',smsReqSn='',address='',putName='',putNumber='',imgCode='',imageNetString='',reqSn='';
  String verificationCode;
  int selterNumber;

  TextEditingController _imageController;
  TextEditingController _yzmController;

_show(context) async{
    Result temp  = await CityPickers.showCityPicker(
      context: context,
      height: 400,
      cancelWidget: Text('取消', style: TextStyle()),
      confirmWidget: Text('确定', style: TextStyle())
    );
    setState(() {
      if(temp == null) return;
      _city = (temp.provinceName??'') + '  ' + (temp.cityName??'')+'  ' + (temp.areaName??'');
      userAddress['province'] = temp.provinceName??'';
      userAddress['city'] = temp.cityName??'';
      userAddress['district'] = temp.areaName??'';
    });
  }
  @override
  void initState() {
    super.initState();
    count.openPage();
    WidgetsBinding bind = WidgetsBinding.instance;
    bind.addPostFrameCallback((callback) {
      //加载数据
      getUserMessage();
    });
  }
   getUserMessage(){
    ApiConfig().getAccount().then((onValue){
       if(onValue == null){return;}
       if(onValue['rspCode'] != '0000'){
          Fluttertoast.showToast(msg:onValue['rspDesc'],
          toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0
          );
          return;
       }
       UserInfoCache().setUserInfo(userInfo: onValue);
       UserInfoCache().saveInfo(key: UserInfoCache.loginStatus,value: '1');
       userMap = onValue;
       shdz = [];
       for (var item in onValue['addrs']??[]) {
           if(item['type'] == widget.number){
             shdz.add(item);
           }
         }
       if(mounted){
         setState(() {
       });
       }
     });

  }
  @override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      UserInfoCache().getInfo(key: UserInfoCache.loginStatus).then((onValue){
        setState(() {
          _isLogin = onValue == '1'?true:false;
        });
    });
    }
  }

///退出登录设置
leaveLogIn(BuildContext context){
  setState(() {
    _isLogin = false;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: mydrawer,
      drawerScrimColor: Colors.transparent,
      key: _scaffoldkey,
      backgroundColor: Colors.white,
      appBar: myappbar(context, true, _isLogin,sckey: _scaffoldkey,leaveLogIn: leaveLogIn,image: imgUrl),
      body: userMap.length == 0
          ? LoadingDialog(
              //调用对话框
              text: '正在加载...',
            )
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.all(0),
                  child: GestureDetector(
                    onTap: (){
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: ListView(
                      controller: _scrollController,
                      children: <Widget>[
                         ListView.builder(
                            shrinkWrap:true,
                            physics:NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                            itemCount: shdz.length,
                            itemBuilder: (BuildContext context, int position){
                              Map item = shdz[position];
                              return  Container(
                                decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              border: Border.all(
                                color: AppStyle.colorBackground,
                                width: 1,
                                    )
                                ),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 9,
                                      child: GestureDetector(
                                        onTap: (){
                                        UserInfoCache().setMapInfo(key: UserInfoCache.buyInfo, map: {
                                                'name':item['name'],
                                                'phone':item['phone'],
                                                'province':item['province'],
                                                'city':item['city'],
                                                'district':item['district'],
                                                'addr':item['addr']
                                            });
                                          Application.router.pop(context);
                                        },
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  child: Text(item['name'],style: TextStyle(fontSize: 18,color: AppStyle.colorPrimary)),
                                                ),
                                                SizedBox(width: 10,),
                                                Container(
                                                  child: Text(item['phone'],style: TextStyle(fontSize: 14,color: AppStyle.colorPrimary)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                                  child: Text(item['province']+'  '+item['city']+'  '+item['district']+'  '+item['addr'],style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary),maxLines: 4,),
                                                ),
                                        ],
                                      ),
                                    ),
                                    ),
                                    Container(width: 0.8,height: 40,color: AppStyle.colorBackground,),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        alignment: Alignment.topCenter,
                                        child: FlatButton(
                                          padding: EdgeInsets.all(0),
                                      child: new Text('编辑'),
                                      onPressed: () {
                                        setState(() {
                                          selterNumber = position;
                                          _citySelected = true;
                                          _city = item['province']+'  '+item['city']+'  '+item['district'];
                                          _putNumberController = TextEditingController(text: item['phone']);
                                          _putNameController = TextEditingController(text: item['name']);
                                          _addressController = TextEditingController(text: item['addr']);
                                          userAddress['province'] = item['province'];
                                          userAddress['city'] = item['city'];
                                          userAddress['district'] = item['district'];
                                          userAddress['phone'] = item['phone'];
                                          userAddress['name'] = item['name'];
                                          userAddress['addr'] = item['addr'];
                                          userAddress['addId'] = item['addId'];
                                          userAddress['type'] = item['type'];
                                        });
                                        //滚动
                                        _scrollController.animateTo(_scrollController.position.maxScrollExtent,duration: Duration(milliseconds: 500),curve: Curves.decelerate);
                                      },
                                  ),
                                      )
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          //地址选择器
          Container(
            padding: EdgeInsets.only(left: 20,top: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child:  Text('城市',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  flex: 7,
                  child: GestureDetector(
            onTap: () {
                this._show(context);
              },
            child: Text(_city,style: TextStyle(fontSize: 16,color: Color(0xFF979797),fontWeight: FontWeight.w500)),
          ),
                )
              ],
            )
          ),
          //地址
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text('详细地址',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 7,
                child: TextField(
                  maxLines: 2,
                controller: _addressController,
                decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: AppStyle.colorLightDarkText,
                        fontSize: 14,
                        
                    ),
                    helperStyle: TextStyle(
                        color: Color(0xFF979797)

                    ),
                    
                ),
                style: TextStyle(
                    color: Color(0xFF979797)
                ),
                onChanged: (value){
                  //输入改变
                  phoneNumber = value;
                  userAddress['addr'] = value;
                },
                //完成编辑
                onEditingComplete:(){
                  print('aaa');
                }

            ),
              )
            ],
          ),
          ),

          //收发件人
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text('收发件人',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 7,
                child: TextField(
                  controller: _putNameController,
                decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: AppStyle.colorLightDarkText,
                        fontSize: 14,
                    ),
                    helperStyle: TextStyle(
                        color: Color(0xFF979797)

                    ),
                    
                ),
                style: TextStyle(
                    color: Color(0xFF979797)
                ),
                onChanged: (value){
                  //输入改变
                  phoneNumber = value;
                  userAddress['name'] = value;
                },
                //完成编辑
                onEditingComplete:(){

                }

            ),
              )
            ],
          ),
          ),

          //手机号
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text('手机号',style: TextStyle(fontSize: 16,color: AppStyle.colorPrimary,fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 7,
                child: TextField(
                controller: _putNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: AppStyle.colorLightDarkText,
                        fontSize: 14,
                        
                    ),
                    helperStyle: TextStyle(
                        color: Color(0xFF979797)

                    ),
                    
                ),
                style: TextStyle(
                    color: Color(0xFF979797)
                ),
                onChanged: (value){
                  //输入改变
                  userAddress['phone'] = value;
                },
                //完成编辑
                onEditingComplete:(){

                }

            ),
              )
            ],
          ),
          ),
          Container(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              _citySelected ? MaterialButton(
                 color: AppStyle.colorWhite,
                    shape:new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)) ,
                  textColor: AppStyle.colorPrimary,
                  child: new Text('删除联系人'),
                  onPressed: () {
                    if(alidate() == false){
                      Fluttertoast.showToast(msg:'请完善信息',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                        return;
                    }
                    if(_citySelected){
                      //删除联系人
                      ApiConfig().removePerson(userAddress['addId']).
                      then((onValue){
                        if(onValue == null){return;}
                            if(onValue['rspCode'] != '0000'){
                                Fluttertoast.showToast(
                                      msg: onValue['rspDesc'],
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 2,
                                      backgroundColor: AppStyle.colorGreyDark,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  
                                  return;
                              }
                          getUserMessage();
                          userAddress = {};
                          selterNumber = null;
                          _citySelected = false;
                          _city = '点我选择地址';
                           _putNumberController = TextEditingController(text: '');
                           _putNameController = TextEditingController(text: '');
                           _addressController = TextEditingController(text: '');
                          Fluttertoast.showToast(
                                      msg: '删除成功',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 2,
                                      backgroundColor: AppStyle.colorGreyDark,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                      });
                    }else{
                      //添加寄件人
                      ApiConfig().addPerson('2', userAddress['province'], userAddress['city'], userAddress['district'], userAddress['addr'], userAddress['name'], userAddress['phone']).
                      then((onValue){
                        if(onValue == null){return;}
                            if(onValue['rspCode'] != '0000'){
                                Fluttertoast.showToast(
                                      msg: onValue['rspDesc'],
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 2,
                                      backgroundColor: AppStyle.colorGreyDark,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  return;
                              }
                          getUserMessage();
                                userAddress = {};
                                selterNumber = null;
                          _citySelected = false;
                          _city = '点我选择地址';
                           _putNumberController = TextEditingController(text: '');
                           _putNameController = TextEditingController(text: '');
                           _addressController = TextEditingController(text: '');
                          Fluttertoast.showToast(
                                      msg: '添加成功',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 2,
                                      backgroundColor: AppStyle.colorGreyDark,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                      });
                    }
                  },
                ):Container(),
                _citySelected ?SizedBox(width: 20):Container(),
                MaterialButton(
                   color: AppStyle.colorWhite,
                    shape:new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)) ,
                  textColor: AppStyle.colorPrimary,
                  child: new Text(_citySelected ?'  编辑完成  ':'   添加地址   '),
                  onPressed: () {
                    if(alidate() == false){
                      Fluttertoast.showToast(msg:'请完善信息',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                        return;
                    }
                    if(_citySelected){
                      //修改
                      ApiConfig().alterPerson(userAddress['addId'],userAddress['type'], userAddress['province'], userAddress['city'], userAddress['district'], userAddress['addr'], userAddress['name'], userAddress['phone']).
                      then((onValue){
                        if(onValue == null){return;}
                            if(onValue['rspCode'] != '0000'){
                                Fluttertoast.showToast(
                                      msg: onValue['rspDesc'],
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 2,
                                      backgroundColor: AppStyle.colorGreyDark,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  return;
                              }
                          getUserMessage();
                                userAddress = {};
                                selterNumber = null;
                          _citySelected = false;
                          _city = '点我选择地址';
                           _putNumberController = TextEditingController(text: '');
                           _putNameController = TextEditingController(text: '');
                           _addressController = TextEditingController(text: '');
                          Fluttertoast.showToast(
                                      msg: '修改成功',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 2,
                                      backgroundColor: AppStyle.colorGreyDark,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                      });
                    }else{
                      //添加为收件人
                      ApiConfig().addPerson(widget.number, userAddress['province'], userAddress['city'], userAddress['district'], userAddress['addr'], userAddress['name'], userAddress['phone']).
                      then((onValue){
                        if(onValue == null){return;}
                            if(onValue['rspCode'] != '0000'){
                                Fluttertoast.showToast(
                                      msg: onValue['rspDesc'],
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIos: 2,
                                      backgroundColor: AppStyle.colorGreyDark,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  return;
                              }
                          getUserMessage();
                                userAddress = {};
                                selterNumber = null;
                          _citySelected = false;
                          _city = '点我选择地址';
                           _putNumberController = TextEditingController(text: '');
                           _putNameController = TextEditingController(text: '');
                           _addressController = TextEditingController(text: '');
                          Fluttertoast.showToast(msg:'添加成功',toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 2,
                        backgroundColor: AppStyle.colorGreyDark,
                        textColor: Colors.white,
                        fontSize: 16.0);
                      });
                    }
                  },
                )
              ],
            ),
          ),
          SizedBox(height: 20,)
                      ],
                    ),
                  )
                ),
                Positioned(
                  bottom: 20.0,
                  left: 20.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppStyle.colorWhite,
                    ),
                    child: IconButton(
                      color: AppStyle.colorPrimary,
                      icon: Icon(
                        Icons.drag_handle,
                        size: 30.0,
                      ),
                      onPressed: () {
                        _scaffoldkey.currentState.openDrawer();
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

   ///添加或修改验证
     bool alidate(){
      if(userAddress['phone'] == '' || Application.isChinaPhoneLegal(userAddress['phone']??'') == false){
        return false;
      }
      if(userAddress['name'] == ''){
        return false;
      }
      if(userAddress['addr'] == ''){
        return false;
      }
      return true;

    }

  @override
  void dispose() {
    super.dispose();
    _addressController?.dispose();
    _putNameController?.dispose();
    _putNumberController?.dispose();
    _scrollController?.dispose();
    count.endPage();
  }

}
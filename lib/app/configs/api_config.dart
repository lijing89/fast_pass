import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:fast_pass/app/resources/user_info_cache.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:crypto/crypto.dart';
class ApiConfig {

     static const String FPURL = 'https://fp.rongxinhui.com/';

    /// SESSION-ID 的键名
    static const String sessionId = 'SESSION-ID';
    static const String baseUrl = 'http://wallet.ys.wangqi.vc';
    static const String path = '';
    /*
    *
    * {"message":{"user":{"id":"30","name":"11111","email":"13333333333@no.com","head_pic":null,"status":"1","rec_uid":"23","group_id":"0","real_name":null,"is_wine":"0","user_id":"30","login_time":"2019-06-26 19:38:58","mobile":"13333333333","rz":"0"},"securityCookie":"6150a1c86bAQFSBAlWAAIHUlIDDQdTUFdSXlcBDwRVUV1TU1APBFcAAgMDHRYMUltAU1JXDhYIQBIKQQgFDEQIBldSABcLQgINDxoUA0tDFQsQBhEOEglSBwtDUVwLBgwPUFUEAVQEUAQBUVpaA1wAUQcIAVZRAQACAVZBC0cDAVgQEVsLAxERWFsVQwsLWQUBUgRWAAYKWFkCHA"},"error":0,"type":"success"}
    * */
    static const String loginUrl = '/SimpleApi/login'; //登录接口account password  ceshi 111111
    static const String refreshUssUrl = '/UcenterApi/refresh_uss'; //刷新USS交易
    /*
        发送手机验证码
        http://wallet.ys.wangqi.vc/SimpleApi/send_code
        参数 account手机号
    * */
    static const String verificationCodeUrl = '/AjaxApi/send_sms';

    /*
        注册接口
        http://wallet.ys.wangqi.vc/SimpleApi/reg_act
        参数:
        mobile 电话
        password 密码
        repassword 确认密码
        mobile_code 短信验证吗
        rec_name  推荐人手机号 13930377135 18230303580
        ppassword 支付密码
    * */
    static const String registerUrl = '/SimpleApi/reg_act';

    /*
        助记词接口
        http://wallet.ys.wangqi.vc/UcenterApi/get_mnemonic
        参数:
    * */
    static const String helpWordUrl = '/SimpleApi/get_mnemonic';

    /*
        账户数据
         http://wallet.ys.wangqi.vc/UcenterApi/show_uss
        参数:
    * */
    static const String assetsUrl = '/UcenterApi/show_uss';

    /*
        sessionId
        http://tianshi.ys.wangqi.vc/indexApi/sessionId
        参数:
    * */
    static const String sessionIdUrl = '/indexApi/sessionId';

    /*
        uss释放记录 千分之0.5
        http://tianshi.ys.wangqi.vc/UcenterApi/show_one_log
        参数:
    * */
    static const String ussReleaseRecordOneUrl = '/UcenterApi/show_one_log';

    /*
        uss释放记录 千分之1
        http://tianshi.ys.wangqi.vc/UcenterApi/show_two_log
        参数:
    * */
    static const String ussReleaseRecordTwoUrl = '/UcenterApi/show_two_log';

    /*
        uss释放记录 市场奖励
        http://tianshi.ys.wangqi.vc/UcenterApi/show_market_log
        参数:
    * */
    static const String ussReleaseMarketUrl = '/UcenterApi/show_market_log';

    /*
        btc提现记录
        http://tianshi.ys.wangqi.vc/UcenterApi/get_btc_log
        参数:
            BTC提现记录 status 0 申请 1 同意 2 拒绝 3 完成
        返回值:
    * */
    static const String btcCashRecordUrl = '/UcenterApi/get_btc_log';

    /*
        btc提现申请
        http://tianshi.ys.wangqi.vc/UcenterApi/get_btc
        参数:
    * */
    static const String cashBtcUrl = '/UcenterApi/get_btc';

    /*
        校验支付密码
        http://tianshi.ys.wangqi.vc/UcenterApi/get_btc_verified
        参数:
            code 密码
            type  paypwd		类型
            obj   paypwd		类型
    * */

    static const String verifiedPPasswordUrl = '/UcenterApi/get_btc_verified';
    /*
        修改用户信息
        http://tianshi.ys.wangqi.vc/UcenterApi/update_obj_info
        参数:
            obj 为 password 修改登陆密码
            obj 为 paypwd   修改支付密码
            obj 为 title    修改昵称
            password        旧密码
            repassword      新密码
            user_title      昵称
    * */


    static const String updateUserInfoUrl = baseUrl + '/UcenterApi/update_obj_info';

    /*获取个人信息*/
    static const String getMyInfoUrl = baseUrl + '/UcenterApi/info';

    /*
        实名认证
        http://tianshi.ys.wangqi.vc/UcenterApi/ientification
        参数:
            mobile_code 短信验证码
            real_name   真实姓名
            idcard      身份证号码

            before_card  正面
            after_card   反面
            photo_card   手持
            {"message":"身份认证信息提交成功！等待确认!","error":0,"type":"success"}
    * */
    static const String realNameAuthenticationUrl = '/UcenterApi/identification';
    /*
        关于我们
        http://tianshi.ys.wangqi.vc/indexApi/article/id/2
        参数:
    * */
    static const String aboutUrl = baseUrl +'/indexApi/article/id/2';
    /*
        常见问题
        http://tianshi.ys.wangqi.vc/indexApi/article/id/3
        参数:
    * */
    static const String questionUrl = baseUrl +'/indexApi/article/id/3';
    /*
        我的团队
        http://tianshi.ys.wangqi.vc/UcenterApi/team
        参数:
    * */
    static const String teamUrl = baseUrl + '/UcenterApi/team';
    /*
        意见反馈
        http://tianshi.ys.wangqi.vc/UcenterApi/ask_question
        参数:
    * */
    static const String feedBackUrl = '/UcenterApi/ask_question';

    /*上传头像*/
    static const String uploadHeadUrl = '/UcenterApi/upload_head';

    /*推广*/
    static const String extensionUrl = '/UcenterApi/photo_make';




  ///设备信息
  Future<Map<String,dynamic>> getDeviceInfo(String funcNo) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
  Map<String,dynamic> dic = {};
  bool ios = Platform.isIOS;  //操作系统类型
  String version = packageInfo.version;//app版本信息
  dic['funcNo'] = funcNo;
  dic['reqSn'] = reqsnString(funcNo, readTimestamp());
  dic['version'] = 'v1.0';
  dic['reqTime'] = int.parse(readTimestamp());
  dic['appVersion'] = 'v$version';
  dic['osType'] = ios?2:1;
  //登录后返回
 var islog = await UserInfoCache().getInfo(key: UserInfoCache.loginStatus)??'';
 if(islog =='1'){
    var onV = await UserInfoCache().getUserNo()??{};
          dic['userNo'] = onV['userNo'];
 }else{
   dic['userNo'] = 'FASTPASS';
 }


  if(Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;   
    String uuid =  androidInfo.androidId;//唯一标识 
    String verison = androidInfo.version.sdkInt.toString();
    dic['osVersion'] = verison;
    dic['tid'] = uuid;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    String systemVersion =  iosInfo.systemVersion;//系统版本
    String uuid = iosInfo.identifierForVendor;//uuid唯一标识
    dic['osVersion'] = systemVersion;
    dic['tid'] = uuid;
  }
  return dic;
}

///reqSn 请求流水号
String reqsnString(String funcNo,String time){
  String s = funcNo + time;
  var content = new Utf8Encoder().convert(s);
  var digest = md5.convert(content);
  String md =  digest.toString();
  String md30 =  md.substring(0,29);
  return md30;
}

///获取请求时间
String readTimestamp() {
    var now = new DateTime.now().millisecondsSinceEpoch;
    int len = now.toString()?.length;
      if(len == 10){
        now = now * 1000;
      }
    var formatter = new DateFormat('yyyyMMddHHmmss');
    DateTime dateTime = new DateTime.fromMillisecondsSinceEpoch(now, isUtc: false);
    String date = formatter.format(dateTime);
    return date;
}
  ///加密
String mdBase(String data){
  //5
  var content = new Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  String md =  digest.toString();
  //64
  var contentb = utf8.encode(md);
  var digestb = base64Encode(contentb);
  return digestb;
}
///初始化方法
 Future<Map<dynamic,dynamic>> initRequest() async => getDeviceInfo('#000001').then((onValue){
       return onValue;
   });
///检测app版本
Future<Map> appVersion() async{
   var onValue = await getDeviceInfo('#000002');
  //  String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
   dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
   return response;
  }

///上传图片
Future<Map> updateImage(var image) async{
   var onValue = await getDeviceInfo('#000003');
   String path = image.path;
  var name = path.substring(path.lastIndexOf("/") + 1, path.length);
  var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
  Map data = Map<String,dynamic>();
  data['imgFile'] = UploadFileInfo(File(path), name,
      contentType: ContentType.parse("image/$suffix"));
  FormData formData = new FormData.from(data);
  
//64
  var contentb = utf8.encode(formData.toString());
  var digestb = base64Encode(contentb);
  onValue['img'] = digestb;
  //  String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
   String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
   dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
   return response;
  }
///发送短信验证码
Future<Map> sendMessage(String type,String phone) async{
   var onValue = await getDeviceInfo('#000004');
   onValue['type'] = type;
   onValue['phone'] = phone;
  //  String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
   dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
   return response;
  }
///获取图形验证码
Future<Map> obtainImage (int type) async{
  //获取设备信息(通用参数)
  var onValue = await getDeviceInfo('#000005');
  onValue['type'] = type;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}
///发送邮箱验证码
Future<Map> sendEmail(String type,String email) async{
   var onValue = await getDeviceInfo('#000006');
  onValue['type'] = type;
  onValue['email'] = email;
  String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sign = mdBase('${onValue.toString()}$sessionId');
  onValue['sign'] = sign;
  dynamic response = await HttpUtil.getInstance().post('',data: onValue);
  return response;
  }
///获取协议内容
Future<Map> obtainNegotiate(String type) async{
  var onValue = await getDeviceInfo('#000007');
  onValue['type'] = type;
  String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sign = mdBase('${onValue.toString()}$sessionId');
  onValue['sign'] = sign;
  dynamic response = await HttpUtil.getInstance().post('',data: onValue);
  return response;
  }

///账号功能
///
///注册账号
Future<Map> registerUser(String userName,String email,String phone,String smsReqSn,String smsCode,String pwd)async{
  var onValue = await getDeviceInfo('#010001');
  onValue['userName'] = userName;
  onValue['email'] = email;
  onValue['phone'] = phone;
  onValue['smsReqSn'] = smsReqSn;
  onValue['smsCode'] = logInJM(smsCode);
  onValue['pwd'] = logInJM(pwd);
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('${onValue.toString()}$sessionId');
  onValue['sign'] = sign;
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
  String logInJM(String data){
    //5
  var content = new Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  //64
  var digestb = base64Encode(digest.bytes);
  return digestb;
  }
///登录账号
Future<Map> verbUser(String type,{String userName,String phone,String smsReqSn,String smsCode,String pwd})async{
  var onValue = await getDeviceInfo('#010003');
  onValue['type'] = type;
  if(type == '1'){
    onValue['userName'] = userName;
    onValue['pwd'] = logInJM(pwd);
  }
  if(type == '2'){
    onValue['phone'] = phone;
    onValue['smsReqSn'] = smsReqSn;
    onValue['smsCode'] = logInJM(smsCode);
  }
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
  ///注销登录
Future<Map> leaveLogin()async {
  var onValue = await getDeviceInfo('#010004');
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///修改登录密码
Future<Map> alterPWD(String newPwd)async {
  var onValue = await getDeviceInfo('#010005');
  onValue['newPwd'] = logInJM(newPwd);
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///修改头像
Future<Map> alterHead(String imgUrl)async{
  var onValue = await getDeviceInfo('#010006');
  onValue['imgUrl'] = imgUrl;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///账号信息修改
Future<Map> accountNumberChange({String email,String userName,String phone,String smsReqSn,String smsCode})async{
  var onValue = await getDeviceInfo('#010007');
  if(email != ''){
    onValue['email'] = email;
  }
  if(userName != ''){
    onValue['userName'] = userName;
  }
  if(phone != ''){
    onValue['phone'] = phone;
  }
  if(smsReqSn != ''){
    onValue['smsReqSn'] = smsReqSn;
  }
  if(smsCode != ''){
    onValue['smsCode'] = logInJM(smsCode);
  }
  print(onValue.toString());
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///获取账号信息
Future<Map> getAccount()async{
  var onValue = await getDeviceInfo('#010008');
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///增加收发件人
Future<Map> addPerson(String type,String province,String city,String district,String addr,String name,String phone) async {
  var onValue = await getDeviceInfo('#010009');
  onValue['type'] = type;
  onValue['province'] = province;
  onValue['city'] = city;
  onValue['district'] = district;
  onValue['addr'] = addr;
  onValue['name'] = name;
  onValue['phone'] = phone;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///修改收发件人
Future<Map> alterPerson(String addrId,String type,String province,String city,String district,String addr,String name,String phone)async {
  var onValue = await getDeviceInfo('#010010');
  onValue['addrId'] = addrId;
  onValue['type'] = type;
  onValue['province'] = province;
  onValue['city'] = city;
  onValue['district'] = district;
  onValue['addr'] = addr;
  onValue['name'] = name;
  onValue['phone'] = phone;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///删除收发件人
Future<Map> removePerson(String addrId)async {
var onValue = await getDeviceInfo('#010011');
  onValue['addrId'] = addrId;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///查询寄存列表
Future<Map> enquiriesDeposit(String  status)async{
  var onValue = await getDeviceInfo('#010012');
  onValue['status'] = status;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }

///出仓
Future<Map> outTorehouse()async => getDeviceInfo('#010013').then((onValue){

  });
///寄存详情
Future<Map> depositDetail(String depositId)async{
  var onValue = await getDeviceInfo('#010014');
  onValue['depositId'] = depositId;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///关联支付宝
Future<Map> alipayID()async => getDeviceInfo('#010015').then((onValue){

  });
///首页
///获取轮播图
Future<Map> wheelImage({String listId})async{
  print('#020001 listId = $listId');
  var onValue = await getDeviceInfo('#020001');
  onValue['listId'] = listId;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}
///获取定制商品列表
Future<Map> firstGoods({String listId})async{
  print('#020002 listId = $listId');
  var onValue = await getDeviceInfo('#020002');
  onValue['listId'] = listId;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}
///定制文章列表
Future<Map> firstMessage({String listId})async{
  print('#020003 listId = $listId');
  var onValue = await getDeviceInfo('#020003');
  onValue['listId'] = listId;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}
///获取轮播图
Future<Map> firstLink({String listId})async{
  print('#020004 listId = $listId');
  var onValue = await getDeviceInfo('#020004');
  onValue['listId'] = listId;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}

///搜索
///商品消息搜索
Future<Map> search({String key,int comdiPageSize,int comdiPageNum,int articlePageSize,int articlePageNum})async{
    comdiPageSize = comdiPageSize??10;
    comdiPageNum = comdiPageNum??0;
    articlePageSize = articlePageSize??10;
    articlePageNum = articlePageNum??0;
    print('#030001 comdiPageSize = $comdiPageSize comdiPageNum = $comdiPageNum articlePageSize = $articlePageSize'
        ' articlePageNum = $articlePageNum');
    var onValue = await getDeviceInfo('#030001');
    onValue['key'] = key;
    onValue['comdiPageSize'] = comdiPageSize;
    onValue['comdiPageNum'] = comdiPageNum;
    onValue['articlePageSize'] = articlePageSize;
    onValue['articlePageNum'] = articlePageNum;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
}
///FQA搜索
Future<Map> searchFQA(String key,String pageSize,String pageNum)async => getDeviceInfo('#030002').then((onValue){
    
  });


///商品
///商品筛选
Future<Map> goodsSift(String orderType,String sizeType,String pageSize,String pageNum,{String brandId,String sizeId,String priceRange,String crowdId})async{
  var onValue = await getDeviceInfo('#040004');
  onValue['sizeType'] = sizeType;
  onValue['orderType'] = orderType;
  onValue['pageSize'] = pageSize;
  onValue['pageNum'] = pageNum;
  onValue['brandId'] = brandId;
  onValue['sizeId'] = sizeId;
  onValue['priceRange'] = priceRange;
  onValue['crowdId'] = crowdId;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///品牌列表
Future<Map> brandList()async{
    //获取设备信息(通用参数)
  var onValue = await getDeviceInfo('#040001');
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///尺码列表
Future<Map> sizeList(String type)async{
     //获取设备信息(通用参数)
  var onValue = await getDeviceInfo('#040002');
  onValue['type'] = type;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///人群
Future<Map> personList()async{
     //获取设备信息(通用参数)
  var onValue = await getDeviceInfo('#040003');
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///商品详情
Future<Map> goodsDetail(String id)async{
  print('#040005 id = $id');
  var onValue = await getDeviceInfo('#040005');
  onValue['id'] = id;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}

  ///通过id获取商品相关推荐
  Future<Map> recommend(String id)async{
    print('#040006 id = $id');
    var onValue = await getDeviceInfo('#040006');
    onValue['id'] = id;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }
/*
comdiName	ans...64	m	-	商品名称
comdiBrand	ans...32	m	-	品牌和系列
styleSize	ans...32	m	-	款式和尺码
color	ans...16	m	-	颜色
desc	ans...256	m	-	其他介绍
* */
  ///通过id获取商品相关推荐
  Future<Map> uploadNewIncluded({String comdiName,comdiBrand,styleSize,color,desc})async{
    print('#040007 comdiName = $comdiName comdiBrand = $comdiBrand styleSize = $styleSize color = $color desc = $desc');
    var onValue = await getDeviceInfo('#040007');
    onValue['comdiName'] = comdiName;
    onValue['comdiBrand'] = comdiBrand;
    onValue['styleSize'] = styleSize;
    onValue['color'] = color;
    onValue['desc'] = desc;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }

  ///通过id获取鞋码
  Future<Map> makeEnquiriesSize(String id)async{
    var onValue = await getDeviceInfo('#040008');
    onValue['id'] = id;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }
///文章咨询等
///获取文章列表
Future<Map> consultList(int listId,int pageSize,int pageNum)async{
  var onValue = await getDeviceInfo('#050001');
  onValue['listId'] = listId;
  onValue['pageSize'] = pageSize;
  onValue['pageNum'] = pageNum;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///文章详情
Future<Map> consultDetail(String id)async{
    var onValue = await getDeviceInfo('#050002');
  onValue['id'] = id;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///获取文章列表
Future<Map> consultRecommend(String id)async{
    var onValue = await getDeviceInfo('#050003');
  onValue['id'] = id;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }


///行情交易
///获取商品最低和最高
Future<Map> goodsLowHeight(List reqList)async{
  print('#060001 reqList = $reqList ');
    var onValue = await getDeviceInfo('#060001');
  onValue['reqList'] = reqList;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///获取售价队列
Future<Map> sellPrice({String comdiId,String sizeId,String pageSize,String pageNum})async{
  var onValue = await getDeviceInfo('#060002');
  print('#060002 comdiId = $comdiId sizeId = $sizeId,pageSize=$pageSize,pageNum = $pageNum');
  onValue['comdiId'] = comdiId;
  if(sizeId != '')onValue['sizeId'] = sizeId;
  onValue['pageSize'] = pageSize;
  onValue['pageNum'] = pageNum;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}

///获取出价队列
Future<Map> gooutPrice({String comdiId,String sizeId,String pageSize,String pageNum})async{
  var onValue = await getDeviceInfo('#060003');
  print('#060003 comdiId = $comdiId sizeId = $sizeId,pageSize=$pageSize,pageNum = $pageNum');
  onValue['comdiId'] = comdiId;
  if(sizeId != '')onValue['sizeId'] = sizeId;
  onValue['pageSize'] = pageSize;
  onValue['pageNum'] = pageNum;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
}
/*
type	n1	m	r	计算类型。1竞价卖、2砍价买、3立即卖、4立即买
comdiId	ans..16	m	r	商品编号。
sizeId	ans..16	o	r	尺码编号。
deposit	n1	m	r	0不寄存、1从会员仓出售或买入到会员仓。
offer	n1..8	c	r	报价（单位分）。type=1和2时必填。type为其它值时无意义。
* */
  ///报价计算器
  Future<Map> computePrice({String comdiId,String sizeId,int type,int offer,int deposit})async{
    var onValue = await getDeviceInfo('#060007');
    print('#060007 comdiId = $comdiId sizeId = $sizeId type = $type offer = $offer, 060007');
    onValue['comdiId'] = comdiId;
    onValue['sizeId'] = sizeId;
    onValue['deposit'] = deposit;
    onValue['type'] = type;
    onValue['offer'] = offer;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }
  /*
  *
comdiId	ans..16	m	r	商品编号。
sizeId	ans..16	m	r	尺码编号。
orderType	n1	m	r	订单类型。1砍价买、2立即买
orderAmt	n1..8	m	r	订单金额（单位分）。
deposit	n1	m	-	0不寄存，1寄存。
deposit=1时，下面的收货地信息必填。deposit=0时，收货地信息无意义。
province	a..32	c	-	收货地：省
city	a..32	c	-	收货地：市
district	a..32	c	-	收货地：区
addr	ans..128	c	-	收货地：详细地址
name	ans..128	c	-	收货地：收件人姓名
phone	n11	c	-	收货地：收件人手机号
  * */
  ///创建砍价买/立即买订单
  Future<Map> createBuyOrder({String comdiId,String sizeId,int orderType,int orderAmt,int deposit,String province,city,district,addr,name,phone})async{
    var onValue = await getDeviceInfo('#060009');
    print('#060009 comdiId = $comdiId sizeId = $sizeId orderType = $orderType orderAmt = $orderAmt');
    onValue['comdiId'] = comdiId;
    onValue['sizeId'] = sizeId;
    onValue['orderType'] = orderType;
    onValue['orderAmt'] = orderAmt;
    onValue['deposit'] = deposit;
    onValue['province'] = province??'';
    onValue['city'] = city??'';
    onValue['district'] = district??'';
    onValue['addr'] = addr??'';
    onValue['name'] = name??'';
    onValue['phone'] = phone??'';
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }
/*
*
comdiId	ans..16	m	r	商品编号。
sizeId	ans..16	m	r	尺码编号。
orderType	n1	m	r	订单类型。1竞价卖、2立即卖
orderAmt	n1..8	m	r	订单金额（单位分）。
depositId	ans..16	c	-	寄存编号。该字段代表着从会员仓提货。直接影响费用计算结果。
* */
  ///创建竞价卖/立即卖订单
  Future<Map> createSellOrder({String comdiId,String sizeId,int orderType,int orderAmt,int deposit,})async{
    var onValue = await getDeviceInfo('#060008');
    print('#060008 comdiId = $comdiId sizeId = $sizeId orderType = $orderType orderAmt = $orderAmt deposit = $deposit');
    onValue['comdiId'] = comdiId;
    onValue['sizeId'] = sizeId;
    onValue['orderType'] = orderType;
    onValue['orderAmt'] = orderAmt;
    onValue['deposit'] = deposit;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }
  ///获取交易记录
  Future<Map> tradeTakeNotes(String comdiId,String sizeId,String pageSize,String pageNum)async{
    var onValue = await getDeviceInfo('#060004');
    print('#060004 comdiId = $comdiId sizeId = $sizeId, pageSize = $pageSize,pageNum = $pageNum');
    onValue['comdiId'] = comdiId;
    if(sizeId != '')onValue['sizeId'] = sizeId;
    onValue['pageSize'] = pageSize;
    onValue['pageNum'] = pageNum;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }

///通过商品编号获取最低售价鞋码列表
Future<Map> getSizeSellPriceList({String comdiId,String sizeType})async{
  print('#060005 comdiId = $comdiId sizeType = $sizeType, 060005');
  var onValue = await getDeviceInfo('#060005');
  onValue['comdiId'] = comdiId;
  onValue['sizeType'] = sizeType;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String sign = mdBase('$onValue$sessionId');
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
  ///说明：通过商品编号获取包含最高买价的鞋码列表。
  Future<Map> getSizeBuyPriceList({String comdiId,String sizeType})async{
    var onValue = await getDeviceInfo('#060006');
    print('#060006 comdiId = $comdiId sizeType = $sizeType');
    onValue['comdiId'] = comdiId;
    onValue['sizeType'] = sizeType;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String sign = mdBase('$onValue$sessionId');
    onValue['sign'] = sign;
    setHeaders(onValue);
    var response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }

///查询买卖订单详情
Future<Map> buySellDetail(String order)async{
  var onValue = await getDeviceInfo('#060011');

  onValue['orderNo'] = order;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  print('#060011  $onValue');
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
  ///查询买卖订单详情
Future<Map> typeOrderHistory(String orderNo)async{
  var onValue = await getDeviceInfo('#060012');
  onValue['orderNo'] = orderNo;
      // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
    ///取消订单
Future<Map> cancelOrder(String orderNo)async{
  var onValue = await getDeviceInfo('#060013');
  onValue['orderNo'] = orderNo;
      // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }
///买卖订单列表页
Future<Map> buySellList(String type,String status)async{
  var onValue = await getDeviceInfo('#060014');
  onValue['type'] = type;
  onValue['status'] = status;
  // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
  String sessionId = 'test';
  onValue['sessionId'] = sessionId;
  String a = onValue.toString()+sessionId;
  String sign = mdBase(a);
  onValue['sign'] = sign;
  setHeaders(onValue);
  dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
  return response;
  }

  ///支付宝支付
  Future<Map> aliPayMoney(String tradeId)async{
    var onValue = await getDeviceInfo('#060010');
    onValue['tradeId'] = tradeId;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String a = onValue.toString()+sessionId;
    String sign = mdBase(a);
    onValue['sign'] = sign;
    setHeaders(onValue);
    dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }
  ///微信支付
  Future<Map> wXPayMoney(String tradeId)async{
    var onValue = await getDeviceInfo('#060016');
    onValue['tradeId'] = tradeId;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String a = onValue.toString()+sessionId;
    String sign = mdBase(a);
    onValue['sign'] = sign;
    setHeaders(onValue);
    print(onValue);
    dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }

  ///确认发货
  Future<Map> sureSend(String orderNo,String sfOrderNo,String province,String city,String district,String ad,String name,String phone)async{
    var onValue = await getDeviceInfo('#060019');
    onValue['orderNo'] = orderNo;
  onValue['sfOrderNo'] = sfOrderNo;
  onValue['province'] = province;
  onValue['city'] = city;
  onValue['district'] = district;
  onValue['addr'] = ad;
  onValue['name'] = name;
    onValue['phone'] = phone;
    // String sessionId = await UserInfoCache().getInfo(key:UserInfoCache.sessionId);
    String sessionId = 'test';
    onValue['sessionId'] = sessionId;
    String a = onValue.toString()+sessionId;
    String sign = mdBase(a);
    onValue['sign'] = sign;
    setHeaders(onValue);
    dynamic response = await HttpUtil.getInstance().post(FPURL,data: onValue);
    return response;
  }


  void setHeaders(Map<String,dynamic> value){
  Map<String,dynamic> headerInfo = {};
  headerInfo['version'] = value['version'];
  headerInfo['tid'] = value['tid'];
  headerInfo['appVersion'] = value['appVersion'];
  headerInfo['osType'] = value['osType'];
  HttpUtil.getInstance().setRequestOption(headers: headerInfo);
}


    
}
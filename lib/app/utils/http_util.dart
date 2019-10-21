import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:oktoast/oktoast.dart';

export 'package:fluttertoast/fluttertoast.dart';
export 'package:oktoast/oktoast.dart';
export 'package:fast_pass/app/utils/loading_dialog.dart';


/// http请求类型
enum HttpMethod {
    /// get请求
    get,

    /// post请求
    post,

    /// upload请求
    upload,
}
typedef ParseReceiveToken = String Function(Response data);
typedef ParseResponse = Map Function(Map response);
class HttpUtil{
    /// ACCESS TOKEN 的键名
    static const String _TOKEN_KEY_ = 'access_token';
    /// ACCESS TOKEN
    String accessToken;
    /// Dio 对象
    Dio dio;
    /// Token Dio 对象
    Dio tokenDio;
    /// 是否启用拦截器
    bool _withInterceptor = false;
    /// getter
    bool get withInterceptor => _withInterceptor;
    ///单例对象
    static HttpUtil _instance;
    /// getter
    static HttpUtil get instance => getInstance();
    /// 工厂函数
    factory HttpUtil() => getInstance();
    /// 单例
    static HttpUtil getInstance() {
        if (_instance == null) {
            _instance = new HttpUtil._internal();
        }
        return _instance;
    }
    /// 命令构造函数
    HttpUtil._internal() {
        setRequestOption();
    }
    /// 相应数据
    Response _response;
    /// response getter
    Response get response => _response;
    /// request options
    BaseOptions _requestOption;
    /// 鉴权url
    String _authorizationUri;
    /// 鉴权参数
    Map<String, dynamic> _authorizationParameters = {};
    /// 鉴权请求时的方法
    HttpMethod _authorizationMethod;
    /// 鉴权请求的键名
    String _authorizationKey = 'Authorization';
    /// 鉴权请求的值
    String _authorizationValue = 'Bearer ';
    /// 解析token的回调
    ParseReceiveToken _parseReceiveToken;
    /// 解析response的回调
    ParseResponse _parseResponse;
    /// 设置请求配置
    void setRequestOption({
        String baseUrl,
        Map<String, dynamic> queryParameters,
        int connectTimeout,
        int receiveTimeout,
        Map<String, dynamic> headers,
        Map<String, dynamic> extra,
        ResponseType responseType,
        ContentType contentType,
        ValidateStatus validateStatus,
        Iterable<Cookie> cookies,
        bool receiveDataWhenStatusError,
        bool followRedirects,
        bool withInterceptor,
        String authorizationUri,
        Map<String, dynamic> authorizationParameters,
        String authorizationKey,
        String authorizationValue,
        HttpMethod authorizationMethod,
        ParseReceiveToken parseReceiveToken,
        ParseResponse parseResponse,
        bool openRequestLog,
    }){

        _requestOption = new BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout ?? 5000,
            receiveTimeout: receiveTimeout ?? 100000,
            headers: headers ?? {},
            contentType: contentType ?? ContentType.parse("application/json"),
            cookies: cookies ?? null,
            queryParameters: queryParameters ?? null,
            extra: extra ?? null,
            receiveDataWhenStatusError: receiveDataWhenStatusError ?? true,
            followRedirects: followRedirects ?? true,
            responseType: responseType ?? ResponseType.json,
        );
        dio = new Dio(_requestOption);
        dio.interceptors.add(CookieManager(CookieJar()));
//        dio.interceptors.add(LogInterceptor(responseBody: true));//打印log信息
        _withInterceptor = withInterceptor ?? _withInterceptor;
        if(_withInterceptor == true){
            if(authorizationUri == null){
                throw new ArgumentError.notNull('authorizationUri');
            }
            if(authorizationParameters == null){
                throw new ArgumentError.notNull('authorizationParameters');
            }
            _authorizationUri = authorizationUri;
            _authorizationParameters = authorizationParameters;
            _authorizationKey = authorizationKey ?? _authorizationKey;
            _authorizationValue = authorizationValue ?? _authorizationValue;
            _parseReceiveToken = parseReceiveToken ?? _parseReceiveToken;
            _parseResponse = parseResponse ?? _parseResponse;
            _authorizationMethod = authorizationMethod ?? HttpMethod.post;
            /// 开启拦截器
            dio.interceptors.add(LogInterceptor(responseBody: false)); //开启请求日志
            openInterceptor();
        }
    }

    /// 获取请求配置
    BaseOptions get requestOption => _requestOption;

    /// Token请求
    Future<Response> _tokenRequest() async{
        HttpMethod method = HttpMethod.get;
        if(method == _authorizationMethod){
            return tokenDio.get(_authorizationUri, queryParameters: _authorizationParameters);
        }
        return tokenDio.post(_authorizationUri, data: _authorizationParameters);
    }

    /// 获取 TOKEN
    void _getToken() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        accessToken = prefs.getString(_TOKEN_KEY_) ?? null;
    }

    /// 设置 TOKEN
    void _setToken(String value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString(_TOKEN_KEY_, value);
    }

    /// 开启拦截器
    void openInterceptor(){
        _getToken();
        tokenDio = new Dio(dio.options);
        dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
            if (accessToken == null) {
                dio.lock();
                return _tokenRequest().then((d) {
                    accessToken = _parseToken(d);
                    return _setHeaderToken(accessToken, options);
                }).whenComplete(() => dio.unlock());
            } else {
                return options;
            }
        }, onError: (DioError error) {
            if (error.response?.statusCode == 401) {
                RequestOptions options = error.response.request;
                if (accessToken != options.headers[_authorizationKey]) {
                    return dio.request(options.path, options: _setHeaderToken(accessToken, options));
                }
                dio.lock();
                dio.interceptors.responseLock.lock();
                dio.interceptors.errorLock.lock();
                return _tokenRequest().then((d) {
                    accessToken = _parseToken(d);
                    return _setHeaderToken(accessToken, options);
                }).whenComplete(() {
                    dio.unlock();
                    dio.interceptors.responseLock.unlock();
                    dio.interceptors.errorLock.unlock();
                }).then((e) {
                    return dio.request(options.path, options: options);
                });
            }
            return error;
        }));
    }

    /// 从获取的数据中解析出token
    String _parseToken(d) {
        if(this._parseReceiveToken == null){
            return d.data['data'][_TOKEN_KEY_];
        }
        return _parseReceiveToken(d);
    }

    /// 挂载token到header中
    Options _setHeaderToken(String accessToken, Options options) {
        options.headers[_authorizationKey] = _authorizationValue + accessToken;
        _setToken(accessToken);
        print('TOKEN');
        print(accessToken);
        return options;
    }

    /// 解析response
    Map _onParseResponse(var response){
        print("response = $response");
        var data = response?.data;
        if(_parseResponse == null){
            return data;
        }
        return _parseResponse(data);
    }
    /// GET方法
    Future<dynamic> get(String url, {queryParameters, cancelToken}) async {

        try{
            _response = await dio.get(url, queryParameters: queryParameters, cancelToken: cancelToken);
        }catch(exception){
            handleError(exception);
            return {};
        }
        print('http get print :$url');
//        print('queryParameters :$queryParameters');
//        debugPrint('http get print :${_response.toString()}');
//        List arr = _response.toString().split('<tr');
//        for(String str in arr){
//            print(str);
//        }

        if(_response.toString() == '')return '';
        return _onParseResponse(_response);
    }

    /// POST方法
    Future<dynamic> post(String url, {data, cancelToken}) async {
        try{
            _response = await dio.post(url,
                data: data, cancelToken: cancelToken);
        }catch(exception){
            handleError(exception);
            return {};
        }
        print('http post print :$url');
//        print('data :$data');
//        debugPrint('http post print :${_response.toString()}');

//        List arr = _response.toString().split('<tr');
//        for(String str in arr){
//            print(str);
//        }
        if(_response.toString() == '')return '';
        var postData = _onParseResponse(_response);
        if(postData['rspCode'] == '1000'){
          ///用户在其他地方登录 
          ///删除用户信息
          ///重新初始化
        }
        return postData;
    }

    /// UPLOAD方法
    Future<dynamic> upload(String url, {data, cancelToken}) async {
        FormData formData = new FormData.from(data);

        try{
            _response = await dio.post(url,
                data: formData, cancelToken: cancelToken);
        }catch(exception){
            handleError(exception);
            return {};
        }
        print('http upload print :$url');
//        debugPrint('http upload print :${_response.toString()}');
        
        return _onParseResponse(_response);
    }
    /// UPLOADIMAGE方法
    Future<dynamic> uploadThreeImages(String url, {data, cancelToken,image1,image2,image3}) async {
        String path1 = image1.path;
        String path2 = image2.path;
        String path3 = image3.path;
        var name1 = path1.substring(path1.lastIndexOf("/") + 1, path1.length);
        var name2 = path2.substring(path2.lastIndexOf("/") + 1, path2.length);
        var name3 = path3.substring(path3.lastIndexOf("/") + 1, path3.length);
        var suffix1 = name1.substring(name1.lastIndexOf(".") + 1, name1.length);
        var suffix2 = name2.substring(name2.lastIndexOf(".") + 1, name2.length);
        var suffix3 = name3.substring(name3.lastIndexOf(".") + 1, name3.length);

        data['before_card'] = UploadFileInfo(File(path1), name1,
            contentType: ContentType.parse("image/$suffix1"));

        data['after_card'] = UploadFileInfo(File(path2), name2,
            contentType: ContentType.parse("image/$suffix2"));

        data['photo_card'] = UploadFileInfo(File(path3), name3,
            contentType: ContentType.parse("image/$suffix3"));

        FormData formData = new FormData.from(data);

        try{
            _response = await dio.post(url,
                data: formData, cancelToken: cancelToken);
        }catch(exception){
            handleError(exception);
            return {};
        }
        print('http uploadImage print :$url');
//        debugPrint('http uploadImage print :${_response.toString()}');

        return _onParseResponse(_response);
    }
    /// UPLOADIMAGE方法
    Future<dynamic> uploadheadImage(String url, {data, cancelToken,image}) async {
        String path = image.path;

        var name = path.substring(path.lastIndexOf("/") + 1, path.length);

        var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);


        if(data == null) data = Map<String,dynamic>();
        data['imgFile'] = UploadFileInfo(File(path), name,
            contentType: ContentType.parse("image/$suffix"));

        FormData formData = new FormData.from(data);

        try{
            _response = await dio.post(url,
                data: formData, cancelToken: cancelToken);
        }catch(exception){
            handleError(exception);
            return {};
        }
        print('http uploadImage print :$url');
        debugPrint('http uploadImage print :${_response.toString()}');

        return _onParseResponse(_response);
    }
    /// 弹出消息
    void toast(String msg) {
        showToast(msg);
    }

    /// 错误信息
    void handleError(DioError error) {
        DioErrorType errorType = error.type;
        String message = error.message;
        if (errorType == DioErrorType.DEFAULT) {
            toast('网络不可用');
//            return '网络不可用';
        }

        if (errorType == DioErrorType.RESPONSE) {
            _response = error.response;
            toast('服务器响应错误：${_response.statusCode} $message');
            print('服务器响应错误：${_response.statusCode} $message');
//            return '服务器响应错误：${_response.statusCode} $message';
        }

        if (errorType == DioErrorType.CONNECT_TIMEOUT) {
            toast('请求连接超时');
            print('请求连接超时 $message');
//            return '请求连接超时';
        }

        if (errorType == DioErrorType.RECEIVE_TIMEOUT) {
            toast('服务器响应连接超时');
            print('服务器响应连接超时 $message');
//            return '服务器响应连接超时';
        }

        if (errorType == DioErrorType.CANCEL) {
            toast('请求已被用户取消');
//            return '请求已被用户取消';
        }
    }



 
  


}
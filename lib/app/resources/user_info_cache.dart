import 'package:simple_cache/simple_cache.dart';

class UserInfoCache{

    //买订单信息
    static const String buyInfo = 'buyInfo';
    //卖订单信息
    static const String sellInfo = 'sellInfo';
    //助记词
    static const String helpWordKey = 'moc';
    //手机号
    static const String phoneNumber = 'phoneNumber';
    //登录密码
    static const String loginPassword = 'loginPassword';
    //登录状态
    static const String loginStatus = 'loginStatus';
    //session_id
    static const String sessionId = 'sessionId';
    //btc number
    static const String btcNumber = 'btcNumber';
    //提现随机数
    static const String crashRandom = 'crashRandom';
    //实名验证状态
    static const String authenticationStatus = 'authenticationStatus';

    /// set String 单独String字符串不能缓存
    void saveInfo({String key , String value}) async{
        Map map = {key:value};
        SimpleCache simpleCache = await SimpleCache.getInstance();
        await simpleCache.setMap(key, map);
    }
    /// get String
    Future<String> getInfo({String key}) async {
        SimpleCache simpleCache = await SimpleCache.getInstance();
        Map map = simpleCache.getMap(key)??{};
        return map[key];
    }
    /// set map
    void setMapInfo({String key,Map map}) async{
        SimpleCache simpleCache = await SimpleCache.getInstance();
        await simpleCache.setMap(key, map);
    }

    /// get map
    Future getMapInfo({String key}) async {
        SimpleCache simpleCache = await SimpleCache.getInstance();
        return simpleCache.getMap(key);
    }
    /// set map
    void setUserInfo({Map userInfo}) async{
        String cacheKey = 'userInfo';
        SimpleCache simpleCache = await SimpleCache.getInstance();
        await simpleCache.setMap(cacheKey, userInfo);
    }
    /// get map
    Future getUserInfo() async {
        String cacheKey = 'userInfo';
        SimpleCache simpleCache = await SimpleCache.getInstance();
        return simpleCache.getMap(cacheKey);
    }

    void setUserNo({Map userNo}) async{
        String cacheKey = 'userNo';
        SimpleCache simpleCache = await SimpleCache.getInstance();
        await simpleCache.setMap(cacheKey, userNo);
    }
    Future getUserNo() async {
            String cacheKey = 'userNo';
            SimpleCache simpleCache = await SimpleCache.getInstance();
            return simpleCache.getMap(cacheKey);
        }

    void removeCache({String key}) async {
        SimpleCache simpleCache = await SimpleCache.getInstance();
        simpleCache.remove(key);
    }

    void clearCache() async {
        SimpleCache simpleCache = await SimpleCache.getInstance();
        simpleCache.flush();
    }

}


class UrlDeliver{
  //地址
    static const String URL = 'url';
    void saveURL({String key , String value}) async{
        Map map = {key:value};
        SimpleCache simpleCache = await SimpleCache.getInstance();
        await simpleCache.setMap(key, map);
    }
     /// get String
    Future getURL({String key}) async {
        SimpleCache simpleCache = await SimpleCache.getInstance();
        Map map = simpleCache.getMap(key);
        return map[key];
    }
    void removeURL({String key}) async {
        SimpleCache simpleCache = await SimpleCache.getInstance();
        simpleCache.remove(key);
    }
}
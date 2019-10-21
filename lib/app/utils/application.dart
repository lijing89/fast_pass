import 'package:fluro/fluro.dart';
import 'package:simple_cache/simple_cache.dart';

export 'package:fluro/fluro.dart';
export 'package:fast_pass/app/routers/routes.dart';
export 'package:fast_pass/app/configs/app_config.dart';
export 'package:fast_pass/app/configs/api_config.dart';
export 'package:fast_pass/app/resources/user_info_cache.dart';

class Application{
    static Router router;
    static SimpleCache cache;
    static const SplashCacheKey = 'fast_pass:splash:int';
    static bool isChinaPhoneLegal(String str) {
        return new RegExp('^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$').hasMatch(str);
    }
    static bool isEmail(String str){
//      RegExp email = new RegExp(r'^[a-z0-9A-Z]+[- | a-z0-9A-Z . _]+@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-z]{2,}$');
     
      return RegExp(
          r"^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
          .hasMatch(str);
    }
    static bool passWord(String str){
        return RegExp(
            r"^(?![A-Z]+$)(?![a-z]+$)(?!\d+$)(?![\W_]+$)\S{6,16}$")
            .hasMatch(str);
    }
    static bool isCardId (String cardId){
        if (cardId.length != 18) {
            return false; // 位数不够
        }
        // 身份证号码正则
        RegExp postalCode = new RegExp(r'^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|[Xx])$');
        // 通过验证，说明格式正确，但仍需计算准确性
        if (!postalCode.hasMatch(cardId)) {
            return false;
        }
        //将前17位加权因子保存在数组里
        final List idCardList = ["7", "9", "10", "5", "8", "4", "2", "1", "6", "3", "7", "9", "10", "5", "8", "4", "2"];
        //这是除以11后，可能产生的11位余数、验证码，也保存成数组
        final List idCardYArray = ['1','0','10','9','8','7','6','5','4','3','2'];
        // 前17位各自乖以加权因子后的总和
        int idCardWiSum = 0;

        for (int i = 0; i < 17; i ++) {
            int subStrIndex = int.parse(cardId.substring(i,i+1));
            int idCardWiIndex = int.parse(idCardList[i]);
            idCardWiSum += subStrIndex * idCardWiIndex;
        }
        // 计算出校验码所在数组的位置
        int idCardMod = idCardWiSum % 11;
        // 得到最后一位号码
        String idCardLast = cardId.substring(17,18);
        //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
        if (idCardMod == 2){
            if (idCardLast != 'x' && idCardLast != 'X'){
                return false;
            }
        }else{
            //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
            if (idCardLast != idCardYArray[idCardMod]){
                return false;
            }
        }
        return true;
    }
    static bool isPhoneNumber(String str){
        RegExp exp = RegExp(
            r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
        return exp.hasMatch(str);
    }


    static String sizeValueTitle(String sizeValue){
        switch (sizeValue){
            case '1':
                return 'US美码';
            case '2':
                return 'UK英码';
            case '3':
                return 'EUR欧码';
            case '4':
                return 'JP毫米';
        }
    }
}
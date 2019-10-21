/**
 * @Author: sunmoon
 * @Url: http://blog.iw3c.com
 * @Description: 日期相关助手.
 * @Date: 2018-11-11
 * 请在pubspec.yaml中添加依赖 intl: ^0.15.7
 * 该软件包提供国际化和本地化设施，包括消息转换，复数和性别，日期/数字格式和解析以及文字翻译等。
 * @See https://pub.dartlang.org/packages/intl [需要梯子]
 * @See https://pub.dartlang.org/documentation/intl/latest/intl/DateFormat-class.html
 */

import 'package:intl/intl.dart';

Map<int, Map<String, Map<String, String>>> weekMaps = {
  1: {
    'short': {
      'zh_CN': '周一',
      'en_US': 'Mon',
    },
    'normal': {
      'zh_CN': '星期一',
      'en_US': 'Monday',
    }
  },
  2: {
    'short': {
      'zh_CN': '周二',
      'en_US': 'Tue',
    },
    'normal': {
      'zh_CN': '星期二',
      'en_US': 'Tuesday',
    }
  },
  3: {
    'short': {
      'zh_CN': '周三',
      'en_US': 'Mon',
    },
    'normal': {
      'zh_CN': '星期三',
      'en_US': 'Wednesday',
    }
  },
  4: {
    'short': {
      'zh_CN': '周四',
      'en_US': 'Mon',
    },
    'normal': {
      'zh_CN': '星期四',
      'en_US': 'Thursday',
    }
  },
  5: {
    'short': {
      'zh_CN': '周五',
      'en_US': 'Mon',
    },
    'normal': {
      'zh_CN': '星期五',
      'en_US': 'Friday',
    }
  },
  6: {
    'short': {
      'zh_CN': '周六',
      'en_US': 'Mon',
    },
    'normal': {
      'zh_CN': '星期六',
      'en_US': 'Saturday',
    }
  },
  7: {
    'short': {
      'zh_CN': '周日',
      'en_US': 'Mon',
    },
    'normal': {
      'zh_CN': '星期日',
      'en_US': 'Sunday',
    }
  },
};
class DateUtil{

  ///获取当前的微秒
  ///
  static int microtime(){
    return new DateTime.now().millisecondsSinceEpoch;
  }

  ///获取 DateTime 对象
  ///
  static DateTime getDateTime(int milliseconds) {
    int len = milliseconds.toString()?.length;
    if(len == 10){
      milliseconds = milliseconds * 1000;
    }
    DateTime dateTime = new DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    return dateTime;
  }

  ///获取当前的时间戳
  ///
  static int time(){
    double unixTime = microtime() / 1000;
    return unixTime.toInt();
  }

  ///根据日期字符串获取unixtime
  ///@example strtotime('2018-10-31')
  ///
  static int strtotime(String date, {bool isMicro: false}){
    DateTime dateTime = DateTime.tryParse(date);
    if(dateTime == null){
      return null;
    }else{
      int microTime = dateTime.millisecondsSinceEpoch;
      if(isMicro == false){
        double unixTime = microTime / 1000;
        return unixTime.toInt();
      }
      return microTime;
    }
  }

  /// 把时间戳转换为正常的日期字符串或者获取当前日期
  /// @example date('yyyy-MM-dd')
  ///
  static String date([format, value]){
    if(value == null){
      value = microtime();
    }else{
      int len = value.toString()?.length;
      if(len == 10){
        value = value * 1000;
      }
    }
    if(null == format){
      format = 'yyyy-MM-dd';
    }
    DateTime dateTime = new DateTime.fromMillisecondsSinceEpoch(value, isUtc: false);
    var formatter = new DateFormat(format);
    String date = formatter.format(dateTime);
    return date;
  }

  ///周几
  ///
  static String weekDay([DateTime dateTime, locale = 'zh_CN', short = false]) {
    if(dateTime == null){
      dateTime = DateTime.now();
    }
    int weekDay = dateTime.weekday;
    String type = (short == true) ? 'short' : 'normal';
    return weekMaps[weekDay][type][locale];
  }
  
  /// 某天的开始时间 
  /// 返回unxtime
  /// @example dayStart('2018-11-11') or dayStart(1541865600)
  static int dayStart(date){
    DateTime dateTime = parseDate(date);
    int microTime = dateTime.millisecondsSinceEpoch;
    double unixTime = microTime / 1000;
    return unixTime.toInt();
  }

  /// 某天的开始时间 
  /// 返回unxtime
  /// @example dayStart('2018-11-11') or dayStart(1541865600)
  static int dayEnd(date){
    DateTime dateTime = parseDate(date);
    dateTime = dateTime.add(new Duration(days: 1)); 
    double unixTime = dateTime.millisecondsSinceEpoch / 1000;
    return unixTime.toInt();
  }

  /// 昨天的日期
  ///
  static String yesterday([format]){
    if(format == null){
      format = 'yyyy-MM-dd';
    }
    DateTime dateTime = DateTime.now();
    dateTime = dateTime.subtract(new Duration(days: 1)); 
    int unixTime = dateTime.millisecondsSinceEpoch;
    return date(format, unixTime);
  }

  /// 解析出 DateTime 对象
  ///
  static DateTime parseDate(value){
    if(value == null){
      return new DateTime.now();
    }
    if(value is int){ //格式如 1539100800
      return getDateTime(value);
    }else if(value is String){ // 格式如2018-12-11
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// 上个月
  /// 传入format时会返回 String 否则返回 DateTime对象
  /// @example lastMonth('2018-11-11') or lastMonth(1541865600)
  static lastMonth([value, format]){
    DateTime dateTime = parseDate(value);
    var prevMonth = new DateTime(dateTime.year, dateTime.month - 1, dateTime.day);
    if(format == null){
      return prevMonth;
    }
    var formatter = new DateFormat(format);
    String date = formatter.format(prevMonth);
    return date;
  }

  /// 下个月
  /// 传入format时会返回 String 否则返回 DateTime对象
  /// @example nextMonth('2018-11-11') or nextMonth(1541865600)
  static nextMonth([value, format]){
    DateTime dateTime = parseDate(value);
    var nextMonth = new DateTime(dateTime.year, dateTime.month + 1, dateTime.day);
    if(format == null){
      return nextMonth;
    }
    var formatter = new DateFormat(format);
    String date = formatter.format(nextMonth);
    return date;
  }
}

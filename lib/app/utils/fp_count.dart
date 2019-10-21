


import 'package:janalytics/janalytics.dart';

class CountModule{
  String name;
  //极光
  static Janalytics janalytics = new Janalytics();
  CountModule(this.name);
  openPage(){
    janalytics.onPageStart(name);
  }

  endPage(){
    janalytics.onPageEnd(name);
  }

}

import 'package:fast_pass/app/configs/api_config.dart';
import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/utils/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpansionPanelItem {
  final String headerText;
  final Widget body;
  bool isExpanded;
  ExpansionPanelItem({this.headerText, this.body, this.isExpanded});
}

class GZXFilterGoodsPage extends StatefulWidget {
  final Function sureFunc;

  const GZXFilterGoodsPage({Key key, this.sureFunc})
      : super(key: key); //点击确定的方法
  @override
  _GZXFilterGoodsPageState createState() => _GZXFilterGoodsPageState();
}

class _GZXFilterGoodsPageState extends State<GZXFilterGoodsPage> {
  List<ExpansionPanelItem> _expansionPanelItems;

  List<dynamic> _a = [];
  List<dynamic> _b = [];
  List<dynamic> _p = [];
  List<Map<dynamic, dynamic>> _s = [];
  Map selectedMap = {};

  List _fruits = ['EUR欧洲码','US美码', 'UK英码', 'JP毫米'];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _selectedFruit;
  bool _isHideValue1 = true;
  @override
  void initState() {
    _dropDownMenuItems = buildAndGetDropDownMenuItems(_fruits);
    _selectedFruit = _dropDownMenuItems[0].value;
    super.initState();
    if (DataList.getInstance().a.length == 0) {
      DataList.getInstance().getList().then((onValue) {
        setState(() {
          _a.addAll(DataList.getInstance().a);
          _b.addAll(DataList.getInstance().b3);
          _p.addAll(DataList.getInstance().p);
          _s.addAll(DataList.getInstance().s);
        });
        return;
      });
    } else {
      for (var item in DataList.getInstance().a) {
        if (item['id'] == DataList.getInstance().searchMap['brandId']) {
          item['isSelected'] = true;
        } else {
          item['isSelected'] = false;
        }
      }

     for (var item in DataList.getInstance().b3) {
        if (item['id'] == DataList.getInstance().searchMap['sizeId']) {
          item['isSelected'] = true;
        } else {
          item['isSelected'] = false;
        }
      }
      
      for (var item in DataList.getInstance().p) {
        if (item['id'] == DataList.getInstance().searchMap['croedId']) {
          item['isSelected'] = true;
        } else {
          item['isSelected'] = false;
        }
      }
      for (var item in DataList.getInstance().s) {
        if (item['id'] == DataList.getInstance().searchMap['priceRange']) {
          item['isSelected'] = true;
        } else {
          item['isSelected'] = false;
        }
      }

      _a.addAll(DataList.getInstance().a);
      _b.addAll(DataList.getInstance().b3);
      _p.addAll(DataList.getInstance().p);
      _s.addAll(DataList.getInstance().s);
      selectedMap.addAll(DataList.getInstance().searchMap);
    }
    if (selectedMap['sizeType'] != null && selectedMap['sizeType'] != '') {
      setState(() {
        _selectedFruit = _fruits[int.parse(selectedMap['sizeType'])-1];
      });
    }
  }

  Widget _typeGridWidget(List<dynamic> items, {double childAspectRatio = 1.0}) {
    return GridView.count(
        primary: false,
        shrinkWrap: true,
        crossAxisCount: 5,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: childAspectRatio,
        padding: EdgeInsets.all(6),
        children: items.map((value) {
          return GestureDetector(
            onTap: () {
              value['isSelected'] = !value['isSelected'];
              if (value['isSelected'] == false) {
                selectedMap.remove('sizeId');
              }else{
                selectedMap['sizeId'] = value['id'];
              }
              for (var item in _b) {
                if (item == value) {
                      continue;
                    }
                item['isSelected'] = false;
              }
              mysureFunc();
            },
            child: Container(
              // padding: EdgeInsets.only(top: 6,bottom: 6),
              width:ScreenUtil.getInstance().setHeight(18),
              height: ScreenUtil.getInstance().setHeight(18),
                decoration: BoxDecoration(
                    color: AppStyle.colorWhite,border: Border.all(
                    color: Color(0xFF979797),
                    width: 1,
                  )),
                child: Center(
                    child: Text(value['title'],
                        style: TextStyle(
                            color: value['isSelected']
                                ? AppStyle.colorRed
                                : Color(0xFF333333),
                            fontSize: 10.0)))),
          );
        }).toList());
  }

  Widget _buildGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text('品牌&系列',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setHeight(30),fontWeight: FontWeight.w500, color: AppStyle.colorPrimary)),
            ),
            
            // GestureDetector(
            //   onTap: () {
            //     setState(() {
            //       _isHideValue1 = !_isHideValue1;
            //     });
            //   },
            //   child: Icon(
            //     _isHideValue1
            //         ? Icons.keyboard_arrow_down
            //         : Icons.keyboard_arrow_up,
            //     color: Colors.grey,
            //   ),
            // ),
            // SizedBox(
            //   width: 6,
            // ),
          ],
        ),
        SizedBox(
              height: 15,
            ),
        Container(
          margin: EdgeInsets.only(left: 10),
              width: ScreenUtil.getInstance().setHeight(140),
              height: 3,
              color: AppStyle.colorPrimary,
            ),
            Container(
          margin: EdgeInsets.only(left: 10,right: 10),
              height: 2,
              color: AppStyle.colorBackground,
            ),
        SizedBox(height: 10,),
        _selectedNameItem(_a),
        SizedBox(height: 20,),
      ],
    );
  }

  ///selected index
  Widget _selectedItem(List name) {
    return Container(
      alignment: Alignment.topCenter,
      // margin: EdgeInsets.only(top: 10),
      
      child: Column(
          children: name.map((s) {
        return  GestureDetector(
           onTap: (){
                  s['isSelected'] = !s['isSelected'];
                  if (s['depth'] != null) {
                  if (s['isSelected'] == false) {
                    selectedMap.remove('brandId');
                  }else{
                    selectedMap['brandId'] = s['id'];
                  }
                  
                  for (var item in _a) {
                    if (item == s) {
                      continue;
                    }
                    item['isSelected'] = false;
                  }
                } else if (s['title'] == '男子' ||
                    s['title'] == '女子' ||
                    s['title'] == '儿童') {
                  if (s['isSelected'] == false) {
                    selectedMap.remove('crowdId');
                  }else{
                    selectedMap['crowdId'] = s['id'];
                  }
                  
                  for (var item in _p) {
                    if (item == s) {
                      continue;
                    }
                    item['isSelected'] = false;
                  }
                } else if (name.length == 6) {
                  
                  if (s['isSelected'] == false) {
                    selectedMap.remove('priceRange');
                  }else{
                    selectedMap['priceRange'] = s['id'];
                  }
                  
                  for (var item in _s) {
                    if (item == s) {
                      continue;
                    }
                    item['isSelected'] = false;
                  }
                }
                mysureFunc();
                        },
          child: Row(
          children: <Widget>[
            s['depth'] == '1' ? SizedBox(width: 20) : Container(),
            s['depth'] == '2' ? SizedBox(width: 40) : Container(),
            s['depth'] == '3' ? SizedBox(width: 60) : Container(),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
              s['title'],
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 12,
                  color:s['isSelected']? Colors.red:AppStyle.colorPrimary,),
            ),
            ),
            Expanded(
              child: Container(),
            ),Container(
          decoration: BoxDecoration(shape: BoxShape.circle,),
          //icon_down@3x
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: s['isSelected']
                ? Container(child: Image(image: AssetImage(AssetUtil.image('selected11.png')),fit: BoxFit.fitWidth,),width: 12,height: 12,)
                : Container(child: Image(image: AssetImage(AssetUtil.image('noselected11.png')),fit: BoxFit.fitWidth,width: 12,height: 12,))
          ),
                        ),
          ],
        )
        );
      }).toList()),
    );
  }


  Widget _selectedNameItem(List name) {
    print(name);
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
          children: name.map((s) {
        return  GestureDetector(
           onTap: (){
                  s['isSelected'] = !s['isSelected'];
                  if (s['isSelected'] == false) {
                    selectedMap.remove('brandId');
                  }else{
                    selectedMap['brandId'] = s['id'];
                  }
                  for (var item in _a) {
                    if (item == s) {
                      continue;
                    }
                    item['isSelected'] = false;
                  }
                  List list = s['childList'];
                  if(list.length >0){
                    for (var item in list) {
                      item['hiden'] = s['isSelected'];
                      List itemlist = item['childList'];

                     if(itemlist.length>0 &&  s['isSelected'] == false){
                        for (var item1 in itemlist) {
                      item1['hiden'] = s['isSelected'];
                        }
                     }
                    }
                  }
                mysureFunc();
                        },
          child:s['hiden']? Row(
          children: <Widget>[
            s['depth'] == '1' ? SizedBox(width: 20) : Container(),
            s['depth'] == '2' ? SizedBox(width: 30) : Container(),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
              s['title'],
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 12,
                  color:s['isSelected']? Colors.red:AppStyle.colorPrimary,),
            ),
            ),
            Expanded(
              child: Container(),
            ),Container(
          decoration: BoxDecoration(shape: BoxShape.circle,),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: s['isSelected']
                ? Container(child: Image(image: AssetImage(AssetUtil.image(s['depth'] == '2'?'selected11.png':'icon_down@3x.png')),fit: BoxFit.fitWidth,),width: 12,height: 12,)
                : Container(child: Image(image: AssetImage(AssetUtil.image(s['depth'] == '2'?'noselected11.png':'icon_down@3x.png')),fit: BoxFit.fitWidth,width: 12,height: 12,))
          ),
                        ),
          ],
        ):Container()
        );
      }).toList()),
    );
  }



  Widget _buildGroup1(
      String title, bool isShowExpansionIcon, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      SizedBox(
        height: 6,
      ),
      Row(
        children: <Widget>[
          SizedBox(
            width: 6,
          ),
          Expanded(
            child: Text('类型',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setHeight(30),fontWeight: FontWeight.w500, color: AppStyle.colorPrimary)),
          ),
          SizedBox(
            width: 6,
          ),
        ],
      ),
      SizedBox(
              height: 15,
            ),
        Container(
          margin: EdgeInsets.only(left: 10),
              width: ScreenUtil.getInstance().setHeight(140),
              height: 3,
              color: AppStyle.colorPrimary,
            ),
            Container(
          margin: EdgeInsets.only(left: 10,right: 10),
              height: 2,
              color: AppStyle.colorBackground,
            ),
            SizedBox(height: 10,),
      _selectedItem(items),
      SizedBox(height: 20,),
    ]);
  }

  Widget _buildGroup2() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 6,
          ),
          Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('价格',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setHeight(30),fontWeight: FontWeight.w500, color: AppStyle.colorPrimary)),
          ),
          SizedBox(
            height: 6,
          ),
          SizedBox(
              height: 15,
            ),
        Container(
          margin: EdgeInsets.only(left: 10),
              width: ScreenUtil.getInstance().setHeight(140),
              height: 3,
              color: AppStyle.colorPrimary,
            ),
            Container(
          margin: EdgeInsets.only(left: 10,right: 10),
              height: 2,
              color: AppStyle.colorBackground,
            ),
            SizedBox(height: 10,),
          _selectedItem(_s),
          SizedBox(height: 20,),
        ]);
  }

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List fruits) {
    List<DropdownMenuItem<String>> items = List();
    for (String fruit in fruits) {
      items.add(DropdownMenuItem(value: fruit, child: Text(fruit)));
    }
    return items;
  }

  void changedDropDownItem(String selectedFruit) {
    setState(() {
      _selectedFruit = selectedFruit;
      selectedMap['sizeType'] = (_fruits.indexOf(selectedFruit) + 1).toString();
      _b = [];
      if(selectedFruit == 'US美码'){
            _b.addAll(DataList.getInstance().b1);
          }else if(selectedFruit == 'UK英码'){
            _b.addAll(DataList.getInstance().b2);
          }else if(selectedFruit == 'EUR欧洲码'){
            _b.addAll(DataList.getInstance().b3);
          }else if(selectedFruit == 'JP毫米'){
            _b.addAll(DataList.getInstance().b4);
          }
      
    });
  }

  Widget _buildGroup4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      SizedBox(
        height: 6,
      ),
      Row(
        children: <Widget>[
          SizedBox(
            width: 6,
          ),
          Expanded(
            child: Text('尺码',
                  style: TextStyle(fontSize: ScreenUtil.getInstance().setHeight(30),fontWeight: FontWeight.w500, color: AppStyle.colorPrimary)),
          ),
          // DropdownButton(
          //   style: TextStyle(fontSize: 11,color: AppStyle.colorPrimary),
          //   value: _selectedFruit,
          //   items: _dropDownMenuItems,
          //   onChanged: changedDropDownItem,
          // )
        ],
      ),
      SizedBox(
              height: 15,
            ),
        Container(
          margin: EdgeInsets.only(left: 10),
              width: ScreenUtil.getInstance().setHeight(140),
              height: 3,
              color: AppStyle.colorPrimary,
            ),
            Container(
          margin: EdgeInsets.only(left: 10,right: 10),
              height: 2,
              color: AppStyle.colorBackground,
            ),
            SizedBox(height: 10,),
      _typeGridWidget(_b),
      SizedBox(height: 20,),
    ]);
  }

  Widget _buildGroup5(String title, List<String> items, bool isHideValue,
      VoidCallback onTapExpansion) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 6,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 6,
            ),
            Expanded(
              child: Text(title,
                  style: TextStyle(fontSize: 12, color: Color(0xFF6a6a6a))),
            ),
            GestureDetector(
//              onTap: () {
//                setState(() {
//                  isHideValue = !isHideValue;
//                });
//              },
              onTap: onTapExpansion,
              child: Icon(
                isHideValue
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 6,
            ),
          ],
        ),
        Offstage(
          offstage: isHideValue,
          child: _typeGridWidget(items),
        ),
        Container(
            margin: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
//      color: Colors.red,
                border: Border(
                    bottom: BorderSide(
                        width: 1, color: AppStyle.colorBackground)))),
      ],
    );
  }

  doi(i) {
    i++;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            margin: EdgeInsets.only(right: 0, ),
            padding: EdgeInsets.only(bottom: 15),
            color: Colors.white,
            height: ScreenUtil.screenHeight,
            //  padding: EdgeInsets.only(top: ScreenUtil.statusBarHeight),
            child:DataList.getInstance().a.length > 0
        ?  Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: <Widget>[
                        _buildGroup(),
                        _buildGroup1('类型', false, _p),
                        _buildGroup4(),
                        _buildGroup2(),
                      ]),
                ),
                
              ],
            ):LoadingDialog( //调用对话框
                text: '正在加载...',
              ),
          );
        
  }

  void mysureFunc(){
  DataList.getInstance().searchMap = selectedMap;
  DataList.getInstance().a = _a;
  DataList.getInstance().b3 = _b;
  DataList.getInstance().p = _p;
  DataList.getInstance().s = _s;
  widget.sureFunc();
}

}



class DataList {
  ///单例对象
  static DataList _instance;

  /// getter
  static DataList get instance => getInstance();

  /// 工厂函数
  factory DataList() => getInstance();

  /// 单例
  static DataList getInstance() {
    if (_instance == null) {
      _instance = new DataList._internal();
    }
    return _instance;
  }

  Map sizeTyoeList = {'US美码': '1', 'UK英码': '2', 'EUR欧洲码': '3', 'JP毫米': '4'};
  Map searchMap = {'sizeType': '3'};
  List<dynamic> a = [];
  List<dynamic> b1 = [];
  List<dynamic> b2 = [];
  List<dynamic> b3 = [];
  List<dynamic> b4 = [];
  List<dynamic> p = [];
  List<Map<dynamic, dynamic>> s = [
    {'title': '500以内', 'id': '1'},
    {'title': '500~1000', 'id': '2'},
    {'title': '1000~1500', 'id': '3'},
    {'title': '1500~2000', 'id': '4'},
    {'title': '2000~3000', 'id': '5'},
    {'title': '3000以上', 'id': '6'}
  ];

  /// 命令构造函数
  DataList._internal() {}
  Future getList() async {
    var aa = await ApiConfig().brandList();
    var bb1 = await ApiConfig().sizeList('1');
    var bb2 = await ApiConfig().sizeList('2');
    var bb3 = await ApiConfig().sizeList('3');
    var bb4 = await ApiConfig().sizeList('4');
    var pp = await ApiConfig().personList();
    a = aa['list'];
    b1 = bb1['list'];
    b2 = bb2['list'];
    b3 = bb3['list'];
    b4 = bb4['list'];
    p = pp['list'];
    setSelected();
  }

  setSelected() {
    searchMap = {};
    for (var item in b1) {
      item['isSelected'] = false;
    }
    for (var item in b2) {
      item['isSelected'] = false;
    }
    for (var item in b3) {
      item['isSelected'] = false;
    }
    for (var item in b4) {
      item['isSelected'] = false;
    }
    for (var item in p) {
      item['isSelected'] = false;
    }
    for (var item in s) {
      item['isSelected'] = false;
    }
    for (var item in a) {
      item['isSelected'] = false;
      item['childList'] = [];
    }
    Map item1;
    Map item2;
    for (var item in a) {
      if(item['depth'] == '0'){
        item1 = item;
        item['hiden'] = true;

        continue;
      }
      if(item['depth'] == '1'){
       List ch = item1['childList'];
       ch.add(item);
       item2 = item;
       item['hiden'] = false;
       continue;
      }
      List ch = item2['childList'];
        item['hiden'] = false;
       ch.add(item);
    }
  }
}

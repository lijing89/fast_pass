import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fast_pass/app/utils/asset_util.dart';
import 'package:fast_pass/app/model/my_team_entity.dart';
import 'package:fast_pass/app/resources/app_style.dart';

class TeamItemPage extends StatelessWidget {
  List<MyTeamMessageListData> formList;

  TeamItemPage(this.formList);

  Widget buidGrid(BuildContext context) {
    List<Widget> titles = [];

    ///先建立一个数组用于存放循环生成的widget
    Widget content;
    if (formList.isEmpty) return Container(child: Text('暂无数据',style: TextStyle(fontSize: 30),),);
    for (var item in formList) {

        titles.add(
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(width: 1, color: AppStyle.colorGrey))),
            height: ScreenUtil.getInstance().setHeight(100.0),
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Image.network(
                    item.headPic==null?'':item.headPic,
                    height: ScreenUtil.getInstance().setHeight(60),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              item.name,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(36)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Text(
                                item.mobile,
                                textAlign: TextAlign.right,
                              ),
                            ),

                          ],
                        ),
                      ),
                      Container(

                        child: Text(
                          item.regTime,
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );

      
    }
    content = Column(children: titles);
    return content;
  }

  //Widget MyFourRow = buidGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buidGrid(context),
    );
  }
}

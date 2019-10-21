import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:fast_pass/app/utils/application.dart';
import 'package:fast_pass/app/utils/http_util.dart';
import 'package:fast_pass/app/model/my_team_entity.dart';
import 'package:fast_pass/app/pages/my/components/team_item_page.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<MyTeamMessageListData> teamList = [];
  String headPic = '';
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  @override
  void initState(){
    super.initState();
    HttpUtil().get( '${ApiConfig.teamUrl}').then((res){
      setState(() {
        MyTeamEntity myTeamEntity = MyTeamEntity.fromJson(res);
        teamList = myTeamEntity.message.xList.data;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的团队'),
      ),
      body: Center(
        child: Container(
            child: TeamItemPage(teamList),
          //child: Text('tuandui'),
        ),
      ),
    );
  }
}

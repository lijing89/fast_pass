import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fast_pass/app/pages/assets/index_page.dart';
import 'package:fast_pass/app/pages/deal/index_page.dart';
import 'package:fast_pass/app/pages/my/index_page.dart';
import 'package:fast_pass/app/widgets/bottom_nav_bar_widget.dart';

class IndexPage extends StatefulWidget {
    @override
    _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with AutomaticKeepAliveClientMixin {
    PageController _pageController = PageController(initialPage: 0);
    bool get wantKeepAlive => true;
    List<Widget> _pages = [];
    @override
    void initState() {
        super.initState();
        _pages = [
            AssetsIndexPage(),
            DealIndexPage(),
            MyIndexPage(),
        ];
    }
    @override
    void dispose() {
        super.dispose();
        _pageController.dispose();
    }
    @override
    Widget build(BuildContext context) {

        //假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334),设置字体大小根据系统的“字体大小”辅助选项来进行缩放,默认为false
        //默认设计稿为6p7p8p尺寸 width : 1080px , height:1920px , allowFontScaling:false
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

        super.build(context);
        return Scaffold(
            body: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                    return _pages[index];
                },
                itemCount: _pages.length,
            ),
            bottomNavigationBar: BottomNavBarWidget(index: 0, pageController: _pageController,),
        );
    }
}

import 'package:flutter/material.dart';

import 'package:fast_pass/app/resources/app_icon.dart';
import 'package:fast_pass/app/resources/app_style.dart';

typedef VoidOnChange = void Function(int);

class BottomNavBarWidget extends StatefulWidget {
    final PageController pageController;
    final int index;
    final int maxNum;
    final VoidOnChange onChange;
    BottomNavBarWidget({
        Key key,
        this.index,
        this.maxNum,
        @required this.pageController,
        this.onChange,
    }) : super(key: key);
    @override
    _BottomNavBarWidgetState createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
    int _currentIndex = 0;
    @override
    void initState() {
        super.initState();
        setCurrentIndex(widget.index);
    }
    @override
    void dispose() {
        super.dispose();
    }

    void setCurrentIndex(int index){
        if(index != _currentIndex){
            setState(() {
                _currentIndex = index;
            });
        }
    }

    void _callback(int index){
        if(widget.onChange == null){
            widget.pageController.animateToPage(index,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
            setCurrentIndex(index);
        }else{
            widget.onChange(index);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
                //primaryColor: Color.fromRGBO(33, 179, 218, 1), //这里如果修改的话，可以再修改bottom bar中的激活颜色
            ),
            child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                fixedColor: AppStyle.colorSecondary,
                currentIndex: _currentIndex,
                onTap: (int i) {
                    _callback(i);
                },
                items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.folder_shared),
                        title: Text("资产"),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.filter_list),
                        title: Text("交易"),
                    ),
//                    BottomNavigationBarItem(
//                        icon: _buildCartBadge()
//                        , title: Text("购物车"),
//                    ),
                    BottomNavigationBarItem(
                        icon: Icon(AppIcon.my_light),
                        title: Text("个人中心"),
                    ),
                ],
            ),
        );
    }
}

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
///图片加载动画
class ProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new SizedBox(
        width: 24.0,
        height: 24.0,
        child: new CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: new AlwaysStoppedAnimation<Color>(AppStyle.colorPrimary),
        ),
      ),
    );
  }
}

class AnimatedView extends AnimatedWidget {
    // The Tweens are static because they don't change.

    final double height;
    final double width;
    final Color backgroundColor;
    final Widget contentWidget;

    AnimatedView({
        Key key,
        Animation<double> animation ,
        @required this.height,
        @required this.width,
        @required this.contentWidget,
        this.backgroundColor,
    })
        : super(key: key, listenable: animation);

    Widget build(BuildContext context) {
        print('height = $height,width = $width');
        final Animation<double> animation = listenable;
        return Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1).evaluate(animation),
            child: Center(
                child: Container(
                    height: Tween<double>(begin: 0.0, end: height).evaluate(animation),
                    width: width,
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: contentWidget,
                ),
            ),
        );
    }
}

class CustomDropDownMenu extends StatefulWidget {
    final bool isHidden;
    final double height;
    final double width;
    final Color backgroundColor;
    final Widget contentWidget;
    CustomDropDownMenu({
        @required this.isHidden,
        @required this.height,
        @required this.width,
        @required this.contentWidget,
        this.backgroundColor = Colors.white
    });
    @override
    _CustomDropDownMenuState createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> with TickerProviderStateMixin {
    AnimationController controller;
    Animation<double> animation;

    bool isHidden = true;
    bool isReverse = false;

    @override
    initState() {
        super.initState();
        controller = AnimationController(
            duration: const Duration(milliseconds: 300), vsync: this);
        animation = CurvedAnimation(parent: controller, curve: Curves.fastLinearToSlowEaseIn);
    }
    @override
    void didUpdateWidget(CustomDropDownMenu oldWidget) {
        // TODO: implement didUpdateWidget
        super.didUpdateWidget(oldWidget);

        if(isHidden == true && widget.isHidden == false){
        print('开始出现动画');
            controller.forward();
            setState(() {
                isHidden = false;
            });
        }else if (isHidden == false && widget.isHidden == true && isReverse == false){
        print('开始回转动画');
            isReverse = true;
            controller.reverse();
            Future.delayed(const Duration(milliseconds: 300), () async{
                setState(() {
                    isHidden = true;
                    isReverse = false;
                });
            });
        }
    }
    @override
    Widget build(BuildContext context) {
        return Offstage(
            offstage: isHidden,
            child: AnimatedView(
                animation: animation,
                height: widget.height,
                width: widget.width,
                backgroundColor: widget.backgroundColor,
                contentWidget: widget.contentWidget,
            ),
        );
    }

    @override
    dispose() {
        controller.dispose();
        super.dispose();
    }
}
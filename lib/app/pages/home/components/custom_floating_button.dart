import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedButton extends AnimatedWidget {
    final Function onPressed;
    final double size;
    final IconData icon;
    final Color backgroundColor,iconColor;
    // The Tweens are static because they don't change.

    AnimatedButton({
        Key key,
        Animation<double> animation ,
        @required this.onPressed,
        this.backgroundColor = Colors.white,
        @required this.icon,
        this.iconColor = Colors.pink,
        this.size = 30,
        })
        : super(key: key, listenable: animation);

    Widget build(BuildContext context) {
        final Animation<double> animation = listenable;
        return Center(
            child: Opacity(
                opacity: Tween<double>(begin: 0.0, end: 1.0).evaluate(animation),
                child: Container(
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(size),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: IconButton(
                        icon: Icon(
                            icon,
                            color: iconColor,
                            size:  Tween<double>(begin: 0, end: size).evaluate(animation),
                        ),
                        onPressed: onPressed,
                    ),
                ),
            ),
        );
    }
}

class CustomFloatingButton extends StatefulWidget {
    final Function onPressed;
    final bool isHidden;
    final double size;
    final IconData icon;
    final Color backgroundColor,iconColor;
    CustomFloatingButton({
        @required this.onPressed,
        this.isHidden,
        this.size,
        this.iconColor,
        @required this.icon,
        this.backgroundColor
    });
  @override
  _CustomFloatingButtonState createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton> with TickerProviderStateMixin {
    AnimationController controller;
    Animation<double> animation;
    
    bool isHidden = true;
    bool isReverse = false;

    @override
    initState() {
        super.initState();
        controller = AnimationController(
            duration: const Duration(milliseconds: 500), vsync: this);
        animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    }
@override
  void didUpdateWidget(CustomFloatingButton oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if(isHidden == true && widget.isHidden == false){
//        print('开始出现动画');
        controller.forward();
        setState(() {
            isHidden = false;
        });
    }else if (isHidden == false && widget.isHidden == true && isReverse == false){
//        print('开始回转动画');
        isReverse = true;
        controller.reverse();
        Future.delayed(const Duration(milliseconds: 600), () async{
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
            child: AnimatedButton(
                animation: animation,
                onPressed: widget.onPressed,
                size: widget.size,
                iconColor: widget.iconColor,
                icon : widget.icon,
                backgroundColor: widget.backgroundColor
            ),
        );
    }

    @override
    dispose() {
        controller.dispose();
        super.dispose();
    }
}
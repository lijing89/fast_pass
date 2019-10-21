import 'package:flutter/material.dart';

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;
  final double width;

  const MySeparator({this.height = 1, this.color = Colors.black,this.width});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = height;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}



class MyVerticalSeparator extends StatelessWidget {
  final double height;
  final Color color;
  final double width;

  const MyVerticalSeparator({this.height = 1, this.color = Colors.black,this.width});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxHeight = constraints.constrainHeight();
        final dashWidth = width;
        final dashHeight = height;
        final dashCount = (boxHeight / (2 * dashHeight)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: Container(
                margin: EdgeInsets.only(bottom: 2),
                child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
              )
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
        );
      },
    );
  }
}
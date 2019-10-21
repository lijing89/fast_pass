import 'package:flutter/material.dart';

class AssetUtil{
    static const String assetBasePath = 'assets';
    static const String assetImagePath = 'images';

    static String basePath(){
        return assetBasePath + '/';
    }

    static String image(String src){
        return basePath() + assetImagePath + '/' + src;
    }

    static Widget imagePlaceholder({double width, double height}){
        Widget _widget;
        if(width == null && height == null){
            _widget = Center(child: CircularProgressIndicator(),);
        }else{
            _widget = Container(padding: EdgeInsets.all(0.0) ,width: width, height: height, child: Center(child: CircularProgressIndicator(),),);
        }
        return _widget;
    }
}
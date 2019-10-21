

import 'package:fast_pass/app/resources/app_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//可选弹窗
fpshowDiaLog(BuildContext context,String title,String cont,Function sureSelected,{Function cancel}){
   showCupertinoDialog(
       context:context,
       builder:(BuildContext context){
           return new CupertinoAlertDialog(
             title: new Text(
               title,
             ),
             content: new Text(cont),
             actions: <Widget>[
               new Container(
                 decoration: BoxDecoration(
                   border: Border(right:BorderSide(color: AppStyle.colorBackground,width: 1.0),top:BorderSide(color: AppStyle.colorPrimary,width: 1.0))
                 ),
                 child: FlatButton(
                   child: new Text("取消"),
                   onPressed:(){
                     Navigator.pop(context);
                     if(cancel != null){
                       cancel();
                     }
                   },
                 ),
               ),
               new Container(
                 decoration: BoxDecoration(
                     border: Border(top:BorderSide(color: AppStyle.colorBackground,width: 1.0))
                 ),
                 child: FlatButton(
                   child: new Text("确定"),
                   onPressed:(){
                     sureSelected();
                     Navigator.pop(context);
                   },
                 ),
               )
             ],
           );
       }
    );
}



showOneButtonDiaLog(BuildContext context,String title,String cont,Function sureSelected){
   showCupertinoDialog(
       context:context,
       builder:(BuildContext context){
           return new CupertinoAlertDialog(
             title: new Text(
               title,
             ),
             content: new Text(cont),
             actions: <Widget>[
               new Container(
                 decoration: BoxDecoration(
                     border: Border(top:BorderSide(color: AppStyle.colorBackground,width: 1.0))
                 ),
                 child: FlatButton(
                   child: new Text("确定"),
                   onPressed:(){
                     sureSelected();
                     Navigator.pop(context);
                   },
                 ),
               )
             ],
           );
       }
    );
}
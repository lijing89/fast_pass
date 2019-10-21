import 'package:flutter/material.dart';

class GiftProvider extends ChangeNotifier {
    String _giftId = '';
    String _num = '';
    String get giftId => _giftId;
    String get num => _num;

    String _imageUrl = '';
    String _name = '';
    String get imageUrl => _imageUrl;
    String get name => _name;

    String _jumpGiftId = '';
    String get jumpGiftId => _jumpGiftId;

    void jumpToDetail({String jumpGiftId}){
        _jumpGiftId = jumpGiftId;
        notifyListeners();
    }

    void select({String giftId,String num,String imageUrl,String name}) {
        _giftId = giftId;
        _num = num;
        _imageUrl = imageUrl;
        _name = name;
        notifyListeners();
    }

    void clear() {
        _giftId = '';
        _num = '';
        _imageUrl = '';
        _name = '';
        notifyListeners();
    }

}
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
    int _count = 0;
    int get count => _count;

    void increment() {
        _count++;
        notifyListeners();
    }
    void incut() {
        _count--;
        notifyListeners();
    }
}
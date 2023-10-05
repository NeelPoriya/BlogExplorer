import 'package:flutter/material.dart';

class FavouritesModel extends ChangeNotifier {
  final List<String> _favourites = [];

  List<String> get favourites => _favourites;

  void toggleFavorite(String id) {
    print('toggleFavorite for $id called');
    if (_favourites.contains(id)) {
      _favourites.remove(id);
    } else {
      _favourites.add(id);
    }
    notifyListeners();
  }
}

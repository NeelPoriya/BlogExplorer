import 'package:flutter/foundation.dart';

class BlogFavorites extends ChangeNotifier {
  Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
}

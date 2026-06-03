import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/utils/oolaf_music_favorites.dart';

class OolafAudioFavoritesController extends ChangeNotifier {
  Set<String> _favoriteUrls = <String>{};

  Set<String> get favoriteUrls => _favoriteUrls;

  Future<void> loadFavorites() async {
    _favoriteUrls = await OolafMusicFavorites.readUrls();
    notifyListeners();
  }

  Future<void> toggleFavorite(String url) async {
    _favoriteUrls = await OolafMusicFavorites.toggleUrl(url);
    notifyListeners();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favChannelsKey = 'favorites_channels';
  static const String _favSeriesKey = 'favorites_series';

  static Future<List<String>> getFavoriteChannelIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favChannelsKey) ?? [];
  }

  static Future<bool> toggleChannelFavorite(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList(_favChannelsKey) ?? [];
    bool added = false;
    
    if (favs.contains(channelId)) {
      favs.remove(channelId);
    } else {
      favs.add(channelId);
      added = true;
    }
    
    await prefs.setStringList(_favChannelsKey, favs);
    return added;
  }

  static Future<bool> isChannelFavorite(String channelId) async {
    final favs = await getFavoriteChannelIds();
    return favs.contains(channelId);
  }

  static Future<List<String>> getFavoriteSeriesIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favSeriesKey) ?? [];
  }

  static Future<bool> toggleSeriesFavorite(String seriesId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList(_favSeriesKey) ?? [];
    bool added = false;
    
    if (favs.contains(seriesId)) {
      favs.remove(seriesId);
    } else {
      favs.add(seriesId);
      added = true;
    }
    
    await prefs.setStringList(_favSeriesKey, favs);
    return added;
  }

  static Future<bool> isSeriesFavorite(String seriesId) async {
    final favs = await getFavoriteSeriesIds();
    return favs.contains(seriesId);
  }
}

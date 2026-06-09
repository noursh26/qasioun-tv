import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/app_update.dart';
import '../models/contact_slide.dart';
import '../models/live_channel.dart';
import '../models/tv_series.dart';
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.npoint.io';
  
  static const String _updateEndpoint = '$_baseUrl/a9c99e655b64ae231d9f';
  static const String _slidesEndpoint = '$_baseUrl/b768a9abb4b4affb9d52';
  static const String _liveEndpoint = '$_baseUrl/eceafaf185933c6a2a29';
  static const String _kidsEndpoint = '$_baseUrl/6c8825569553e4c569ce';
  static const String _seriesEndpoint = '$_baseUrl/5bb89b9dc5901f6f3fbb';
  static const String _moviesEndpoint = '$_baseUrl/6ced7dda8345067d59b4';

  static const String _updateAsset = 'assets/json/app_update.json';
  static const String _slidesAsset = 'assets/json/contact_slides.json';
  static const String _liveAsset = 'assets/json/live_channels.json';
  static const String _kidsAsset = 'assets/json/kids_channels.json';
  static const String _seriesAsset = 'assets/json/tv_series.json';
  static const String _moviesAsset = 'assets/json/movies.json';

  // Helper method to fetch from network or fallback to asset
  Future<dynamic> _fetchData(String url, String assetPath) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('HTTP error ${response.statusCode} for $url. Falling back to asset.');
        return await _loadAsset(assetPath);
      }
    } catch (e) {
      print('Network error fetching $url: $e. Falling back to asset.');
      return await _loadAsset(assetPath);
    }
  }

  Future<dynamic> _loadAsset(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString);
    } catch (e) {
      print('Failed to load asset $assetPath: $e');
      throw Exception('Data loading failed from both network and local assets.');
    }
  }

  // Fetch app update config
  Future<AppUpdate> fetchAppUpdate() async {
    final data = await _fetchData(_updateEndpoint, _updateAsset);
    return AppUpdate.fromJson(data);
  }

  // Fetch contact slides
  Future<List<ContactSlide>> fetchContactSlides() async {
    final data = await _fetchData(_slidesEndpoint, _slidesAsset);
    if (data is List) {
      return data.map((item) => ContactSlide.fromJson(item)).toList();
    }
    return [];
  }

  // Fetch live channels (general + kids combined or separated)
  Future<List<LiveChannel>> fetchLiveChannels() async {
    List<LiveChannel> channels = [];
    
    // Fetch general live channels
    try {
      final generalData = await _fetchData(_liveEndpoint, _liveAsset);
      if (generalData is List) {
        channels.addAll(generalData.map((item) => LiveChannel.fromJson(item)));
      }
    } catch (e) {
      print('Error fetching general channels: $e');
    }

    // Fetch kids channels
    try {
      final kidsData = await _fetchData(_kidsEndpoint, _kidsAsset);
      if (kidsData is List) {
        channels.addAll(kidsData.map((item) => LiveChannel.fromJson(item)));
      }
    } catch (e) {
      print('Error fetching kids channels: $e');
    }

    return channels;
  }

  // Fetch TV series (VOD)
  Future<List<TvSeries>> fetchTvSeries() async {
    final data = await _fetchData(_seriesEndpoint, _seriesAsset);
    if (data is List) {
      return data.map((item) => TvSeries.fromJson(item)).toList();
    }
    return [];
  }

  // Fetch Movies (VOD)
  Future<List<Movie>> fetchMovies() async {
    final data = await _fetchData(_moviesEndpoint, _moviesAsset);
    if (data is List) {
      return data.map((item) => Movie.fromJson(item)).toList();
    }
    return [];
  }
}

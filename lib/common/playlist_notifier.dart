import 'dart:convert';
import 'dart:developer';

import 'package:budget/common/preference.dart';
import 'package:flutter/material.dart';

class PlaylistNotifier extends ChangeNotifier {
  List<String> _playlists = List.empty(growable: true);
  final Preferences _preferences = Preferences();

  PlaylistNotifier() {
    _preferences.getString(PreferenceType.playlists).then((value) {
      _playlists = List<String>.from(jsonDecode(value ?? ''));
      notifyListeners();
    }).catchError((e) {
      inspect(e);
      notifyListeners();
    });
  }

  Future<void> addPlaylist(String playlistId) async {
    if (_playlists.contains(playlistId)) return;
    _playlists.add(playlistId);
    await _preferences.setString(
      PreferenceType.playlists,
      _playlists.map((id) => '"$id"').toList().toString(),
    );
    notifyListeners();
  }

  Future<void> removePlaylist(String playlistId) async {
    _playlists = _playlists.where((id) => id != playlistId).toList();
    await _preferences.setString(
      PreferenceType.playlists,
      _playlists.map((id) => '"$id"').toList().toString(),
    );
    notifyListeners();
  }

  List<String> get playlists => _playlists;
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/convert.dart';
import '../server/http_service.dart';

class Playlist {
  final String id;
  final String title;
  final List<PlaylistVideo> videos;

  Playlist({required this.id, required this.title, required this.videos});

  bool get hasPendingVideos => videos.any((v) => v.isPending);
}

class PlaylistVideo {
  final String id;
  final String title;
  final Thumbnail? thumbnail;
  final DateTime publishedAt;
  final int pendingDays;

  PlaylistVideo({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.publishedAt,
    required this.pendingDays,
  });

  bool get isPending => publishedAt.isAfter(DateTime.now().subtract(Duration(days: pendingDays)));
}

class Thumbnail {
  final String url;
  final int width;
  final int height;
  Thumbnail({required this.url, required this.width, required this.height});
}

const int DEFAULT_PENDING_DAYS = 2;

class YouTubeApi extends HttpService {
  final version = '/youtube/v3';
  final apiKey = dotenv.env['YOUTUBE_API_KEY'];
  YouTubeApi() : super('youtube.googleapis.com', '');

  Future<String> getPlaylistTitle(String playListId) async {
    try {
      final res = await get(
        endpoint: '$version/playlists',
        queryParams: {'part': 'snippet', 'id': playListId, 'key': apiKey},
      );
      return res['items']?[0]?['snippet']?['title'] ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<Playlist> getPlaylistItems(
    String playListId, {
    bool filerPrivateVideos = true,
    int daysAsPendingVideo = DEFAULT_PENDING_DAYS,
  }) async {
    try {
      final title = await getPlaylistTitle(playListId);
      final res = await get(
        endpoint: '$version/playlistItems',
        queryParams: {'part': 'snippet', 'playlistId': playListId, 'key': apiKey},
      );
      final items = List.from(res['items']).map((p) {
        Thumbnail? thumbnail;
        if (p['snippet']['thumbnails']?['default'] != null) {
          var data = p['snippet']['thumbnails']?['default'];
          thumbnail = Thumbnail(url: data['url'], height: data['height'], width: data['width']);
        }
        return PlaylistVideo(
          id: p['snippet']?['resourceId']?['videoId'] ?? p['id'],
          title: p['snippet']['title'],
          thumbnail: thumbnail,
          publishedAt: Convert.parseDate(p['snippet']['publishedAt'], p),
          pendingDays: daysAsPendingVideo,
        );
      }).toList();
      return Playlist(
        id: playListId,
        title: title,
        videos: items.where((element) => element.thumbnail != null).toList(),
      );
    } catch (e) {
      return Playlist(id: playListId, title: '', videos: []);
    }
  }
}

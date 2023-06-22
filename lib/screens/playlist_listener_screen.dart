import 'dart:convert';

import 'package:budget/common/playlist_notifier.dart';
import 'package:budget/common/preference.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../server/youtube_api.dart';
import '../common/styles.dart';

class PlaylistListenerScreen extends StatefulWidget {
  const PlaylistListenerScreen({Key? key}) : super(key: key);

  @override
  PlaylistListenerScreenState createState() => PlaylistListenerScreenState();
}

class PlaylistListenerScreenState extends State<PlaylistListenerScreen> {
  final YouTubeApi youTubeApi = YouTubeApi();
  Map<String, bool> showPlaylist = {};
  Preferences preferences = Preferences();
  int daysAsPendingVideo = DEFAULT_PENDING_DAYS;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var playlistNotifier = Provider.of<PlaylistNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getBackButton(context),
        title: Text('Playlist Listener'.i18n),
        actions: [
          addAction(playlistNotifier),
          setPendingDaysAction(playlistNotifier),
        ],
      ),
      body: getBody(playlistNotifier, theme),
    );
  }

  addAction(PlaylistNotifier playlistNotifier) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        String playlistId = '';
        await showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text('Add Playlist'.i18n),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Playlist ID',
                  hintText: 'PLDhPxd2d23SziFXM9n8e9wNbwZZjyeXrD',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) => playlistId = value,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      playlistNotifier.addPlaylist(playlistId);
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Add'.i18n),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  setPendingDaysAction(PlaylistNotifier playlistNotifier) {
    return IconButton(
      icon: const Icon(Icons.pending_actions_outlined),
      onPressed: () async {
        var controller = TextEditingController(text: '$daysAsPendingVideo');
        await showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text('Set Days as Pending Video'.i18n),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Days',
                  hintText: '$DEFAULT_PENDING_DAYS',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                keyboardType: TextInputType.number,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      daysAsPendingVideo = int.parse(controller.text);
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Set Day'.i18n),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getBody(PlaylistNotifier playlistsNotifier, ThemeData theme) {
    var playlists = playlistsNotifier.playlists;
    return RefreshIndicator(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          if (playlists.isEmpty)
            SliverToBoxAdapter(
              child: Column(children: [
                Text('No playlist added yet'.i18n, style: theme.textTheme.bodyLarge),
              ]),
            ),
          if (playlists.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FutureBuilder(
                  future: Future.wait(
                      playlists.map((id) => youTubeApi.getPlaylistItems(id, daysAsPendingVideo: daysAsPendingVideo))),
                  builder: (_, AsyncSnapshot<List<Playlist>> snapshot) {
                    if (snapshot.data == null) {
                      return Column(mainAxisSize: MainAxisSize.min, children: [getLoadingProgress(context: context)]);
                    } else {
                      return Column(
                        children: (snapshot.data ?? [])
                            .map((playlist) => getPlayList(playlistsNotifier, playlist, theme))
                            .toList(),
                      );
                    }
                  },
                ),
              ),
            ),
        ],
      ),
      onRefresh: () async => setState(() {}),
    );
  }

  Widget getPlayList(PlaylistNotifier playlistsNotifier, Playlist playlist, ThemeData theme) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            showPlaylist.addAll({playlist.id: !(showPlaylist[playlist.id] == true)});
          }),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  !(showPlaylist[playlist.id] == true) ? Icons.arrow_right : Icons.arrow_drop_down,
                  color: theme.disabledColor,
                ),
              ),
              if (playlist.hasPendingVideos)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  playlist.title,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => playlistsNotifier.removePlaylist(playlist.id),
                icon: Icon(Icons.delete, color: theme.disabledColor),
              ),
            ],
          ),
        ),
        Visibility(
          visible: showPlaylist[playlist.id] ?? false,
          child: DisplayPlaylistVideos(videos: playlist.videos),
        ),
      ],
    );
  }
}

class DisplayPlaylistVideos extends StatelessWidget {
  static const String _dateFormat = DateFormat.ABBR_MONTH_WEEKDAY_DAY;
  final List<PlaylistVideo> videos;
  static final DateTime now = DateTime.now();

  final SizedBox heightPadding = const SizedBox(height: 7);
  final double widthPaddingValue = 15;
  final double opacitySlide = 0.25;

  const DisplayPlaylistVideos({Key? key, required this.videos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 8, left: widthPaddingValue, right: widthPaddingValue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: videos.map((video) => displayVideo(context, video)).toList(),
          ),
          heightPadding,
        ],
      ),
    );
  }

  Widget displayVideo(BuildContext context, PlaylistVideo video) {
    final theme = Theme.of(context);
    Uri url = Uri.parse('http://www.youtube.com/watch?v=${video.id}');

    return Row(
      children: [
        if (video.thumbnail != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                video.thumbnail!.url,
                width: video.thumbnail!.width.toDouble(),
                height: video.thumbnail!.height.toDouble(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                video.title,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  if (video.isPending)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  Text(DateFormat(_dateFormat).format(video.publishedAt), style: theme.textTheme.bodySmall),
                  IconButton(
                    onPressed: () {
                      launchUrl(url, mode: LaunchMode.externalApplication).catchError((_) {});
                    },
                    icon: const Icon(Icons.launch),
                    tooltip: 'Open in app'.i18n,
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

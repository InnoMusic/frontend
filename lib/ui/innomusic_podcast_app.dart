// Copyright 2020 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:innomusic/api/podcast/mobile_podcast_api.dart';
import 'package:innomusic/bloc/discovery/discovery_bloc.dart';
import 'package:innomusic/bloc/podcast/audio_bloc.dart';
import 'package:innomusic/bloc/podcast/episode_bloc.dart';
import 'package:innomusic/bloc/podcast/podcast_bloc.dart';
import 'package:innomusic/bloc/search/search_bloc.dart';
import 'package:innomusic/core/chrome.dart';
import 'package:innomusic/l10n/L.dart';
import 'package:innomusic/repository/repository.dart';
import 'package:innomusic/repository/sembast/sembast_repository.dart';
import 'package:innomusic/services/audio/audio_player_service.dart';
import 'package:innomusic/services/audio/mobile_audio_service.dart';
import 'package:innomusic/services/download/download_service.dart';
import 'package:innomusic/services/download/mobile_download_service.dart';
import 'package:innomusic/services/podcast/mobile_podcast_service.dart';
import 'package:innomusic/services/podcast/podcast_service.dart';
import 'package:innomusic/services/settings/mobile_settings_service.dart';
import 'package:innomusic/state/pager_bloc.dart';
import 'package:innomusic/ui/library/discovery.dart';
import 'package:innomusic/ui/library/downloads.dart';
import 'package:innomusic/ui/library/library.dart';
import 'package:innomusic/ui/settings/settings.dart';
import 'package:innomusic/ui/themes.dart';
import 'package:innomusic/ui/widgets/custom_expanding_bottom_bar.dart';
import 'package:innomusic/ui/widgets/mini_player_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'search/search_page.dart';

final theme = Themes.lightTheme().themeData;


// ignore: must_be_immutable
class InnoMusicPodcastApp extends StatelessWidget {
  final Repository repository;
  final MobilePodcastApi podcastApi;
  DownloadService downloadService;
  PodcastService podcastService;
  AudioPlayerService audioPlayerService;

  // Initialise all the services our application will need.
  InnoMusicPodcastApp.InnoMusicApp()
      : repository = SembastRepository(),
        podcastApi = MobilePodcastApi() {
    downloadService = MobileDownloadService(repository: repository);
    podcastService =
        MobilePodcastService(api: podcastApi, repository: repository);
    audioPlayerService = MobileAudioPlayerService(repository: repository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SearchBloc>(
          create: (_) => SearchBloc(
              podcastService: MobilePodcastService(
                  api: podcastApi, repository: repository)),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<DiscoveryBloc>(
          create: (_) => DiscoveryBloc(
              podcastService: MobilePodcastService(
                  api: podcastApi, repository: repository)),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<EpisodeBloc>(
          create: (_) => EpisodeBloc(
              podcastService:
                  MobilePodcastService(api: podcastApi, repository: repository),
              audioPlayerService: audioPlayerService),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<PodcastBloc>(
          create: (_) => PodcastBloc(
              podcastService: podcastService,
              audioPlayerService: audioPlayerService,
              downloadService: downloadService),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<PagerBloc>(
          create: (_) => PagerBloc(),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<AudioBloc>(
          create: (_) => AudioBloc(audioPlayerService: audioPlayerService),
          dispose: (_, value) => value.dispose(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'InnoMusic',
        localizationsDelegates: [
          const LocalisationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
        ],
        theme: theme,
        home: InnomusicHomePage(title: 'InnoMusic'),
      ),
    );
  }
}

class InnomusicHomePage extends StatefulWidget {
  final String title;

  InnomusicHomePage({this.title});

  @override
  _InnomusicHomePageState createState() => _InnomusicHomePageState();
}

class _InnomusicHomePageState extends State<InnomusicHomePage>
    with WidgetsBindingObserver {
  final log = Logger('_InnomusicHomePageState');
  Widget library;

  @override
  void initState() {
    super.initState();

    final audioBloc = Provider.of<AudioBloc>(context, listen: false);

    Chrome.transparentLight();

    WidgetsBinding.instance.addObserver(this);

    audioBloc.transitionLifecycleState(LifecyleState.resume);
  }

  @override
  void dispose() {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);
    audioBloc.transitionLifecycleState(LifecyleState.pause);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);
    switch (state) {
      case AppLifecycleState.resumed:
        audioBloc.transitionLifecycleState(LifecyleState.resume);
        break;
      case AppLifecycleState.paused:
        audioBloc.transitionLifecycleState(LifecyleState.pause);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pager = Provider.of<PagerBloc>(context);
    final searchBloc = Provider.of<EpisodeBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: own,
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<int>(
                      stream: pager.currentPage,
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        return _fragment(snapshot.data, searchBloc);
                      }),
            ),
            MiniPlayer(),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder<int>(
          stream: pager.currentPage,
          initialData: 0,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            return CustomExpandingBottomNavBar(
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.white,
              selectedIndex: snapshot.data,
              navBarHeight: 54,
              onIndexChanged: (index) {
                print('onIndexChanged: $index');
                pager.changePage(index);
                },
              items: <CustomExpandingBottomBarItem>[
                CustomExpandingBottomBarItem(
                  icon: Icons.play_circle_fill,
                  iconColor: blueD,
                  selectedColor: primCol,
                  text: 'Listen Now',
                ),
                CustomExpandingBottomBarItem(
                  icon: Icons.search_outlined,
                  iconColor: blueD,
                  selectedColor: primCol,
                  text: 'Search',
                ),
                CustomExpandingBottomBarItem(
                  icon: Icons.library_music,
                  iconColor: blueD,
                  selectedColor: primCol,
                  text: L.of(context).library,
                ),
              ],
            );
          }),
    );
  }

  Widget _appbar(int index){}



  Widget _fragment(int index, EpisodeBloc searchBloc) {
    switch (index) {
      case 0:
        return Discovery();
      case 1:
        return SearchPage();
      default:
        return Library();
    }
  }
    /*if (index == 0) {
      return Library();
    } else if (index == 1) {
      return Discovery(); //
    } else {
      return Downloads();
    }*/


  void _menuSelect(String choice) async {
    final packageInfo = await PackageInfo.fromPlatform();

    switch (choice) {
      case 'about':
        showAboutDialog(
            context: context,
            applicationName: 'InnoMusic',
            applicationVersion:
                'v${packageInfo.version} Alpha build ${packageInfo.buildNumber}',
            applicationIcon: Image.asset(
              'assets/images/anytime-logo-s.png',
              width: 52.0,
              height: 52.0,
            ),
            children: <Widget>[
              Text('\u00a9 2020 Ben Hills'),
              GestureDetector(
                  child: Text('anytime@amugofjava.me.uk',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue)),
                  onTap: () {
                    _launchEmail();
                  }),
            ]);
        break;
      case 'settings':
        var s = await MobileSettingsService.instance();

        await Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (context) => Settings(
                    settingsService: s,
                  )),
        );
        break;
    }
  }

  void _launchEmail() async {
    const url = 'mailto:anytime@amugofjava.me.uk';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class TitleWidget extends StatelessWidget {
  final TextStyle _titleTheme1 = theme.textTheme.bodyText2.copyWith(
      color: Colors.red,
      fontWeight: FontWeight.bold,
      fontFamily: 'MontserratRegular',
      fontSize: 18);

  final TextStyle _titleTheme2 = theme.textTheme.bodyText2.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontFamily: 'MontserratRegular',
      fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        children: <Widget>[
          Text(
            'Anytime ',
            style: _titleTheme1,
          ),
          Text(
            'Player',
            style: _titleTheme2,
          ),
        ],
      ),
    );
  }
}

const primCol = Color(0xff80bc00);
const bluel = Color(0xff97caeb);
const bluell = Color(0xffc5d9e7);
const greenR = Color(0xff348f41);
const orangeR = Color(0xffff5c35);
const purple = Color(0xff60269e);
const blueD = Color(0xdf1a428a);

const SystemUiOverlayStyle own = SystemUiOverlayStyle(
  systemNavigationBarColor: Color(0xff348f41),
  systemNavigationBarDividerColor: null,
  statusBarColor: Color(0xff80bc00),
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);
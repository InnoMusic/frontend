// Copyright 2020 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:innomusic/bloc/discovery/discovery_state_event.dart';
import 'package:innomusic/l10n/L.dart';
import 'package:innomusic/state/bloc_state.dart';
import 'package:innomusic/ui/innomusic_podcast_app.dart';
import 'package:innomusic/ui/podcast/discovery_page.dart';
import 'package:innomusic/ui/widgets/platform_progress_indicator.dart';
import 'package:innomusic/ui/widgets/podcast_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:podcast_search/podcast_search.dart' as search;

class DiscoveryResults extends StatelessWidget {
  final Stream<DiscoveryState> data;

  var log = Logger("discoverResult");

  DiscoveryResults({@required this.data});

  @override
  Widget build(BuildContext context) {
    log.fine("discoverRes");
    return StreamBuilder<DiscoveryState>(
      stream: data,
      builder: (BuildContext context, AsyncSnapshot<DiscoveryState> snapshot) {
        final state = snapshot.data;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              brightness: Brightness.light,
              flexibleSpace: FlexibleSpaceBar(
                title: Container(
                  //alignment: Alignment.center,
                  color: Colors.transparent,
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Discover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      )),
                ),
              ),
              bottom: PreferredSize(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 56,
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  color: Colors.transparent,
                ),
                preferredSize: Size.fromHeight(56),
              ),
              backgroundColor: primCol,
              floating: false,
              pinned: false,
              expandedHeight: 128,
              snap: false,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    // _searchController.clear();
                    //FocusScope.of(context).requestFocus(_searchFocusNode);
                  },
                ),
              ],
            ),
            _discoveryState(state, context)
          ],
        );
      },
    );
  }
}

Widget _discoveryState(DiscoveryState state, BuildContext context){
  if (state is DiscoveryPopulatedState) {
    //return PodcastList(results: state.results as search.SearchResult);
    return DiscoverPage(results: state.results as search.SearchResult);
  }
  else {
    if (state is DiscoveryLoadingState) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            PlatformProgressIndicator(),
          ],
        ),
      );
    }
    else if (state is BlocErrorState) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 75,
                color: Colors.blue[900],
              ),
              Text(
                L.of(context).no_search_results_message,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    else {
      return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(),
    );
    }
  }
}

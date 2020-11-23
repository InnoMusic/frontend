// Copyright 2020 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:innomusic/bloc/podcast/podcast_bloc.dart';
import 'package:innomusic/entities/podcast.dart';
import 'package:innomusic/l10n/L.dart';
import 'package:innomusic/ui/widgets/podcast_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../innomusic_podcast_app.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    final _podcastBloc = Provider.of<PodcastBloc>(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          brightness: Brightness.light,
          flexibleSpace: FlexibleSpaceBar(
            title: Container(
              //alignment: Alignment.center,
              color: Colors.transparent,
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Library',
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
        _libState(_podcastBloc, context),
      ],
    );

  }
}

Widget _libState(PodcastBloc _podcastBloc, BuildContext context){
  return StreamBuilder<List<Podcast>>(
      stream: _podcastBloc.subscriptions,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.headset,
                      size: 75,
                      color: Colors.blue[900],
                    ),
                    Text(
                      L.of(context).no_subscriptions_message,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SliverList(
              delegate: SliverChildListDelegate([
                ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PodcastTile(
                        podcast: snapshot.data.elementAt(index));
                  },
                ),
              ]),
            );
          }
        } else {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(),
          );
        }
      });
}
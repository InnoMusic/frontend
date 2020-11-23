import 'package:innomusic/bloc/discovery/discovery_state_event.dart';
import 'package:innomusic/entities/podcast.dart';
import 'package:innomusic/l10n/L.dart';
import 'package:innomusic/state/bloc_state.dart';
import 'package:innomusic/ui/widgets/platform_progress_indicator.dart';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:logging/logging.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:podcast_search/podcast_search.dart' as search;

import '../innomusic_podcast_app.dart';

class SearchPageResults extends StatelessWidget {
  final Stream<BlocState> data;
  final double width;

  var log = Logger("searchPageResults");

  SearchPageResults({Key key, @required this.data, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("rebuild BUILD");
    return StreamBuilder<BlocState>(
      stream: data,
      builder: (BuildContext context, AsyncSnapshot<BlocState> snapshot) {
        final state = snapshot.data;

        if (state is BlocPopulatedState) {
          print('blocPopulated searchPageRes');
          print(
              'blocPopulated searchPageRes ${(state.results as search.SearchResult).items.length}');
          //return PodcastList(results: state.results as search.SearchResult);
          return SearchPageContent(
            results: state.results as search.SearchResult,
            width: width,
          );
        } else {
          if (state is BlocLoadingState) {
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
          } else if (state is BlocErrorState) {
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
          } else {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(),
            );
          }
        }
      },
    );
  }
}

class SearchPageContent extends StatelessWidget {
  final search.SearchResult results;
  final double width;

  const SearchPageContent({Key key, this.results, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logger('searchPageContent').log(Level.FINE, 'rebuild');
    return SliverStaggeredGrid.countBuilder(
        crossAxisCount: 4,
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(_getCardType(index) * 2,
              _getCardType(index) == 2 ? _getCardType(index) * 2 + 1 : 3);
        },
        itemBuilder: (BuildContext context, int index) {
          final p = Podcast.fromSearchResultItem(results.items[index]);
          return SearchPageGridCard(
            cardType: _getCardType(index),
            podcast: p,
            width: width,
          );
        },
        itemCount: results.items.length);
  }
}

int _getCardType(int index) {
  if (index == 2) return 2;
  if ((index - 2) != 0 && (index - 2) % 5 == 0) return 2;

  return 1;
}

class SearchPageGridCard extends StatefulWidget {
  SearchPageGridCard({Key key, this.cardType, this.podcast, this.width})
      : img = CachedNetworkImage(
          fadeInDuration: Duration(milliseconds: 10),
          fadeOutDuration: Duration(milliseconds: 10),
          imageUrl: podcast.imageUrl,
          placeholder: (context, url) {
            return Container(
              constraints: BoxConstraints.expand(height: 60, width: 60),
              child: Placeholder(
                color: Colors.grey,
                strokeWidth: 1,
                fallbackWidth: 60,
                fallbackHeight: 60,
              ),
            );
          },
          errorWidget: (_, __, dynamic ___) {
            return Container(
              constraints: BoxConstraints.expand(height: 60, width: 60),
              child: Placeholder(
                color: Colors.grey,
                strokeWidth: 1,
                fallbackWidth: 60,
                fallbackHeight: 60,
              ),
            );
          },
        ),
        super(key: key);

  final int cardType;
  final Podcast podcast;
  final double width;
  final CachedNetworkImage img;

  @override
  _SearchPageGridCardState createState() {
    return _SearchPageGridCardState();
  }
}

class _SearchPageGridCardState extends State<SearchPageGridCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger('gridcardstate').log(Level.FINE, 'rebuild');
    return Container(
      padding: EdgeInsets.all(8),
      child: Card(
        elevation: 1,
        color: primCol.withOpacity(0.5),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            FittedBox(
              clipBehavior: Clip.antiAlias,
              fit: BoxFit.fill,
              child: widget.img,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                      child: Text(
                        widget.podcast.title,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                      child: Text(
                        widget.podcast.copyright,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PairColor {
  final Color dominant;
  final Color lighter;

  PairColor(this.dominant, this.lighter);
}
/*
Future<PairColor> getImagePalette(CachedNetworkImageProvider imageProvider) async {
  final paletteGenerator =
      await PaletteGenerator.fromImageProvider(imageProvider);
  return PairColor(paletteGenerator.dominantColor.color, paletteGenerator.vibrantColor.color);
}*/

int _getFlex(int cardType) {
  if (cardType == 2)
    return 8;
  else
    return 6;
}

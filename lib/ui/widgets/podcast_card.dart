import 'package:innomusic/bloc/podcast/podcast_bloc.dart';
import 'package:innomusic/core/chrome.dart';
import 'package:innomusic/entities/podcast.dart';
import 'package:innomusic/ui/podcast/podcast_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../innomusic_podcast_app.dart';


class PodcastCard extends StatelessWidget {
  final Podcast podcast;

  PodcastCard({Key key, this.podcast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Logger('PodcastCard').fine('build');
    final _podcastBloc = Provider.of<PodcastBloc>(context);
    return InkWell(
      onTap: () {
        //Chrome.transparentLight();
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => PodcastDetails(podcast, _podcastBloc)),
        );
      },
      child: Container(
          padding: EdgeInsets.all(8),
          width: 180,
          child: Column(
            children: <Widget>[
              Container(
                height: 164,
                width: double.infinity,
                child: FittedBox(
                  child: Hero(
                    tag: '${podcast.imageUrl}:${podcast.link}',
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 10),
                      fadeOutDuration: Duration(milliseconds: 10),
                      imageUrl: podcast.imageUrl,
                      width: 60,
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
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                    top: 4,
                    bottom: 4),
                child: Text(podcast.title,
                    maxLines: 2,
                    style: TextStyle(fontSize: 16, color: purple)),
              ),
            ],
          ),
        ),
    );
  }
}

import 'package:innomusic/entities/podcast.dart';
import 'package:innomusic/ui/innomusic_podcast_app.dart';
import 'package:innomusic/ui/widgets/podcast_card.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart' as search;

class DiscoverRow extends StatelessWidget {
  final String label;
  final List<search.Item> items;
  final int offset;

  DiscoverRow({Key key, this.label, this.items, this.offset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16, top: 8),
            child: Text(
              label,
              style: TextStyle(color: purple, fontSize: 24),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 8.0),
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 8, right: 8),
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                final p = Podcast.fromSearchResultItem(items[index+offset]);

                return PodcastCard(podcast: p);
              },
            ),
          )
        ],
      ),
    );
  }
}

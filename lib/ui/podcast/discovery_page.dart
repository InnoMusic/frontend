import 'package:innomusic/ui/widgets/discover_row.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart' as search;


class DiscoverPage extends StatelessWidget {
  const DiscoverPage({
    Key key,
    @required this.results,
  }) : super(key: key);

  final search.SearchResult results;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: [
          DiscoverRow(label: 'Popular this week', items: results.items, offset: 0),
          DiscoverRow(label: 'Continue lisnening', items: results.items, offset: 4),
          DiscoverRow(label: 'New Releases', items: results.items, offset: 8),
          DiscoverRow(label: 'Jsut to check', items: results.items, offset: 12),
          DiscoverRow(label: 'New Releases', items: results.items, offset: 16),
        ],
      ),
    );
  }
}

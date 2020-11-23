import 'package:innomusic/bloc/discovery/discovery_bloc.dart';
import 'package:innomusic/bloc/discovery/discovery_state_event.dart';
import 'package:innomusic/bloc/search/search_bloc.dart';
import 'package:innomusic/bloc/search/search_state_event.dart';
import 'package:innomusic/l10n/L.dart';
import 'package:innomusic/ui/innomusic_podcast_app.dart';
import 'package:innomusic/ui/search/search.dart';
import 'package:innomusic/ui/search/search_page_results.dart';
import 'package:innomusic/ui/search/search_results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//открывается страница поиска с популярными жанрами и тд
class SearchPage extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchPage> {
  TextEditingController _searchController;
  FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();

    final bloc = Provider.of<SearchBloc>(context, listen: false);

    //final discover_bloc = Provider.of<DiscoveryBloc>(context, listen: false);
    //discover_bloc.discover(DiscoveryChartEvent(count: 12));

    bloc.search(SearchChartsEvent());

    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SearchBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            brightness: Brightness.light,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(
                color: primCol,
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Text('Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      )),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(68),
              child: Hero(
                tag: 'search_field',
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 68,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                      //controller: _searchController,
                      //focusNode: _searchFocusNode,
                      autofocus: false,
                      readOnly: true,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: primCol),
                        hintText: 'Authors, topics, or songs',
                        hintStyle: TextStyle(),
                        border: InputBorder.none,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (context) => Search()),
                        );
                      },
                      style: TextStyle(color: Colors.grey, fontSize: 18.0),
                      onSubmitted: ((value) {}),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            floating: true,
            pinned: true,
            expandedHeight: 180,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(4),
              child: Text(
                'Trending searches',
                style: TextStyle(color: purple, fontSize: 28),
              ),
            ),
          ),
          SearchPageResults(data: bloc.results,
            width: MediaQuery.of(context).size.width,)
        ],
      ),
    );
  }
}


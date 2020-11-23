// Copyright 2020 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:innomusic/bloc/discovery/discovery_bloc.dart';
import 'package:innomusic/bloc/discovery/discovery_state_event.dart';
import 'package:innomusic/ui/library/discovery_results.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///This will be home page
class Discovery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  @override
  void initState() {
    super.initState();

    final bloc = Provider.of<DiscoveryBloc>(context, listen: false);

    bloc.discover(DiscoveryChartEvent(count: 30));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<DiscoveryBloc>(context);

    return DiscoveryResults(data: bloc.results);
  }
}

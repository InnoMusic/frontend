// Copyright 2020 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:innomusic/bloc/podcast/audio_bloc.dart';
import 'package:innomusic/l10n/L.dart';
import 'package:innomusic/services/audio/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Builds a transport control bar for rewind, play and fast-forward.
/// See [NowPlaying].
class PlayerTransportControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42.0),
      child: StreamBuilder<AudioState>(
          stream: audioBloc.playingState,
          builder: (context, snapshot) {
            var playing = snapshot.data == AudioState.playing;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    _rewind(audioBloc);
                  },
                  tooltip: L.of(context).rewind_button_label,
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.skip_previous,
                    size: 48.0,
                    color: Color(0xff348f41),
                  ),
                ),
                Tooltip(
                  message: playing ? L.of(context).fast_forward_button_label : L.of(context).play_button_label,
                  child: FlatButton(
                    onPressed: () {
                      if (playing) {
                        _pause(audioBloc);
                      } else {
                        _play(audioBloc);
                      }
                    },
                    shape: CircleBorder(side: BorderSide(color: Color(0xff348f41), width: 2.0)),
                    color: Color(0xff348f41),
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      size: 60.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _fastforward(audioBloc);
                  },
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.skip_next,
                    size: 48.0,
                    color: Color(0xff348f41),
                  ),
                ),
              ],
            );
          }),
    );
  }

  void _play(AudioBloc audioBloc) {
    audioBloc.transitionState(TransitionState.play);
  }

  void _pause(AudioBloc audioBloc) {
    audioBloc.transitionState(TransitionState.pause);
  }

  void _rewind(AudioBloc audioBloc) {
    audioBloc.transitionState(TransitionState.rewind);
  }

  void _fastforward(AudioBloc audioBloc) {
    audioBloc.transitionState(TransitionState.fastforward);
  }
}

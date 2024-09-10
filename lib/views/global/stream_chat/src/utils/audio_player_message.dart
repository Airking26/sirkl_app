import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../config/s_colors.dart';
import 'audio_loading_message.dart';

class AudioPlayerMessage extends StatefulWidget {
  const AudioPlayerMessage({
    Key? key,
    required this.source,
    required this.id,
  }) : super(key: key);

  final AudioSource source;
  final String id;

  @override
  AudioPlayerMessageState createState() => AudioPlayerMessageState();
}

class AudioPlayerMessageState extends State<AudioPlayerMessage> {
  final _audioPlayer = AudioPlayer();
  late StreamSubscription<PlayerState> _playerStateChangedSubscription;

  late Future<Duration?> futureDuration;

  @override
  void initState() {
    super.initState();

    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen(playerStateListener);

    futureDuration = _audioPlayer.setAudioSource(widget.source);
  }

  void playerStateListener(PlayerState state) async {
    if (state.processingState == ProcessingState.completed) {
      await reset();
    }
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Duration?>(
      future: futureDuration,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _controlButtons(),
              _slider(snapshot.data),
            ],
          );
        }
        return const AudioLoadingMessage();
      },
    );
  }

  Widget _controlButtons() {
    return StreamBuilder<bool>(
      stream: _audioPlayer.playingStream,
      builder: (context, _) {
        final color =
        _audioPlayer.playerState.playing ? SColors.activeColor : SColors.activeColor;
        final icon =
        _audioPlayer.playerState.playing ? Icons.pause : Icons.play_arrow;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () async {
              if (_audioPlayer.playerState.playing) {
                await pause();
              } else {
                await AudioManager().play(_audioPlayer, widget.id);
                setState(() {});
              }
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: color, size: 30),
            ),
          ),
        );
      },
    );
  }

  Widget _slider(Duration? duration) {
    return StreamBuilder<Duration>(
      stream: _audioPlayer.positionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && duration != null) {
          return Slider(
            activeColor: SColors.activeColor,
            thumbColor: Colors.grey,
            inactiveColor: Colors.grey,
            value: snapshot.data!.inMicroseconds / duration.inMicroseconds,
            onChanged: (val) {
              _audioPlayer.seek(duration * val);
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Future<void> play() async {
    await AudioManager().play(_audioPlayer, widget.id);
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(const Duration(milliseconds: 0));
  }
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() => _instance;

  AudioManager._internal();

  AudioPlayer? _currentPlayer;
  String? _currentAudioId;

  Future<void> play(AudioPlayer player, String audioId) async {
    if (_currentPlayer != null && _currentPlayer != player) {
      await _currentPlayer?.stop();
    }
    _currentPlayer = player;
    _currentAudioId = audioId;
    await player.play();
  }

  Future<void> stopCurrent() async {
    if (_currentPlayer != null) {
      await _currentPlayer?.stop();
      _currentPlayer = null;
      _currentAudioId = null;
    }
  }

  String? get currentAudioId => _currentAudioId;
}
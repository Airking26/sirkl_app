import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final File file;

  const TrimmerView(this.file, {super.key});

  @override
  TrimmerViewState createState() => TrimmerViewState();
}

class TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });


    await _trimmer
        .saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (String? value) {
          setState(() {
            _progressVisibility = false;
            Navigator.of(context).pop([File(value!)]);
          });

    });

  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Trimmer"),
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Color(0xFF00CB7D),
                  ),
                ),
                const SizedBox(height: 24,),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                const SizedBox(height: 12,),
                Center(
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width - 16,
                    maxVideoLength: const Duration(seconds: 10),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.only(left: 4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.transparent,
                        ),
                      ),
                      TextButton(
                        child: _isPlaying
                            ?  Icon(
                          Icons.pause,
                          size: 50.0,
                          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color.fromARGB(255, 247, 253, 255) : const Color(0xFF102437),
                        )
                            : Icon(
                          Icons.play_arrow,
                          size: 50.0,
                          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color.fromARGB(255, 247, 253, 255) :const Color(0xFF102437) ,
                        ),
                        onPressed: () async {
                          bool playbackState = await _trimmer.videoPlaybackControl(
                            startValue: _startValue,
                            endValue: _endValue,
                          );
                          setState(() {
                            _isPlaying = playbackState;
                          });
                        },
                      ),
                      InkWell(
                        onTap: _progressVisibility ? null : () async {
                            await _saveVideo();
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.only(left: 4),
                          decoration:  BoxDecoration(
                            shape: BoxShape.circle,
                            color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color.fromARGB(255, 247, 253, 255) : const Color(0xFF102437) ,
                          ),
                          child: const Icon(Icons.send_rounded, color: Color(0xFF00CB7D),),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
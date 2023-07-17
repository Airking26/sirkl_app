import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sirkl/common/view/stream_chat/src/misc/stream_svg_icon.dart';
import 'package:sirkl/common/view/stream_chat/src/theme/stream_chat_theme.dart';

import '../../../../../config/s_colors.dart';

typedef RecordCallback = void Function(String);

class RecordButton extends StatefulWidget {
  const RecordButton({
    Key? key,
    required this.recordingFinishedCallback,
  }) : super(key: key);

  final RecordCallback recordingFinishedCallback;

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;
  final _audioRecorder = Record();

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();

    widget.recordingFinishedCallback(path!);

    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {

    return IconButton(
      icon: Icon( _isRecording ? Icons.stop : Icons.mic),
      color: _isRecording ? SColors.activeColor : StreamChatTheme.of(context).primaryIconTheme.color,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        height: 24,
        width: 24,
      ),
      splashRadius: 24,
      onPressed: (){
        _isRecording ? _stop() : _start();
      },
    );
  }
}
import 'package:dart_vlc/dart_vlc.dart';
import 'package:sirkl/views/global/stream_chat/src/video/vlc/vlc_manager.dart';

/// The desktop implementation of [VlcManager]. It simply initializes VLC.
class VlcManagerDesktop extends VlcManager {
  @override
  void initialize() {
    DartVLC.initialize();
  }
}

/// Allows [VlcManager] to return the correct implementation.
VlcManager getVlc() => VlcManagerDesktop();

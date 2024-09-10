import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sirkl/views/global/story_insta/camera/src/widgets/ui_handler.dart';
import 'package:sirkl/views/global/story_insta/drishya_picker.dart';
import 'package:sirkl/views/global/story_insta/editor/src/widgets/draggable_resizable.dart';
import 'package:uuid/uuid.dart';

/// Drishya editing controller
class DrishyaEditingController extends ValueNotifier<EditorValue> {
  ///
  /// Drishya editing controller
  DrishyaEditingController()
      : _editorKey = GlobalKey(),
        _stickerController = StickerController(),
        _textController = TextEditingController(),
        _focusNode = FocusNode(),
        _currentAssetState = ValueNotifier(null),
        _currentAsset = ValueNotifier(null),
        super(const EditorValue()) {
    init();
  }

  ///
  late EditorSetting _setting;

  ///
  late ValueNotifier<Color> _colorNotifier;

  ///
  late ValueNotifier<EditorBackground> _backgroundNotifier;

  ///
  final GlobalKey _editorKey;

  ///
  final StickerController _stickerController;

  ///
  final TextEditingController _textController;

  /// Editor textfield focus node
  final FocusNode _focusNode;

  ///
  final ValueNotifier<DraggableResizableState?> _currentAssetState;

  ///
  final ValueNotifier<StickerAsset?> _currentAsset;

  /// Editor key
  GlobalKey get editorKey => _editorKey;

  /// Current color notifier
  ValueNotifier<Color> get colorNotifier => _colorNotifier;

  /// Current background notifier
  ValueNotifier<EditorBackground> get backgroundNotifier => _backgroundNotifier;

  /// Sticker controller
  StickerController get stickerController => _stickerController;

  /// Editor text field controller
  TextEditingController get textController => _textController;

  /// Editor text field focus node
  FocusNode get focusNode => _focusNode;

  /// Editor settings
  EditorSetting get setting => _setting;

  /// Initialize controller setting
  @internal
  void init({EditorSetting? setting}) {
    _setting = setting ?? const EditorSetting();
    _colorNotifier = ValueNotifier(_setting.colors.first);
    _backgroundNotifier = ValueNotifier(_setting.backgrounds.first);
  }

  ///
  @internal
  ValueNotifier<DraggableResizableState?> get currentAssetState =>
      _currentAssetState;

  ///
  @internal
  ValueNotifier<StickerAsset?> get currentAsset => _currentAsset;

  var _isDisposed = false;

  /// Update editor value
  @internal
  void updateValue({
    bool? keyboardVisible,
    bool? fillTextfield,
    int? maxLines,
    TextAlign? textAlign,
    bool? hasFocus,
    bool? hasStickers,
    bool? isEditing,
    bool? isStickerPickerOpen,
    bool? isColorPickerOpen,
  }) {
    final oldValue = value;
    if (oldValue.hasFocus && !(hasFocus ?? false)) {
      UIHandler.hideStatusBar();
    }
    value = value.copyWith(
      keyboardVisible: keyboardVisible,
      fillTextfield: fillTextfield,
      maxLines: maxLines,
      textAlign: textAlign,
      hasFocus: hasFocus,
      hasStickers: hasStickers,
      isEditing: isEditing,
      isStickerPickerOpen: isStickerPickerOpen,
      isColorPickerOpen: isColorPickerOpen,
    );
  }

  /// Current color
  Color get currentColor => _colorNotifier.value;

  /// Current background
  EditorBackground get currentBackground => _backgroundNotifier.value;

  /// Computed text color as per the background
  Color get textColor => value.fillTextfield
      ? generateForegroundColor(currentColor)
      : currentColor;

  /// Generate foreground color from background color
  Color generateForegroundColor(Color background) =>
      background.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  ///
  /// Clear editor
  ///
  void clear() {
    _stickerController.clearStickers();
    updateValue(hasStickers: false);
  }

  ///
  /// Change editor gradient background
  void changeBackground() {
    assert(
      _setting.backgrounds.isNotEmpty,
      'Backgrounds cannot be empty',
    );
    final index = _setting.backgrounds.indexOf(currentBackground);
    final nextIndex =
        index >= 0 && index + 1 < _setting.backgrounds.length ? index + 1 : 0;
    final bg = _setting.backgrounds[nextIndex];
    _backgroundNotifier.value = bg;
  }

  ///
  /// Complete editing and generate image
  Future<DrishyaEntity?> completeEditing({
    ValueSetter<Exception>? onException,
  }) async {
    try {
      final bg = _backgroundNotifier.value;

      // If background is a DrishyaBackground and no stickers added, return the entity
      if (bg is DrishyaBackground && !value.hasStickers) {
        return bg.entity;
      }
      // If background is memory bytes and no stickers, save the image
      else if (bg is MemoryAssetBackground && !value.hasStickers) {
        final fileName = const Uuid().v4();
        final filePath = await getTemporaryDirectory();
        final file = File('${filePath.path}/$fileName.png');
        await file.writeAsBytes(bg.bytes);

        final entity = await PhotoManager.editor.saveImageWithPath(
          file.path,
          title: fileName,
        );
        return entity?.toDrishya;
      }
      // If the image is edited, take a screenshot and save it
      else {
        final boundary = _editorKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

        // Ensure boundary is not null
        if (boundary == null) {
          throw Exception("Render boundary is null");
        }

        // Capture image from boundary
        final image = await boundary.toImage();

        // Convert image to byte data
        final byteData = await image.toByteData(format: ImageByteFormat.png);

        /*final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (bytes != null) {
          ui.decodeImageFromPixels(
              Uint8List.view(bytes.buffer),
              image.width,
              image.height,
              ui.PixelFormat.rgba8888, (result) async {
            await result.toByteData(format: ui.ImageByteFormat.png);
          });
        }*/

        // Ensure byteData is not null
        if (byteData == null) {
          throw Exception("Failed to get byte data from image");
        }

        // Convert byte data to Uint8List
        final data = byteData.buffer.asUint8List();
        final fileName = const Uuid().v4();
        final filePath = await getTemporaryDirectory();

        // Create file in temporary directory and write the image data
        final file = File('${filePath.path}/$fileName.png');
        await file.writeAsBytes(data);

        // Save the image using PhotoManager
        final entity = await PhotoManager.editor.saveImageWithPath(
          file.path,
          title: fileName,
        );
        return entity?.toDrishya;
      }
    } catch (e) {
      onException?.call(
        Exception('Exception occurred while capturing picture: $e'),
      );
    }
    return null;
  }

  @override
  set value(EditorValue newValue) {
    if (_isDisposed) return;
    super.value = newValue;
  }

  @override
  void dispose() {
    _colorNotifier.dispose();
    _backgroundNotifier.dispose();
    _textController.dispose();
    _stickerController.dispose();
    _focusNode.dispose();
    _currentAssetState.dispose();
    _currentAsset.dispose();
    _isDisposed = true;
    super.dispose();
  }

  //
}

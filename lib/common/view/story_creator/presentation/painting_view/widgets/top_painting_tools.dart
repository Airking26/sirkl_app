import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sirkl/common/view/story_creator/domain/providers/notifiers/control_provider.dart';
import 'package:sirkl/common/view/story_creator/domain/providers/notifiers/painting_notifier.dart';
import 'package:sirkl/common/view/story_creator/presentation/utils/constants/app_enums.dart';
import 'package:sirkl/common/view/story_creator/presentation/widgets/tool_button.dart';

class TopPaintingTools extends StatefulWidget {
  const TopPaintingTools({Key? key}) : super(key: key);

  @override
  _TopPaintingToolsState createState() => _TopPaintingToolsState();
}

class _TopPaintingToolsState extends State<TopPaintingTools> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ControlNotifier, PaintingNotifier>(
      builder: (context, controlNotifier, paintingNotifier, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 40.h),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// remove last line
                if (paintingNotifier.lines.isNotEmpty)
                  ToolButton(
                    onTap: paintingNotifier.removeLast,
                    onLongPress: paintingNotifier.clearAll,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    backGroundColor: Colors.black12,
                    child: Transform.scale(
                        scale: 0.6,
                        child: const ImageIcon(
                          AssetImage('assets/images/return.png',),
                          color: Colors.white,
                        )),
                  ),

                /// select pen
                ToolButton(
                  onTap: () {
                    paintingNotifier.paintingType = PaintingType.pen;
                  },
                  colorBorder: paintingNotifier.paintingType == PaintingType.pen
                      ? Colors.black
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor:
                      paintingNotifier.paintingType == PaintingType.pen
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black12,
                  child: Transform.scale(
                      scale: 1.2,
                      child: ImageIcon(
                        const AssetImage('assets/images/pen.png',),
                        color: paintingNotifier.paintingType == PaintingType.pen
                            ? Colors.black
                            : Colors.white,
                      )),
                ),

                /// select marker
                ToolButton(
                  onTap: () {
                    paintingNotifier.paintingType = PaintingType.marker;
                  },
                  colorBorder:
                      paintingNotifier.paintingType == PaintingType.marker
                          ? Colors.black
                          : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor:
                      paintingNotifier.paintingType == PaintingType.marker
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black12,
                  child: Transform.scale(
                      scale: 1.2,
                      child: ImageIcon(
                        const AssetImage('assets/images/marker.png',),
                        color:
                            paintingNotifier.paintingType == PaintingType.marker
                                ? Colors.black
                                : Colors.white,
                      )),
                ),

                /// select neon marker
                ToolButton(
                  onTap: () {
                    paintingNotifier.paintingType = PaintingType.neon;
                  },
                  colorBorder:
                      paintingNotifier.paintingType == PaintingType.neon
                          ? Colors.black
                          : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor:
                      paintingNotifier.paintingType == PaintingType.neon
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black12,
                  child: Transform.scale(
                      scale: 1.1,
                      child: ImageIcon(
                        const AssetImage('assets/images/neon.png',),
                        color:
                            paintingNotifier.paintingType == PaintingType.neon
                                ? Colors.black
                                : Colors.white,
                      )),
                ),

                /// done button
                ToolButton(
                  onTap: () {
                    controlNotifier.isPainting = !controlNotifier.isPainting;
                    paintingNotifier.resetDefaults();
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor: Colors.black12,
                  child: Transform.scale(
                      scale: 0.7,
                      child: const ImageIcon(
                        AssetImage('assets/images/check.png',),
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

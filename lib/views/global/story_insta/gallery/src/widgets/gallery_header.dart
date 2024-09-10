import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirkl/views/global/story_insta/drishya_picker.dart';
import 'package:sirkl/views/global/story_insta/gallery/src/repo/gallery_repository.dart';
import 'package:sirkl/views/global/story_insta/gallery/src/widgets/album_builder.dart';
import 'package:sirkl/views/global/story_insta/gallery/src/widgets/gallery_builder.dart';

///
class GalleryHeader extends StatefulWidget {
  ///
  const GalleryHeader({
    Key? key,
    required this.controller,
    required this.onClose,
    required this.onAlbumToggle,
    required this.albums,
    this.headerSubtitle,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final String? headerSubtitle;

  ///
  final void Function() onClose;

  ///
  final void Function(bool visible) onAlbumToggle;

  ///
  final Albums albums;

  @override
  State<GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<GalleryHeader> {
  late final GalleryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final panelSetting = _controller.panelSetting;

    return Container(
      height: 87,
      color: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : Colors.white,
      child: Column(
        children: [
          // Handler
          _Handler(controller: _controller),
          // Details and controls
          Expanded(
            child: Row(
              children: [
                // Close icon
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      _AnimatedDropdown(
                        controller: _controller,
                        onPressed: widget.onAlbumToggle,
                        albumVisibility: _controller.albumVisibility,
                      ),
                      const Spacer(),
                      if (_controller.setting.selectionMode ==
                          SelectionMode.actionBased)
                        GalleryBuilder(
                          controller: _controller,
                          builder: (value, child) {
                            return InkWell(
                              onTap: () {},
                              child: Icon(
                                CupertinoIcons.rectangle_stack,
                                color: value.enableMultiSelection
                                    ? Colors.transparent
                                    : Colors.transparent,
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                // Album name and media receiver name
                FittedBox(
                  child: _AlbumDetail(
                    subtitle: widget.headerSubtitle,
                    controller: _controller,
                    albums: widget.albums,
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _IconButton(
                        iconData: Icons.close,
                        onPressed: widget.onClose,
                        size: 34,
                      ),
                    ),
                  ),
                ),

                //
              ],
            ),
          ),

          //
        ],
      ),
    );
  }
}

class _AnimatedDropdown extends StatelessWidget {
  const _AnimatedDropdown({
    Key? key,
    required this.controller,
    required this.onPressed,
    required this.albumVisibility,
  }) : super(key: key);

  final GalleryController controller;

  ///
  final void Function(bool visible) onPressed;

  ///
  final ValueNotifier<bool> albumVisibility;

  @override
  Widget build(BuildContext context) {
    return GalleryBuilder(
      controller: controller,
      builder: (value, child) {
        return AnimatedOpacity(
          opacity: value.selectedEntities.isEmpty ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: albumVisibility,
        builder: (context, visible, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween(
              begin: visible ? 0.0 : 1.0,
              end: visible ? 1.0 : 0.0,
            ),
            duration: const Duration(milliseconds: 300),
            builder: (context, factor, child) {
              return Transform.rotate(
                angle: pi * factor,
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    Key? key,
    this.iconData,
    this.onPressed,
    this.size,
  }) : super(key: key);

  final IconData? iconData;
  final void Function()? onPressed;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(40),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          iconData ?? Icons.close,
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.white.withOpacity(0.75)
              : Colors.black.withOpacity(0.75),
          size: size ?? 26.0,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _AlbumDetail extends StatelessWidget {
  const _AlbumDetail({
    Key? key,
    this.subtitle,
    required this.controller,
    required this.albums,
  }) : super(key: key);

  ///
  final String? subtitle;

  ///
  final GalleryController controller;

  ///
  final Albums albums;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album name
        CurrentAlbumBuilder(
          albums: albums,
          builder: (context, album, child) {
            final isAll = album.value.assetPathEntity?.isAll ?? true;

            return Text(
              isAll
                  ? controller.setting.albumTitle
                  : album.value.assetPathEntity?.name ?? 'Unknown',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white.withOpacity(0.75)
                      : Colors.black.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gilroy',
                  fontSize: 24),
            );
          },
        ),
      ],
    );
  }
}

class _Handler extends StatelessWidget {
  const _Handler({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.fullScreenMode) {
      return SizedBox(height: MediaQuery.of(context).padding.top);
    }

    return SizedBox(
      height: controller.panelSetting.thumbHandlerHeight,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 40,
            height: 5,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

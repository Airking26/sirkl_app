import 'package:flutter/material.dart';
import 'package:sirkl/views/global/story_insta/animations/animations.dart';
import 'package:sirkl/views/global/story_insta/drishya_picker.dart';
import 'package:sirkl/views/global/story_insta/gallery/src/widgets/gallery_builder.dart';

///
class SendButton extends StatelessWidget {
  ///
  const SendButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GalleryBuilder(
        controller: controller,
        builder: (value, child) {
          final crossFadeState = value.selectedEntities.isEmpty
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond;
          return AppAnimatedCrossFade(
            crossFadeState: crossFadeState,
            firstChild: const SizedBox(),
            secondChild: InkWell(
              onTap: () {
                Navigator.of(context).pop(value.selectedEntities);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  child!,
                  Positioned(
                    top: -6,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      radius: 12,
                      child: Text(
                        '${value.selectedEntities.length}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.only(left: 4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Icon(
            Icons.send_rounded,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

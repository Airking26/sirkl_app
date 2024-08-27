import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/config/size_config.dart';
import 'package:sirkl/controllers/calls_controller.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class CallInviteSendingScreen extends StatefulWidget {
  const CallInviteSendingScreen({Key? key}) : super(key: key);

  @override
  State<CallInviteSendingScreen> createState() =>
      _CallInviteSendingScreenState();
}

class _CallInviteSendingScreenState extends State<CallInviteSendingScreen> {
  CallsController get _callController => Get.find<CallsController>();
  HomeController get _homeController => Get.find<HomeController>();
  late Timer timer;

  @override
  void initState() {
    FocusManager.instance.primaryFocus?.unfocus();
    timer = Timer(const Duration(seconds: 30), () async {
      if (!_callController.userJoinedCall.value) {
        _callController.playRingback(50);
        await _callController
            .missedCallNotification(_callController.userCalled.value.id!);
        await _callController.leaveChannel();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    _callController.isCallOnSpeaker.value = false;
    _callController.isCallMuted.value = false;
    _callController.playRingback(50);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Obx(() => Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              // Black Layer
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF102437)),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, //start,
                    children: [
                      const VerticalSpacing(of: 24),
                      Text(
                        displayName(
                            _callController.userCalled.value, _homeController),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Colors.white, fontFamily: 'Gilroy'),
                      ),
                      const VerticalSpacing(of: 10),
                      _callController.userJoinedCall.value
                          ? StreamBuilder<int>(
                              initialData:
                                  _callController.timer.value.rawTime.value,
                              stream: _callController.timer.value.rawTime,
                              builder: (context, data) {
                                return Text(
                                  StopWatchTimer.getDisplayTime(data.data!,
                                      milliSecond: false),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontFamily: 'Gilroy'),
                                );
                              },
                            )
                          : Text(
                              "Calling...",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontFamily: 'Gilroy'),
                            ),
                      const VerticalSpacing(),
                      _callController.userJoinedCall.value
                          ? SizedBox(
                              height: getProportionateScreenWidth(200),
                              width: getProportionateScreenWidth(200),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(90),
                                child: Image.network(
                                  _callController.userCalled.value.picture ??
                                      "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(30 / 192 * 192),
                              height: getProportionateScreenWidth(192),
                              width: getProportionateScreenWidth(192),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.02),
                                    Colors.white.withOpacity(0.05)
                                  ],
                                  stops: const [.5, 1],
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(90),
                                child: Image.network(
                                  _callController.userCalled.value.picture ??
                                      "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(90),
                                  color: Colors.white),
                              child: IconButton(
                                  icon: Icon(
                                      _callController.isCallMuted.value
                                          ? Icons.mic_off_rounded
                                          : Icons.mic,
                                      color: Colors.black87),
                                  onPressed: () async {
                                    _callController.isCallMuted.value =
                                        !_callController.isCallMuted.value;
                                    _callController.isCallMuted.value
                                        ? _callController.rtcEngine
                                            ?.disableAudio()
                                        : _callController.rtcEngine
                                            ?.enableAudio();
                                  }),
                            ),
                            InkWell(
                              onTap: () async {
                                _callController.playRingback(50);
                                if (_callController.userJoinedCall.value) {
                                  await FlutterCallkitIncoming.endAllCalls();
                                  await _callController.leaveChannel();
                                } else {
                                  await _callController.missedCallNotification(
                                      _callController.userCalled.value.id!);
                                  await FlutterCallkitIncoming.endAllCalls();
                                  await _callController.endCall(
                                      _callController.userCalled.value.id!,
                                      _callController.currentCallID ?? '');
                                  await _callController.leaveChannel();
                                }
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(90),
                                    color: Colors.red),
                                child: IconButton(
                                    icon: SvgPicture.asset(
                                        "assets/images/call_end.svg",
                                        color: Colors.white),
                                    onPressed: null),
                              ),
                            ),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(90),
                                  color: Colors.white),
                              child: IconButton(
                                  icon: Icon(
                                    _callController.isCallOnSpeaker.value
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_down_rounded,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () async {
                                    _callController.isCallOnSpeaker.value =
                                        !_callController.isCallOnSpeaker.value;
                                    _callController.rtcEngine
                                        ?.setEnableSpeakerphone(_callController
                                            .isCallOnSpeaker.value);
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

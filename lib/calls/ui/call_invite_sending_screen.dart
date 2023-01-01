import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/size_config.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class CallInviteSendingScreen extends StatefulWidget {
  const CallInviteSendingScreen({Key? key}) : super(key: key);

  @override
  State<CallInviteSendingScreen> createState() => _CallInviteSendingScreenState();
}

class _CallInviteSendingScreenState extends State<CallInviteSendingScreen> {

  final _callController = Get.put(CallsController());
  late StopWatchTimer timer = StopWatchTimer();

  @override
  void initState() {
    timer.onStartTimer();
    super.initState();
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.network(
            _callController.userCalled.value.picture ?? "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png",
            fit: BoxFit.cover,
          ),
          // Black Layer
          const DecoratedBox(
            decoration: BoxDecoration(color:
            Color(0xFF102437)
          //  Colors.black.withOpacity(0.3)
          ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, //start,
                children: [
                  const VerticalSpacing(of: 24),
                  Text(
                    _callController.userCalled.value.userName.isNullOrBlank! ? "${_callController.userCalled.value.wallet!.substring(0, 10)}..." : _callController.userCalled.value.userName!.length > 10 ? "${_callController.userCalled.value.userName!.substring(0,10)}..." : _callController.userCalled.value.userName!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(color: Colors.white, fontFamily: 'Gilroy'),
                  ),
                  const VerticalSpacing(of: 10),
                  StreamBuilder<int>(
                    initialData: timer.rawTime.value,
                    stream: timer.rawTime,
                    builder: (context, data){ return Text(
                        StopWatchTimer.getDisplayTime(data.data!, milliSecond: false),
                        //"Calling...", //countup
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Gilroy'
                        ),
                      );},
                  ),
                  const VerticalSpacing(),
                  DialUserPic(image: _callController.userCalled.value.picture ?? "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png",),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.white),
                          child: IconButton(
                              icon: SvgPicture.asset("assets/images/micro.svg", color: Colors.black),onPressed: null),
                        ),
                        InkWell(
                          onTap: () async{
                            _callController.leaveChannel();
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                            child: IconButton(
                                icon: SvgPicture.asset("assets/images/call_end.svg", color: Colors.white),onPressed: null),
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.white),
                          child: IconButton(
                              icon: SvgPicture.asset("assets/images/volume.svg", color: Colors.black),onPressed: null),
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
    );
  }
}

class DialUserPic extends StatelessWidget {
  const DialUserPic({
    Key? key,
    this.size = 192,
    required this.image,
  }) : super(key: key);

  final double size;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30 / 192 * size),
      height: getProportionateScreenWidth(size),
      width: getProportionateScreenWidth(size),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.02),
            Colors.white.withOpacity(0.05)
          ],
          stops: [.5, 1],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(90),
        child: Image.network(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
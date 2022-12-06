import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sirkl/common/size_config.dart';

class CallInviteSendingScreen extends StatefulWidget {
  const CallInviteSendingScreen({Key? key}) : super(key: key);

  @override
  State<CallInviteSendingScreen> createState() => _CallInviteSendingScreenState();
}

class _CallInviteSendingScreenState extends State<CallInviteSendingScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.asset(
            "assets/images/full_image.png",
            fit: BoxFit.cover,
          ),
          // Black Layer
          DecoratedBox(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jemmy \nWilliams",
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(color: Colors.white),
                  ),
                  VerticalSpacing(of: 10),
                  Text(
                    "Incoming 00:01".toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RoundedButton(
                        press: () {},
                        iconSrc: "assets/icons/Icon Mic.svg",
                      ),
                      RoundedButton(
                        press: () {},
                        color: Colors.red,
                        iconColor: Colors.white,
                        iconSrc: "assets/icons/call_end.svg",
                      ),
                      RoundedButton(
                        press: () {},
                        iconSrc: "assets/icons/Icon Volume.svg",
                      ),
                    ],
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

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    Key? key,
    this.size = 64,
    required this.iconSrc,
    this.color = Colors.white,
    this.iconColor = Colors.black,
    required this.press,
  }) : super(key: key);

  final double size;
  final String iconSrc;
  final Color color, iconColor;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenWidth(size),
      width: getProportionateScreenWidth(size),
      child: IconButton(
        padding: EdgeInsets.all(15 / 64 * size),
        color: color,
        onPressed: press,
        icon: SvgPicture.asset(iconSrc, color: iconColor),
      ),
    );
  }
}
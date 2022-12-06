import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sirkl/calls/ui/call_invite_sending_screen.dart';
import 'package:sirkl/common/size_config.dart';

class CallAcceptedScreen extends StatefulWidget {
  const CallAcceptedScreen({Key? key}) : super(key: key);

  @override
  State<CallAcceptedScreen> createState() => _CallAcceptedScreenState();
}

class _CallAcceptedScreenState extends State<CallAcceptedScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Anna williams",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: Colors.white),
              ),
              const Text(
                "Calling…",
                style: TextStyle(color: Colors.white60),
              ),
              const VerticalSpacing(),
              DialUserPic(image: "assets/images/calling_face.png"),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  DialButton(
                    iconSrc: "assets/icons/Icon Mic.svg",
                    text: "Audio",
                    press: () {},
                  ),
                  DialButton(
                    iconSrc: "assets/icons/Icon Volume.svg",
                    text: "Microphone",
                    press: () {},
                  ),
                  DialButton(
                    iconSrc: "assets/icons/Icon Video.svg",
                    text: "Video",
                    press: () {},
                  ),
                  DialButton(
                    iconSrc: "assets/icons/Icon Message.svg",
                    text: "Message",
                    press: () {},
                  ),
                  DialButton(
                    iconSrc: "assets/icons/Icon User.svg",
                    text: "Add contact",
                    press: () {},
                  ),
                  DialButton(
                    iconSrc: "assets/icons/Icon Voicemail.svg",
                    text: "Voice mail",
                    press: () {},
                  ),
                ],
              ),
              const VerticalSpacing(),
              RoundedButton(
                iconSrc: "assets/icons/call_end.svg",
                press: () {},
                color: Colors.red,
                iconColor: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DialButton extends StatelessWidget {
  const DialButton({
    Key? key,
    required this.iconSrc,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String iconSrc, text;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(120),
      child: IconButton(
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenWidth(20),
        ),
        onPressed: press,
        icon: Column(
          children: [
            SvgPicture.asset(
              iconSrc,
              color: Colors.white,
              height: 36,
            ),
            const VerticalSpacing(of: 5),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            )
          ],
        ),
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
        borderRadius: const BorderRadius.all(Radius.circular(100)),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
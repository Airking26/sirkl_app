import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../config/s_colors.dart';

class PositionedDialog {
  List<Widget> widgetList = [];
  static BuildContext? _context;
  BuildContext? context;

  double? width;
  double? height;
  Duration duration = const Duration(milliseconds: 250);
  Gravity gravity = Gravity.center;
  bool gravityAnimationEnable = false;
  Color barrierColor = Colors.black.withOpacity(.3);
  BoxConstraints? constraints;
  Function(Widget child, Animation<double> animation)? animatedFunc;
  bool barrierDismissible = true;
  EdgeInsets margin = const EdgeInsets.all(0.0);

  bool useRootNavigator = true;

  Decoration? decoration;
  Color backgroundColor =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color(0xFF1E3244).withOpacity(0.7)
          : Colors.white;
  double borderRadius = 0.0;

  Function()? showCallBack;
  Function()? dismissCallBack;

  get isShowing => _isShowing;
  bool _isShowing = false;

  static void init(BuildContext ctx) {
    _context = ctx;
  }

  PositionedDialog build([BuildContext? ctx]) {
    if (ctx == null && _context != null) {
      context = _context;
      return this;
    }
    context = ctx;
    return this;
  }

  PositionedDialog widget(Widget child) {
    widgetList.add(child);
    return this;
  }

  PositionedDialog text(
      {padding,
      text,
      color,
      fontSize,
      alignment,
      textAlign,
      maxLines,
      textDirection,
      overflow,
      fontWeight,
      fontFamily}) {
    return widget(
      Padding(
        padding: padding ?? const EdgeInsets.all(0.0),
        child: Align(
          alignment: alignment ?? Alignment.centerLeft,
          child: Text(
            text ?? "",
            textAlign: textAlign,
            maxLines: maxLines,
            textDirection: textDirection,
            overflow: overflow,
            style: TextStyle(
              color: color ?? Colors.black,
              fontSize: fontSize ?? 14.0,
              fontWeight: fontWeight,
              fontFamily: fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  PositionedDialog doubleButton({
    padding,
    gravity,
    height,
    isClickAutoDismiss = true,
    withDivider = false,
    text1,
    color1,
    fontSize1,
    fontWeight1,
    fontFamily1,
    VoidCallback? onTap1,
    buttonPadding1 = const EdgeInsets.all(0.0),
    text2,
    color2,
    fontSize2,
    fontWeight2,
    fontFamily2,
    onTap2,
    buttonPadding2 = const EdgeInsets.all(0.0),
  }) {
    return widget(
      SizedBox(
        height: height ?? 45.0,
        child: Row(
          mainAxisAlignment: getRowMainAxisAlignment(gravity),
          children: <Widget>[
            TextButton(
              onPressed: () {
                if (onTap1 != null) onTap1();
                if (isClickAutoDismiss) {
                  dismiss();
                }
              },
              style: TextButton.styleFrom(
                  padding: buttonPadding1,
                  textStyle: TextStyle(
                    fontSize: fontSize1 ?? 18.0,
                    fontWeight: fontWeight1,
                    fontFamily: fontFamily1,
                  )),
              child: Text(
                text1 ?? "",
              ),
            ),
            Visibility(
              visible: withDivider,
              child: const VerticalDivider(),
            ),
            TextButton(
              onPressed: () {
                if (onTap2 != null) onTap2();
                if (isClickAutoDismiss) {
                  dismiss();
                }
              },
              style: TextButton.styleFrom(
                padding: buttonPadding2,
                textStyle: TextStyle(
                  fontSize: fontSize2 ?? 14.0,
                  fontWeight: fontWeight2,
                  fontFamily: fontFamily2,
                ),
              ),
              child: Text(
                text2 ?? "",
              ),
            )
          ],
        ),
      ),
    );
  }

  PositionedDialog listViewOfListTile({
    List<ListTileItem>? items,
    double? height,
    isClickAutoDismiss = true,
    Function(int)? onClickItemListener,
  }) {
    return widget(
      SizedBox(
        height: height,
        child: ListView.builder(
          padding: const EdgeInsets.all(0.0),
          shrinkWrap: true,
          itemCount: items?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return Material(
              color: Colors.white,
              child: InkWell(
                child: ListTile(
                  onTap: () {
                    if (onClickItemListener != null) {
                      onClickItemListener(index);
                    }
                    if (isClickAutoDismiss) {
                      dismiss();
                    }
                  },
                  contentPadding:
                      items?[index].padding ?? const EdgeInsets.all(0.0),
                  leading: items?[index].leading,
                  title: Text(
                    items?[index].text ?? "",
                    style: TextStyle(
                      color: items?[index].color,
                      fontSize: items?[index].fontSize,
                      fontWeight: items?[index].fontWeight,
                      fontFamily: items?[index].fontFamily,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PositionedDialog listViewOfRadioButton({
    List<RadioItem>? items,
    double? height,
    Color? color,
    Color? activeColor,
    int? initialValue,
    Function(int)? onClickItemListener,
  }) {
    Size size = MediaQuery.of(context!).size;
    return widget(
      Container(
        height: height,
        constraints: BoxConstraints(
          minHeight: size.height * .1,
          minWidth: size.width * .1,
          maxHeight: size.height * .5,
        ),
        child: YYRadioListTile(
          items: items,
          initialValue: initialValue,
          color: color,
          activeColor: activeColor,
          onChanged: onClickItemListener,
        ),
      ),
    );
  }

  PositionedDialog circularProgress(
      {padding, backgroundColor, valueColor, strokeWidth}) {
    return widget(Padding(
      padding: padding,
      child: CircularProgressIndicator(
        color: SColors.activeColor,
        strokeWidth: strokeWidth ?? 4.0,
        backgroundColor: backgroundColor,
        //valueColor: AlwaysStoppedAnimation<Color>(valueColor),
      ),
    ));
  }

  PositionedDialog divider({color, height, padding}) {
    return widget(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Divider(
          color: color ?? Colors.grey[300],
          height: height ?? 0.1,
        ),
      ),
    );
  }

  void show([x, y]) {
    var mainAxisAlignment = getColumnMainAxisAlignment(gravity);
    var crossAxisAlignment = getColumnCrossAxisAlignment(gravity);
    if (x != null && y != null) {
      gravity = Gravity.leftTop;
      margin = EdgeInsets.only(left: x, top: y);
    }
    CustomDialog(
      gravity: gravity,
      gravityAnimationEnable: gravityAnimationEnable,
      context: context!,
      barrierColor: barrierColor,
      animatedFunc: animatedFunc,
      barrierDismissible: barrierDismissible,
      duration: duration,
      child: Padding(
        padding: margin,
        child: Column(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: <Widget>[
            Material(
              clipBehavior: Clip.antiAlias,
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                width: width,
                height: height,
                decoration: decoration ??
                    BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: backgroundColor,
                    ),
                constraints: constraints ?? const BoxConstraints(),
                child: CustomDialogChildren(
                  widgetList: widgetList,
                  isShowingChange: (bool isShowingChange) {
                    // showing or dismiss Callback
                    if (isShowingChange) {
                      showCallBack?.call();
                    } else {
                      dismissCallBack?.call();
                    }
                    _isShowing = isShowingChange;
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void dismiss() {
    if (_isShowing) {
      Navigator.of(context!, rootNavigator: useRootNavigator).pop();
    }
  }

  getColumnMainAxisAlignment(gravity) {
    var mainAxisAlignment = MainAxisAlignment.start;
    switch (gravity) {
      case Gravity.bottom:
      case Gravity.leftBottom:
      case Gravity.rightBottom:
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case Gravity.top:
      case Gravity.leftTop:
      case Gravity.rightTop:
        mainAxisAlignment = MainAxisAlignment.start;
        break;
      case Gravity.left:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Gravity.right:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Gravity.center:
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
    }
    return mainAxisAlignment;
  }

  getColumnCrossAxisAlignment(gravity) {
    var crossAxisAlignment = CrossAxisAlignment.center;
    switch (gravity) {
      case Gravity.bottom:
        break;
      case Gravity.top:
        break;
      case Gravity.left:
      case Gravity.leftTop:
      case Gravity.leftBottom:
        crossAxisAlignment = CrossAxisAlignment.start;
        break;
      case Gravity.right:
      case Gravity.rightTop:
      case Gravity.rightBottom:
        crossAxisAlignment = CrossAxisAlignment.end;
        break;
      default:
        break;
    }
    return crossAxisAlignment;
  }

  getRowMainAxisAlignment(gravity) {
    var mainAxisAlignment = MainAxisAlignment.start;
    switch (gravity) {
      case Gravity.bottom:
        break;
      case Gravity.top:
        break;
      case Gravity.left:
        mainAxisAlignment = MainAxisAlignment.start;
        break;
      case Gravity.right:
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case Gravity.spaceEvenly:
        mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        break;
      case Gravity.center:
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
    }
    return mainAxisAlignment;
  }
}

class CustomDialogChildren extends StatefulWidget {
  final List<Widget> widgetList; //弹窗内部所有组件
  final Function(bool)? isShowingChange;

  const CustomDialogChildren(
      {super.key, this.widgetList = const [], this.isShowingChange});

  @override
  CustomDialogChildState createState() => CustomDialogChildState();
}

class CustomDialogChildState extends State<CustomDialogChildren> {
  @override
  Widget build(BuildContext context) {
    if (widget.isShowingChange != null) {
      widget.isShowingChange!(true);
    }
    return Column(
      children: widget.widgetList,
    );
  }

  @override
  void dispose() {
    if (widget.isShowingChange != null) {
      widget.isShowingChange!(false);
    }
    super.dispose();
  }
}

class CustomDialog {
  final BuildContext _context;
  final Widget _child;
  final Duration? _duration;
  Color? _barrierColor;
  final RouteTransitionsBuilder? _transitionsBuilder;
  final bool? _barrierDismissible;
  final Gravity? _gravity;
  final bool _gravityAnimationEnable;
  final Function? _animatedFunc;

  CustomDialog({
    required Widget child,
    required BuildContext context,
    Duration? duration,
    Color? barrierColor,
    RouteTransitionsBuilder? transitionsBuilder,
    Gravity? gravity,
    bool gravityAnimationEnable = false,
    Function? animatedFunc,
    bool? barrierDismissible,
  })  : _child = child,
        _context = context,
        _gravity = gravity,
        _gravityAnimationEnable = gravityAnimationEnable,
        _duration = duration,
        _barrierColor = barrierColor,
        _animatedFunc = animatedFunc,
        _transitionsBuilder = transitionsBuilder,
        _barrierDismissible = barrierDismissible {
    show();
  }

  show() {
    if (_barrierColor == Colors.transparent) {
      _barrierColor = Colors.white.withOpacity(0.0);
    }

    showGeneralDialog(
      context: _context,
      barrierColor: _barrierColor ?? Colors.black.withOpacity(.3),
      barrierDismissible: _barrierDismissible ?? true,
      barrierLabel: "",
      transitionDuration: _duration ?? const Duration(milliseconds: 250),
      transitionBuilder: _transitionsBuilder ?? _buildMaterialDialogTransitions,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Builder(
          builder: (BuildContext context) {
            return _child;
          },
        );
      },
    );
  }

  Widget _buildMaterialDialogTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    Animation<Offset> custom;
    switch (_gravity) {
      case Gravity.top:
      case Gravity.leftTop:
      case Gravity.rightTop:
        custom = Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.left:
        custom = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.right:
        custom = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.bottom:
      case Gravity.leftBottom:
      case Gravity.rightBottom:
        custom = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case Gravity.center:
      default:
        custom = Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
    }

    if (_animatedFunc != null) {
      return _animatedFunc!(child, animation);
    }

    if (!_gravityAnimationEnable) {
      custom = Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(animation);
    }

    return SlideTransition(
      position: custom,
      child: child,
    );
  }
}

enum Gravity {
  left,
  top,
  bottom,
  right,
  center,
  rightTop,
  leftTop,
  rightBottom,
  leftBottom,
  spaceEvenly,
}

class ListTileItem {
  ListTileItem({
    this.padding,
    this.leading,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  EdgeInsets? padding;
  Widget? leading;
  String? text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  String? fontFamily;
}

class RadioItem {
  RadioItem({
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.onTap,
  });

  EdgeInsets? padding;
  String? text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  Function(int)? onTap;
}

class YYRadioListTile extends StatefulWidget {
  const YYRadioListTile({
    Key? key,
    this.items,
    this.initialValue,
    this.color,
    this.activeColor,
    this.onChanged,
  })  : assert(items != null),
        super(key: key);

  final List<RadioItem>? items;
  final Color? color;
  final Color? activeColor;
  final initialValue;
  final Function(int)? onChanged;

  @override
  State<StatefulWidget> createState() {
    return YYRadioListTileState();
  }
}

class YYRadioListTileState extends State<YYRadioListTile> {
  var groupId = -1;

  void intialSelectedItem() {
    //intialValue:
    //The button initializes the position.
    //If it is not filled, it is not selected.
    if (groupId == -1) {
      groupId = widget.initialValue ?? -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    intialSelectedItem();

    return ListView.builder(
      padding: const EdgeInsets.all(0.0),
      shrinkWrap: true,
      itemCount: widget.items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return Material(
          color: widget.color,
          child: RadioListTile(
            title: Text(
              widget.items?[index].text ?? "",
              style: TextStyle(
                  fontSize: widget.items?[index].fontSize ?? 14,
                  fontWeight:
                      widget.items?[index].fontWeight ?? FontWeight.normal,
                  color: widget.items?[index].color ?? Colors.black),
            ),
            value: index,
            groupValue: groupId,
            activeColor: widget.activeColor,
            onChanged: (int? value) {
              setState(() {
                if (widget.onChanged != null) {
                  widget.onChanged!(value ?? 0);
                }
                groupId = value ?? -1;
              });
            },
          ),
        );
      },
    );
  }
}

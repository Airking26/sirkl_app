import 'package:flutter/material.dart';


class MyCircularLoader extends StatelessWidget {
  final Color? color;
  const MyCircularLoader({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: color ?? Theme.of(context).primaryColor));
  }
}

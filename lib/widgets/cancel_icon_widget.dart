import 'package:flutter/material.dart';

class CancelIconWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final double rightPadding;
  final double size;
  final Color color;

  const CancelIconWidget({
    Key? key,
    this.onTap,
    this.rightPadding = 14.0,
    this.size = 28.0,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: size + 20,
          height: size + 20,
          alignment: Alignment.center,
          child: Icon(
            Icons.close,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}

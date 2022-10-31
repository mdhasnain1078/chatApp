import 'package:flutter/material.dart';


class ReusableButton extends StatelessWidget {
  const ReusableButton({
    this.onPressed,
    this.color,
    this.text,
    Key key,
  }) : super(key: key);

  final Color color;
  final Function onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}

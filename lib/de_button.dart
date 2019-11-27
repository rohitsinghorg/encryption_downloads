import 'package:flutter/material.dart';

class DEButton extends StatelessWidget {
  final String name;
  final Function function;

  DEButton({Key key, @required this.name, @required this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      margin: EdgeInsets.only(
          top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: RaisedButton(
        child: Text(
          name.toUpperCase(),
          style: TextStyle(fontFamily: 'Raleway', fontSize: 14, letterSpacing: 2.1, fontWeight: FontWeight.w800),
        ),
        padding: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0)),
        color: Color(0xFF420062),
        textColor: Color(0xFFFFFFFF),
        onPressed: function,
      ),
    );
  }
}


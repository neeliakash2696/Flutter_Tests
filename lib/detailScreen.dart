import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget{
  String data;
  DetailScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child:CustomButton()),);
  }
}
class CustomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 50,
      decoration: ShapeDecoration(
        shape: CustomButtonShape(), // Use your custom shape here
        color: Colors.white, // Button background color
      ),
      child: Center(
        child: Text(
          'Call Now',
          style: TextStyle(color: Colors.teal),
        ),
      ),
    );
  }
}

class CustomButtonShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left + 20, rect.top) // Top-left corner
      ..lineTo(rect.right, rect.top) // Top-right corner
      ..lineTo(rect.right, rect.bottom) // Bottom-right corner
      ..lineTo(rect.left + 20, rect.bottom) // Bottom-left corner
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(rect.left, rect.top, 20, rect.height), // Rounded corner
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}
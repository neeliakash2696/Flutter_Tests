import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget{
  String data;
  DetailScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child:Text(data)),);
  }
}
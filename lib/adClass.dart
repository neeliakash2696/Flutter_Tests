import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdClass extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      child: Container(
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(3)
              ),
                child: Padding(padding: EdgeInsets.all(3),
                  child: Text("Ad",style: TextStyle(color: Colors.grey.shade400),)),
                )
          ],
        ),
      ),
    );
  }

}
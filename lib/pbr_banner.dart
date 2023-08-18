import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PBRBanner extends StatelessWidget{
  String product_name;
  PBRBanner({super.key, required this.product_name});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.teal[50],
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Get the Best Suppliers for your Requirement",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width-110,
                        decoration: BoxDecoration(
                          color: Colors.teal[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(product_name,style: TextStyle(fontWeight:FontWeight.bold,color: Colors.teal[700])),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/getBestPrice.png"),
                            fit: BoxFit.fill),
                      ),
                      alignment: Alignment.center,
                    ),

                  ],
                )

              ],
            ),
          ),
        ),
      );
  }
  
}
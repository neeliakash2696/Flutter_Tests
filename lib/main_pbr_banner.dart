// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class MainPBRBanner extends StatefulWidget {
  @override
  State<MainPBRBanner> createState() => _MainPBRBannerState();
  String productName;
  dynamic img;
  MainPBRBanner({required this.productName, required this.img});
}

class _MainPBRBannerState extends State<MainPBRBanner> {
  List<String> dropdownItems = ['Option 1', 'Option 2', 'Option 3'];
  String selectedValue = 'Option 1'; // Initialize with the first option

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.teal[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width / 4,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(widget.img),
                                fit: BoxFit.fill)),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Looking for ${widget.productName}?",
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.indigo),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What is required qauntity?",
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Row(children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10), // Add padding for spacing
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue), // Border color
                    borderRadius: BorderRadius.circular(4), // Border radius
                  ),
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width - 120,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  fontSize: 15, color: Colors.grey[350]),
                              hintText: 'Enter Quantity',
                              alignLabelWithHint: true,
                              border: InputBorder
                                  .none, // Remove default TextField border
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.blue, // Partition color
                          thickness: 1, // Partition thickness
                          width: 1, // Width of the partition
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            iconEnabledColor: Colors.blue,
                            value: selectedValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                            items: dropdownItems.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/getBestPrice.png"),
                          fit: BoxFit.fill),
                    ),
                    alignment: Alignment.center,
                  ),
                )
              ]),
            )
          ],
        ));
  }
}

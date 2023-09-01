// ignore_for_file: must_be_immutable, unrelated_type_equality_checks

import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  @override
  FiltersState createState() => FiltersState();
  List<String> categoriesList;
  List<String> backList;
  bool isSellerType;
  int productIndex;
  Filters(
      {Key? key,
      required this.categoriesList,
      required this.backList,
      required this.isSellerType,
      required this.productIndex})
      : super(key: key);
}

class FiltersState extends State<Filters> {
  int? _value = 0;

// View Did Load
  @override
  void initState() {
    super.initState();
    if (widget.isSellerType) {
      setState(() {
        _value = widget.productIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
      backgroundColor: Colors.transparent.withOpacity(0.6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.transparent,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            color: Colors.white,
                            child: Wrap(
                              spacing: 5.0,
                              runSpacing: 5.0,
                              children: List<Widget>.generate(
                                    widget.categoriesList.length,
                                (int index) {
                                  return ChoiceChip(
                                    selectedColor: (widget.isSellerType)?Colors.teal:Colors.grey[350],
                                    label: Text(widget.categoriesList[index],
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                    selected: _value == index,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        if (widget.isSellerType && _value == index) {
                                          _value = index;
                                          Navigator.pop(context);
                                        } else {
                                          var selectedChip = widget.categoriesList[index];
                                          var selectedChip1= widget.backList[index];
                                          if(widget.isSellerType)
                                          _value = index;
                                          var selectedChipDetails = [
                                            selectedChip,
                                            selectedChip1,
                                            _value,
                                          ];
                                          print(
                                              "selectedChipDetails $selectedChipDetails");
                                          Navigator.pop(
                                              context, selectedChipDetails);
                                        }
                                      });
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                          )
                        ],
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

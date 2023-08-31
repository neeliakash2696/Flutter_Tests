// ignore_for_file: must_be_immutable, unrelated_type_equality_checks

import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  @override
  FiltersState createState() => FiltersState();
  List<String> categoriesList;
  List<String> sellerTypeItems;
  bool isSellerType;
  int productIndex;
  Filters(
      {Key? key,
      required this.categoriesList,
      required this.sellerTypeItems,
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
    if (!widget.isSellerType) {
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
                            spacing: 15.0,
                            children: List<Widget>.generate(
                              widget.isSellerType
                                  ? widget.sellerTypeItems.length
                                  : widget.categoriesList.length,
                              (int index) {
                                return ChoiceChip(
                                  selectedColor: Colors.teal,
                                  label: Text(
                                    widget.isSellerType
                                        ? widget.sellerTypeItems[index]
                                        : widget.categoriesList[index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  selected: _value == index,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (_value == index) {
                                        _value = index;
                                        Navigator.pop(context);
                                      } else {
                                        var selectedChip = widget.isSellerType
                                            ? widget.sellerTypeItems[index]
                                            : widget.categoriesList[index];
                                        _value = index;
                                        var selectedChipDetails = [
                                          selectedChip,
                                          index,
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
            )
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: must_be_immutable, unrelated_type_equality_checks

import 'package:flutter/material.dart';

class SearchFieldController extends StatefulWidget {
  @override
  SearchFieldControllerState createState() => SearchFieldControllerState();

  SearchFieldController({
    Key? key,
  }) : super(key: key);
}

class SearchFieldControllerState extends State<SearchFieldController> {
  TextEditingController searchBar = TextEditingController();
  FocusNode focus = FocusNode();

  // View Did Load
  @override
  void initState() {
    super.initState();
    focus.requestFocus();
  }

  @override
  void dispose() {
    searchBar.dispose();
    super.dispose();
  }

  closeKeyboard(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                closeKeyboard(context);
                Navigator.pop(context);
              },
              color: Colors.black,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          focusNode: focus,
                          autocorrect: false,
                          autofocus: true,
                          onChanged: (text) {
                            print(text);
                          },
                          onEditingComplete: () {
                            print("Search Clicked");
                            closeKeyboard(context);
                          },
                          onTapOutside: (event) {
                            closeKeyboard(context);
                          },
                          onTap: () {
                            //
                          },
                          controller: searchBar,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("images/mic_icon_colored.png"),
                                  fit: BoxFit.cover),
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // backgroundColor: Colors.transparent.withOpacity(0.6),
      body: Column(
        children: [
          const Text(
            "Tell us What you need",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

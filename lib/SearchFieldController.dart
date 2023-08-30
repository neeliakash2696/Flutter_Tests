// ignore_for_file: must_be_immutable, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter_tests/ImportantSuppilesDetailsList.dart';
import 'package:http/http.dart' as http;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

enum FromScreen { def, impSuppliesList, viewCategories, categoriesDetail }

class SearchFieldController extends StatefulWidget {
  @override
  SearchFieldControllerState createState() => SearchFieldControllerState();
  FromScreen fromScreen;
  SearchFieldController({Key? key, required this.fromScreen}) : super(key: key);
}

class SearchFieldControllerState extends State<SearchFieldController> {
  TextEditingController searchBar = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode focus = FocusNode();
  List<dynamic> dataArray = [];
  String searchQuery = "";

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

  proceedForSearch() {
    switch (widget.fromScreen) {
      case FromScreen.def:
        Navigator.pop(context, searchQuery);
        break;
      case FromScreen.impSuppliesList:
        Navigator.pop(context, searchQuery);
        break;
      case FromScreen.viewCategories:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImportantSuppilesDetailsList(
                      productName: searchQuery,
                    )));
      case FromScreen.categoriesDetail:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImportantSuppilesDetailsList(
                      productName: searchQuery,
                    )));
    }
  }

  getRecents(String query) async {
    EasyLoading.show(status: 'Loading...');
    try {
      String pathUrl =
          "https://mapi.indiamart.com//wservce/im/search/?biztype_data=&VALIDATION_GLID=136484661&APP_SCREEN_NAME=Search Products&src=as-rcnt:pos=6:cat=-2:mcat=-2&options_start=0&options_end=9&AK=eyJ0eXAiOiJKV1QiLCJhbGciOiJzaGEyNTYifQ.eyJpc3MiOiJVU0VSIiwiYXVkIjoiMSoxKjEqMiozKiIsImV4cCI6MTY5MzQwNTg5MCwiaWF0IjoxNjkzMzE5NDkwLCJzdWIiOiIxMzY0ODQ2NjEiLCJjZHQiOiIyOS0wOC0yMDIzIn0.732rXOiilzyC6vA3NTcJHg5CA_KI6f6lkdk9-SReF2k&source=android.search&token=imartenquiryprovider&APP_USER_ID=136484661&implicit_info_city_data=Chennai&APP_MODID=ANDROID&q=$query&modeId=android.search&APP_ACCURACY=0.0&prdsrc=1&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&VALIDATION_USER_IP=61.3.38.129&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233";
      http.Response response = await http.get(Uri.parse(pathUrl));
      var code = json.decode(response.body)['CODE'];
      if (code == "402" || code == "401") {
        var msg = json.decode(response.body)['MESSAGE'];
        EasyLoading.dismiss();
        Flushbar(
          title: code,
          message: msg,
          flushbarStyle: FlushbarStyle.FLOATING,
          isDismissible: true,
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          boxShadows: const [
            BoxShadow(
              offset: Offset(0.0, 2.0),
              blurRadius: 3.0,
            )
          ],
        ).show(context);
      } else if (response.statusCode == 200) {
        var resultsArray = json.decode(response.body)['results'];
        dataArray.clear();
        for (var i = 0; i < resultsArray.length; i++) {
          var moreResultsFirstEntry = resultsArray[i]["more_results"][0];
          var company = moreResultsFirstEntry["companyname"];
          print(company);
          if (company != null) {
            dataArray.add(company.toString());
          } else {
            dataArray.add("NA");
          }
        }
        setState(() {});
        print("dataArray" "$dataArray");
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      setState(() {});
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
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
                          onChanged: (searchingText) {
                            print(searchingText);
                            searchQuery = searchingText;
                            getRecents(searchQuery);
                          },
                          onEditingComplete: () {
                            print("Search Clicked");
                            closeKeyboard(context);
                            proceedForSearch();
                          },
                          onTapOutside: (event) {
                            closeKeyboard(context);
                          },
                          onTap: () {},
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Text(
              "Past Searches",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: dataArray.length,
              itemBuilder: (BuildContext context, int index) {
                var inkWell = InkWell(
                  onTap: () {
                    closeKeyboard(context);
                    searchQuery = dataArray[index];
                    proceedForSearch();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.access_time_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 90,
                              child: Text(dataArray[index],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                      Transform.rotate(
                        angle: 120,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                );
                return Container(
                  child: inkWell,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

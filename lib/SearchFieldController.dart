// ignore_for_file: must_be_immutable, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter_tests/ImportantSuppilesDetailsList.dart';
import 'package:http/http.dart' as http;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

enum SearchingFromScreen {
  def,
  impSuppliesList,
  viewCategories,
  categoriesDetail
}

class SearchFieldController extends StatefulWidget {
  @override
  SearchFieldControllerState createState() => SearchFieldControllerState();
  SearchingFromScreen fromScreen;
  String word;
  SearchFieldController({Key? key, required this.fromScreen, required this.word}) : super(key: key);
}

class SearchFieldControllerState extends State<SearchFieldController> {
  bool hasText = false;
  TextEditingController searchBar = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode focus = FocusNode();
  List<String> dataArray = [];
  String searchQuery = "";
  int maxCount = 5;

  // View Did Load
  @override
  void initState() {
    super.initState();
    focus.requestFocus();
    getRecents("");
    formattedEndDate();
    if(widget.word!=null)
    searchBar.text=widget.word;
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
    saveSearchQueryLocally(searchQuery);
    switch (widget.fromScreen) {
      case SearchingFromScreen.def:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImportantSuppilesDetailsList(
                      productName: searchQuery,
                      productFname: searchQuery,
                  productIndex: 0,
                  biztype: "",
                  screen: "search",
                    )));
        break;
      case SearchingFromScreen.impSuppliesList:
        Navigator.pop(context, searchQuery);
        break;
      case SearchingFromScreen.viewCategories:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImportantSuppilesDetailsList(
                      productName: searchQuery,
                      productFname: searchQuery,
                  productIndex: 0,
                  biztype:"",
                  screen: "search"
                    )));
      case SearchingFromScreen.categoriesDetail:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImportantSuppilesDetailsList(
                      productName: searchQuery,
                      productFname: searchQuery,
                  productIndex: 0,
                  biztype: "",
                    screen: "search"
                    )));
    }
  }

  showInitialRecommendations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var x = prefs.getStringList("localSearchArray");
    dataArray = x ?? [];
    print("init $dataArray");
    setState(() {});
  }

  saveSearchQueryLocally(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FlutterTests.localSearchArray.add(query);
    prefs.setStringList("localSearchArray", FlutterTests.localSearchArray);

    if (FlutterTests.localSearchArray.length > maxCount) {
      FlutterTests.localSearchArray.removeAt(0);
      prefs.setStringList("localSearchArray", FlutterTests.localSearchArray);
    }
    print("saved this ${FlutterTests.localSearchArray}");
  }

  getRecents(String query) async {
    EasyLoading.show(status: 'Loading...');
    try {
      String pathUrl ="";
      if(query.isEmpty) {
        var logtime = formattedEndDate();
        pathUrl =
            "https://mapi.indiamart.com//wservce/users/getBuyerData/?VALIDATION_GLID=136484661&APP_SCREEN_NAME=Default-Seller&count=15&AK=${FlutterTests.AK}&source=Search Products On Scroll&type=2&modid=ANDROID&token=imobile@15061981&APP_USER_ID=136484661&APP_MODID=ANDROID&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=49.36.220.222&logtime=$logtime&app_version_no=13.2.0&VALIDATION_USERCONTACT=1511122233";
      } else
        pathUrl="https://suggest.imimg.com/suggest/suggest.php/?q=$query&limit=10&type=product%2Cmcat&match=fuzzy&fields=&p=5&APP_MODID=ANDROID&AK=${FlutterTests.AK}&VALIDATION_GLID=136484661&VALIDATION_USER_IP=117.244.8.184&VALIDATION_USERCONTACT=7983071546&app_version_no=13.2.1_T1&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&APP_USER_ID=145754117&APP_SCREEN_NAME=Default-Seller";
      print("pathurl=$pathUrl");
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
        if(query.isEmpty) {
          var resultsArray = json.decode(response.body)['details']['searches'];
          dataArray.clear();
          for (var i = 0; i < resultsArray.length; i++) {
            var label = resultsArray[i]["search"];
            print(label);
            if (label != null) {
              dataArray.add(label.toString());
            }
          }
        } else{
          var resultsArray = json.decode(response.body)['product'];
          dataArray.clear();
          for (var i = 0; i < resultsArray.length; i++) {
            var label = resultsArray[i]["label"];
            if (label != null) {
              dataArray.add(label);
            }
          }
        }
        setState(() {});
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
                            if (searchingText.isNotEmpty) {
                              searchQuery = searchingText;
                              print("searchingText=$searchingText");
                              setState(() {
                                hasText = true;
                              });
                              getRecents(searchQuery);
                            }
                            else {
                              setState(() {
                                hasText = false;
                                print("searchingText1=$searchingText");
                                getRecents(searchingText);
                              });
                            }
                          },
                          onEditingComplete: () {
                            print("Search Clicked");
                            closeKeyboard(context);
                            proceedForSearch();
                          },
                          onTapOutside: (event) {
                            closeKeyboard(context);
                          },
                          onTap: () {
                            if(searchQuery.isEmpty)
                              getRecents("");
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          //   child: Text(
          //     "Past Searches",
          //     style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          //   ),
          // ),
          // const Divider(
          //   color: Colors.grey,
          //   thickness: 1,
          // ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: dataArray.length,
              itemBuilder: (BuildContext context, int index) {
                final searchText = searchQuery.toLowerCase();
                final itemText = dataArray[index].toLowerCase();
                final textSpan = _buildTextSpan(itemText, searchText);
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
                           Padding(
                            padding: EdgeInsets.all(8.0),
                            child: hasText?Icon(
                              Icons.search,
                              color: Colors.grey,
                            ):
                            Icon(
                              Icons.access_time_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 90,
                              child: RichText(
                                text: textSpan,
                                textAlign: TextAlign.left,
                                // style: const TextStyle(fontSize: 16),
                              ),
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
  TextSpan _buildTextSpan(String text, String searchText) {
    final startIndex = text.indexOf(searchText);
    if (startIndex == -1) {
      return TextSpan(text: text);
    }

    final endIndex = startIndex + searchText.length;

    final span = TextSpan(
      children: [
        TextSpan(
          text: text.substring(0, startIndex),
        ),
        TextSpan(
          text: text.substring(startIndex, endIndex),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: text.substring(endIndex),
        ),
      ],
    );

    return span;
  }
  String formattedEndDate() {
    try {
      final DateFormat targetFormat = DateFormat("yyyyMMddHHmmss");
      final DateTime endDate = DateTime.now();
      final formattedEndDate = targetFormat.format(endDate);
      print("SF: Formatted Date: $formattedEndDate");
      return formattedEndDate;
    } catch (e) {
      // Handle any exceptions here.
      return ""; // Or return a default value.
    }
  }
}

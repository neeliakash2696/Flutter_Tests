// ignore_for_file: must_be_immutable, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tests/search.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'SpeechToTextConverter.dart';

enum SearchingFromScreen {
  def,
  impSuppliesList,
  viewCategories,
  categoriesDetail,
  search
}

class SearchFieldController extends StatefulWidget {
  @override
  SearchFieldControllerState createState() => SearchFieldControllerState();
  SearchingFromScreen fromScreen;
  String word;
  int cityIndex;
  SearchFieldController(
      {Key? key,
      required this.fromScreen,
      required this.word,
      required this.cityIndex})
      : super(key: key);
}

class SearchFieldControllerState extends State<SearchFieldController> {
  bool hasText = false;
  TextEditingController searchBar = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode focus = FocusNode();
  List<String> dataArray = [];
  String searchQuery = "";
  int maxCount = 5;
  String? mobNo = "";
  String? glid = "";
  String? ak = "";
  // View Did Load
  @override
  void initState() {
    super.initState();
    focus.requestFocus();
    getRecents(widget.word);
    formattedEndDate();
    fetchSavedData();
    if (widget.word != null && widget.word != "") {
      hasText = true;
      // getRecents(widget.word);
      searchBar.text = widget.word;
      searchQuery = widget.word;
    } else {
      hasText = false;
      // getRecents("");
    }
  }

  @override
  void dispose() {
    focus.unfocus();
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
    // saveSearchQueryLocally(searchQuery);
    focus.unfocus();
    print(widget.fromScreen);
    switch (widget.fromScreen) {
      case SearchingFromScreen.def:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Search(
                      city: 0,
                      productName: searchQuery,
                      productFname: searchQuery,
                      productIndex: 0,
                      biztype: "",
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
                builder: (context) => Search(
                      city: 0,
                      productName: searchQuery,
                      productFname: searchQuery,
                      productIndex: 0,
                      biztype: "",
                    )));
      case SearchingFromScreen.categoriesDetail:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Search(
                      city: 0,
                      productName: searchQuery,
                      productFname: searchQuery,
                      productIndex: 0,
                      biztype: "",
                    )));
      case SearchingFromScreen.search:
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Search(
                      city: 0,
                      productName: searchQuery,
                      productFname: searchQuery,
                      productIndex: 0,
                      biztype: "",
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

  // saveSearchQueryLocally(String query) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   FlutterTests.localSearchArray.add(query);
  //   prefs.setStringList("localSearchArray", FlutterTests.localSearchArray);

  //   if (FlutterTests.localSearchArray.length > maxCount) {
  //     FlutterTests.localSearchArray.removeAt(0);
  //     prefs.setStringList("localSearchArray", FlutterTests.localSearchArray);
  //   }
  //   print("saved this ${FlutterTests.localSearchArray}");
  // }

  getRecents(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var glid = prefs.getString("glid");
    var ak = prefs.getString("AK");
    var currentPlatform = prefs.getString("platform");
    var ipAddress = prefs.getString("ipAddress");
    var mobile = prefs.getString("Mobile");
    EasyLoading.show(status: 'Loading...');
    var modId = "";
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        modId = "ANDROID";
      } else if (Platform.isIOS) {
        modId = "IOS";
      }
    } else {
      modId = "ANDROID";
    }
    try {
      String pathUrl = "";
      if (query.isEmpty) {
        var logtime = formattedEndDate();
        pathUrl =
            "https://mapi.indiamart.com//wservce/users/getBuyerData/?VALIDATION_GLID=$glid&APP_SCREEN_NAME=Default-Seller&count=15&AK=$ak&source=Search Products On Scroll&type=2&modid=$modId&token=imobile@15061981&APP_USER_ID=$glid&APP_MODID=$modId&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=$glid&VALIDATION_USER_IP=$ipAddress&logtime=$logtime&app_version_no=13.2.0&VALIDATION_USERCONTACT=$mobile";
      } else {
        pathUrl =
            "https://suggest.imimg.com/suggest/suggest.php/?q=$query&limit=10&type=product%2Cmcat&match=fuzzy&fields=&p=5&APP_MODID=$modId&AK=$ak&VALIDATION_GLID=$glid&VALIDATION_USER_IP=$ipAddress&VALIDATION_USERCONTACT=$mobile&app_version_no=13.2.1_T1&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&APP_USER_ID=$glid&APP_SCREEN_NAME=Default-Seller";
      }
      print("pathurl=$pathUrl");
      http.Response response = await http.get(Uri.parse(pathUrl));
      var code = json.decode(response.body)['CODE'];
      if (code == "402" || code == "401") {
        var msg = json.decode(response.body)['MESSAGE'];
        EasyLoading.dismiss();
        // Flushbar(
        //   title: code,
        //   message: msg,
        //   flushbarStyle: FlushbarStyle.FLOATING,
        //   isDismissible: true,
        //   duration: const Duration(seconds: 4),
        //   backgroundColor: Colors.red,
        //   margin: const EdgeInsets.all(8),
        //   borderRadius: BorderRadius.circular(8),
        //   boxShadows: const [
        //     BoxShadow(
        //       offset: Offset(0.0, 2.0),
        //       blurRadius: 3.0,
        //     )
        //   ],
        // ).show(context);
      } else if (response.statusCode == 200) {
        if (query.isEmpty) {
          var resultsArray = json.decode(response.body)['details']['searches'];
          dataArray.clear();
          for (var i = 0; i < resultsArray.length; i++) {
            var label = resultsArray[i]["search"];
            print(label);
            if (label != null) {
              dataArray.add(label.toString());
            }
          }
        } else {
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
                            } else {
                              setState(() {
                                hasText = false;
                                print("searchingText1=$searchingText");
                                searchQuery = "";
                                getRecents(searchQuery);
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
                            if (searchQuery.isEmpty) getRecents("");
                          },
                          controller: searchBar,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          hasText
                              ? searchBar.clear()
                              : openVoiceToTextConverter();
                          if (hasText) {
                            setState(() {
                              hasText = false;
                              searchQuery = "";
                              getRecents(searchQuery);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: hasText
                                ? BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "images/cross_icon_bl_balance_strip.png"),
                                        fit: BoxFit.cover),
                                  )
                                : BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "images/mic_icon_colored.png"),
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
                            child: hasText
                                ? Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  )
                                : Icon(
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

  openVoiceToTextConverter() async {
    var receivedText = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => SpeechToTextConverter(
                onTap: (details) {
                  //
                },
                bgColor: Colors.teal,
                // size: Size(
                //   MediaQuery.of(context).size.width - 60,
                //   MediaQuery.of(context).size.height * 0.6,
                // ),
                fromScreen: VoiceSearchFromScreen.impSuppliesList,
                localeId: "en_US",
                selectedIndex: 0,
                cityIndex: widget.cityIndex),
            opaque: false,
            fullscreenDialog: true));
    if (receivedText != "" && receivedText != null) {
      print("output text at impCat page $receivedText");
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Search(
              city: widget.cityIndex,
              productName: receivedText,
              productFname: encodeString(receivedText),
              productIndex: 0,
              biztype: "")));
    }
  }

  String encodeString(String? inputString) {
    var queryParamRaw = inputString ?? "";
    var encoded = queryParamRaw.replaceAll(" ", "%20");
    return encoded;
  }

  TextSpan _buildTextSpan(String text, String searchText) {
    final startIndex = text.indexOf(searchText);
    if (startIndex == -1) {
      return TextSpan(
          text: text, style: TextStyle(color: Colors.black, fontSize: 18));
    }

    final endIndex = startIndex + searchText.length;

    final span = TextSpan(children: [
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
    ], style: TextStyle(color: Colors.black, fontSize: 18));

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

  void fetchSavedData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      mobNo = sharedPreferences.getString('UserContact');
      glid = sharedPreferences.getString('glid');
      ak = sharedPreferences.getString('AK');
    });
  }
}

// ignore_for_file: must_be_immutable, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tests/LocationSelector.dart';
import 'package:flutter_tests/SearchFieldController.dart';
import 'package:flutter_tests/pbr_banner.dart';
import 'package:flutter_tests/Fliters.dart';
import 'package:flutter_tests/recent_search_banner.dart';
import 'package:flutter_tests/sellerType.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'ImportantSuppilesDetailsList.dart';
import 'SpeechToTextConverter.dart';
import 'adClass.dart';
import 'main_pbr_banner.dart';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;

enum ScreenLayout { details, list }

class Search extends StatefulWidget {
  @override
  SearchState createState() => SearchState();
  String productName;
  String productFname;
  int productIndex;
  String biztype;
  int city;
  Search(
      {Key? key,
      required this.city,
      required this.productName,
      required this.productFname,
      required this.productIndex,
      required this.biztype})
      : super(key: key);
}

class SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late String encodedQueryParam;
  int clickedIndex = 0;
  List<List<String>>? imagesArray = [];
  List<List<String>>? titlesArray = [];
  List<List<String>>? phoneArray = [];
  List<List<String>>? itemPricesArray = [];
  List<List<String>>? companyNameArray = [];
  List<List<String>>? sealArray = [];
  List<List<String>>? locationsArray = [];
  List<List<String>>? localityArray = [];
  List<String>? imagesArrayM = [];
  List<String>? titlesArrayM = [];
  List<String>? phoneArrayM = [];
  List<String>? itemPricesArrayM = [];
  List<String>? companyNameArrayM = [];
  List<String>? sealArrayM = [];
  List<String>? locationsArrayM = [];
  List<String>? localityArrayM = [];
  List<dynamic> resultsArray = [];
  List<String> sellerTypeModelList = [];
  List<dynamic> sellerTypeArray = [];
  List<dynamic> bizWiseArray = [];
  var currentLayout = ScreenLayout.details;
  final ScrollController _scrollController = ScrollController();
  bool _isAtEnd = false;

  List<dynamic> items = [];

  // List<String> categoriesList = ["English", "Hindi"];

  final List<String> citiesArrayLocal = [...FlutterTests.citiesArray];
  final List<String> cityIdArrayLocal = [...FlutterTests.cityIdArray];

  String currentCityId = "";
  String currentCity = "";

  var totalItemCount = 0;
  var itemCount = 0;

  late String pbrimage;

  bool stop = false;

  int scrolled = 1;

  int start = 0;
  int end = 0;

  int currentPage = 0;
  List<String> related = [];
  List<String> relatedfname = [];

  bool isLoading=false;

  // View Did Load
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    encodedQueryParam = encodeString(widget.productFname);
    print(encodedQueryParam);
    currentPage = 1;
    start = 0;
    end = 9;
    if (widget.city != 0) {
      currentCity = citiesArrayLocal[widget.city];
      currentCityId = cityIdArrayLocal[widget.city];
      reArrangeLocalArraysAndRefreshScreen(
          widget.city, currentCity, currentCityId);
    } else
      getMoreDetails(encodedQueryParam, widget.biztype, 0, 9, currentPage, true,
          currentCityId, currentCity);
    _scrollController.addListener(() {
      if ((_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent) &&
          scrolled == 1) {
        setState(() {
          _isAtEnd = true;
          scrolled = 0;
          start = end + 1;
          end = start + 10;
          if (end > totalItemCount) {
            start = end - 10;
            end = totalItemCount;
          }
          if (stop == false && start <= end && !isLoading) {
            currentPage += 1;
            getMoreDetails(encodedQueryParam, widget.biztype, start, end,
                currentPage, false, currentCityId, currentCity);
          } // Mark that you've reached the end
        });
      } else {
        setState(() {
          _isAtEnd = false; // Not at the end
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
  }

  String encodeString(String? inputString) {
    var queryParamRaw = inputString ?? "";
    var encoded = queryParamRaw.replaceAll(" ", "%20");
    return encoded;
  }

  openFilters(bool isSellerType, List<String> list, List<String> list1) async {
    var selectedChip = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => Filters(
                  categoriesList: list,
                  backList: list1,
                  isSellerType: isSellerType,
                  productIndex: widget.productIndex,
                ),
            opaque: false,
            fullscreenDialog: true));

    if (selectedChip != null) {
      encodedQueryParam = encodeString(widget.productFname);
      print("issellertype=$isSellerType biztype=${selectedChip[0]}");
      if (!isSellerType) {
        // resetUI();
        encodedQueryParam = encodeString(selectedChip[1]);
        widget.productName = selectedChip[0];
      } else {
        var productName = widget.productName;
        // resetUI();
        widget.productName = productName;
        widget.biztype = selectedChip[0];
        widget.productIndex = selectedChip[2];
      }
      startFromFirst();
      if (!isSellerType) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ImportantSuppilesDetailsList(
                  city: clickedIndex,
                  productName: widget.productName,
                  productFname: encodedQueryParam,
                  productIndex: 0,
                  biztype: "",
                )));
      } else
        getMoreDetails(encodedQueryParam, widget.biztype, 0, 9, 1, false,
            currentCityId, currentCity);
    }
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
                //   MediaQuery.of(context).size.height - 300,
                // ),
                fromScreen: VoiceSearchFromScreen.impSuppliesList,
                localeId: "en_US",
                selectedIndex: 0,
                cityIndex: widget.city),
            opaque: false,
            fullscreenDialog: true));
    if (receivedText != "" && receivedText != null) {
      print("output text at impCat page $receivedText");
      encodedQueryParam = encodeString(receivedText);
      widget.productName = receivedText;
      items.length = 0;
      getMoreDetails(encodedQueryParam, widget.biztype, 0, 9, 1, false,
          currentCityId, currentCity);
    }
  }

  void resetUI() {
    setState(() {
      // imagesArray?.clear();
      // phoneArray?.clear();
      // titlesArray?.clear();
      // itemPricesArray?.clear();
      // companyNameArray?.clear();
      // locationsArray?.clear();
      // localityArray?.clear();
      // widget.productName = "";
      // Add more variables to reset if needed.
    });
  }

  showSearchController() async {
    var outputText = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchFieldController(
                  fromScreen: SearchingFromScreen.impSuppliesList,
                  word: widget.productName,
              cityIndex: clickedIndex,
                )));
    if (outputText != null && outputText != "") {
      resetUI();
      encodedQueryParam = encodeString(outputText);
      widget.productName = outputText;
      startFromFirst();
      getMoreDetails(
          encodedQueryParam, widget.biztype, 0, 9, 1, true, currentCityId, "");
    }
  }

  // reArrangeLanguageArraysAndRefreshScreen(
  //     int clickedIndex, String clickedCity) {
  //   if (clickedIndex != 0) {
  //     categoriesList.removeAt(1);
  //     categoriesList.insert(1, categoriesList[0]);
  //     categoriesList.removeAt(0);
  //     categoriesList.insert(0, clickedCity);
  //   }
  //   setState(() {
  //     if (clickedCity == "English") {
  //       locale = 'en_US';
  //     } else {
  //       locale = 'hi_IN';
  //     }
  //   });
  //   Navigator.pop(context);
  //   // showBottomSheet(context, locale);
  // }

  reArrangeLocalArraysAndRefreshScreen(
      int clickedIndex, String clickedCity, String clickedCityId) {
    this.clickedIndex = clickedIndex;
    citiesArrayLocal.removeAt(clickedIndex);
    citiesArrayLocal.insert(0, clickedCity);
    cityIdArrayLocal.removeAt(clickedIndex);
    cityIdArrayLocal.insert(0, clickedCityId);
    currentCityId = cityIdArrayLocal[0];
    currentCity = clickedCity;
    String productName = widget.productName;
    resetUI();
    items.clear();
    startFromFirst();
    widget.productName = productName;
    getMoreDetails(encodedQueryParam, widget.biztype, 0, 9, 1, true,
        currentCityId, clickedCity);
  }

  showLocationSelector() async {
    var selectedCity = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LocationSelector()));
    print("selected city=$selectedCity");
    if (selectedCity != null) {
      var index = citiesArrayLocal.indexOf(selectedCity);
      reArrangeLocalArraysAndRefreshScreen(
          index, selectedCity, cityIdArrayLocal[index]);
    }
  }

  getMoreDetails(
      String category,
      String biztype,
      int start,
      int end,
      int currentPage,
      bool shouldUpdateSellerTypeList,
      String cityId,
      String cityName) async {
    DateTime then = DateTime.now();
    if(currentPage==1)
    EasyLoading.show(status: 'Loading...');
    try {
      setState(() {
        if(currentPage>1)
          isLoading = true;
      });
      String biztype_data = "";
      if (SellerTypeData.getValueFromName(biztype) != "")
        biztype_data = SellerTypeData.getValueFromName(biztype);
      String pathUrl = "";
      if (cityName == "All India") cityName = "";
      print("api=$cityName");
      pathUrl =
          // "https://mapi.indiamart.com/wservce/im/search/?biztype_data=${biztype_data}&VALIDATION_GLID=136484661&APP_SCREEN_NAME=Search%20Products&options_start=${start}&options_end=${end}&AK=${FlutterTests.AK}&source=android.search&implicit_info_latlong=&token=imartenquiryprovider&implicit_info_cityid_data=Delhi&APP_USER_ID=136484661&implicit_info_city_data=&APP_MODID=ANDROID&q=${category}&modeId=android.search&APP_ACCURACY=0.0&prdsrc=0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&VALIDATION_USER_IP=117.244.8.217&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233";
          "https://mapi.indiamart.com/wservce/im/search/?biztype_data=${biztype_data}&VALIDATION_GLID=136484661&APP_SCREEN_NAME=Search%20Products&src=as-popular:pos=5:cat=-2:mcat=-2&options_start=${start}&options_end=${end}&AK=${FlutterTests.AK}&source=android.search&token=imartenquiryprovider&APP_USER_ID=136484661&implicit_info_city_data=${cityName}&APP_MODID=ANDROID&q=${category}&modeId=android.search&APP_ACCURACY=33.543&prdsrc=1&APP_LATITUDE=&APP_LONGITUDE=&VALIDATION_USER_IP=117.244.8.217&app_version_no=13.2.0&VALIDATION_USERCONTACT=1511122233";
      print("api=$pathUrl");
      http.Response response = await http.get(Uri.parse(pathUrl));
      var code = json.decode(response.body)['CODE'];
      if (code == "402") {
        var msg = json.decode(response.body)['MESSAGE'];
        if(currentPage==1)
        EasyLoading.dismiss();
      } else if (response.statusCode == 200) {
        resultsArray.clear();
        print("resultsarrayafterclearing=${resultsArray.length}");
        resultsArray = json.decode(response.body)['results'];
        if (resultsArray.length > 0) {
          DateTime now = DateTime.now();
          print("search_api_hit_time=${now.difference(then)}");
        }
        if (resultsArray.length > 0) {
          sellerTypeArray =
              json.decode(response.body)['facet_fields']['biztype'];
          List<String> stringsOnly = [];
          if (shouldUpdateSellerTypeList) {
            sellerTypeModelList.clear();
            sellerTypeModelList.add("All");
            for (var item in sellerTypeArray) {
              if (item is String) {
                stringsOnly.add(item);
                if (SellerTypeData.getNameOfSellerType(item) != "")
                  sellerTypeModelList
                      .add(SellerTypeData.getNameOfSellerType(item));
              }
            }
          }
          print("search_a,,pi_hit_time)}");
        }
        if (currentPage == 1) {
          if(json.decode(response.body)['guess']!=null) {
            dynamic live_mcats =
                json.decode(response.body)['guess']['guess']['live_mcats'];

            if (live_mcats is List) {
              pbrimage = live_mcats.isNotEmpty ? live_mcats[0]['smallimg'] : "";
              related.clear();
              relatedfname.clear();

              for (var i = 0; i < live_mcats.length; i++) {
                if (live_mcats[i] != null && live_mcats[i] is Map) {
                  related.add(live_mcats[i]['name']);
                  relatedfname.add(live_mcats[i]['filename']);
                }
              }

              totalItemCount = json
                  .decode(response.body)['total_results_without_repetition'];
            }
          } else {
            pbrimage = "";
            related.clear();
            relatedfname.clear();
            totalItemCount = 0;
          }

          imagesArray?.clear();
          phoneArray?.clear();
          titlesArray?.clear();
          itemPricesArray?.clear();
          companyNameArray?.clear();
          sealArray?.clear();
          locationsArray?.clear();
          localityArray?.clear();
          imagesArrayM?.clear();
          phoneArrayM?.clear();
          titlesArrayM?.clear();
          itemPricesArrayM?.clear();
          companyNameArrayM?.clear();
          sealArrayM?.clear();
          locationsArrayM?.clear();
          localityArrayM?.clear();
        }
        for (var i = 0; i < resultsArray.length; i++) {
          List<String>? imagesArrayM=[];
          List<String>?phoneArrayM=[];
          List<String>?titlesArrayM=[];
          List<String>? itemPricesArrayM=[];
          List<String>? companyNameArrayM=[];
          List<String>? sealArrayM=[];
          List<String>? locationsArrayM=[];
          List<String>? localityArrayM=[];
          var image = resultsArray[i]['fields']['large_image'];
          imagesArrayM?.add(image);

          var title = resultsArray[i]['fields']['title'];
          titlesArrayM?.add(title ?? "NA");


          var phoneNo = resultsArray[i]['fields']['pns'];
          phoneArrayM?.add(phoneNo ?? "NA");
          var itemPrices = resultsArray[i]['fields']['itemprice'];
          var units = resultsArray[i]['fields']['moq_type'];
          if (itemPrices == "" || itemPrices == null) {
            itemPricesArrayM?.add("Prices on demand");
          } else {
            if (units == "" || units == null) {
              units = "units";
            }
            itemPricesArrayM?.add((itemPrices) + "/ " + (units));
          }
          var company = resultsArray[i]['fields']['companyname'];
          companyNameArrayM?.add(company ?? "NA");

          var dealsLocation = resultsArray[i]['fields']['deals_in_loc'] ?? "NA";
          locationsArrayM?.add("$dealsLocation");
          int CUSTTYPE_WEIGHT1 = resultsArray[i]['fields']['CustTypeWt'] ??
              "NA";
          var tsCode = resultsArray[i]['fields']['tscode'] ?? "NA";
          sealArrayM?.add(getSupplierType(CUSTTYPE_WEIGHT1, tsCode));

          var city = resultsArray[i]['fields']['city'] ?? "";

          var locality = resultsArray[i]['fields']['locality'] ?? "NA";
          if (locality == "" || locality == "NA")
            localityArrayM?.add(city);
          else if (city != "") localityArrayM?.add(city + " - " + locality);
          dynamic moreResults = resultsArray[i]['more_results'];
          if (moreResults != null)
            for (int j = 0; j < moreResults.length; j++) {
              var image = moreResults[j]['large_image'];
              imagesArrayM?.add(image);
              var title = moreResults[j]['title'];
              titlesArrayM?.add(title ?? "NA");

              var phoneNo = moreResults[j]['pns'];
              phoneArrayM?.add(phoneNo ?? "NA");
              var itemPrices = moreResults[j]['itemprice'];
              var units = moreResults[j]['moq_type'];
              if (itemPrices == "" || itemPrices == null) {
                itemPricesArrayM?.add("Prices on demand");
              } else {
                if (units == "" || units == null) {
                  units = "units";
                }
                itemPricesArrayM?.add((itemPrices) + "/ " + (units));
              }
              var company = moreResults[j]['companyname'];
              companyNameArrayM?.add(company ?? "NA");

              var dealsLocation = moreResults[j]['deals_in_loc'] ?? "NA";
              locationsArrayM?.add("$dealsLocation");

              int CUSTTYPE_WEIGHT1 = moreResults[j]['CustTypeWt'] ?? "NA";
              var tsCode = moreResults[j]['tscode'] ?? "NA";
              sealArrayM?.add(getSupplierType(CUSTTYPE_WEIGHT1, tsCode));

              var city = moreResults[j]['city'] ?? "";

              var locality = moreResults[j]['locality'] ?? "NA";
              if (locality == "" || locality == "NA")
                localityArrayM?.add(city);
              else if (city != "") localityArrayM?.add(city + " - " + locality);
            }

          imagesArray?.add(imagesArrayM!);
          print("imagesarray=$imagesArray");
          phoneArray?.add(phoneArrayM!);
          titlesArray?.add(titlesArrayM!);
          itemPricesArray?.add(itemPricesArrayM!);
          companyNameArray?.add(companyNameArrayM!);
          sealArray?.add(sealArrayM!);
          locationsArray?.add(locationsArrayM!);
          localityArray?.add(localityArrayM!);
        }
        setState(() {
          isLoading = false;
          items.addAll(resultsArray);
        });
      }

      if (resultsArray.length > 0) if (currentPage > 1 && totalItemCount > 10) {
        //   if (!kIsWeb) ;
        //   // addBannerOrAd(end, "ADEMPTY");
        if(start<end)
        addBannerOrAd(items.length - 4, "PBRBANNER");
      } else if (currentPage == 1) {
        if (!kIsWeb) {
          addBannerOrAd(2, "ADEMPTY");
          addBannerOrAd(7, "ADEMPTY");
        }
        addBannerOrAd(5, "isq_banner");
        addBannerOrAd(10, "PBRBANNER");
        addBannerOrAd(11, "RECENTPBRBANNER");
      } else
        stop = true;

      print("resultsArray=${items.length} ${resultsArray?.length},");
      if(currentPage==1)
      EasyLoading.dismiss();
      DateTime now = DateTime.now();
      print("DateTime now = DateTime.now();${now.difference(then)}");
      scrolled = 1;
    } catch (e) {
      // EasyLoading.dismiss();
      print("exception is ${e.toString()} $start");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    itemCount = items.length;
    // print("itemcounta=$itemCount");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
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
                          onTap: () {
                            showSearchController();
                          },
                          controller: TextEditingController(
                              text: "${widget.productName}"),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          readOnly: true,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          openVoiceToTextConverter();
                          // var x = await showBottomSheet(context, locale);
                          // print("nameofproduct=$x");
                          // var receivedText = await Navigator.push(
                          //     context,
                          //     PageRouteBuilder(
                          //         pageBuilder: (_, __, ___) =>
                          //             SpeechToTextEnglish(
                          //                 onTap: (details) {
                          //                   //
                          //                 },
                          //                 bgColor: Colors.teal,
                          //                 size: Size(
                          //                   MediaQuery.of(context).size.width -
                          //                       60,
                          //                   MediaQuery.of(context).size.height -
                          //                       300,
                          //                 ),
                          //                 fromScreen: VoiceSearchFromScreen
                          //                     .impSuppliesList,
                          //                 localeId: "en_US",
                          //                 selectedIndex: 0,
                          //                 cityIndex: widget.city),
                          //         opaque: false,
                          //         fullscreenDialog: true));

                          // print("output text $receivedText");
                        },
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
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    openFilters(true, sellerTypeModelList, sellerTypeModelList);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Seller Type",
                        style: TextStyle(
                          color: Color(0xff432B20),
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.expand_more,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                TextButton(
                  onPressed: () {
                    openFilters(false, related, relatedfname);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Categories",
                        style: TextStyle(
                          color: Color(0xff432B20),
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.expand_more,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                TextButton(
                  onPressed: () {
                    if (currentLayout == ScreenLayout.details) {
                      currentLayout = ScreenLayout.list;
                    } else {
                      currentLayout = ScreenLayout.details;
                    }
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentLayout == ScreenLayout.details
                            ? "Detail "
                            : "List ",
                        style: const TextStyle(
                          color: Color(0xff432B20),
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        currentLayout == ScreenLayout.details
                            ? Icons.dvr
                            : Icons.list,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const VerticalDivider(
                  color: Colors.blue, // Partition color
                  thickness: 1, // Partition thickness
                  width: 1, // Width of the partition
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
            const Divider(
              height: 4,
              color: Colors.black,
            ),
            Container(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: citiesArrayLocal.length,
                itemBuilder: (BuildContext context, int index) {
                  var inkWell = InkWell(
                      onTap: () {
                        if (index == 0) {
                          showLocationSelector();
                        } else {
                          reArrangeLocalArraysAndRefreshScreen(index,
                              citiesArrayLocal[index], cityIdArrayLocal[index]);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            if (index == 0) ...[
                              const Icon(
                                Icons.gps_fixed,
                                color: Colors.black54,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                            Text(citiesArrayLocal[index]),
                          ],
                        ),
                      ));
                  return Card(
                    color: index == 0
                        ? Colors.teal.shade200
                        : Colors.grey.shade300,
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: inkWell,
                  );
                },
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              height: 8,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: itemCount+1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == itemCount) {
                    print("index==$index $itemCount");
                    return (isLoading) ? Center(child: Padding(
                        padding:EdgeInsets.all(8),
                        child:CircularProgressIndicator())) : Text("");
                  }
                  else {
                    // var inkWell = InkWell(
                    //   onTap: () {
                    //     // Action
                    //   },
                    //   child: CarouselWidget(currentLayout: currentLayout,localityArray: localityArrayM,locationsArray: locationsArray,imagesArray: imagesArrayM,
                    //                     titlesArray: titlesArrayM, phoneArray: phoneArrayM, companyNameArray: companyNameArrayM, itemPricesArray: itemPricesArrayM, sealArray: sealArrayM,)
                    //   Column(
                    //     children: [
                    //       if (currentLayout == ScreenLayout.details) ...[
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             if (imagesArray?[index] == "") ...[
                    //               Container(
                    //                   margin: const EdgeInsets.all(10),
                    //                   height: 150,
                    //                   width: 100,
                    //                   color: Colors.grey.shade200,
                    //                   alignment: Alignment.topCenter,
                    //                   child: const Center(
                    //                     child: Text(
                    //                       "No Image Available",
                    //                       style: TextStyle(
                    //                           color: Color.fromARGB(
                    //                               255, 103, 97, 97),
                    //                           fontSize: 16,
                    //                           fontWeight: FontWeight.w900),
                    //                       textAlign: TextAlign.center,
                    //                     ),
                    //                   )),
                    //             ] else ...[
                    //               Container(
                    //                 margin: const EdgeInsets.all(10),
                    //                 height: 150,
                    //                 width: 100,
                    //                 alignment: Alignment.topCenter,
                    //                 child: Image(
                    //                   image: CachedNetworkImageProvider(
                    //                       imagesArray?[index] ??
                    //                           "https://ik.imagekit.io/hpapi/harry.jpg"),
                    //                   fit: BoxFit.fill,
                    //                 ),
                    //               ),
                    //             ],
                    //             Flexible(
                    //               child: Description(
                    //                   companyName:
                    //                       companyNameArray?[index] ?? "",
                    //                   itemPrice:
                    //                       itemPricesArray?[index] ?? "NA",
                    //                   locality: localityArray?[index] ?? "NA",
                    //                   location: locationsArray?[index] ?? "NA",
                    //                   title: titlesArray?[index] ?? "NA",
                    //                   phone: phoneArray?[index] ?? "NA",
                    //                   seal: sealArray?[index] ?? "NA"),
                    //             ),
                    //           ],
                    //         ),
                    //       ] else ...[
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: [
                    //             if (imagesArray?[index] == "") ...[
                    //               Container(
                    //                 height: 150,
                    //                 color: Colors.grey.shade200,
                    //                 margin: const EdgeInsets.all(10),
                    //                 alignment: Alignment.topCenter,
                    //                 child: const Center(
                    //                   child: Text(
                    //                     "No Image Available",
                    //                     style: TextStyle(
                    //                         color: Color.fromARGB(
                    //                             255, 103, 97, 97),
                    //                         fontSize: 16,
                    //                         fontWeight: FontWeight.w900),
                    //                     textAlign: TextAlign.center,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ] else ...[
                    //               Container(
                    //                 margin: const EdgeInsets.all(10),
                    //                 alignment: Alignment.topCenter,
                    //                 child: Image(
                    //                   image: CachedNetworkImageProvider(
                    //                       imagesArray?[index] ??
                    //                           "https://ik.imagekit.io/hpapi/harry.jpg"),
                    //                 ),
                    //               ),
                    //             ],
                    //             Padding(
                    //               padding: const EdgeInsets.only(left: 20),
                    //               child: Description(
                    //                 companyName: companyNameArray?[index] ?? "",
                    //                 itemPrice: itemPricesArray?[index] ?? "NA",
                    //                 locality: localityArray?[index] ?? "NA",
                    //                 location: locationsArray?[index] ?? "NA",
                    //                 title: titlesArray?[index] ?? "NA",
                    //                 phone: phoneArray?[index] ?? "NA",
                    //                 seal: sealArray?[index] ?? "NA",
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ],
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           CustomButton(phoneNo: phoneArray![index]),
                    //           CustomButton2()
                    //         ],
                    //       )
                    //     ],
                    //   ),
                    // )
                    // ;
                    //
                    if (titlesArray?[index][0] == "PBRBANNER") {
                      return PBRBanner(product_name: widget.productName);
                    } else if (titlesArray?[index][0] == "isq_banner") {
                      return MainPBRBanner(
                          productName: widget.productName, img: pbrimage);
                    } else if (titlesArray?[index][0] == "RECENTPBRBANNER") {
                      return LimitedChipsList();
                    } else if (titlesArray?[index][0] == "ADEMPTY") {
                      return AdClass();
                    } else {
                      return
                           Card(child: HorizontalList(currentLayout: currentLayout, localityArray: localityArray![index], imagesArray: imagesArray![index], phoneArray: phoneArray![index], titlesArray: titlesArray![index], companyNameArray: companyNameArray![index], itemPricesArray: itemPricesArray![index], locationsArray: locationsArray![index], sealArray: sealArray![index],));

                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Future showBottomSheet(BuildContext context, String locale) async {
  //   bool isEnglishSelected = true;
  //   int selectedCategoryIndex = -1;
  //   bool isHindiSelected = false;
  //   String? enteredText = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Center(
  //           child: Stack(
  //         children: [
  //           WaveWidget(
  //             size: Size(
  //               MediaQuery.of(context).size.width - 60,
  //               MediaQuery.of(context).size.height - 400,
  //             ),
  //             textForListening: locale,
  //             onTap: (TapDownDetails) {},
  //             bgColor: Colors.teal,
  //           ),
  //           Positioned(
  //             left: (MediaQuery.of(context).size.width - 60) / 2 -
  //                 90, // Adjust the horizontal position as needed
  //             top: MediaQuery.of(context).size.height -
  //                 470, // Adjust the vertical position as needed
  //             child: Container(
  //               height: 40,
  //               child: ListView.builder(
  //                 shrinkWrap: true,
  //                 scrollDirection: Axis.horizontal,
  //                 itemCount: categoriesList.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   var inkWell = InkWell(
  //                       onTap: () {
  //                         // if (index == 0) {
  //                         //   // showLocationSelector();
  //                         // } else {
  //                         reArrangeLanguageArraysAndRefreshScreen(
  //                             index, categoriesList[index]);
  //                         // }
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           children: [
  //                             if (index == 0) ...[
  //                               const SizedBox(
  //                                 width: 5,
  //                               ),
  //                             ],
  //                             Text(categoriesList[index]),
  //                           ],
  //                         ),
  //                       ));
  //                   return Card(
  //                     color: index == 0
  //                         ? Colors.teal.shade200
  //                         : Colors.grey.shade300,
  //                     clipBehavior: Clip.hardEdge,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(20.0),
  //                     ),
  //                     child: inkWell,
  //                   );
  //                 },
  //               ),
  //             ),

  //             //     SizedBox(width: 5,),
  //             //     GestureDetector(
  //             //       onTap: (){
  //             //         setState(() {
  //             //           print("isEnglishSelected=$isEnglishSelected");
  //             //           isEnglishSelected=false;
  //             //           isHindiSelected=true;
  //             //         });
  //             //       },
  //             //       child: ActionChip(
  //             //         onPressed: (){},
  //             //         label: Text('Hindi',style: TextStyle(color: isHindiSelected?Colors.white: Colors.teal),),
  //             //         backgroundColor:isHindiSelected?Colors.teal: Colors.transparent,
  //             //         shape: RoundedRectangleBorder(
  //             //           borderRadius: BorderRadius.circular(20.0), // Adjust border radius as needed
  //             //           side: BorderSide(
  //             //             color: Colors.teal, // Border color
  //             //             width: 2.0, // Border width
  //             //           ),
  //             //         ),
  //             //       ),
  //             // ),
  //           ),
  //         ],
  //       ));
  //     },
  //   );
  //   print("enteredText=$enteredText");
  //   if (enteredText != null && enteredText != "") {
  //     resetUI();
  //     encodedQueryParam = encodeString(enteredText);
  //     widget.productName = enteredText;
  //     items.length = 0;
  //     widget.screen = "search";
  //     getMoreDetails(encodedQueryParam, widget.biztype, 0, 9, 1, true,
  //         widget.screen, currentCityId, currentCity);
  //   }
  // }

  Future addBannerOrAd(int pos, String value) async {
    imagesArray?.insert(pos, [""]);
    titlesArray?.insert(pos, [value]);
    itemPricesArray?.insert(pos, [""]);
    companyNameArray?.insert(pos, [""]);
    sealArray?.insert(pos, [""]);
    locationsArray?.insert(pos, [""]);
    localityArray?.insert(pos, [""]);
    phoneArray?.insert(pos, [""]);
    items.length += 1;
    // itemCount++;
  }

//
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void startFromFirst() {
    items = [];
    start = 0;
    end = 9;
  }
  String getSupplierType( int custTypeWeight, String tsCode) {
    if (custTypeWeight == 149 ||
        custTypeWeight == 179 ||
        (tsCode != null && tsCode.isNotEmpty && tsCode != "null") ||
        (tsCode != null && tsCode.isEmpty && custTypeWeight == 199)) {
      return 'images/trustseal_supplier.png';
    } else if (custTypeWeight < 1400 && custTypeWeight != 755) {
      return 'images/shared_ic_verifiedsupplier.png';
    } else {
      return 'images/company_icon.png';
    }
  }
}


class CustomButton extends StatelessWidget {
  String phoneNo;

  CustomButton({required this.phoneNo});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            print("Call Now pressed}");
            _makePhoneCall('$phoneNo');
          },
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width / 2 - 25,
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal), // Rectangle border
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), // Top-left circular border
                bottomLeft: Radius.circular(25), // Bottom-left circular border
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/call.png"),
                          fit: BoxFit.cover),
                    ),
                    alignment: Alignment.center,
                  ),
                  const Text(
                    'Call Now',
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final call = "+91 $phoneNumber";
    if (!kIsWeb) {
      final permissionStatus = await Permission.phone.request();
      if (permissionStatus.isGranted) {
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      }
      else
        await makePhoneCall(call);
    }
    else
      await makePhoneCall(call);
  }


  Future makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}

class CustomButton2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 25,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.teal, // Rectangle border
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25), // Top-left circular border
            bottomRight: Radius.circular(25), // Bottom-left circular border
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/getBestPrice.png"),
                      fit: BoxFit.cover),
                ),
                alignment: Alignment.center,
              ),
              const Text(
                'Get Best Price',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Description extends StatefulWidget {
  @override
  State<Description> createState() => _DescriptionState();
  String title;
  String itemPrice;
  String companyName;
  String location;
  String locality;
  String phone;
  String seal;
  Description(
      {Key? key,
      required this.title,
      required this.itemPrice,
      required this.companyName,
      required this.location,
      required this.locality,
      required this.phone,
      required this.seal,
      })
      : super(key: key);
}

class _DescriptionState extends State<Description> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 5, 0),
          child: Text(
            widget.title,
            style: const TextStyle(
                color: Color(0xff432B20),
                fontSize: 15,
                fontFamily: 'HVD Fonts',
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                height: 14,
                width: 14,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/indian_rupee.png"),
                      fit: BoxFit.contain),
                ),
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
                child: Text(
                  widget.itemPrice,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'HVD Fonts',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/trustseal_supplier.png"),
                      fit: BoxFit.contain),
                ),
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
                child: Text(
                  widget.companyName,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xff432B20),
                    fontSize: 14,
                    fontFamily: 'HVD Fonts',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.locality != null && widget.locality.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/Location.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
                child: Text(
                  "${widget.locality}",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xff432B20),
                    fontSize: 14,
                    fontFamily: 'HVD Fonts',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.location != null && widget.location.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/url_mp.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                child: Text(
                  "${widget.location}",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xff432B20),
                    fontSize: 14,
                    fontFamily: 'HVD Fonts',
                  ),
                ),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 10),
      ],
    );
  }
}
class CarouselWidget extends StatelessWidget {
  var currentLayout;
  List<String>? imagesArray;
  List<String>? companyNameArray;
  List<String>? itemPricesArray;
  List<String>? localityArray;
  List<String>? locationsArray;
  List<String>? titlesArray;
  List<String>? phoneArray;
  List<String>? sealArray;
  CarouselWidget({required this.currentLayout,required this.localityArray,required this.imagesArray,required this.phoneArray,required this.titlesArray,
  required this.companyNameArray, required this.itemPricesArray, required this.locationsArray, required this.sealArray});

  @override
  Widget build(BuildContext context) {
    print("lengthfor horizontal ${imagesArray?.length}");
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imagesArray?.length,
      itemBuilder: (context, index) {
        return Container(
          width: 150,
          margin: EdgeInsets.all(8.0),
          color: Colors.blue,
          child: Center(
            child: Column(
              children: [
                if (currentLayout == ScreenLayout.details) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imagesArray?[index] == "") ...[
                        Container(
                            margin: const EdgeInsets.all(10),
                            height: 150,
                            width: 100,
                            color: Colors.grey.shade200,
                            alignment: Alignment.topCenter,
                            child: const Center(
                              child: Text(
                                "No Image Available",
                                style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 103, 97, 97),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ] else ...[
                        Container(
                          margin: const EdgeInsets.all(10),
                          height: 150,
                          width: 100,
                          alignment: Alignment.topCenter,
                          child: Image(
                            image: CachedNetworkImageProvider(
                                imagesArray?[index] ??
                                    "https://ik.imagekit.io/hpapi/harry.jpg"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                      Flexible(
                        child: Description(
                            companyName:
                            companyNameArray?[index] ?? "",
                            itemPrice:
                            itemPricesArray?[index] ?? "NA",
                            locality: localityArray?[index] ?? "NA",
                            location: locationsArray?[index] ?? "NA",
                            title: titlesArray?[index] ?? "NA",
                            phone: phoneArray?[index] ?? "NA",
                            seal: sealArray?[index] ?? "NA"),
                      ),
                    ],
                  ),
                ] else ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (imagesArray?[index] == "") ...[
                        Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.all(10),
                          alignment: Alignment.topCenter,
                          child: const Center(
                            child: Text(
                              "No Image Available",
                              style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 103, 97, 97),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          margin: const EdgeInsets.all(10),
                          alignment: Alignment.topCenter,
                          child: Image(
                            image: CachedNetworkImageProvider(
                                imagesArray?[index] ??
                                    "https://ik.imagekit.io/hpapi/harry.jpg"),
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Description(
                          companyName: companyNameArray?[index] ?? "",
                          itemPrice: itemPricesArray?[index] ?? "NA",
                          locality: localityArray?[index] ?? "NA",
                          location: locationsArray?[index] ?? "NA",
                          title: titlesArray?[index] ?? "NA",
                          phone: phoneArray?[index] ?? "NA",
                          seal: sealArray?[index] ?? "NA",
                        ),
                      ),
                    ],
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomButton(phoneNo: phoneArray![index]),
                    CustomButton2()
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}


class HorizontalList extends StatefulWidget {
  var currentLayout;
  List<String>? imagesArray;
  List<String>? companyNameArray;
  List<String>? itemPricesArray;
  List<String>? localityArray;
  List<String>? locationsArray;
  List<String>? titlesArray;
  List<String>? phoneArray;
  List<String>? sealArray;
  HorizontalList({required this.currentLayout,required this.localityArray,required this.imagesArray,required this.phoneArray,required this.titlesArray, required this.companyNameArray, required this.itemPricesArray, required this.locationsArray, required this.sealArray});


  @override
  State<HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  PageController _pageController = PageController(viewportFraction: 1);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return (widget.imagesArray!.isNotEmpty)
        ?  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  // height:  MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  child: ExpandablePageView.builder(
                        controller:_pageController,
                        itemCount: widget.imagesArray!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return  Column(
                                  children: [
                                    if (widget.currentLayout == ScreenLayout.details) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (widget.imagesArray?[index] == "") ...[
                                            Container(
                                                margin: const EdgeInsets.all(10),
                                                height: 150,
                                                width: 100,
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.topCenter,
                                                child: const Center(
                                                  child: Text(
                                                    "No Image Available",
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 103, 97, 97),
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w900),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )),
                                          ] else ...[
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              height: 150,
                                              width: 100,
                                              alignment: Alignment.topCenter,
                                              child: Image(
                                                image: CachedNetworkImageProvider(
                                                    widget.imagesArray?[index] ??
                                                        "https://ik.imagekit.io/hpapi/harry.jpg"),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                          Flexible(
                                            child: Description(
                                                companyName:
                                                    widget.companyNameArray?[index] ?? "",
                                                itemPrice:
                                                    widget.itemPricesArray?[index] ?? "NA",
                                                locality: widget.localityArray?[index] ?? "NA",
                                                location: widget.locationsArray?[index] ?? "NA",
                                                title: widget.titlesArray?[index] ?? "NA",
                                                phone: widget.phoneArray?[index] ?? "NA",
                                                seal: widget.sealArray?[index] ?? "NA"),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if (widget.imagesArray?[index] == "") ...[
                                            Container(
                                              height: 150,
                                              color: Colors.grey.shade200,
                                              margin: const EdgeInsets.all(10),
                                              alignment: Alignment.topCenter,
                                              child: const Center(
                                                child: Text(
                                                  "No Image Available",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 103, 97, 97),
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w900),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ] else ...[
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              alignment: Alignment.topCenter,
                                              child: Image(
                                                image: CachedNetworkImageProvider(
                                                    widget.imagesArray?[index] ??
                                                        "https://ik.imagekit.io/hpapi/harry.jpg"),
                                              ),
                                            ),
                                          ],
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20),
                                            child: Description(
                                              companyName: widget.companyNameArray?[index] ?? "",
                                              itemPrice: widget.itemPricesArray?[index] ?? "NA",
                                              locality: widget.localityArray?[index] ?? "NA",
                                              location: widget.locationsArray?[index] ?? "NA",
                                              title: widget.titlesArray?[index] ?? "NA",
                                              phone: widget.phoneArray?[index] ?? "NA",
                                              seal: widget.sealArray?[index] ?? "NA",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CustomButton(phoneNo: widget.phoneArray![index]),
                                        CustomButton2()
                                      ],
                                    ),
                                  ],
                                );
                        },
                  ),

    ),
              widget.imagesArray!.length>1?_buildIndicators():SizedBox(height: 0),
              SizedBox(height: 5,)
            ],

          )
        : Text("");
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.imagesArray!.length,
            (index) {
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (index == _currentPage) ? Colors.teal : Colors.grey,
            ),
          );
        },
      ),
    );
  }
}




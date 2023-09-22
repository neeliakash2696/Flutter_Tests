// ignore_for_file: must_be_immutable, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:flutter_tests/ApiManager.dart';
import 'package:flutter_tests/search.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tests/LocationSelector.dart';
import 'package:flutter_tests/SearchFieldController.dart';
import 'package:flutter_tests/adClass.dart';
import 'package:flutter_tests/pbr_banner.dart';
import 'package:flutter_tests/Fliters.dart';
import 'package:flutter_tests/recent_search_banner.dart';
import 'package:flutter_tests/sellerType.dart';
import 'package:flutter_tests/SpeechToTextConverter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'main_pbr_banner.dart';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;

enum ScreenLayout { details, list }

class ImportantSuppilesDetailsList extends StatefulWidget {
  @override
  ImportantSuppilesDetailsListState createState() =>
      ImportantSuppilesDetailsListState();
  String productName;
  String productFname;
  int productIndex;
  String biztype;
  int city;
  ImportantSuppilesDetailsList(
      {Key? key,
      required this.city,
      required this.productName,
      required this.productFname,
      required this.productIndex,
      required this.biztype})
      : super(key: key);
}

class ImportantSuppilesDetailsListState
    extends State<ImportantSuppilesDetailsList>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  int clickedIndex = 0;
  bool isLoading = false;
  late String encodedQueryParam;
  List<String>? imagesArray = [];
  List<String>? titlesArray = [];
  List<String>? phoneArray = [];
  List<String>? itemPricesArray = [];
  List<String>? companyNameArray = [];
  List<String>? sealArray = [];
  List<String>? locationsArray = [];
  List<String>? localityArray = [];
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
  // String locale = 'en_US';
  List<String> related = [];
  List<String> relatedfname = [];

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
    print("currentCity=${widget.city}");
    if (widget.city != 0) {
      currentCity = citiesArrayLocal[widget.city];
      currentCityId = cityIdArrayLocal[widget.city];
      reArrangeLocalArraysAndRefreshScreen(
          widget.city, currentCity, currentCityId);
    } else
      getMoreDetails(encodedQueryParam, widget.biztype, 0, 9, currentPage, true,
          currentCityId, currentCity);
    // getProductDetails(encodedQueryParam);
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
    // This method is called when the layout metrics change,
    // which indicates that the widgets have been fully laid out.
    // You can perform actions after the page is fully loaded here.
    // print("cutrre");
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
        resetUI();
        encodedQueryParam = encodeString(selectedChip[1]);
        widget.productName = selectedChip[0];
      } else {
        var productName = widget.productName;
        resetUI();
        widget.productName = productName;
        widget.biztype = selectedChip[0];
        widget.productIndex = selectedChip[2];
      }
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
                cityIndex: widget.city),
            opaque: false,
            fullscreenDialog: true));
    if (receivedText != "" && receivedText != null) {
      print("output text at impCat page $receivedText");
      encodedQueryParam = encodeString(receivedText);
      widget.productName = receivedText;
      items.length = 0;
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Search(
              city: clickedIndex,
              productName: widget.productName,
              productFname: encodedQueryParam,
              productIndex: 0,
              biztype: widget.biztype)));
    }
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
      items.length = 0;
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Search(
              city: clickedIndex,
              productName: widget.productName,
              productFname: encodedQueryParam,
              productIndex: 0,
              biztype: "")));
    }
  }

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
    if (currentPage == 1) EasyLoading.show(status: 'Loading...');
    // print("cateory=$category");
    // print(
    // "start=$start and end=$end and item length=${items.length} currentpage=${currentPage}");
    try {
      setState(() {
        if (currentPage > 1) isLoading = true;
      });
      String biztype_data = "";
      if (SellerTypeData.getValueFromName(biztype) != "")
        biztype_data = SellerTypeData.getValueFromName(biztype);
      // print("biztype_data=$biztype_data");
      String pathUrl = "";
      print("api=$cityId");
      pathUrl =
          "https://mapi.indiamart.com/wservce/products/listing/?flag=product&VALIDATION_GLID=136484661&flname=${category}&APP_SCREEN_NAME=IMPCat Listing&start=${start}&AK=${FlutterTests.AK}&cityid=${cityId}&modid=ANDROID&token=imobile@15061981&APP_USER_ID=136484661&APP_MODID=ANDROID&in_country_iso=0&biz_filter=${biztype_data}&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=117.244.8.192&end=${end}&app_version_no=13.2.1_T1&VALIDATION_USERCONTACT=1511122233";
      print("api=$pathUrl");
      http.Response response = await http.get(Uri.parse(pathUrl));
      Map<String, dynamic> data = json.decode(response.body);
      log("$data");
      // Category categoryArray = Category.fromJson(data);

      // var response = await ApiManager().getResponse(
      //     context: context,
      //     method: ApiManager.getMethod,
      //     webLink: pathUrl,
      //     showLoading: true);

      // log(response.toString());
      ProductModel productModelArray = ProductModel.fromJson(data);
      print("required $productModelArray");
      // print("requuired 1 $categoryArray");
      // print("requuired${categoryArray.grp[0].img_v2}");
      /*var code = json.decode(response.body)['CODE'];
      if (code == "402") {
        var msg = json.decode(response.body)['MESSAGE'];
        if (currentPage == 1) EasyLoading.dismiss();
      } else if (response.statusCode == 200) {
        resultsArray = json.decode(response.body)['data'];
        bizWiseArray = json.decode(response.body)['biz_wise_count'];
        sellerTypeArray.clear();
        for (int i = 0; i < bizWiseArray.length; i++)
          sellerTypeArray
              .add((bizWiseArray[i]['PRD_SEARCH_PRIMARY_BIZ_ID']).toString());
        // print("resultsArray=$resultsArray $sellerTypeArray");
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
        if (currentPage == 1) {
          dynamic live_mcats = json.decode(response.body)['mcatdata'];
          pbrimage = live_mcats[0]['GLCAT_MCAT_IMG1_125X125'];
          related.clear();
          relatedfname.clear();
          for (var i = 0; i < live_mcats.length; i++) {
            related.add(live_mcats[i]['GLCAT_MCAT_NAME']);
            relatedfname.add(live_mcats[i]['GLCAT_MCAT_FLNAME']);
          }
          print("pbrimage=$sellerTypeModelList");
          print(
              "pbrimage=${json.decode(response.body)['out_total_unq_count']}");
          totalItemCount =
              int.tryParse(json.decode(response.body)['out_total_unq_count'])!;
          imagesArray?.clear();
          phoneArray?.clear();
          titlesArray?.clear();
          itemPricesArray?.clear();
          companyNameArray?.clear();
          sealArray?.clear();
          locationsArray?.clear();
          localityArray?.clear();
        }
        for (var i = 0; i < resultsArray.length; i++) {
          var image = resultsArray[i]['photo_250'] ?? "NA";
          imagesArray?.add(image);

          var title = resultsArray[i]['prd_name'] ?? "NA";
          titlesArray?.add(title);

          var phoneNo = resultsArray[i]['comp_contct'] ?? "NA";
          phoneArray?.add(phoneNo);

          // print("phone=$phoneNo");

          var itemPrices = resultsArray[i]['prd_price'];
          if (itemPrices == "" || itemPrices == null) {
            itemPricesArray?.add("Prices on demand");
          } else {
            itemPricesArray?.add(itemPrices);
          }

          var company = resultsArray[i]['COMPANY'] ?? "NA";
          companyNameArray?.add(company);

          var CUSTTYPE_WEIGHT1 = resultsArray[i]['CUSTTYPE_WEIGHT1'] ?? "NA";
          var tsCode = resultsArray[i]['tscode'] ?? "NA";
          sealArray?.add(getSupplierType(CUSTTYPE_WEIGHT1, tsCode));

          var city = resultsArray[i]['city_orig'] ?? "NA";
          var localityForAddress =
              resultsArray[i]['SDA_GLUSR_USR_LOCALITY'] ?? "NA";
          if (localityForAddress == "" || locationsArray == "NA")
            localityArray?.add(city);
          else if (city != "")
            localityArray?.add(city + " - " + localityForAddress);

          var locality = resultsArray[i]['city'] ?? "";
          locationsArray?.add("Deals in $locality");
        }
        print("resultsArray $locationsArray");
        setState(() {
          isLoading = false;
          items.addAll(resultsArray);
          // print(
          //     "items length=${items.length} $totalItemCount ${localityArray?.length}");
        });

        if (resultsArray.length > 0) if (currentPage > 1 &&
            totalItemCount > 10) {
          // if (!kIsWeb)
          // addBannerOrAd(end, "ADEMPTY");
          if (end > start) addBannerOrAd(items.length - 4, "PBRBANNER");
        } else if (currentPage == 1) {
          if (!kIsWeb && end > 7) {
            addBannerOrAd(2, "ADEMPTY");
            addBannerOrAd(7, "ADEMPTY");
          }
          print("end=$end");
          if (end >= 9) {
            addBannerOrAd(5, "isq_banner");
            addBannerOrAd(10, "PBRBANNER");
            addBannerOrAd(11, "RECENTPBRBANNER");
          }
        } else
          stop = true;

        print(
            "resultsArray=${items.length} ${resultsArray?.length} start=$start end=$end ,");
        if (currentPage == 1) EasyLoading.dismiss();
        DateTime now = DateTime.now();
        print("DateTime now = DateTime.now();${now.difference(then)}");
        scrolled = 1;
      }*/
    } catch (e) {
      // EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      log(e.toString());
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (items.length == 0) {
      itemCount = 0;
    } else {
      itemCount = items.length;
      // print("itemcounta=$itemCount");
    }
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
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: GestureDetector(
                        onTap: () {
                          Share.share(
                              'Hey, Check out these verified suppliers for ${widget.productName}! \n https://m.indiamart.com/impcat/${widget.productFname}.html \n\n via indiamart App (Download Now):https://e7d27.app.goo.gl/A97Q');
                        },
                        child: const Icon(
                          Icons.share,
                          color: Colors.black54,
                        ))),
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
                itemCount: itemCount + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == itemCount) {
                    print("index==$index $itemCount");
                    return (isLoading)
                        ? Center(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator()))
                        : Text("");
                  } else {
                    print("index==$index $itemCount");
                    if (titlesArray?[index] == "PBRBANNER") {
                      return PBRBanner(product_name: widget.productName);
                    } else if (titlesArray?[index] == "isq_banner") {
                      return MainPBRBanner(
                          productName: widget.productName, img: pbrimage);
                    } else if (titlesArray?[index] == "RECENTPBRBANNER") {
                      return LimitedChipsList();
                    } else if (titlesArray?[index] == "ADEMPTY") {
                      return AdClass();
                    } else {
                      return Card(
                        // elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Action
                          },
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
                                          locality:
                                              localityArray?[index] ?? "NA",
                                          location:
                                              locationsArray?[index] ?? "NA",
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
                                        companyName:
                                            companyNameArray?[index] ?? "",
                                        itemPrice:
                                            itemPricesArray?[index] ?? "NA",
                                        locality: localityArray?[index] ?? "NA",
                                        location:
                                            locationsArray?[index] ?? "NA",
                                        title: titlesArray?[index] ?? "NA",
                                        phone: phoneArray?[index] ?? "NA",
                                        seal: sealArray?[index] ?? "NA",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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

  Future addBannerOrAd(int pos, String value) async {
    imagesArray?.insert(pos, "");
    titlesArray?.insert(pos, value);
    itemPricesArray?.insert(pos, "");
    companyNameArray?.insert(pos, "");
    locationsArray?.insert(pos, "");
    localityArray?.insert(pos, "");
    phoneArray?.insert(pos, "");
    sealArray?.insert(pos, "");
    items.length += 1;
    // itemCount++;
  }

//
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  String getSupplierType(int custTypeWeight, String tsCode) {
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
            width: MediaQuery.of(context).size.width / 2 - 25,
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
      } else
        await makePhoneCall(call);
    } else
      await makePhoneCall(call);
  }
}

Future makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
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
      required this.seal})
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(widget.seal), fit: BoxFit.contain),
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
        const SizedBox(height: 10),
      ],
    );
  }
}

class Category {
  final String cnt;
  final List<CategoryGroup> grp;

  Category({required this.cnt, required this.grp});

  factory Category.fromJson(Map<String, dynamic> json) {
    List<CategoryGroup> groups = (json['grps']['grp'] as List)
        .map((groupJson) => CategoryGroup.fromJson(groupJson))
        .toList();

    return Category(
      cnt: json['grps']['cnt'],
      grp: groups,
    );
  }
}

class CategoryGroup {
  final String id;
  final String name;
  final String fname;
  final String type;
  final String sm;
  final String icon_v2;
  final String bgc_v2;
  final String img_v2;

  CategoryGroup({
    required this.id,
    required this.name,
    required this.fname,
    required this.type,
    required this.sm,
    required this.icon_v2,
    required this.bgc_v2,
    required this.img_v2,
  });

  factory CategoryGroup.fromJson(Map<String, dynamic> json) {
    return CategoryGroup(
      id: json['id'],
      name: json['name'],
      fname: json['fname'],
      type: json['type'],
      sm: json['sm'],
      icon_v2: json['icon_v2'],
      bgc_v2: json['bgc_v2'],
      img_v2: json['img_v2'],
    );
  }
}

class ProductModel {
  final int? indexOrig;
  final int? index;
  final int? isGenericFlag;
  final String? headerStatus;
  final String? stateName;
  final String? cityTier;
  final dynamic isDistrict;
  final int? supplierCountCity;
  final String? districtName;
  final int? ecomFilter;
  final String? cityLatitude;
  final String? cityLongitude;
  final String? cityCountryIso;
  final String? stateCode;
  final String? datatype;
  final String? outTotalUnqCount;
  final String? subcatFlanme;
  final String? isBrand;
  final int? isBusinessType;
  final String? priceCount;
  final String? outTotalCount;
  final List<dynamic>? standardProdArr;
  final List<dynamic>? relatedSearchWords;
  final List<Mcatdata>? mcatdata;
  final String? mcatgenricFlag;
  final String? mcatisgen;
  final List<BizWiseCount>? bizWiseCount;
  final List<Data>? data;

  ProductModel({
    required this.indexOrig,
    required this.index,
    required this.isGenericFlag,
    required this.headerStatus,
    required this.stateName,
    required this.cityTier,
    required this.isDistrict,
    required this.supplierCountCity,
    required this.districtName,
    required this.ecomFilter,
    required this.cityLatitude,
    required this.cityLongitude,
    required this.cityCountryIso,
    required this.stateCode,
    required this.datatype,
    required this.outTotalUnqCount,
    required this.subcatFlanme,
    required this.isBrand,
    required this.isBusinessType,
    required this.priceCount,
    required this.outTotalCount,
    required this.standardProdArr,
    required this.relatedSearchWords,
    required this.mcatdata,
    required this.mcatgenricFlag,
    required this.mcatisgen,
    required this.bizWiseCount,
    required this.data,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse the JSON and create an instance of ProductModel
    // You'll need to handle the list parsing for mcatdata, bizWiseCount, and data separately.
    // I'll provide an example for mcatdata.
    List<Mcatdata> mcatdataList = (json['mcatdata'] as List)
        .map((item) => Mcatdata.fromJson(item))
        .toList();

    List<BizWiseCount> bizWiseCountList = (json['biz_wise_count'] as List)
        .map((item) => BizWiseCount.fromJson(item))
        .toList();

    List<Data> dataList =
        (json['data'] as List).map((item) => Data.fromJson(item)).toList();

    return ProductModel(
      // Assign values here
      indexOrig: json["index_orig"],
      index: json["index"],
      isGenericFlag: json["is_generic_flag"],
      headerStatus: json["header_status"],
      stateName: json["state_name"],
      cityTier: json["city_tier"],
      isDistrict: json["is_district"],
      districtName: json["supplier_count_city"],
      supplierCountCity: json["district_name"],
      ecomFilter: json["ecom_filter"],
      cityLatitude: json["city_latitude"],
      cityLongitude: json["city_longitude"],
      mcatisgen: json["mcatisgen"],
      mcatgenricFlag: json["mcatgenric_flag"],
      standardProdArr: json["standard_prod_arr"],
      stateCode: json["state_code"],
      subcatFlanme: json["subcat_flanme"],
      cityCountryIso: json["city_country_iso"],
      datatype: json["datatype"],
      outTotalUnqCount: json["out_total_unq_count"],
      isBusinessType: json["is_business_type"],
      isBrand: json["is_brand"],
      priceCount: json["price_count"],
      outTotalCount: json["out_total_count"],
      relatedSearchWords: json["related_search_words"],
      bizWiseCount: bizWiseCountList,
      data: dataList,
      mcatdata: mcatdataList,
    );
  }
}

class Mcatdata {
  final int? cnt;
  final int? glcatMcatId;
  final String? glcatMcatName;
  final String? glcatMcatFlname;
  final int? glcatMcatIsGeneric;
  final int? glcatMcatAdultFlag;
  final int? prdSearchGlCityId;
  final int? iilDirRelMcatCityCnt;
  final String? glCityName;
  final String? glcatMcatImg1125X125;
  final int? relTypeFlag;
  final int? pmcatId;
  final String? pmcatName;
  final String? pmcatFlname;
  final int? iilDirRelMcatOfrCnt;
  final String? pmcatImg1125X125;
  final dynamic brandImg1125X125;

  Mcatdata({
    required this.cnt,
    required this.glcatMcatId,
    required this.glcatMcatName,
    required this.glcatMcatFlname,
    required this.glcatMcatIsGeneric,
    required this.glcatMcatAdultFlag,
    required this.prdSearchGlCityId,
    required this.iilDirRelMcatCityCnt,
    required this.glCityName,
    required this.glcatMcatImg1125X125,
    required this.relTypeFlag,
    required this.pmcatId,
    required this.pmcatName,
    required this.pmcatFlname,
    required this.iilDirRelMcatOfrCnt,
    required this.pmcatImg1125X125,
    required this.brandImg1125X125,
  });

  factory Mcatdata.fromJson(Map<String, dynamic> json) {
    return Mcatdata(
      cnt: json['CNT'],
      glcatMcatId: json['GLCAT_MCAT_ID'],
      glcatMcatName: json['GLCAT_MCAT_NAME'],
      glcatMcatFlname: json['GLCAT_MCAT_FLNAME'],
      glcatMcatIsGeneric: json['GLCAT_MCAT_IS_GENERIC'],
      glcatMcatAdultFlag: json['GLCAT_MCAT_ADULT_FLAG'],
      prdSearchGlCityId: json['PRD_SEARCH_GL_CITY_ID'],
      iilDirRelMcatCityCnt: json['IIL_DIR_REL_MCAT_CITY_CNT'],
      glCityName: json['GL_CITY_NAME'],
      glcatMcatImg1125X125: json['GLCAT_MCAT_IMG1_125X125'],
      relTypeFlag: json['REL_TYPE_FLAG'],
      pmcatId: json['PMCAT_ID'],
      pmcatName: json['PMCAT_NAME'],
      pmcatFlname: json['PMCAT_FLNAME'],
      iilDirRelMcatOfrCnt: json['IIL_DIR_REL_MCAT_OFR_CNT'],
      pmcatImg1125X125: json['PMCAT_IMG1_125X125'],
      brandImg1125X125: json['BRAND_IMG1_125X125'],
    );
  }
}

class BizWiseCount {
  final int? bizCnt;
  final int? prdSearchPrimaryBizId;

  BizWiseCount({
    required this.bizCnt,
    required this.prdSearchPrimaryBizId,
  });

  factory BizWiseCount.fromJson(Map<String, dynamic> json) {
    return BizWiseCount(
      bizCnt: json['BIZ_CNT'],
      prdSearchPrimaryBizId: json['PRD_SEARCH_PRIMARY_BIZ_ID'],
    );
  }
}

class Data {
  final String? allPls;
  final int? custtypeWeightOrig;
  final int? iilMcatProdGlcatMcatId;
  final int? primaryBizIdOrig;
  final String? pcItemDisplayName;
  final String? pcItemHindiName;
  final String? pcItemSecondaryName;
  final String? pcItemReviewFlag;
  final int? hasFprefCountry;
  final String? glusrCountryIso;
  final String? cntUserProducts;
  final int? glusrDistanceCity;
  final String? prdSearchGlcatMcatIdList;
  final int? myPageOrder;
  final int? rk;
  final int? iilMcatProdHnpdStatus;
  final int? rn;
  final int? sc;
  final int? so;
  final int? vef;
  final int? enqCount;
  final int? pageViews;
  final int? callCount;
  final String? enqCountNew;
  final String? pageViewsNew;
  final String? pmcatRank;
  final String? childRankFlag;
  final String? pnsFlag;
  final int? dloc;
  final String? childMcatAggr;
  final int? custtypeWeight1;
  final int? glId;
  final String? prdSearchEcomUrl;
  final String? prdSearchEcomIsActive;
  final String? ecomSourceBuyNowLogo;
  final int? iilDisplayFlag;
  final String? prdName;
  final String? city;
  final String? sdaGlusrUsrLocality;
  final String? district;
  final String? cityOrig;
  final String? fullAddress;
  final String? pcItemUrlName;
  final int? yearOfEstablishment;
  final String? companyLogo;
  final List<String>? companyVideo;
  final String? prdPrice;
  final String? prdCurrency;
  final String? quantity;
  final String? ecomStoreName;
  final String? ecomLandingUrl;
  final String? ecomCartUrl;
  final String? unit;
  final String? catFlname;
  final String? company;
  final String? compContctVal;
  final String? compContct;
  final String? standardPrice;
  final String? searchUrl;
  final String? tscode;
  final String? repeat;
  final List<String>? prdDocPath;
  final List<String>? prdVideoPath;
  final int? parentMcatStatus;
  final String? companylink;

  Data({
    required this.allPls,
    required this.custtypeWeightOrig,
    required this.iilMcatProdGlcatMcatId,
    required this.primaryBizIdOrig,
    required this.pcItemDisplayName,
    required this.pcItemHindiName,
    required this.pcItemSecondaryName,
    required this.pcItemReviewFlag,
    required this.hasFprefCountry,
    required this.glusrCountryIso,
    required this.cntUserProducts,
    required this.glusrDistanceCity,
    required this.prdSearchGlcatMcatIdList,
    required this.myPageOrder,
    required this.rk,
    required this.iilMcatProdHnpdStatus,
    required this.rn,
    required this.sc,
    required this.so,
    required this.vef,
    required this.enqCount,
    required this.pageViews,
    required this.callCount,
    required this.enqCountNew,
    required this.pageViewsNew,
    required this.pmcatRank,
    required this.childRankFlag,
    required this.pnsFlag,
    required this.dloc,
    required this.childMcatAggr,
    required this.custtypeWeight1,
    required this.glId,
    required this.prdSearchEcomUrl,
    required this.prdSearchEcomIsActive,
    required this.ecomSourceBuyNowLogo,
    required this.iilDisplayFlag,
    required this.prdName,
    required this.city,
    required this.sdaGlusrUsrLocality,
    required this.district,
    required this.cityOrig,
    required this.fullAddress,
    required this.pcItemUrlName,
    required this.yearOfEstablishment,
    required this.companyLogo,
    required this.companyVideo,
    required this.prdPrice,
    required this.prdCurrency,
    required this.quantity,
    required this.ecomStoreName,
    required this.ecomLandingUrl,
    required this.ecomCartUrl,
    required this.unit,
    required this.catFlname,
    required this.company,
    required this.compContctVal,
    required this.compContct,
    required this.standardPrice,
    required this.searchUrl,
    required this.tscode,
    required this.repeat,
    required this.prdDocPath,
    required this.prdVideoPath,
    required this.parentMcatStatus,
    required this.companylink,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      allPls: json['all_pls'],
      custtypeWeightOrig: json['custtype_weight_orig'],
      iilMcatProdGlcatMcatId: json['iil_mcat_prod_glcat_mcat_id'],
      primaryBizIdOrig: json['primary_biz_id_orig'],
      pcItemDisplayName: json['pc_item_display_name'],
      pcItemHindiName: json['pc_item_hindi_name'],
      pcItemSecondaryName: json['pc_item_secondary_name'],
      pcItemReviewFlag: json['pc_item_review_flag'],
      hasFprefCountry: json['has_fpref_country'],
      glusrCountryIso: json['glusr_country_iso'],
      cntUserProducts: json['cnt_user_products'],
      glusrDistanceCity: json['glusr_distance_city'],
      prdSearchGlcatMcatIdList: json['prd_search_glcat_mcat_id_list'],
      myPageOrder: json['my_page_order'],
      rk: json['rk'],
      iilMcatProdHnpdStatus: json['iil_mcat_prod_hnpd_status'],
      rn: json['rn'],
      sc: json['sc'],
      so: json['so'],
      vef: json['vef'],
      enqCount: json['enq_count'],
      pageViews: json['page_views'],
      callCount: json['call_count'],
      enqCountNew: json['enq_count_new'],
      pageViewsNew: json['page_views_new'],
      pmcatRank: json['PmcatRank'],
      childRankFlag: json['ChildRankFlag'],
      pnsFlag: json['PNSFlag'],
      dloc: json['Dloc'],
      childMcatAggr: json['ChildMcatAggr'],
      custtypeWeight1: json['CUSTTYPE_WEIGHT1'],
      glId: json['gl_id'],
      prdSearchEcomUrl: json['PRD_SEARCH_ECOM_URL'],
      prdSearchEcomIsActive: json['PRD_SEARCH_ECOM_IS_ACTIVE'],
      ecomSourceBuyNowLogo: json['ECOM_SOURCE_BUY_NOW_LOGO'],
      iilDisplayFlag: json['iil_display_flag'],
      prdName: json['prd_name'],
      city: json['city'],
      sdaGlusrUsrLocality: json['SDA_GLUSR_USR_LOCALITY'],
      district: json['district'],
      cityOrig: json['city_orig'],
      fullAddress: json['full_address'],
      pcItemUrlName: json['pc_item_url_name'],
      yearOfEstablishment: json['year_of_establishment'],
      companyLogo: json['company_logo'],
      companyVideo: List<String>.from(json['company_video']),
      prdPrice: json['prd_price'],
      prdCurrency: json['prd_currency'],
      quantity: json['quantity'],
      ecomStoreName: json['ecom_store_name'],
      ecomLandingUrl: json['ecom_landing_url'],
      ecomCartUrl: json['ecom_cart_url'],
      unit: json['unit'],
      catFlname: json['cat_flname'],
      company: json['COMPANY'],
      compContctVal: json['comp_contct_val'],
      compContct: json['comp_contct'],
      standardPrice: json['standardPrice'],
      searchUrl: json['search_url'],
      tscode: json['tscode'],
      repeat: json['repeat'],
      prdDocPath: List<String>.from(json['prd_doc_path']),
      prdVideoPath: List<String>.from(json['prd_video_path']),
      parentMcatStatus: json['PARENT_MCAT_STATUS'],
      companylink: json['companylink'],
    );
  }
}

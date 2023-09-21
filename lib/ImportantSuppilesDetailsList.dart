// ignore_for_file: must_be_immutable, use_build_context_synchronously, curly_braces_in_flow_control_structures

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
              cityIndex:clickedIndex,
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
      var code = json.decode(response.body)['CODE'];
      if (code == "402") {
        var msg = json.decode(response.body)['MESSAGE'];
        if(currentPage==1)
        EasyLoading.dismiss();
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



        if (resultsArray.length > 0)
          if (currentPage > 1 && totalItemCount > 10) {
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

        print("resultsArray=${items.length} ${resultsArray?.length} start=$start end=$end ,");
        if (currentPage == 1)
          EasyLoading.dismiss();
        DateTime now = DateTime.now();
        print("DateTime now = DateTime.now();${now.difference(then)}");
        scrolled = 1;
      }

    } catch (e) {
      // EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
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
                         ? Center(child: Padding(
                          padding:EdgeInsets.all(8),
                          child:CircularProgressIndicator())):Text("");
                    }
                   else{

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

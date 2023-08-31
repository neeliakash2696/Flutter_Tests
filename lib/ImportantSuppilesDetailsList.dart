// ignore_for_file: must_be_immutable, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tests/SearchFieldController.dart';
import 'package:flutter_tests/VoiceToTextConverter.dart';
import 'package:flutter_tests/adClass.dart';
import 'package:flutter_tests/pbr_banner.dart';
import 'package:flutter_tests/Fliters.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main_pbr_banner.dart';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;

enum ScreenLayout { details, list }

class ImportantSuppilesDetailsList extends StatefulWidget {
  @override
  ImportantSuppilesDetailsListState createState() =>
      ImportantSuppilesDetailsListState();
  String productName;
  ImportantSuppilesDetailsList(
      {Key? key,
      required this.productName,})
      : super(key: key);
}

class ImportantSuppilesDetailsListState
    extends State<ImportantSuppilesDetailsList>
    with AutomaticKeepAliveClientMixin {
  late String encodedQueryParam;
  List<String>? imagesArray = [];
  List<String>? titlesArray = [];
  List<String>? phoneArray = [];
  List<String>? itemPricesArray = [];
  List<String>? companyNameArray = [];
  List<String>? locationsArray = [];
  List<String>? localityArray = [];
  List<dynamic> resultsArray = [];
  var currentLayout = ScreenLayout.details;
  final ScrollController _scrollController = ScrollController();
  bool _isAtEnd = false;

  List<dynamic> items = [];

  var totalItemCount = 0;
  var itemCount = 0;

  late String pbrimage;

  bool stop = false;

  int scrolled = 1;

  int start = 0;
  int end = 0;

  int currentPage = 0;

  List<String> related=[];

  // View Did Load
  @override
  void initState() {
    super.initState();
    encodedQueryParam = encodeString(widget.productName);
    print(encodedQueryParam);
    currentPage = 1;
    start = 0;
    end = 9;
    getMoreDetails(encodedQueryParam, 0, 9, currentPage);
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
          if (end > totalItemCount) end = totalItemCount;
          if (stop == false) {
            currentPage += 1;
            getMoreDetails(encodedQueryParam, start, end, currentPage);
          } // Mark that you've reached the end
        });
      } else {
        setState(() {
          _isAtEnd = false; // Not at the end
        });
      }
    });
  }

  String encodeString(String? inputString) {
    var queryParamRaw = inputString ?? "";
    var encoded = queryParamRaw.replaceAll(" ", "%20");
    return encoded;
  }

  openFilters(bool isSellerType) async {
    print("related=$related");
    var selectedChip = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => Filters(
                  categoriesList: related,
                  isSellerType: isSellerType,
                  productIndex: 0,
                ),
            opaque: false,
            fullscreenDialog: true));

    if (selectedChip != null) {
      encodedQueryParam = encodeString(selectedChip[0]);
      widget.productName = selectedChip[0];
      // widget.productIndex = selectedChip[1];
      items.length = 0;
      getMoreDetails(encodedQueryParam, 0, 9, 1);
    }
  }

  openVoiceToTextConverter() async {
    var outputText = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => VoiceToTextConverter(
                  fromScreen: VoiceSearchFromScreen.impSuppliesList,
                ),
            opaque: false,
            fullscreenDialog: true));
    if (outputText != null && outputText != "") {
      encodedQueryParam = encodeString(outputText);
      widget.productName = outputText;
      items.length = 0;
      getMoreDetails(encodedQueryParam, 0, 9, 1);
    }
  }

  showSearchController() async {
    var outputText = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchFieldController(
                  fromScreen: SearchingFromScreen.impSuppliesList,
                )));
    if (outputText != null && outputText != "") {
      encodedQueryParam = encodeString(outputText);
      widget.productName = outputText;
      items.length = 0;
      getMoreDetails(encodedQueryParam, 0, 9, 1);
    }
  }

  getMoreDetails(String category, int start, int end, int currentPage) async {
    EasyLoading.show(status: 'Loading...');
    print(
        "start=$start and end=$end and item length=${items.length} currentpage=${currentPage}");
    try {
      String pathUrl =
          "https://mapi.indiamart.com/wservce/im/search/?biztype_data=&VALIDATION_GLID=136484661&APP_SCREEN_NAME=Search%20Products&options_start=${start}&options_end=${end}&AK=${FlutterTests.AK}&source=android.search&implicit_info_latlong=&token=imartenquiryprovider&implicit_info_cityid_data=70672&APP_USER_ID=136484661&implicit_info_city_data=jaipur&APP_MODID=ANDROID&q=${category}&modeId=android.search&APP_ACCURACY=0.0&prdsrc=0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&VALIDATION_USER_IP=117.244.8.217&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233";
      print("api=$pathUrl");
      http.Response response = await http.get(Uri.parse(pathUrl));
      var code = json.decode(response.body)['CODE'];
      if (code == "402") {
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
        resultsArray = json.decode(response.body)['results'];
        if (currentPage == 1) {
          dynamic live_mcats =
              json.decode(response.body)['guess']['guess']['live_mcats'];
          pbrimage = live_mcats[0]['smallimg'];
          for(var i=0;i<live_mcats.length;i++)
            related.add(live_mcats[i]['name']);
          print("pbrimage=$related");
          totalItemCount =
              json.decode(response.body)['total_results_without_repetition'];
          imagesArray?.clear();
          phoneArray?.clear();
          titlesArray?.clear();
          itemPricesArray?.clear();
          companyNameArray?.clear();
          locationsArray?.clear();
          localityArray?.clear();
        }
        for (var i = 0; i < resultsArray.length; i++) {
          var image = resultsArray[i]['fields']['large_image'];
          imagesArray?.add(image);

          var title = resultsArray[i]['fields']['title'];
          titlesArray?.add(title ?? "NA");

          var phoneNo = resultsArray[i]['fields']['pns'];
          phoneArray?.add(phoneNo ?? "NA");
          print("phoine=$phoneNo");
          var itemPrices = resultsArray[i]['fields']['itemprice'];
          var units = resultsArray[i]['fields']['moq_type'];
          if (itemPrices == "" || itemPrices == null) {
            itemPricesArray?.add("Prices on demand");
          } else {
            if (units == "" || units == null) {
              units = "units";
            }
            itemPricesArray?.add((itemPrices) + "/ " + (units));
          }
          var company = resultsArray[i]['fields']['tscode'];
          companyNameArray?.add(company ?? "NA");

          var city = resultsArray[i]['fields']['city'] ?? "";
          locationsArray?.add(city);

          var locality = resultsArray[i]['fields']['locality'] ?? "NA";
          localityArray?.add(locality);
        }
        setState(() {
          items.addAll(resultsArray);
          print(
              "items length=${items.length} $totalItemCount ${localityArray?.length}");
        });

        if (resultsArray.length > 0) if (currentPage > 1) {
          if (!kIsWeb) addBannerOrAd(end, "ADEMPTY");
          addBannerOrAd(start + 4, "PBRBANNER");
        } else if (currentPage == 1) {
          if (!kIsWeb) {
            addBannerOrAd(2, "ADEMPTY");
            addBannerOrAd(7, "ADEMPTY");
          }
          addBannerOrAd(5, "isq_banner");
          addBannerOrAd(10, "PBRBANNER");
        } else
          stop = true;

        print("resultsArray=${items.length} ${resultsArray?.length},");
        EasyLoading.dismiss();
        scrolled = 1;
        if (resultsArray.length > 0) {
          Flushbar(
            title: "DONE",
            message: "API HITTING DONE",
            flushbarStyle: FlushbarStyle.FLOATING,
            isDismissible: true,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
            boxShadows: const [
              BoxShadow(
                offset: Offset(0.0, 2.0),
                blurRadius: 3.0,
              )
            ],
          ).show(context);
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      Flushbar(
        title: "Error",
        message: e.toString(),
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
      // debugPrint(e.toString());
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (items.length - 1 < 0) {
      itemCount = 0;
    } else {
      itemCount = items.length - 1;
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
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
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
                    openFilters(true);
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
                    openFilters(false);
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
              ],
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int index) {
                  var inkWell = InkWell(
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
                                    image: CachedNetworkImageProvider(imagesArray?[
                                            index] ??
                                        "https://ik.imagekit.io/hpapi/harry.jpg"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                              Flexible(
                                child: Description(
                                    companyName: companyNameArray?[index] ?? "",
                                    itemPrice: itemPricesArray?[index] ?? "NA",
                                    locality: localityArray?[index] ?? "NA",
                                    location: locationsArray?[index] ?? "NA",
                                    title: titlesArray?[index] ?? "NA",
                                    phone: phoneArray?[index] ?? "NA"),
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
                                          color:
                                              Color.fromARGB(255, 103, 97, 97),
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
                                    image: CachedNetworkImageProvider(imagesArray?[
                                            index] ??
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
                  );

                  if (titlesArray?[index] == "PBRBANNER") {
                    return PBRBanner(product_name: widget.productName);
                  } else if (titlesArray?[index] == "isq_banner") {
                    return MainPBRBanner(
                        productName: widget.productName, img: pbrimage);
                  }
                  // else if (titlesArray?[index] == "ADEMPTY") {
                  //   return AdClass();
                  // }
                  else {
                    return Card(
                      // elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: inkWell,
                    );
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
    items.length += 1;
    // itemCount++;
  }

//
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
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
    final call = "tel:+91 $phoneNumber";
    if (!kIsWeb) {
      final permissionStatus = await Permission.phone.request();
      if (permissionStatus.isGranted) {
        if (await canLaunch(call)) {
          await FlutterPhoneDirectCaller.callNumber(phoneNumber);
        } else {
          throw 'Could not launch $call';
        }
      } else {
        if (await canLaunch(call)) {
          await launch(call);
        } else {
          throw 'Could not launch $call';
        }
      }
    } else {
      if (await canLaunch(call)) {
        await launch(call);
      } else {
        throw 'Could not launch $call';
      }
    }
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
  Description(
      {Key? key,
      required this.title,
      required this.itemPrice,
      required this.companyName,
      required this.location,
      required this.locality,
      required this.phone})
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
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/Location.png"),
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
                  (widget.location) + "${widget.locality}",
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
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/url_mp.png"),
                      fit: BoxFit.contain),
                ),
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                child: Text(
                  "Deals in ${widget.locality}",
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

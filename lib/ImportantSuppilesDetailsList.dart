// ignore: file_names
import 'dart:convert';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class ImportantSuppilesDetailsList extends StatefulWidget {
  @override
  ImportantSuppilesDetailsListState createState() =>
      ImportantSuppilesDetailsListState();
  String productName;
  ImportantSuppilesDetailsList({Key? key, required this.productName})
      : super(key: key);
}

class ImportantSuppilesDetailsListState
    extends State<ImportantSuppilesDetailsList> {
  late var encodedQueryParam;
  var test;
  List<String> imagesArray = [];
  List<String> titlesArray = [];
  // View Did Load
  @override
  void initState() {
    super.initState();
    encodedQueryParam = encodeString(widget.productName);
    print(encodedQueryParam);
    getProductDetails();
  }

  encodeString<String>(String inputString) {
    var queryParamRaw = widget.productName;
    var encoded = queryParamRaw.replaceAll(" ", "%20");
    return encoded;
  }

  getProductDetails() async {
    EasyLoading.show(status: 'Loading...');
    try {
      String pathUrl =
          "https://mapi.indiamart.com/wservce/im/search/?biztype_data=&VALIDATION_GLID=136484661&APP_SCREEN_NAME=Search%20Products&options_start=0&options_end=9&AK=eyJ0eXAiOiJKV1QiLCJhbGciOiJzaGEyNTYifQ.eyJpc3MiOiJVU0VSIiwiYXVkIjoiMSoxKjEqMiozKiIsImV4cCI6MTY5MjMzNzM0NCwiaWF0IjoxNjkyMjUwOTQ0LCJzdWIiOiIxMzY0ODQ2NjEiLCJjZHQiOiIxNy0wOC0yMDIzIn0.rtdlqKxpdYjKVHs1rKlw-htad96rk9rigeNUt10EcTI&source=android.search&implicit_info_latlong=&token=imartenquiryprovider&implicit_info_cityid_data=70672&APP_USER_ID=136484661&implicit_info_city_data=jaipur&APP_MODID=ANDROID&q=$encodedQueryParam&modeId=android.search&APP_ACCURACY=0.0&prdsrc=0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&VALIDATION_USER_IP=117.244.8.217&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233";
      http.Response response = await http.get(Uri.parse(pathUrl));
      if (response.statusCode == 200) {
        var x = json.decode(response.body)['results'];
        for (var i = 0; i < x.length; i++) {}
        var image = x[0]['more_results'][0]['large_image'];
        test = image;
        // dataArray = DataModel.fromJson(json.decode(response.body));
        setState(() {});
        EasyLoading.dismiss();
        // ignore: use_build_context_synchronously
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
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Notifications",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0xff432B40),
              fontSize: 16,
              fontFamily: 'HVD Fonts',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Color(0xff432B40),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  var inkWell = InkWell(
                    onTap: () {
                      // Action
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          height: 70,
                          width: 100,
                          alignment: Alignment.topCenter,
                          child: Image(
                            image: CachedNetworkImageProvider(test ??
                                "https://ik.imagekit.io/hpapi/harry.jpg"),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 5, 0),
                                child: Text(
                                  "All Life Portable Oxygen Can",
                                  style: TextStyle(
                                      color: Color(0xff432B40),
                                      fontSize: 16,
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
                                      height: 15,
                                      width: 15,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "images/indian_rupee.png"),
                                            fit: BoxFit.contain),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Text(
                                        "125/Piece",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xff432B40),
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
                                            image: AssetImage(
                                                "images/trustseal_supplier.png"),
                                            fit: BoxFit.contain),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Text(
                                        "Unatti Aerosols Product and Machines",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xff432B40),
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
                                            image: AssetImage(
                                                "images/Location.png"),
                                            fit: BoxFit.contain),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Text(
                                        "New Delhi-Badarpur",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xff432B40),
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
                                            image:
                                                AssetImage("images/url_mp.png"),
                                            fit: BoxFit.contain),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Text(
                                        "Deals in Noida",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xff432B40),
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
                          ),
                        ),
                      ],
                    ),
                  );
                  return Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: inkWell,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tests/InAppWebView.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tests/DataModels/LoginResponseDataModel';
import 'package:flutter_tests/DataModels/VerifyIPLocationDataModel';

import '../otp_veification.dart';

class LoginController extends StatefulWidget {
  @override
  State<LoginController> createState() => LoginControllerState();
}

class LoginControllerState extends State<LoginController> {
  bool checkStatus = false;
  TextEditingController loginTextField = TextEditingController();
  TextEditingController countrySearchTextFiled = TextEditingController();
  var countriesData;
  var results;
  bool searching = false;
  String currentFlag =
      "http://imghost.indiamart.com/country-flags/small/in_flag_s.png";
  String countryCode = "91";
  String countryId = "IN";
  String currentCountry = "India";
  bool isIndian = true;
  var currentPlatform = "";

  late LoginResponse loginData;
  late GeoLocationResponse verifyIpData;

  StreamController dialogStreamController = StreamController.broadcast();
  Stream get dialogStream => dialogStreamController.stream;
  Function get dialogSink => dialogStreamController.sink.add;

  @override
  void initState() {
    super.initState();
    readJson();
    getPlatform();
  }

  @override
  void dispose() {
    dialogStreamController.close();
    super.dispose();
  }

  triggerOTP(String platform, String countryId, String country,
      String countryCode, String textFieldValue, String userIp) async {
    EasyLoading.show(status: 'Sending OTP...');
    var requiredParam = "";
    var process = "";
    if (isIndian) {
      requiredParam = "mobile_num";
    } else {
      requiredParam = "email";
    }
    if (Platform.isIOS) {
      process = "OTP_Screen_Fusion";
    } else {
      process = "OTP_Screen_Android";
    }
    String pathUrl =
        "https://mapi.indiamart.com/wservce/users/OTPverification/?process=$process&flag=OTPGen&user_country=$countryId&APP_SCREEN_NAME=OtpEnterMobileNumber&USER_IP_COUNTRY=$country&modid=$platform&token=imobile@15061981&APP_USER_ID=&APP_MODID=$platform&user_mobile_country_code=$countryCode&$requiredParam=$textFieldValue&APP_ACCURACY=0.0&USER_IP_COUNTRY_ISO=$countryId&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&USER_IP=$userIp&app_version_no=13.2.2_T1&user_updatedusing=OTPfrom%20$platform%20App";
    print(pathUrl);
    http.Response response = await http.post(Uri.parse(pathUrl));
    Map<String, dynamic> data = json.decode(response.body);
    loginData = LoginResponse.fromJson(data);
    if (loginData.response.code == "200") {
      // Success
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OTP_Verification(
                mobNo: loginTextField.text,
                glusrid: loginData.response.glusrid ?? "",
                isIndian: isIndian,
            country: country,
            countryCode: countryCode,
            countryId: countryId,
            platform: platform,
            process: process,
            requiredParam: requiredParam,
              )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "${loginData.response.message}\n${loginData.response.error}")));
    }
    EasyLoading.dismiss();
  }

  verifyIpCountry(String creds) async {
    var platform = "";
    if (Platform.isIOS) {
      platform = "IOS";
    } else if (Platform.isAndroid) {
      platform = "Android";
    } else if (kIsWeb) {
      platform = "Web";
    }
    var requiredParam = "";
    if (isIndian) {
      requiredParam = "mobile_num";
    } else {
      requiredParam = "email";
    }
    String pathUrl =
        "http://geoip.imimg.com/api/location.php?modid=$platform&token=imobile@15061981&AK&app_version_no=13.2.2_T1&VALIDATION_GLID&APP_MODID=$platform&isGuestUser=0&$requiredParam=$creds&VALIDATION_USER_IP&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&APP_USER_ID&APP_ACCURACY=0.0";
    print(pathUrl);
    try {
      http.Response response = await http.post(Uri.parse(pathUrl));
      Map<String, dynamic> data = json.decode(response.body);
      verifyIpData = GeoLocationResponse.fromJson(data);
      print(verifyIpData.response.data.geoipCountryName);
      if (verifyIpData.response.code == 200) {
        if (isIndian &&
            verifyIpData.response.data.geoipCountryName == "India") {
          triggerOTP(
              currentPlatform,
              countryId,
              currentCountry,
              countryCode,
              loginTextField.text,
              verifyIpData.response.data.geoipIpAddress.toString());
        } else {
          showAlert();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "${verifyIpData.response.status}\n${verifyIpData.response.message}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  validateAndSendOTP() {
    if (loginTextField.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your Credentials")));
    } else {
      if (checkStatus == true) {
        verifyIpCountry(loginTextField.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please Accept Terms and Privacy Policy")));
      }
    }
  }

  getPlatform() {
    if (Platform.isAndroid) {
      currentPlatform = "ANDROID";
    } else if (Platform.isIOS) {
      currentPlatform = "Ios";
    } else if (kIsWeb) {
      currentPlatform = "WEB";
    }
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/countrylist.json');
    countriesData = await json.decode(response);
  }

  showAlert() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Alert'),
                content: const Text(
                    'It seems you are outside India.\nPress Ok to get OTP on email'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ]));
  }

  showCountries() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder(
            initialData: countriesData,
            stream: dialogStream,
            builder: (context, snapshot) {
              return SimpleDialog(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onSubmitted: (value) {
                                  // keyboard done action
                                  Navigator.pop(context);
                                },
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                autofocus: false,
                                onChanged: (searchingText) {
                                  if (searchingText.isNotEmpty) {
                                    searching = true;
                                    results = countriesData
                                        .where((elem) =>
                                            elem['cnname']
                                                .toString()
                                                .toLowerCase()
                                                .contains(searchingText
                                                    .toLowerCase()) ||
                                            elem['cncode']
                                                .toString()
                                                .toLowerCase()
                                                .contains(searchingText
                                                    .toLowerCase()))
                                        .toList();
                                    dialogSink(results);
                                  } else {
                                    searching = false;
                                    results = countriesData;
                                    dialogSink(results);
                                  }
                                },
                                onEditingComplete: () {},
                                onTapOutside: (event) {},
                                onTap: () {},
                                controller: countrySearchTextFiled,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  labelText: "Search Country",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  contentPadding: const EdgeInsets.all(8),
                                  filled: true,
                                  fillColor:
                                      const Color.fromRGBO(233, 229, 229, 1),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 13, 92, 229)),
                                ),
                              ),
                            )
                          ],
                        ),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return SimpleDialogOption(
                                onPressed: () {
                                  currentFlag = snapshot.data[index]['cflag'];
                                  countryCode = snapshot.data[index]['cncode'];
                                  countryId = snapshot.data[index]['cniso'];
                                  currentCountry =
                                      snapshot.data[index]['cnname'];
                                  loginTextField.text = "";
                                  if (countryCode == "91") {
                                    isIndian = true;
                                  } else {
                                    isIndian = false;
                                  }
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image(
                                      image: CachedNetworkImageProvider(
                                          searching == true
                                              ? results[index]['cflag']
                                              : snapshot.data[index]['cflag']),
                                      fit: BoxFit.fill,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(searching == true
                                        ? results[index]['cnname']
                                        : snapshot.data[index]['cnname']),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            searching == true
                                                ? results[index]['cncode']
                                                : snapshot.data[index]
                                                    ['cncode'],
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          )),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: searching == true
                                ? results.length
                                : snapshot.data.length),
                      ],
                    ),
                  )
                ],
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) => KeyboardDismisser(
          gestures: const [
            GestureType.onTap,
            GestureType.onPanUpdateDownDirection,
          ],
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.teal,
              toolbarHeight: 1,
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 60,
                            width: 200,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("images/indiamartLogo.png"),
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(isIndian == true
                          ? "Please enter your 10 digit mobile number to begin"
                          : "Enter your e-mail address to help us begin"),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                        height: 70,
                        width: MediaQuery.of(context).size.width - 20,
                        child: InkWell(
                          onTap: () {
                            countrySearchTextFiled.text = "";
                            searching = false;
                            results = countriesData;
                            dialogSink(results);
                            showCountries();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Image(
                                  image: NetworkImage(currentFlag),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "+$countryCode",
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded),
                              const VerticalDivider(
                                color: Colors.black,
                              ),
                              Expanded(
                                child: TextField(
                                  textInputAction: TextInputAction.go,
                                  keyboardType: isIndian
                                      ? TextInputType.number
                                      : TextInputType.emailAddress,
                                  autocorrect: false,
                                  autofocus: true,
                                  onChanged: (searchingText) {},
                                  onEditingComplete: () {},
                                  onTapOutside: (event) {},
                                  onTap: () {},
                                  controller: loginTextField,
                                  decoration: InputDecoration(
                                    labelText: isIndian
                                        ? "Enter your Mobile number."
                                        : "Please Enter your Email Address",
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                              "Don't worry! Your details are safe with us."),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("images/loginShield.png"),
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                                value: checkStatus,
                                activeColor: Colors.teal,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkStatus = value ?? false;
                                  });
                                }),
                            const Text("I accept all the "),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => webview_class(
                                        title: "",
                                        initialUrl:
                                            "https://m.indiamart.com/terms-of-use.html",
                                        navMode: '1',
                                      ),
                                    ));
                              },
                              child: Text(
                                "Terms",
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.grey,
                                  decorationThickness: 1,
                                  decorationStyle: TextDecorationStyle.dashed,
                                ),
                              ),
                            ),
                            const Text(" and "),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => webview_class(
                                        title: "",
                                        initialUrl:
                                            "https://m.indiamart.com/privacy-policy.html",
                                        navMode: '1',
                                      ),
                                    ));
                              },
                              child: Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.grey,
                                  decorationThickness: 1,
                                  decorationStyle: TextDecorationStyle.dashed,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      print("Next tapped");
                      validateAndSendOTP();
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.teal,
                      child: const Center(
                          child: Text(
                        "NEXT",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600),
                      )),
                    ),
                  )
                ],
              ),
            ),
          ));
}

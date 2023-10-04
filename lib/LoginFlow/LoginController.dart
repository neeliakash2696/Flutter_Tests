// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tests/DataModels/LoginResponseDataModel';

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

  @override
  void initState() {
    super.initState();
    readJson();
    getPlatform();
  }

  triggerOTP(String platform, String countryId, String country,
      String countryCode, String textFieldValue) async {
    EasyLoading.show(status: 'Sending OTP...');
    var requiredParam = "";
    if (isIndian) {
      requiredParam = "mobile_num";
    } else {
      requiredParam = "email";
    }
    String pathUrl =
        "https://mapi.indiamart.com/wservce/users/OTPverification/?process=OTP_Screen_$platform&flag=OTPGen&user_country=$countryId&APP_SCREEN_NAME=OtpEnterMobileNumber&USER_IP_COUNTRY=$country&modid=$platform&token=imobile@15061981&APP_USER_ID=&APP_MODID=$platform&user_mobile_country_code=$countryCode&$requiredParam=$textFieldValue&APP_ACCURACY=0.0&USER_IP_COUNTRY_ISO=$countryId&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&USER_IP=49.36.221.59&app_version_no=13.2.2_T1&user_updatedusing=OTPfrom%20$platform%20App";
    print(pathUrl);
    http.Response response = await http.get(Uri.parse(pathUrl));
    Map<String, dynamic> data = json.decode(response.body);
    loginData = LoginResponse.fromJson(data);
    if (loginData.response.code == "200") {
      // Success
      print(loginData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "${loginData.response.message}\n${loginData.response.error}")));
    }
    EasyLoading.dismiss();
  }

  validateAndSendOTP() {
    if (loginTextField.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your Credentials")));
    } else {
      if (checkStatus == true) {
        triggerOTP(currentPlatform, countryId, currentCountry, countryCode,
            loginTextField.text);
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
      currentPlatform = "iOS";
    } else if (kIsWeb) {
      currentPlatform = "WEB";
    }
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/countrylist.json');
    countriesData = await json.decode(response);
  }

  showCountries() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
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
                          textInputAction: TextInputAction.search,
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
                                          .contains(
                                              searchingText.toLowerCase()) ||
                                      elem['cncode']
                                          .toString()
                                          .toLowerCase()
                                          .contains(
                                              searchingText.toLowerCase()))
                                  .toList();
                              setState(() {});
                              print(results);
                            } else {
                              searching = false;
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
                            fillColor: const Color.fromRGBO(233, 229, 229, 1),
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
                            currentFlag = countriesData[index]['cflag'];
                            countryCode = countriesData[index]['cncode'];
                            countryId = countriesData[index]['cniso'];
                            currentCountry = countriesData[index]['cnname'];
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
                                        : countriesData[index]['cflag']),
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(searching == true
                                  ? results[index]['cnname']
                                  : countriesData[index]['cnname']),
                              Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      searching == true
                                          ? results[index]['cncode']
                                          : countriesData[index]['cncode'],
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: searching == true
                          ? results.length
                          : countriesData.length),
                ],
              ),
            )
          ],
        );
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
                      const Text(
                          "Please enter your 10 digit mobile number to begin"),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                        height: 70,
                        width: MediaQuery.of(context).size.width - 20,
                        child: InkWell(
                          onTap: () {
                            showCountries();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: NetworkImage(currentFlag),
                                fit: BoxFit.fill,
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
                                print("Show terms");
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
                                print("Show Privacy policy");
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

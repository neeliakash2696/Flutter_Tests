// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously, sort_child_properties_last

import 'dart:convert';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:account_picker/account_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tests/LoginFlow/DetailsRequest.dart';
import 'package:flutter_tests/DataModels/UserDetailSyncModel.dart';
import 'package:flutter_tests/LoginFlow/LoginController.dart';
import 'package:flutter_tests/view_categories.dart';
import 'package:http/http.dart' as http;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataModels/VerifyOTPDataModel.dart';

class OTP_Verification extends StatefulWidget {
  String mobNo;
  String glusrid;
  bool isIndian;
  String process;
  String countryId;
  String country;
  String platform;
  String requiredParam;
  String countryCode;
  String ipCountry;
  String ipAddress;
  OTP_Verification(
      {required this.mobNo,
      required this.glusrid,
      required this.isIndian,
      required this.platform,
      required this.process,
      required this.country,
      required this.countryId,
      required this.requiredParam,
      required this.countryCode,
      required this.ipCountry,
      required this.ipAddress});

  @override
  State<OTP_Verification> createState() => _OTP_VerificationState();
}

class _OTP_VerificationState extends State<OTP_Verification> with CodeAutoFill {
  bool _isVisible = true;
  late FocusNode otp1;
  late FocusNode otp2;
  late FocusNode otp3;
  late FocusNode otp4;
  late VerifyOTP loginData1;
  late UDS uds;
  String _code="";
  String authkey = "";
  bool clear = false;

  String codeValue = "";

  @override
  void initState() {
    otp1 = FocusNode();
    otp2 = FocusNode();
    otp3 = FocusNode();
    otp4 = FocusNode();
    listenOtp();
    super.initState();
  }

  @override
  void dispose() {
    otp1.dispose();
    otp2.dispose();
    otp3.dispose();
    otp4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyboardDismisser(
          gestures: const [
            GestureType.onTap,
            GestureType.onPanUpdateDownDirection,
          ],
          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 1,
                title: Center(
                    child: Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  // color: Colors.white,
                  alignment: Alignment.center,
                  child: Center(
                    child: Container(
                      height: 30,
                      // width: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/indiamartLogo.png"),
                            fit: BoxFit.contain),
                      ),
                    ),
                  ),
                )),
              ),
              backgroundColor: Colors.white,
              body: Stack(children: [
                WillPopScope(
                  onWillPop: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            LoginController(mobNo: widget.mobNo)));
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const VerticalDivider(
                            width: 10,
                            thickness: 10,
                          ),
                          Center(
                            child: widget.isIndian
                                ? const Text(
                                    "You will receive an OTP (One Time Password) on your mobile number",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15),
                                  )
                                : const Text(
                                    "You will receive an OTP (One Time Password) on your e-mail address",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15),
                                  ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.isIndian
                                    ? Text(
                                        "+91-${widget.mobNo}",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        "${widget.mobNo}",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginController(
                                                    mobNo: widget.mobNo)));
                                  },
                                  child: Text(
                                    "Not You?",
                                    style: TextStyle(
                                        color: Colors.teal[400], fontSize: 15),
                                  ),
                                ),
                              ],
                            ),

                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(80,0,80,0),
                              child: PinFieldAutoFill(
                                cursor:Cursor(color: Colors.teal,width: 2,height: 25,enabled: true) ,
                                currentCode: codeValue,
                                decoration: UnderlineDecoration(
                                  gapSpace: 5,
                                  textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                                  colorBuilder: FixedColorBuilder(Colors.teal),
                                ),
                                codeLength: 4,
                                onCodeChanged: (code) {
                                  print("onCodeChanged $code");
                                  setState(() {
                                    codeValue = code.toString();
                                    authkey=code??"";
                                  });
                                },
                                onCodeSubmitted: (val) {
                                  print("onCodeSubmitted $val");
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TweenAnimationBuilder(
                            tween: widget.isIndian
                                ? Tween(begin: 60.0, end: 0)
                                : Tween(begin: 150.0, end: 0),
                            duration: widget.isIndian
                                ? const Duration(seconds: 60)
                                : const Duration(seconds: 150),
                            builder: (context, value, child) {
                              if (value > 1)
                                // ignore: curly_braces_in_flow_control_structures
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        "The OTP will expire in ${value.toInt()} seconds",
                                        style: const TextStyle(),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        Image.asset(
                                          'images/otp_verification_auto_fetching_image.png',
                                          // width: 150,
                                          height: 300,
                                          fit: BoxFit.cover,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              80, 130, 0, 0),
                                          child: Column(
                                            children: [
                                              Container(
                                                  width: 140,
                                                  // height: 40,
                                                  // color: Colors.black.withOpacity(0.5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[400],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  // / Semi-transparent black color
                                                  child: const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 15, 10, 15),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Fetching',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15),
                                                          ),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          SpinKitPulse(
                                                            color: Colors
                                                                .white, // Adjust the color
                                                            size:
                                                                10.0, // Adjust the size
                                                            duration: Duration(
                                                                seconds: 1),
                                                          ),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          SpinKitPulse(
                                                            color: Colors
                                                                .white, // Adjust the color
                                                            size:
                                                                16.0, // Adjust the size
                                                            duration: Duration(
                                                                seconds: 1),
                                                          ),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          SpinKitPulse(
                                                            color: Colors
                                                                .white, // Adjust the color
                                                            size: 20.0,
                                                            duration: Duration(
                                                                seconds:
                                                                    1), // Adjust the size
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                              Container(
                                                height: 15,
                                                child: Image.asset(
                                                  'images/triangle_otp_verification.png',
                                                  // width: 150,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                );
                              else {
                                return Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isVisible =
                                                false; // Toggle visibility on tap
                                          });
                                        },
                                        child: _isVisible
                                            ? Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      apiCall(
                                                          "https://mapi.indiamart.com/wservce/users/OTPverification/?process=${widget.process}&flag=OTPGen&user_country=${widget.countryId}&APP_SCREEN_NAME=OtpEnterMobileNumber&USER_IP_COUNTRY=${widget.country}&modid=${widget.platform}&token=imobile@15061981&APP_USER_ID=&APP_MODID=${widget.platform}&user_mobile_country_code=${widget.countryCode}&${widget.requiredParam}=${widget.mobNo}&APP_ACCURACY=0.0&USER_IP_COUNTRY_ISO=${widget.countryId}&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&USER_IP=49.36.221.59&app_version_no=13.2.2_T1&user_updatedusing=OTPfrom%20${widget.platform}%20App");
                                                      setState(() {
                                                        clear = true;
                                                        hideWidet();
                                                      });
                                                      listenOtp();
                                                      print(
                                                          "visibility=$_isVisible");
                                                    },
                                                    child: const Text(
                                                      "Request OTP again",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.orange[300]),
                                              )
                                            : TweenAnimationBuilder(
                                                tween: widget.isIndian
                                                    ? Tween(begin: 60.0, end: 0)
                                                    : Tween(
                                                        begin: 150.0, end: 0),
                                                duration: widget.isIndian
                                                    ? const Duration(
                                                        seconds: 60)
                                                    : const Duration(
                                                        seconds: 150),
                                                builder:
                                                    (context, value, child) {
                                                  if (value > 1) {
                                                    clear = false;
                                                    return Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text(
                                                            "Auto Fetching the OTP"),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          height: 15,
                                                          width: 15,
                                                          child:
                                                              const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.teal,
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  } else
                                                    return const Text("");
                                                }),
                                      ),
                                    )
                                  ],
                                );
                              }
                              ;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Container(
                        height: 50,
                        color: Colors.teal[400],
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginController(
                                                    mobNo: widget.mobNo)));
                                  },
                                  child: const Text(
                                    "PREVIOUS",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  )),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                              child: GestureDetector(
                                  onTap: () async {
                                    if (authkey.length == 4)
                                      apiCall(
                                          "https://mapi.indiamart.com/wservce/users/OTPverification/?user_ip=${widget.ipAddress}&flag=OTPVer&verify_process=Online&user_country=IN&APP_SCREEN_NAME=Default-Buyer&verify_screen=${widget.platform}%20VERIFICATION%20THROUGH%20OTP&auth_key=$authkey&modid=${widget.platform}&token=imobile@15061981&APP_USER_ID=&APP_MODID=${widget.platform}&user_mobile_country_code=91&mobile_num=${widget.mobNo}&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=${widget.glusrid}&ScreenName=OtpVerification&app_version_no=13.2.2_T1");
                                    else
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text("Enter a valid OTP")));
                                  },
                                  child: const Text("NEXT",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17))),
                            )
                          ],
                        )),
                  ),
                ),
              ])));

  void hideWidet() {
    _isVisible = false;
  }

  void apiCall(String pathUrl) async {
    EasyLoading.show(status: "Verifying OTP...");
    print("pathUrl=$pathUrl");
    http.Response response = await http.get(Uri.parse(pathUrl));
    print("response=$response");
    Map<String, dynamic> data = json.decode(response.body);
    print("response.body${response.body}");
    EasyLoading.dismiss();
    if (pathUrl.contains("flag=OTPVer")) {
      loginData1 = VerifyOTP.fromJson(data);
      if (loginData1.response.code == "200") {
        print("ak check${loginData1.response.loginData?.imIss.AK}");
        // Success
        apiCall(
            "https://mapi.indiamart.com/wservce/users/detail/?VALIDATION_GLID=${widget.glusrid}&APP_SCREEN_NAME=Default-Seller&AK=${loginData1.response.loginData?.imIss.AK}&modid=${widget.platform}&token=imobile@15061981&APP_USER_ID=${widget.glusrid}&APP_MODID=${widget.platform}&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=${widget.glusrid}&logo=1&VALIDATION_USER_IP=${widget.ipAddress}&app_version_no=13.2.2_S1&others=glusr_usr_latitude,glusr_usr_longitude,glusr_usr_membersince,glusr_listing_status_reason&VALIDATION_USERCONTACT=${widget.mobNo}");
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              content: Text(
                'Please enter correct OTP',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              title: Text(
                'OTP Verification failed\n',
                style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                CupertinoDialogAction(
                    child: Text(
                      'RESEND',
                      style: TextStyle(
                          color: Colors.teal,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      OtpTextField(
                        clearText: true,
                      );
                      apiCall(
                          "https://mapi.indiamart.com/wservce/users/OTPverification/?process=${widget.process}&flag=OTPGen&user_country=${widget.countryId}&APP_SCREEN_NAME=OtpEnterMobileNumber&USER_IP_COUNTRY=${widget.country}&modid=${widget.platform}&token=imobile@15061981&APP_USER_ID=&APP_MODID=${widget.platform}&user_mobile_country_code=${widget.countryCode}&${widget.requiredParam}=${widget.mobNo}&APP_ACCURACY=0.0&USER_IP_COUNTRY_ISO=${widget.countryId}&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&USER_IP=${widget.ipAddress}&app_version_no=13.2.2_T1&user_updatedusing=OTPfrom%20${widget.platform}%20App");
                      Navigator.of(context).pop();
                    }),
                CupertinoDialogAction(
                    child: Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.teal,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            );
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "${loginData1.response.message}\n${loginData1.response.error}")));
      }
    } else if (pathUrl.contains("users/detail/")) {
      uds = UDS.fromJson(data);
      if (!checkIfCodeExists(uds.code)) {
        print(
            "name,lastname,email=${uds.firstName},${uds.lastName},${uds.email1}");
        FocusScope.of(context).unfocus();
        String ak = loginData1.response.loginData?.imIss.AK ?? "";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("AK", ak);
        // saveDetails(uds, ak);
        prefs.setString("glid", widget.glusrid);
        prefs.setString("ipAddress", widget.ipAddress);
        if (widget.isIndian) {
          prefs.setString("Mobile", widget.mobNo);
        }
        if (uds.firstName == "" ||
            uds.lastName == "" ||
            uds.email1 == "" ||
            uds.city == "")
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => DetailsRequest(
                    fname: uds.firstName,
                    lname: uds.lastName,
                    email: uds.email1,
                    city: uds.city,
                    isIndian: widget.isIndian,
                    creds: widget.mobNo,
                    ipCountry: widget.ipCountry,
                    glId: widget.glusrid,
                    ipAddress: widget.ipAddress,
                  )));
        else {
          ak = loginData1.response.loginData?.imIss.AK ?? "";
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ViewCategories()));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text("Verification Successful Welcome ${uds.firstName}")));
        }
      }
    }
  }

  bool checkIfCodeExists(String code) {
    String codeArray = "403,412,204,400";

    try {
      List<String> codeList = codeArray.split(',');
      if (codeList.contains(code)) {
        return true;
      }
    } catch (e) {
      print('Exception in retrieving codes: $e');
    }
    return false;
  }

  void saveDetails(UDS uds, String ak) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', '${uds.firstName} ${uds.lastName}');
    sharedPreferences.setString('FName', uds.firstName);
    sharedPreferences.setString('LName', uds.lastName);
    sharedPreferences.setString('UserContact', widget.mobNo);
    sharedPreferences.setString('Mobile', uds.mobile1);
    sharedPreferences.setString('Email', uds.email1);
    sharedPreferences.setString('City', uds.city);
    sharedPreferences.setString('glid', uds.glid);
    sharedPreferences.setString('AK', ak);
    sharedPreferences.setString('CountryISO', uds.countryIso);
    sharedPreferences.setString('pnsNo', uds.pnsNo);
    sharedPreferences.setString('pnsRatio', uds.pnsRatio);
    sharedPreferences.setInt('MEMBER_SINCE', uds.glusrUsrMembersince);
    sharedPreferences.setString('GLUSR_ENABLED_FLAG', uds.glusrUsrApprov);
    sharedPreferences.setString('COMPANYNAME', uds.companyName);
    sharedPreferences.setString('CONTACT_ADDRESS', uds.contactAddress);
    sharedPreferences.setString('DISTRICT', uds.glusrUsrDistrict);
  }

  void listenOtp() async {
    await SmsAutoFill().unregisterListener();
    listenForCode();
    await SmsAutoFill().listenForCode;
    print("OTP listen Called");
  }

  @override
  void codeUpdated() {

  }



}

class OtpInputFields extends StatefulWidget {
  @override
  _OtpInputFieldsState createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<OtpInputFields> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  int _otpLength = 4; // Assuming OTP is 4 digits

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _addFocusListeners();
  }

  void _addFocusListeners() {
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.isEmpty && i > 0) {
          FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _otpLength; i++) {
      _focusNodes[i].dispose();
      _controllers[i].dispose();
    }
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_otpLength, (index) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Container(
              width: 40.0,
              height: 40.0,
              // ignore: sort_child_properties_last
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                // maxLength: 1,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  if (value.isNotEmpty && index < _otpLength - 1) {
                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.teal, width: 2)),
              ),
            ));
      }),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Your main content goes here
        Container(
          width: 100.0,
          height: 100.0,
          color: Colors.white, // Adjust the background color if needed
          child: const Center(
            child: Text(
              'Your Content',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
        // Loading indicator overlay
        const Positioned.fill(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.teal), // Adjust the color
            ),
          ),
        ),
      ],
    );
  }
}

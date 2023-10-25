// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:account_picker/account_picker.dart';
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
import 'package:sms_autofill/sms_autofill.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataModels/UserDetailSyncModel.dart';
import '../DataModels/VerifyTruecallerDataModel.dart';
import '../view_categories.dart';
import 'DetailsRequest.dart';
import 'otp_veification.dart';

class LoginController extends StatefulWidget {
  String mobNo;
  LoginController({required this.mobNo});
  @override
  State<LoginController> createState() => LoginControllerState();
}

class LoginControllerState extends State<LoginController> {
  String _phoneNumber = "";
  bool checkStatus = true;
  TextEditingController loginTextField = TextEditingController();
  FocusNode _focusNode = FocusNode();
  TextEditingController countrySearchTextFiled = TextEditingController();
  var countriesData;
  var results;
  late VerifyTruecallerDataModel loginData1;
  late UDS uds;
  bool searching = false;
  String currentFlag =
      "http://imghost.indiamart.com/country-flags/small/in_flag_s.png";
  String countryCode = "91";
  String countryId = "IN";
  String currentCountry = "India";
  bool isIndian = true;
  var currentPlatform = "";
  String ipCountry = "";
  String ipAddress = "";

  late LoginResponse loginData;
  late GeoLocationResponse verifyIpData;
  late Stream<TruecallerSdkCallback>? _stream;
  StreamController dialogStreamController = StreamController.broadcast();

  var glid = "";

  Stream get dialogStream => dialogStreamController.stream;

  Function get dialogSink => dialogStreamController.sink.add;
  static const Color otpButtonColor = Color(0xFF00FF00);

  @override
  void initState() {
    super.initState();
    readJson();
    getPlatform();
    if (widget.mobNo != "");
    {
      loginTextField.text = widget.mobNo;
    }

    _stream = TruecallerSdk.streamCallbackData;
    TruecallerSdk.initializeSDK(
      sdkOptions: TruecallerSdkScope.SDK_OPTION_WITH_OTP,
      consentTitleOptions: TruecallerSdkScope.SDK_CONSENT_TITLE_LOG_IN,
      footerType: TruecallerSdkScope.FOOTER_TYPE_CONTINUE,
      consentMode: TruecallerSdkScope.CONSENT_MODE_BOTTOMSHEET,
      loginTextPrefix: TruecallerSdkScope.LOGIN_TEXT_PREFIX_TO_CONTINUE,
      loginTextSuffix: TruecallerSdkScope.LOGIN_TEXT_SUFFIX_PLEASE_LOGIN,
      ctaTextPrefix: TruecallerSdkScope.CTA_TEXT_PREFIX_CONTINUE_WITH,
      // buttonColor: otpButtonColor,
    );
    // TruecallerSdk.isUsable.then((isUsable) {
      getTruecaller();
    // });
  }

  @override
  void dispose() {
    dialogStreamController.close();
    widget.mobNo = "";
    loginTextField.dispose();
    countrySearchTextFiled.dispose();
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
    if (!kIsWeb) {
      if (Platform.isIOS) {
        process = "OTP_Screen_Fusion";
      } else {
        process = "OTP_Screen_Android";
      }
    } else {
      process = "OTP_Screen_Android";
    }
    String pathUrl =
        "https://mapi.indiamart.com/wservce/users/OTPverification/?process=$process&flag=OTPGen&user_country=$countryId&APP_SCREEN_NAME=OtpEnterMobileNumber&USER_IP_COUNTRY=$country&modid=$platform&token=imobile@15061981&APP_USER_ID=&APP_MODID=$platform&user_mobile_country_code=$countryCode&$requiredParam=$textFieldValue&APP_ACCURACY=0.0&USER_IP_COUNTRY_ISO=$countryId&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&USER_IP=$userIp&app_version_no=13.2.2_T1&user_updatedusing=OTPfrom%20$platform%20App";
    print(pathUrl);
    try {
      http.Response response = await http.post(Uri.parse(pathUrl));
      Map<String, dynamic> data = json.decode(response.body);
      loginData = LoginResponse.fromJson(data);
      if (loginData.response.code == "200") {
        // Success
        FocusScope.of(context).unfocus();
        if (!kIsWeb) {
        if (Platform.isAndroid) {
          var appSignatureID = await SmsAutoFill().getAppSignature;
          Map sendOtpData = {
            "mobile_number": loginTextField.text,
            "app_signature_id": appSignatureID
          };
          print(sendOtpData);
        }
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                OTP_Verification(
                  mobNo: loginTextField.text,
                  glusrid: loginData.response.glusrid ?? "",
                  isIndian: isIndian,
                  country: country,
                  countryCode: countryCode,
                  countryId: countryId,
                  platform: platform,
                  process: process,
                  requiredParam: requiredParam,
                  ipCountry: ipCountry,
                  ipAddress: ipAddress,
                )));
      } else {
        print("${loginData.response.message}\n${loginData.response.error}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "${loginData.response.message}\n${loginData.response.error}")));
      }
      EasyLoading.dismiss();
    } catch (e) {
      print("${loginData.response.message}\n${loginData.response.error}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "${loginData.response.message}\n${loginData.response.error}")));
    }
  }

  verifyIpCountry(String creds, bool tcUsed, bool otpTriggered,
      TruecallerUserProfile? profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var platform = "";
    if (!kIsWeb) {
      if (Platform.isIOS) {
        platform = "IOS";
      } else if (Platform.isAndroid) {
        platform = "Android";
      }
    } else {
      platform = "Android";
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
      ipCountry = verifyIpData.response.data.geoipCountryName ?? "";
      ipAddress = verifyIpData.response.data.geoipIpAddress ?? "";
      print("ipcountry=$ipCountry");
      setState(() {
        if (ipCountry != "India") isIndian = false;
      });
      prefs.setString("ipAddress", ipAddress);
      if (verifyIpData.response.code == 200) {
        if (otpTriggered) {
          if (isIndian &&
              verifyIpData.response.data.geoipCountryName == "India") {
            triggerOTP(
                currentPlatform,
                countryId,
                currentCountry,
                countryCode,
                loginTextField.text.replaceAll(" ", ""),
                verifyIpData.response.data.geoipIpAddress.toString());
        } else if (countryCode == "91" && ipCountry != "India") {
            showAlert();
          } else {
            triggerOTP(
                currentPlatform,
                countryId,
                currentCountry,
                countryCode,
                loginTextField.text.replaceAll(" ", ""),
                verifyIpData.response.data.geoipIpAddress.toString());
          }
        }
        else
          callApi(creds, profile);
      } else {
        print(
            "${verifyIpData.response.status}\n${verifyIpData.response.message}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "${verifyIpData.response.status}\n${verifyIpData.response
                    .message}")));
      }
    } catch (e) {
      // triggerOTP(currentPlatform, countryId, currentCountry, countryCode,
      //     loginTextField.text.replaceAll(" ", ""), "   ");
      print(e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  validateAndSendOTP() {
    if (loginTextField.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your mobile number")));
    } else if ((isIndian == true) &&
        (loginTextField.text.length < 10 ||
            loginTextField.text.startsWith("0") ||
            loginTextField.text.startsWith("2") ||
            loginTextField.text.startsWith("3") ||
            loginTextField.text.startsWith("5"))) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid mobile number")));
    } else if (checkStatus == false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please accept Terms and Privacy Policy")));
    } else {
      if (checkStatus == true) {
        verifyIpCountry(loginTextField.text, false, true, null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please Accept Terms and Privacy Policy")));
      }
    }
  }

  getPlatform() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        currentPlatform = "ANDROID";
        prefs.setString("platform", "ANDROID");
      } else if (Platform.isIOS) {
        currentPlatform = "Ios";
        prefs.setString("platform", "iOS");
      }
    } else {
      currentPlatform = "ANDROID";
      prefs.setString("platform", "ANDROID");
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
        builder: (_) =>
            AlertDialog(
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
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          180,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image(
                                            image: CachedNetworkImageProvider(
                                                searching == true
                                                    ? results[index]['cflag']
                                                    : snapshot.data[index]
                                                        ['cflag']),
                                            fit: BoxFit.fill,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Flexible(
                                            child: Text(
                                              searching == true
                                                  ? results[index]['cnname']
                                                  : snapshot.data[index]
                                                      ['cnname'],
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          searching == true
                                              ? results[index]['cncode']
                                              : snapshot.data[index]['cncode'],
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        )),
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
  Widget build(BuildContext context) =>
      KeyboardDismisser(
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
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: <Widget>[
                      // Container(
                      //   height: 100,
                      //   width: MediaQuery.of(context).size.width,
                      //   color: Colors.black12,
                      //   alignment: Alignment.center,
                      //   child: Align(
                      //     alignment: Alignment.center,
                      //     child: Container(
                      //       height: 60,
                      //       width: 200,
                      //       decoration: const BoxDecoration(
                      //         image: DecorationImage(
                      //             image: AssetImage("images/indiamartLogo.png"),
                      //             fit: BoxFit.contain),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        isIndian == true
                            ? "Please enter your 10 digit mobile number to begin"
                            : "Enter your e-mail address to help us begin",
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                        height: 60,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 20,
                        child: GestureDetector(
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
                                child: FadeInImage(
                                  image: NetworkImage(currentFlag),
                                  placeholder:
                                      const AssetImage("images/in_flag_s.png"),
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.asset('images/in_flag_s.png',
                                        fit: BoxFit.fitWidth);
                                  },
                                  fit: BoxFit.fitWidth,
                                ),
                                // child: Image(
                                //   image: NetworkImage(currentFlag),
                                //   fit: BoxFit.fill,
                                // ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "+$countryCode",
                                style: const TextStyle(fontSize: 15),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded),
                              const VerticalDivider(
                                color: Colors.black,
                              ),
                              Expanded(
                                child: TextField(
                                  textInputAction: TextInputAction.go,
                                  inputFormatters: [
                                    if (isIndian)
                                      LengthLimitingTextInputFormatter(10)
                                  ],
                                  keyboardType: isIndian
                                      ? TextInputType.number
                                      : TextInputType.emailAddress,
                                  autocorrect: false,
                                  focusNode: _focusNode,
                                  autofocus: false,
                                  onChanged: (searchingText) {},
                                  onEditingComplete: () {},
                                  onTapOutside: (event) {},
                                  onTap: () {},
                                  controller: loginTextField,
                                  decoration: InputDecoration(
                                    hintText: isIndian
                                        ? "Enter your Mobile number"
                                        : "Please Enter your Email Address",
                                    border: InputBorder.none,
                                    // contentPadding: const EdgeInsets.all(8),
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
                            "Don't worry! Your details are safe with us.",
                            style: TextStyle(fontSize: 12),
                          ),
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
                            const Text(
                              "I accept all the ",
                              style: TextStyle(fontSize: 12),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          webview_class(
                                            title: "",
                                            initialUrl:
                                            "https://m.indiamart.com/terms-of-use.html",
                                            navMode: '1',
                                          ),
                                    ));
                              },
                              child: Text(
                                "terms",
                                style: TextStyle(
                                    color: Colors.teal[400],
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.grey,
                                    decorationThickness: 1,
                                    // decorationStyle: TextDecorationStyle.dashed,
                                    fontSize: 12),
                              ),
                            ),
                            const Text(" and "),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          webview_class(
                                            title: "Privacy Policy",
                                            initialUrl:
                                            "https://m.indiamart.com/privacy-policy.html",
                                            navMode: '1',
                                          ),
                                    ));
                              },
                              child: Text(
                                "privacy policy",
                                style: TextStyle(
                                    color: Colors.teal[400],
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.grey,
                                    decorationThickness: 1,
                                    // decorationStyle: TextDecorationStyle.dashed,
                                    fontSize: 12),
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
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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

  void hint_picker() async {
    final String? phone = await AccountPicker.phoneHint();
    setState(() {
      if (phone != null && phone != "") {
        _phoneNumber = phone;
        loginTextField.text = _phoneNumber.replaceFirst('+91', '');
        loginTextField.selection =
            TextSelection.collapsed(offset: loginTextField.text.length);
        validateAndSendOTP();
      } else
        _focusNode.requestFocus();
    });
    print("phonenumber=$_phoneNumber");
  }

  void getTruecaller() async {
    TruecallerSdk.isUsable.then((isUsable) {
      if (isUsable && countryCode == "91") {
        TruecallerSdk.getProfile;
        try{
        StreamSubscription streamSubscription = TruecallerSdk.streamCallbackData
            .listen((truecallerSdkCallback) {
          print("currentplatform=${truecallerSdkCallback.result}");
          switch (truecallerSdkCallback.result) {
            case TruecallerSdkCallbackResult.success:
              print("payload=${truecallerSdkCallback.profile?.payload}");
              print("signature=${truecallerSdkCallback.profile?.signature}");
              var phoneNumber = truecallerSdkCallback.profile?.phoneNumber
                  .replaceFirst('+91', '') ?? "";
              verifyIpCountry(
                  phoneNumber, true, false, truecallerSdkCallback.profile);
              storeDataTruecaller(truecallerSdkCallback.profile, phoneNumber);
              String? firstName = truecallerSdkCallback.profile!.signatureAlgorithm;
              print("firstName=${firstName}");
              String? lastName = truecallerSdkCallback.profile!.lastName;
              String phNo = truecallerSdkCallback.profile!.phoneNumber;
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(builder: (context) => ViewCategories()));
              break;
            case TruecallerSdkCallbackResult.failure:
              int errorCode = truecallerSdkCallback.error!.code;
              break;
            case TruecallerSdkCallbackResult.verification:
              if (!kIsWeb) {
                if (Platform.isAndroid) {
                  print("currentplatform=$currentPlatform");
                  hint_picker();
                }
              } else
                setState(() {
                  _focusNode.requestFocus();
                });
              break;
            default:
              print("Invalid result");
          }
        });
        print("currentplatform=${streamSubscription}");
      } catch(e){
          print("exceptionhdhfhhf=$e");
        }
      }
      else{
        if (!kIsWeb) {
          if (Platform.isAndroid) {
            print("currentplatform=$currentPlatform");
            hint_picker();
          }
        } else
          setState(() {
            _focusNode.requestFocus();
          });
      }
    });
  }

  void storeDataTruecaller(TruecallerUserProfile? trueProfile,
      String phoneNumber) async {
    SharedPreferences tcDataSharedPreference =
    await SharedPreferences.getInstance();

    String userName = '${trueProfile?.firstName} ${trueProfile?.lastName}';

    tcDataSharedPreference.setString("TC_NAME", userName);
    tcDataSharedPreference.setString("TC_EMAIL_ID", trueProfile?.email ?? "");
    tcDataSharedPreference.setString("TC_MOBILE_NO", phoneNumber ?? "");
    tcDataSharedPreference.setString("TC_CITY", trueProfile?.city ?? "");
    tcDataSharedPreference.setString(
        "TC_COUNTRY_CODE", trueProfile?.countryCode ?? "");
    tcDataSharedPreference.setBool("TC_IS_SUCCESS", true);
    tcDataSharedPreference.setBool("IS_LOGIN_VIA_TC", true);
  }

  void callApi(String phoneNumber, TruecallerUserProfile? profile) async {
    String pathUrl =
        "https://mapi.indiamart.com/wservce/users/add/?S_Query_Modid=$currentPlatform&APP_SCREEN_NAME=Default-Buyer&user_updatedby=USER&USER_IP_COUNTRY=India&token=imartenquiryprovider&APP_USER_ID=&APP_MODID=$currentPlatform&S_mobile=$phoneNumber&user_mobile_country_code=91&APP_ACCURACY=0.0&USER_IP_COUNTRY_ISO=IN&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&USER_IP=$ipAddress&app_version_no=13.2.1&country_iso=IN&user_updatedusing=TRUECALLER";
    print(pathUrl);
    try {
      http.Response response = await http.post(Uri.parse(pathUrl));
      var code = json.decode(response.body)['CODE'];
      print("tccode=$pathUrl");
      glid = json.decode(response.body)['gluser_id'];
      print("tcglid=$glid");
      callTcAuthApi(glid, profile, phoneNumber);
      SharedPreferences tcDataSharedPreference = await SharedPreferences
          .getInstance();
      tcDataSharedPreference.setString("glid", glid);
    } catch (e) {

    }
  }

  void callTcAuthApi(String glid, TruecallerUserProfile? profile,
      String phoneNumber) async {
    Map<String,String> formData={
    'APP_SCREEN_NAME':'Default-Buyer',
    'KEY_MOB_VERIFY':'${profile?.payload}',
    'SIGNATURE':'${profile?.signature}',
    'USER_IP_COUNTRY':'India',
    'modid':'$currentPlatform',
    'token':'imobile@15061981',
    'APP_USER_ID':'',
    'APP_MODID':'$currentPlatform',
    'APP_ACCURACY':'0.0',
    'USER_IP_COUNTRY_ISO':'IN',
    'APP_LATITUDE':'0.0',
    'APP_LONGITUDE':'0.0',
    'glusrid':'$glid',
    'USER_IP':'$ipAddress',
    'app_version_no':'13.2.2'
    };
    String pathUrl =
        "https://mapi.indiamart.com/wservce/users/TCAuthenticate_Verify/?";
    String encodedFormData = Uri(queryParameters: formData).query;
    print(pathUrl+encodedFormData);
    try {
      http.Response response = await http.post(
          Uri.parse(pathUrl),
          body:encodedFormData,
          headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        encoding: Encoding.getByName("utf-8")

      );
      print("tccode=${response.body}");
      Map<String, dynamic> data = json.decode(response.body);
      print("response.body${response.body}");
      print("response.body1${VerifyTruecallerDataModel.fromJson(data).response}");
      loginData1 = VerifyTruecallerDataModel.fromJson(data);
      if (loginData1.response.code == "200") {
        print("ak check${loginData1.response.loginData?.imIss.AK}");
        udsApiCall(phoneNumber);
      }
    } catch (e) {
      print("exceptionff=$e");
    }
  }

  void udsApiCall(String phoneNumber) async {
    String pathUrl="https://mapi.indiamart.com/wservce/users/detail/?VALIDATION_GLID=${glid}&APP_SCREEN_NAME=Default-Seller&AK=${loginData1.response.loginData?.imIss
        .AK}&modid=${currentPlatform}&token=imobile@15061981&APP_USER_ID=${glid}&APP_MODID=${currentPlatform}&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=${glid}&logo=1&VALIDATION_USER_IP=${ipAddress}&app_version_no=13.2.2_S1&others=glusr_usr_latitude,glusr_usr_longitude,glusr_usr_membersince,glusr_listing_status_reason&VALIDATION_USERCONTACT=$phoneNumber";
    http.Response response = await http.post(Uri.parse(pathUrl));
    // var code = json.decode(response.body)['CODE'];
    print("tccode=${response.body}");
    Map<String, dynamic> data = json.decode(response.body);
    print("response.body${response.body}");
    uds = UDS.fromJson(data);
    if (!checkIfCodeExists(uds.code)) {
      print(
          "name,lastname,email=${uds.firstName},${uds.lastName},${uds.email1}");
      FocusScope.of(context).unfocus();
      String ak = loginData1.response.loginData?.imIss.AK ?? "";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("AK", ak);
      prefs.setString("glid", glid);
      prefs.setString("ipAddress", ipAddress);
      if (isIndian) {
        prefs.setString("Mobile", phoneNumber);
      }
      if (uds.firstName == "" ||
          uds.lastName == "" ||
          uds.email1 == "" ||
          uds.city == "")
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                DetailsRequest(
                  fname: uds.firstName,
                  lname: uds.lastName,
                  email: uds.email1,
                  city: uds.city,
                  isIndian: isIndian,
                  creds: widget.mobNo,
                  ipCountry: ipCountry,
                  glId: glid,
                  ipAddress: ipAddress,
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
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tests/DataModels/LoginResponseDataModel';
import 'package:http/http.dart' as http;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class OTP_Verification extends StatefulWidget {
  String mobNo;
  String glusrid;
  bool isIndian;
  OTP_Verification(
      {required this.mobNo, required this.glusrid, required this.isIndian});
  @override
  State<OTP_Verification> createState() => _OTP_VerificationState();
}

class _OTP_VerificationState extends State<OTP_Verification> {
  late FocusNode otp1;
  late FocusNode otp2;
  late FocusNode otp3;
  late FocusNode otp4;
  late LoginResponse loginData;

  @override
  void initState() {
    otp1 = FocusNode();
    otp2 = FocusNode();
    otp3 = FocusNode();
    otp4 = FocusNode();
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

  void nextField(var value, FocusNode focus) {
    if (value != null || value != "") otp1.requestFocus();
  }

  void prevField(var value, FocusNode focus) {
    // if(value=="")
    otp1.requestFocus();
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
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerticalDivider(
                      width: 10,
                      thickness: 10,
                    ),
                    Center(
                      child: Text(
                        "You will receive an OTP (One Time Password) on your mobile number",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "+91-${widget.mobNo}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Not You?",
                            style: TextStyle(
                                color: Colors.teal[400], fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    // Center(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Container(
                    //         width: 40,
                    //         height: 40,
                    //         margin: EdgeInsets.only(top: 24, bottom: 8),
                    //         child: TextField(
                    //           autofocus: true,
                    //           textAlign: TextAlign.center,
                    //           keyboardType: TextInputType.number,
                    //           inputFormatters: <TextInputFormatter>[
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(1),
                    //           ],
                    //           decoration: InputDecoration(
                    //             border: InputBorder.none,
                    //           ),
                    //           onChanged:(value){
                    //             nextField(value,otp2);
                    //           },
                    //         ),
                    //         decoration: BoxDecoration(
                    //           border: Border(bottom: BorderSide(
                    //             color: Colors.teal,
                    //             width: 2
                    //           )),
                    //         ),
                    //       ),
                    //       SizedBox(width: 5,),
                    //       Container(
                    //         width: 40,
                    //         height: 40,
                    //         margin: EdgeInsets.only(top: 24, bottom: 8),
                    //         child: TextField(
                    //           focusNode: otp2,
                    //           textAlign: TextAlign.center,
                    //           keyboardType: TextInputType.number,
                    //           inputFormatters: <TextInputFormatter>[
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(1),
                    //           ],
                    //           decoration: InputDecoration(
                    //             border: InputBorder.none,
                    //           ),
                    //           onChanged: (value){
                    //             nextField(value,otp3);}
                    //         ),
                    //         decoration: BoxDecoration(
                    //           border: Border(bottom: BorderSide(
                    //               color: Colors.teal,
                    //               width: 2
                    //           )),
                    //         ),
                    //       ),
                    //       SizedBox(width: 5,),
                    //       Container(
                    //         width: 40,
                    //         height: 40,
                    //         margin: EdgeInsets.only(top: 24, bottom: 8),
                    //         decoration: BoxDecoration(
                    //           border: Border(bottom: BorderSide(
                    //               color: Colors.teal,
                    //               width: 2
                    //           )),
                    //         ),
                    //         child: TextField(
                    //           focusNode: otp3,
                    //           textAlign: TextAlign.center,
                    //           keyboardType: TextInputType.number,
                    //           inputFormatters: <TextInputFormatter>[
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(1),
                    //           ],
                    //           decoration: InputDecoration(
                    //             border: InputBorder.none,
                    //           ),
                    //           onChanged: (value){nextField(value,otp4);},
                    //         ),
                    //       ),
                    //       SizedBox(width: 5,),
                    //       Container(
                    //         width: 40,
                    //         height: 40,
                    //         margin: EdgeInsets.only(top: 24, bottom: 8),
                    //         child: TextField(
                    //           focusNode: otp4,
                    //           textAlign: TextAlign.center,
                    //           keyboardType: TextInputType.number,
                    //           inputFormatters: <TextInputFormatter>[
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(1),
                    //           ],
                    //           decoration: InputDecoration(
                    //             border: InputBorder.none,
                    //           ),
                    //         ),
                    //         decoration: BoxDecoration(
                    //           border: Border(bottom: BorderSide(
                    //               color: Colors.teal,
                    //               width: 2
                    //           )),
                    //         ),
                    //       ),
                    //     ]
                    //   ),
                    // ),
                    SizedBox(height: 16),
                    Center(
                      child: OtpInputFields(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "The OTP will expire in ",
                            style: TextStyle(),
                          ),
                          TweenAnimationBuilder(
                            tween: Tween(begin: 60.0, end: 0),
                            duration: Duration(seconds: 60),
                            builder: (context, value, child) =>
                                Text("${value.toInt()} seconds"),
                            onEnd: () {
                              SizedBox(height: 16);
                              Center(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "Request OTP again",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  decoration:
                                      BoxDecoration(color: Colors.orange[300]),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
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
                          padding: const EdgeInsets.fromLTRB(80, 130, 0, 0),
                          child: Column(
                            children: [
                              Container(
                                  width: 140,
                                  // height: 40,
                                  // color: Colors.black.withOpacity(0.5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  // / Semi-transparent black color
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 15, 10, 15),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Fetching',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          SpinKitPulse(
                                            color: Colors
                                                .white, // Adjust the color
                                            size: 10.0, // Adjust the size
                                            duration: Duration(seconds: 1),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          SpinKitPulse(
                                            color: Colors
                                                .white, // Adjust the color
                                            size: 16.0, // Adjust the size
                                            duration: Duration(seconds: 1),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          SpinKitPulse(
                                            color: Colors
                                                .white, // Adjust the color
                                            size: 20.0,
                                            duration: Duration(
                                                seconds: 1), // Adjust the size
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
                    // Add other UI components like Image, Text, etc.
                    // ...
                    // ...
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
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
                          },
                          child: Text(
                            "PREVIOUS",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                      child: GestureDetector(
                          onTap: () async {
                            String pathUrl =
                                "https://mapi.indiamart.com/wservce/users/OTPverification/?user_ip=49.36.221.59&flag=OTPVer&verify_process=Online&user_country=IN&APP_SCREEN_NAME=Default-Buyer&verify_screen=ANDROID%20VERIFICATION%20THROUGH%20OTP&auth_key=6054&modid=ANDROID&token=imobile@15061981&APP_USER_ID=&APP_MODID=ANDROID&user_mobile_country_code=91&mobile_num=${widget.mobNo}&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=${widget.glusrid}&ScreenName=OtpVerification&app_version_no=13.2.2_T1";
                            print(pathUrl);
                            http.Response response =
                                await http.get(Uri.parse(pathUrl));
                            Map<String, dynamic> data =
                                json.decode(response.body);
                            loginData = LoginResponse.fromJson(data);
                            if (loginData.response.code == "200") {
                              // Success
                              print(loginData);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "${loginData.response.message}\n${loginData.response.error}")));
                            }
                          },
                          child: Text("NEXT",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 17))),
                    )
                  ],
                )),
          ));
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
                    print("object");
                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              decoration: BoxDecoration(
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
          child: Center(
            child: Text(
              'Your Content',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
        // Loading indicator overlay
        Positioned.fill(
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

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tests/view_categories.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailsRequest extends StatefulWidget {
  String fname;
  String lname;
  String email;
  String city;
  DetailsRequest({required this.fname, required this.lname, required this.email, required this.city});
  @override
  State<DetailsRequest> createState() => DetailsRequestState();
}

class DetailsRequestState extends State<DetailsRequest> {
  TextEditingController nameTextField = TextEditingController();
  TextEditingController emailTextField = TextEditingController();
  TextEditingController pincodeTextField = TextEditingController();
  FocusNode emailTextFieldFocus = FocusNode();
  FocusNode pinCodeTextFieldFocus = FocusNode();


  String? currentAddress;
  Position? currentPosition;
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  List<dynamic> emailList = <dynamic>[];
  bool showDropdown=false;

  // List<String> items=["kkk","kjjj"];

  @override
  void initState() {
    _getEmails();
    super.initState();
  }
  Future<void> _getEmails() async {
    final permissionStatus = await Permission.contacts.request();
    if (!(permissionStatus.isGranted))
      return;
    try {
      var list = await platform.invokeMethod('getEmailList');
      if (list != null && mounted) {
        setState(() {
          emailList = list;
          emailTextField.text=emailList[0];
          print("emaillist=$emailList");
        });
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
  @override
  void dispose() {
    nameTextField.dispose();
    emailTextField.dispose();
    pincodeTextField.dispose();
    super.dispose();
  }

  updateDetails() {
    var updatedUsing = "";

    if (Platform.isIOS) {
      updatedUsing = "Edit Profile (IOS)";
    } else {
      updatedUsing = "Edit Profile (Android)";
    }
    String pathUrl =
        "https://mapi.indiamart.com/wservce/users/edit/?USR_ID=199718898&VALIDATION_GLID=199718898&APP_SCREEN_NAME=OtpEnterMoreDetails&IP=49.36.221.59&FIRSTNAME=mnb&AK=eyJ0eXAiOiJKV1QiLCJhbGciOiJzaGEyNTYifQ.eyJpc3MiOiJVU0VSIiwiYXVkIjoiMSo1KjQqNyo4KiIsImV4cCI6MTY5NjYwMDc4OCwiaWF0IjoxNjk2NTE0Mzg4LCJzdWIiOiIxOTk3MTg4OTgiLCJjZHQiOiIwNS0xMC0yMDIzIn0.uJIAduzC6Q6e3ED63IQb9GMpRbs3A-lZB16ZYLs5BJU&EMAIL=ghahah@gmail.com&UPDATEDUSING=Edit Profile (Android)&APP_USER_ID=199718898&APP_MODID=ANDROID&VALIDATION_KEY=e27d039e38ae7b3d439e8d1fe870fc68&APP_ACCURACY=0.0&APP_LATITUDE=0.0&IP_COUNTRY=India&APP_LONGITUDE=0.0&VALIDATION_USER_IP=49.36.221.59&UPDATEDBY=User&app_version_no=13.2.2_T1&VALIDATION_USERCONTACT=1455487885&MODID=ANDROID";
  }

  proceedToHome() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ViewCategories()));
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      if (Geolocator.openLocationSettings() == true) {
        Geolocator.openLocationSettings();
      }
      return false;
    }
    return true;
  }

  Future getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    EasyLoading.show(status: "Fetching...");
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => currentPosition = position);
      _getAddressFromLatLng(currentPosition!);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Can't fetch Location due to ${e.toString()}")));

      debugPrint(e);
      EasyLoading.dismiss();
    });
  }

  Future _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            currentPosition!.latitude, currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        print(place.postalCode);
        currentAddress = '${place.postalCode}';
        pincodeTextField.text = currentAddress.toString();
        EasyLoading.dismiss();
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Can't fetch Location due to ${e.toString()}")));
      debugPrint(e.toString());
      EasyLoading.dismiss();
    });
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
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
                          //             image: AssetImage(
                          //                 "images/indiamartLogo.png"),
                          //             fit: BoxFit.contain),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20, right: 10),
                            child: Text(
                              "Please confirm your Contact Name and E-mail address",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                            child: TextField(
                              textInputAction: TextInputAction.unspecified,
                              keyboardType: TextInputType.name,
                              autocorrect: false,
                              autofocus: true,
                              onSubmitted: (value) {
                                // keyboard done action
                                emailTextFieldFocus.requestFocus();
                              },
                              onChanged: (searchingText) {},
                              onEditingComplete: () {},
                              onTapOutside: (event) {},
                              onTap: () {
                                setState(() {
                                  showDropdown=false;
                                });
                                },
                              controller: nameTextField,
                              decoration: const InputDecoration(
                                hintText: "Contact Name",
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          WillPopScope(
                            onWillPop: () async {
                              if (showDropdown) {
                              setState(() {
                              showDropdown = false;
                              });
                              return false;
                              }
                              return true;
                              },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                              child: Column(
                                children: <Widget>[
                                  TextField(
                                    textInputAction: TextInputAction.unspecified,
                                    keyboardType: TextInputType.name,
                                    autocorrect: false,
                                    autofocus: true,
                                    onSubmitted: (value) {
                                      // keyboard done action
                                      emailTextFieldFocus.requestFocus();
                                    },
                                    onChanged: (searchingText) {},
                                    onEditingComplete: () {},
                                    scrollPhysics: NeverScrollableScrollPhysics(),
                                    controller:emailTextField ,
                                    onTapOutside: (event){
                                      showDropdown =false;
                                    },
                                    onTap: () {
                                      setState(() {
                                        showDropdown = true;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(8),
                                      hintText: 'Email',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  if (showDropdown)
                                    Container(
                                      color: Colors.white,
                                      child: ListView(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true, // This is important
                                        children: emailList
                                            .map(
                                              (item) => Column(
                                                children: [
                                                  ListTile(
                                            title: Text(item),
                                            onTap: () {
                                                  // Handle item selection
                                                  print('Selected: $item');
                                                  setState(() {
                                                    emailTextField.text=item;
                                                    emailTextField.selection = TextSelection.collapsed(offset: emailTextField.text.length);
                                                    showDropdown = false;
                                                  });
                                                  },
                                                ),
                                                  if(item!=emailList[emailList.length-1])
                                                  Divider(  // Divider to separate items
                                                    color: Colors.grey[300],
                                                    height: 1,
                                                    thickness: 1,
                                                  ),
                                                ],
                                              ),
                                        )
                                            .toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Select your Location",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.transparent),
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          side: BorderSide(
                                            color: Colors.teal, // Border color
                                            width: 1.0, // Border width
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showDropdown=false;
                                      });
                                      // get Location
                                      FocusScope.of(context).unfocus();
                                      getCurrentPosition();
                                    },
                                    icon: Icon(
                                      Icons.gps_fixed,
                                      color: Colors.teal,
                                    ),
                                    label: Text(
                                      'Use current location',
                                      style: TextStyle(
                                        color: Colors.teal[300],
                                        fontSize: 15,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:5.0),
                                  child: Text("or",style: TextStyle(color: Colors.grey[400]),),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width - 253,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: TextField(
                                      focusNode: pinCodeTextFieldFocus,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      onSubmitted: (value) {
                                        // keyboard done action
                                      },
                                      onChanged: (searchingText) {},
                                      onEditingComplete: () {},
                                      onTapOutside: (event) {},
                                      onTap: () {
                                        setState(() {
                                          showDropdown=false;
                                        });
                                      },
                                      controller: pincodeTextField,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Pincode",
                                        contentPadding: EdgeInsets.only(left:8),
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(width: 1, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 100, 20),
                            child: TextField(
                              focusNode: pinCodeTextFieldFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              autocorrect: false,
                              onSubmitted: (value) {
                                // keyboard done action
                                FocusScope.of(context).unfocus();
                                proceedToHome();
                              },
                              onChanged: (searchingText) {},
                              onEditingComplete: () {},
                              onTapOutside: (event) {},
                              onTap: () {},
                              controller: pincodeTextField,
                              decoration: const InputDecoration(
                                labelText: "Enter Pincode",
                                contentPadding: EdgeInsets.all(8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          // Row(
                          //   children: [
                          //     Padding(
                          //       padding:
                          //           const EdgeInsets.only(left: 120, top: 10),
                          //       child: Text(
                          //         "or",
                          //         style: TextStyle(fontSize: 16),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(20, 10, 100, 20),
                          //   child: TextField(
                          //     focusNode: pinCodeTextFieldFocus,
                          //     textInputAction: TextInputAction.done,
                          //     keyboardType: TextInputType.number,
                          //     autocorrect: false,
                          //     onSubmitted: (value) {
                          //       // keyboard done action
                          //     },
                          //     onChanged: (searchingText) {},
                          //     onEditingComplete: () {},
                          //     onTapOutside: (event) {},
                          //     onTap: () {},
                          //     controller: pincodeTextField,
                          //     decoration: const InputDecoration(
                          //       labelText: "Enter Pincode",
                          //       contentPadding: EdgeInsets.all(8),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderSide:
                          //             BorderSide(width: 1, color: Colors.grey),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Next tapped");
                      proceedToHome();
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.bottomCenter,
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
  void _showPopupMenu(BuildContext context) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(20, 350, 20, 0),
      items: emailList.map((dynamic item) {
        return PopupMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}

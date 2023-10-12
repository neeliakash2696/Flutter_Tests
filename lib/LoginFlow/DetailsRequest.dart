// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tests/view_categories.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class DetailsRequest extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
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
              backgroundColor: Colors.teal,
              toolbarHeight: 1,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
                                      image: AssetImage(
                                          "images/indiamartLogo.png"),
                                      fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20, right: 10),
                            child: Text(
                              "Please confirm your Contact Name and E-mail address",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 16),
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
                              onTap: () {},
                              controller: nameTextField,
                              decoration: const InputDecoration(
                                labelText: "Contact Name",
                                contentPadding: EdgeInsets.all(8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child: TextField(
                              focusNode: emailTextFieldFocus,
                              textInputAction: TextInputAction.unspecified,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              onSubmitted: (value) {
                                // keyboard done action
                                pinCodeTextFieldFocus.requestFocus();
                              },
                              onChanged: (searchingText) {},
                              onEditingComplete: () {},
                              onTapOutside: (event) {},
                              onTap: () {},
                              controller: emailTextField,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                contentPadding: EdgeInsets.all(8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Select your Location",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 10),
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
                                      color: Colors.teal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 120, top: 10),
                                child: Text(
                                  "or",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
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
                              ),
                            ),
                          ),
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
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tests/view_categories.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';

class DetailsRequest extends StatefulWidget {
  String fname;
  String lname;
  String email;
  String city;
  bool isIndian;
  String creds;
  String ipCountry;
  String glId;
  String ipAddress;
  DetailsRequest(
      {required this.fname,
      required this.lname,
      required this.email,
      required this.city,
      required this.isIndian,
      required this.creds,
      required this.ipCountry,
      required this.glId,
      required this.ipAddress});
  @override
  State<DetailsRequest> createState() => DetailsRequestState();
}

class DetailsRequestState extends State<DetailsRequest> {
  TextEditingController nameTextField = TextEditingController();
  TextEditingController credentialTextField = TextEditingController();
  TextEditingController pincodeTextField = TextEditingController();
  FocusNode credentialTextFieldFocus = FocusNode();
  FocusNode pinCodeTextFieldFocus = FocusNode();

  String? currentAddress;
  Position? currentPosition;
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  List<dynamic> emailList = <dynamic>[];
  bool showDropdown = false;
  late Placemark place;
  List<dynamic> filteredEmailList = [];
  String currentCity = "";
  String currentLocality = "";
  String currentState = "";

  bool isChanged = false;

  @override
  void initState() {
    if (!kIsWeb) {
      if (Platform.isAndroid && widget.isIndian) {
        _getEmails();
        filteredEmailList.addAll(emailList);
      }
    }
    super.initState();
  }

  void filterList(String searchText) {
    setState(() {
      filteredEmailList = emailList
          .where(
              (email) => email.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  Future<void> _getEmails() async {
    final permissionStatus = await Permission.contacts.request();
    if (!(permissionStatus.isGranted)) return;
    try {
      var list = await platform.invokeMethod('getEmailList');
      if (list != null && mounted) {
        setState(() {
          emailList = list;
          credentialTextField.text = emailList[0];
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
    credentialTextField.dispose();
    pincodeTextField.dispose();
    super.dispose();
  }

  updateDetails() async {
    var updatedUsing = "";
    var ak = "";
    var appModId = "";
    String pathUrl = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ak = prefs.getString("AK") ?? "";
    print("ak is $ak");
    if (!kIsWeb) {
      if (Platform.isIOS) {
        appModId = "iOS";
        updatedUsing = "Edit Profile (IOS)";
      } else if (Platform.isAndroid) {
        appModId = "ANDROID";
        updatedUsing = "Edit Profile (Android)";
      }
    } else {
      appModId = "ANDROID";
      updatedUsing = "Edit Profile (Android)";
    }
    if (widget.isIndian == true) {
      pathUrl =
          "https://mapi.indiamart.com/wservce/users/edit/?USR_ID=${widget.glId}&VALIDATION_GLID=${widget.glId}&APP_SCREEN_NAME=OtpEnterMoreDetails&IP=${widget.ipAddress}&FIRSTNAME=${nameTextField.text}&AK=$ak&EMAIL=${credentialTextField.text.replaceAll(" ", "")}&UPDATEDUSING=$updatedUsing&APP_USER_ID=${widget.glId}&APP_MODID=$appModId&VALIDATION_KEY=e27d039e38ae7b3d439e8d1fe870fc68&APP_ACCURACY=0.0&APP_LATITUDE=0.0&IP_COUNTRY=${widget.ipCountry}&APP_LONGITUDE=0.0&VALIDATION_USER_IP=${widget.ipAddress}&UPDATEDBY=User&app_version_no=13.2.2_T1&VALIDATION_USERCONTACT=${widget.creds}&MODID=$appModId&ZIP=${pincodeTextField.text.replaceAll(" ", "")}&CITY=${place.locality}&STATE=${place.administrativeArea}&LOCALITY=${place.locality}";
    } else {
      pathUrl =
          "https://mapi.indiamart.com/wservce/users/edit/?USR_ID=${widget.glId}&VALIDATION_GLID=${widget.glId}&APP_SCREEN_NAME=OtpEnterMoreDetails&IP=${widget.ipAddress}&FIRSTNAME=${nameTextField.text}&AK=$ak&PH_MOBILE=${credentialTextField.text.replaceAll(" ", "")}}&UPDATEDUSING=$updatedUsing&APP_USER_ID=${widget.glId}&APP_MODID=$appModId&VALIDATION_KEY=e27d039e38ae7b3d439e8d1fe870fc68&APP_ACCURACY=0.0&APP_LATITUDE=0.0&IP_COUNTRY=${widget.ipCountry}&APP_LONGITUDE=0.0&VALIDATION_USER_IP=${widget.ipAddress}&UPDATEDBY=User&app_version_no=13.2.2_T1&VALIDATION_USERCONTACT=${credentialTextField.text}&MODID=$appModId";
    }
    print(pathUrl);
    try {
      http.Response response = await http.post(Uri.parse(pathUrl));
      Map<String, dynamic> data = json.decode(response.body);
      var updateDetailsResponseCode = data["RESPONSE"]["CODE"];
      if (updateDetailsResponseCode == "200") {
        prefs.setString("glid", widget.glId);
        prefs.setString("ipAddress", widget.ipAddress);
        if (widget.isIndian) {
          prefs.setString("Mobile", widget.creds);
          prefs.setString("Email", credentialTextField.text);
        } else {
          prefs.setString("Email", widget.creds);
          prefs.setString(
              "Mobile",
              credentialTextField
                  .text); // this textfield now contains Phone Number
        }
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ViewCategories()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data["ERROR"] + "\n" + data["ERR_MSG"]["REASON"])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  proceedToHome() {
    if (nameTextField.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter your Name")));
    } else if (credentialTextField.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all the Details")));
    } else if (widget.isIndian == true &&
        pincodeTextField.text.isEmpty == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter Pincode")));
    } else {
      updateDetails();
    }
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
    await NominatimGeocoding.init(reqCacheNum: 20);
    if (!hasPermission) return;
    EasyLoading.show(status: "Fetching...");
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => currentPosition = position);
      if (currentPosition != null) {
        _getAddressFromLatLng();
      } else {
        print("Can't fetch Location");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Can't fetch Location")));
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Can't fetch Location due to ${e.toString()}")));

      debugPrint(e);
      EasyLoading.dismiss();
    });
  }

  Future _getAddressFromLatLng() async {
    if (kIsWeb) {
      var coordinate = Coordinate(
          latitude: currentPosition?.latitude ?? 0.0,
          longitude: currentPosition?.longitude ?? 0.0);
      Geocoding geocoding =
          await NominatimGeocoding.to.reverseGeoCoding(coordinate);
      print(geocoding.address.city);
      print(geocoding.address.country);
      print(geocoding.address.countryCode);
      print(geocoding.address.district);
      print(geocoding.address.houseNumber);
      print(geocoding.address.locale);
      print(geocoding.address.neighbourhood);
      print(geocoding.address.postalCode);
      print(geocoding.address.suburb);
      currentCity = geocoding.address.city;
      currentState = geocoding.address.state;
      currentLocality = geocoding.address.suburb;
      pincodeTextField.text = geocoding.address.postalCode.toString();
      EasyLoading.dismiss();
    } else {
      await placemarkFromCoordinates(currentPosition?.latitude ?? 0.0,
              currentPosition?.longitude ?? 0.0)
          .then((List<Placemark> placemarks) {
        place = placemarks[0];
        setState(() {
          print(place.administrativeArea);
          print(place.country);
          print(place.isoCountryCode);
          print(place.locality);
          print(place.name);
          print(place.street);
          print(place.subAdministrativeArea);
          print(place.subLocality);
          print(place.subThoroughfare);
          print(place.thoroughfare);
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
            body: WillPopScope(
              onWillPop: () async {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ViewCategories()));
                return true;
              },
              child: SafeArea(
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
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                autocorrect: false,
                                autofocus: true,
                                onSubmitted: (value) {
                                  // keyboard done action
                                  credentialTextFieldFocus.requestFocus();
                                },
                                onChanged: (searchingText) {},
                                onEditingComplete: () {},
                                onTapOutside: (event) {},
                                onTap: () {
                                  setState(() {
                                    showDropdown = false;
                                  });
                                },
                                controller: nameTextField,
                                decoration: const InputDecoration(
                                  hintText: "Contact Name",
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
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
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 20),
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      focusNode: credentialTextFieldFocus,
                                      textInputAction:
                                          TextInputAction.unspecified,
                                      keyboardType: widget.isIndian == true
                                          ? TextInputType.emailAddress
                                          : TextInputType.number,
                                      autocorrect: false,
                                      autofocus: true,
                                      onSubmitted: (value) {
                                        // keyboard done action
                                        FocusScope.of(context).unfocus();
                                      },
                                      onChanged: (searchText) {
                                        print("changed=$searchText");
                                        setState(() {
                                          isChanged = true;
                                          showDropdown = true;
                                        });
                                        filterList(searchText);
                                      },
                                      onEditingComplete: () {},
                                      scrollPhysics:
                                          NeverScrollableScrollPhysics(),
                                      controller: credentialTextField,
                                      onTapOutside: (event) {
                                        showDropdown = false;
                                      },
                                      onTap: () {
                                        setState(() {
                                          showDropdown = true;
                                          if (isChanged == false)
                                            filterList("");
                                        });
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(8),
                                        hintText: widget.isIndian == true
                                            ? "Email"
                                            : "Contact Number",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    if (showDropdown)
                                      Container(
                                        color: Colors.white,
                                        child: ListView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true, // This is important
                                          children: filteredEmailList
                                              .map(
                                                (item) => Column(
                                                  children: [
                                                    ListTile(
                                                      title: Text(item),
                                                      onTap: () {
                                                        // Handle item selection
                                                        print(
                                                            'Selected: $item');
                                                        setState(() {
                                                          credentialTextField
                                                              .text = item;
                                                          credentialTextField
                                                                  .selection =
                                                              TextSelection.collapsed(
                                                                  offset:
                                                                      credentialTextField
                                                                          .text
                                                                          .length);
                                                          showDropdown = false;
                                                        });
                                                      },
                                                    ),
                                                    if (item !=
                                                        emailList[
                                                            emailList.length -
                                                                1])
                                                      Divider(
                                                        // Divider to separate items
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
                            if (widget.isIndian == true) ...{
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
                                child: Row(children: <Widget>[
                                  // if (!kIsWeb) ...{
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: TextButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.transparent),
                                        shape: MaterialStateProperty.all<
                                            OutlinedBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            side: BorderSide(
                                              color:
                                                  Colors.teal, // Border color
                                              width: 1.0, // Border width
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showDropdown = false;
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
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      "or",
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ),
                                  // } else ...{
                                  //   SizedBox(
                                  //     width: 8,
                                  //   )
                                  // },
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 253,
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
                                            showDropdown = false;
                                          });
                                        },
                                        controller: pincodeTextField,
                                        decoration: const InputDecoration(
                                          hintText: "Enter Pincode",
                                          contentPadding:
                                              EdgeInsets.only(left: 8),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            },
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

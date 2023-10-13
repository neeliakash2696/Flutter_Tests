// ignore_for_file: must_be_immutable

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainPBRBanner extends StatefulWidget {
  @override
  State<MainPBRBanner> createState() => _MainPBRBannerState();
  String productName;
  dynamic img;
  MainPBRBanner({required this.productName, required this.img});
}

class _MainPBRBannerState extends State<MainPBRBanner> {
  List<String> optionList = [];
  String selectedValue = 'Option 1'; // Initialize with the first option
  String? mobNo = "";
  String? glid = "";
  String? ak = "";

  @override
  void initState() {
    super.initState();
    fetchSavedData();
    getUnits();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.teal[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width / 4,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(widget.img),
                                fit: BoxFit.fill)),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Looking for ${widget.productName}?",
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.indigo),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What is required qauntity?",
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Row(children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10), // Add padding for spacing
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue), // Border color
                    borderRadius: BorderRadius.circular(4), // Border radius
                  ),
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width - 120,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  fontSize: 15, color: Colors.grey[350]),
                              hintText: 'Enter Quantity',
                              alignLabelWithHint: true,
                              border: InputBorder
                                  .none, // Remove default TextField border
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.blue, // Partition color
                          thickness: 1, // Partition thickness
                          width: 1, // Width of the partition
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            iconEnabledColor: Colors.blue,
                            value: selectedValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                            items: optionList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/getBestPrice.png"),
                          fit: BoxFit.fill),
                    ),
                    alignment: Alignment.center,
                  ),
                )
              ]),
            )
          ],
        ));
  }

  getUnits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var glid = prefs.getString("glid");
    var ak = prefs.getString("AK");
    var currentPlatform = prefs.getString("platform");
    var ipAddress = prefs.getString("ipAddress");
    var mobile = prefs.getString("Mobile");
    try {
      String pathUrl =
          "https://mapi.indiamart.com//wservce/buyleads/getISQ/?encode=1&VALIDATION_GLID=$glid&generic_flag=1&APP_SCREEN_NAME=Pbr%20Isq%20Screen&format=1&AK=$ak&modid=$currentPlatform&prod_name=${widget.productName}&token=imobile@15061981&APP_USER_ID=$glid&glid=glid&APP_MODID=$currentPlatform&APP_ACCURACY=0.0&cat_type=3&APP_LATITUDE=0.0&fixed_attr=1&APP_LONGITUDE=0.0&VALIDATION_USER_IP=$ipAddress&isq_format=1&app_version_no=13.2.0&country_iso=IN&VALIDATION_USERCONTACT=$mobile";
      print("pathuurl=$pathUrl");
      http.Response response = await http.get(Uri.parse(pathUrl));
      var code = json.decode(response.body)['CODE'];
      if (code == "402" || code == "401") {
        var msg = json.decode(response.body)['MESSAGE'];
      } else if (response.statusCode == 200) {
        dynamic resultsArray = json.decode(response.body)['DATA'][0];
        print("hashMapViewData=${resultsArray.length}");
        if (resultsArray.length == 2) {
          resultsArray = resultsArray[1];
          print("hashMapViewData=${resultsArray[1]}");
        }

        // Map<String, String> hashMapViewData = getMapViewData(resultsArray);
        // print("hashMapViewData=$hashMapViewData");
        // Ensure unique values in optionList
        List<String> uniqueOptionList = getSpinnerAdapter(
            context,
            resultsArray['IM_SPEC_OPTIONS_DESC'],
            resultsArray['IM_SPEC_MASTER_DESC']);

        setState(() {
          optionList = uniqueOptionList;
          selectedValue =
              optionList.isNotEmpty ? optionList[0] : ''; // Set selected value
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void fetchSavedData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      mobNo = sharedPreferences.getString('UserContact');
      glid = sharedPreferences.getString('glid');
      ak = sharedPreferences.getString('AK');
    });
  }
}

class SpinnerAdapter {
  final List<DropdownMenuItem<String>> items;

  SpinnerAdapter(this.items);

  DropdownButton<String> buildDropdownButton(
      String value, void Function(String?) onChanged) {
    return DropdownButton<String>(
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}

List<String> getSpinnerAdapter(
    BuildContext context, String hashmap, String ques) {
  if (context == null || hashmap == null) return ["null"];

  final List<String> optionList =
      hashmap.contains('##') ? hashmap.split('##') : hashmap.split(',');

  // final List<dynamic>? optionListId = hashmap['optionsId']!.contains('##')
  //     ? hashmap['optionsId']?.split('##')
  //     : hashmap['optionsId']?.split(',');

  String? ques1 = (ques == "Quantity Unit") ? "Select Unit" : ques;

  optionList?.insert(0, '$ques1');
  print("optionList=${optionList}");
  // optionListId?.insert(0, '');
  // optionListId?.insert(0, '');

  // final List<DropdownMenuItem<String>>? dropdownItems = optionList
  //     ?.asMap()
  //     .entries
  //     .map<DropdownMenuItem<String>>(
  //       (entry) => DropdownMenuItem<String>(
  //     value: optionListId?[entry.key],
  //     child: Text(entry.value),
  //   ),
  // )
  //     .toList();
  //
  return optionList;
}

class Constants {
  static const String TYPE = "type";
  static const String QUES = "ques";
  static const String QUES_ID = "quesId";
  static const String OPTIONS = "options";
  static const String OPTIONS_ID = "optionsId";
  static const String ISCHECKED = "isChecked";
  static const String PREFILLED_DATA = "prefilledData";
}

Map<String, String> getMapViewData(dynamic jsonObject) {
  Map<String, String> map = {
    // Constants.TYPE: jsonObject['IM_SPEC_MASTER_TYPE'].toString(),
    Constants.QUES: jsonObject['IM_SPEC_MASTER_DESC'].toString(),
    // Constants.QUES_ID: jsonObject['IM_SPEC_MASTER_ID'].toString(),
    Constants.OPTIONS: jsonObject['IM_SPEC_OPTIONS_DESC'].toString(),
    // Constants.OPTIONS_ID: jsonObject['IM_SPEC_OPTIONS_ID'].toString(),
    // Constants.ISCHECKED: jsonObject[ Constants.ISCHECKED].toString(),
    // Constants.PREFILLED_DATA: jsonObject[ Constants.PREFILLED_DATA].toString(),
  };

  return map;
}

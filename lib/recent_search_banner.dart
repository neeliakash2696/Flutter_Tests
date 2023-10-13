import 'dart:convert';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LimitedChipsList extends StatefulWidget {
  @override
  State<LimitedChipsList> createState() => _LimitedChipsListState();
}

class _LimitedChipsListState extends State<LimitedChipsList> {
  List<String> dataArray = [];
  String? mobNo = "";
  String? glid = "";
  String? ak = "";
  @override
  void initState() {
    super.initState();
    fetchSavedData();
    getRecents();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Column(
        children: [
          SizedBox(height: 10),
          Wrap(
            spacing: 8.0, // Adjust horizontal spacing
            runSpacing: 8.0, // Adjust vertical spacing
            alignment:
                WrapAlignment.start, // Align chips to the start of each row
            children: dataArray.map((item) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(50.0), // Adjust border radius
                  border: Border.all(
                      width: 2.0, // Adjust border width
                      color: Colors.teal.shade400),
                ),
                child: Chip(
                  label: Text(
                    item,
                  ),
                  backgroundColor: Colors.teal[50], // Set the background color
                  labelStyle:
                      TextStyle(color: Colors.teal), // Set label text color
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  getRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var glid = prefs.getString("glid");
    var ak = prefs.getString("AK");
    var currentPlatform = prefs.getString("platform");
    var ipAddress = prefs.getString("ipAddress");
    var mobile = prefs.getString("Mobile");
    try {
      var logtime = formattedEndDate();
      String pathUrl =
          "https://mapi.indiamart.com//wservce/users/getBuyerData/?VALIDATION_GLID=$glid&APP_SCREEN_NAME=Default-Seller&count=10&AK=$ak&source=Search%20Products%20On%20Scroll&type=2&modid=$currentPlatform&token=imobile@15061981&APP_USER_ID=$glid&APP_MODID=$currentPlatform&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=$glid&VALIDATION_USER_IP=$ipAddress&logtime=$logtime&app_version_no=13.2.0&VALIDATION_USERCONTACT=$mobile";
      print("pathurl=$pathUrl");
      http.Response response = await http.get(Uri.parse(pathUrl));
      var code = json.decode(response.body)['CODE'];
      if (code == "402" || code == "401") {
        var msg = json.decode(response.body)['MESSAGE'];
      } else if (response.statusCode == 200) {
        var resultsArray = json.decode(response.body)['details']['searches'];
        dataArray.clear();
        for (var i = 0; i < resultsArray.length; i++) {
          var label = resultsArray[i]["search"];
          print(label);
          if (label != null) {
            dataArray.add(label.toString());
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  String formattedEndDate() {
    try {
      final DateFormat targetFormat = DateFormat("yyyyMMddHHmmss");
      final DateTime endDate = DateTime.now();
      final formattedEndDate = targetFormat.format(endDate);
      print("SF: Formatted Date: $formattedEndDate");
      return formattedEndDate;
    } catch (e) {
      // Handle any exceptions here.
      return ""; // Or return a default value.
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

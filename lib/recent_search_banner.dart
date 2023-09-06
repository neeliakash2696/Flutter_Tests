import 'dart:convert';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
as FlutterTests;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LimitedChipsList extends StatefulWidget {
  @override
  State<LimitedChipsList> createState() => _LimitedChipsListState();
}

class _LimitedChipsListState extends State<LimitedChipsList> {
  List<String> dataArray = [];

  @override
  void initState() {
    super.initState();
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
            alignment: WrapAlignment.start, // Align chips to the start of each row
            children: dataArray.map((item) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0), // Adjust border radius
                  border: Border.all(
                    width: 2.0, // Adjust border width
                    color: Colors.teal.shade400
                  ),
                ),
                child: Chip(
                  label: Text(item),
                  backgroundColor: Colors.teal[50], // Set the background color
                  labelStyle: TextStyle(color: Colors.teal), // Set label text color
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
    try {
      var logtime = formattedEndDate();
      String pathUrl =
        "https://mapi.indiamart.com//wservce/users/getBuyerData/?VALIDATION_GLID=136484661&APP_SCREEN_NAME=Default-Seller&count=10&AK=${FlutterTests.AK}&source=Search Products On Scroll&type=2&modid=ANDROID&token=imobile@15061981&APP_USER_ID=136484661&APP_MODID=ANDROID&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=49.36.220.222&logtime=$logtime&app_version_no=13.2.0&VALIDATION_USERCONTACT=1511122233";
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
}

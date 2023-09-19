// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tests/section.dart';
import 'package:flutter_tests/ImportantSuppilesDetailsList.dart';
import 'package:flutter_tests/view_categories.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // runApp(MyApp());
  runApp(MaterialApp(
    home: ViewCategories(),
    builder: EasyLoading.init(),
  ));
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..progressColor = Colors.teal
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.teal
    ..textColor = Colors.teal
    ..maskColor = Colors.blue
    ..maskType = EasyLoadingMaskType.clear
    ..userInteractions = true
    ..dismissOnTap = true;
  EasyLoadingToastPosition.bottom;
}

class MyApp extends StatelessWidget {
  final List<Section> sections = [
    Section(title: 'Oxygen Supplies', items: [
      "Oxygen Cylinder",
      "Portable Oxygen Cans",
      "Empty Oxygen Cylinder",
      "Oxygen Concentrator",
      "Oxygen Cylinder Manifold",
      "Oxygen Flow Meter",
      "Oxygen Mask"
    ]),
    Section(title: 'Medicines', items: [
      "Tocilizumab",
      "FabiFlu",
      "Remdesivir",
      "Dexamethasone Tablet",
      "Ivermectin",
      "Doxycycline",
      "Deflazacort"
    ]),
    Section(title: "Immunity Boosters", items: [
      "Vitamin C Tablets",
      "Zinc Sulphate Tablets",
      "Zincovit Tablets",
      "Multivitamin Syrup",
      "Vitamin D3"
    ]),
    Section(title: "Safety Essentials", items: [
      "Face Mask",
      "PPE Kits",
      "Face Shield",
      "Disposable Gloves",
      "Sneeze Guard",
      "Car Partition",
      "Surgical Caps",
      "Hand Sanitizer & Disinfectant",
      "Automatic Sanitizer Dispenser"
    ]),
    Section(title: "Medical Supplies", items: [
      "Pulse Oximeter",
      "Thermometer",
      "Steam Vaporizer",
      "Nebulizer",
      "Corona Test Kit"
    ]),
    Section(title: "Hospital Machines & Supplies", items: [
      "Ventilator",
      "BiPAP Machine",
      "CPAP Machine",
      "Oxygen Mask",
      "Patient Monitoring System",
      "Suction Machine"
    ])
  ];
  @override
  Widget build(BuildContext context) {
    // sections.insert(2, Section(title:"PBR BANNER", items:[]));
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            {
              print(sections[2].title);
              return SectionWidget(section: sections[index]);
            }
          },
          // separatorBuilder: (context, index) {
          //   return Divider(); // Add a divider between sections
          // },
        ),
      ),
      debugShowCheckedModeBanner: false,
      // builder: EasyLoading.init(),
    );
  }
}

class SectionWidget extends StatelessWidget {
  Section section;
  SectionWidget({required this.section});
  @override
  Widget build(BuildContext context) {
    print("section title: ${section.title}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            section.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: section.items.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 1,
              child: ListTile(
                  title: Text(section.items[index]),
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.teal,
                    size: 30,
                  ),
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => ViewCategories()));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImportantSuppilesDetailsList(
                                city: 0,
                                productName: section.items[index],
                                productFname: section.items[index],
                                productIndex: 0,
                                biztype: "")));
                  }),
            );
          },
        )
      ],
    );
  }
}

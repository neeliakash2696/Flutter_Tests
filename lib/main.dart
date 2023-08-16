import 'package:flutter/material.dart';
import 'package:flutter_tests/section.dart';
import 'package:flutter_tests/ImportantSuppilesDetailsList.dart';

void main() {
  runApp(MyApp());
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
      "Hand Sanitizer &amp; Disinfectant",
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
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            return SectionWidget(section: sections[index]);
          },
          // separatorBuilder: (context, index) {
          //   return Divider(); // Add a divider between sections
          // },
        ),
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  Section section;
  SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            section.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: section.items.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 1,
              child: ListTile(
                  title: Text(section.items[index]),
                trailing: Icon(Icons.keyboard_arrow_right, color: Colors.teal,size: 30,),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ImportantSuppilesDetailsList()));
                  }),
            );
          },
        )
      ],
    );
  }
}

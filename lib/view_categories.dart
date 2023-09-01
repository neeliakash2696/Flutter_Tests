import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/SearchFieldController.dart';
import 'package:flutter_tests/VoiceToTextConverter.dart';
import 'package:flutter_tests/categories_detail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;

class ViewCategories extends StatefulWidget {
  @override
  State<ViewCategories> createState() => _ViewCategoriesState();
}

class _ViewCategoriesState extends State<ViewCategories> {
  dynamic resultsArray = [];

  List<String> nameArray = [];
  List<String> fnameArray = [];
  List<String> imagesArray = [];
  List<String> idsArray = [];

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                "All Categories",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          child: IconButton(
                            icon: const Icon(
                              Icons.search,
                              size: 30,
                            ),
                            onPressed: () {},
                            color: Colors.grey[600],
                          ),
                        ),
                        // SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.none,
                            controller: TextEditingController(text: ""),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SearchFieldController(
                                            fromScreen: SearchingFromScreen
                                                .viewCategories,
                                          )));
                            },
                            decoration: const InputDecoration(
                                hintStyle:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                                hintText: 'Search for Products & Services',
                                alignLabelWithHint: true,
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 0, 0, 8)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        VoiceToTextConverter(
                                          fromScreen: VoiceSearchFromScreen
                                              .viewCategories,
                                        ),
                                    opaque: false,
                                    fullscreenDialog: true));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        "images/mic_icon_colored.png"),
                                    fit: BoxFit.cover),
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.teal[400],
      ),
      body: FutureBuilder<void>(
          future: getCategories(),
          builder: (context, snapshot) {
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 0.7),
                itemCount: resultsArray.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategoriesDetail(
                                    fname: fnameArray[index],
                                    id: idsArray[index],
                                    name: nameArray[index],
                                    api:
                                        "https://mapi.indiamart.com/wservce/im/category/?flname=${fnameArray[index]}&VALIDATION_GLID=136484661&APP_SCREEN_NAME=SUBCAT-plant-machinery-34&mid=${idsArray[index]}&AK=${FlutterTests.AK}&modid=ANDROID&token=immenu%407851&APP_USER_ID=136484661&APP_MODID=ANDROID&mtype=grp&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=61.3.38.129&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233",
                                    pageNo: 2,
                                  )));
                    },
                    child: GridTile(
                        child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                child: Image(
                                  image: CachedNetworkImageProvider(imagesArray?[
                                          index] ??
                                      "https://ik.imagekit.io/hpapi/harry.jpg"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(
                              nameArray[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )),
                  );
                });
          }),
    );
  }

  Future<void> getCategories() async {
    String path =
        "https://mapi.indiamart.com/wservce/im/category/?VALIDATION_GLID=136484661&APP_SCREEN_NAME=Default-Seller&AK=${FlutterTests.AK}&token=immenu%407851&APP_USER_ID=136484661&APP_MODID=ANDROID&mtype=group_v2&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=61.3.38.129&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233";
    http.Response response = await http.get(Uri.parse(path));
    var code = json.decode(response.body)['CODE'];
    if (code == "402") {
      var msg = json.decode(response.body)['MESSAGE'];
      print("message=$msg");
    } else if (response.statusCode == 200) {
      resultsArray = json.decode(response.body)['grps']['grp'];
      nameArray.clear();
      fnameArray.clear();
      imagesArray.clear();
      idsArray.clear();
      for (var i = 0; i < resultsArray.length; i++) {
        nameArray.add(resultsArray[i]['name']);
        imagesArray.add(resultsArray[i]['img_v2']);
        fnameArray.add(resultsArray[i]['fname']);
        idsArray.add(resultsArray[i]['id']);
      }
    }
  }
}

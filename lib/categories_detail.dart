import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/SearchFieldController.dart';
import 'package:flutter_tests/SpeechToTextConverter.dart';
import 'package:flutter_tests/VoiceToTextConverter.dart';
import 'package:http/http.dart' as http;
import 'ImportantSuppilesDetailsList.dart';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;

class CategoriesDetail extends StatefulWidget {
  @override
  State<CategoriesDetail> createState() => _CategoriesDetailState();
  String fname;
  String id;
  String name;

  String api;
  int pageNo;
  CategoriesDetail(
      {required this.fname,
      required this.id,
      required this.name,
      required this.api,
      required this.pageNo});
}

class _CategoriesDetailState extends State<CategoriesDetail> {
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
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 25,
                        color: Colors.white,
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(widget.name,
                          style: const TextStyle(fontSize: 18))),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            size: 30,
                          ),
                          onPressed: () {},
                          color: Colors.grey[600],
                        ),
                        // SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.none,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SearchFieldController(
                                            fromScreen: SearchingFromScreen
                                                .categoriesDetail,
                                            word: "",
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
                            openVoiceToTextConverter();
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
                    crossAxisCount: 2, childAspectRatio: 0.8
                    // mainAxisSpacing: 4.0, // Space between rows
                    // crossAxisSpacing: 4.0,
                    ),
                itemCount: resultsArray.length,
                itemBuilder: (context, index) {
                  // if(widget.pageNo=="2")
                  return Card(child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    double gridTileWidth = constraints.maxWidth;
                    double gridTileHeight = constraints.maxHeight;
                    return GestureDetector(
                      onTap: () {
                        print("pageno");
                        print(widget.pageNo);
                        if (widget.pageNo >= 3) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ImportantSuppilesDetailsList(
                                          city: 0,
                                          productName: nameArray[index],
                                          productFname: fnameArray[index],
                                          productIndex: 0,
                                          biztype: "")));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoriesDetail(
                                        fname: fnameArray[index],
                                        id: idsArray[index],
                                        name: nameArray[index],
                                        api:
                                            "https://mapi.indiamart.com/wservce/im/category/?flname=${fnameArray[index]}&VALIDATION_GLID=136484661&APP_SCREEN_NAME=MCAT-m_miscel-164&mid=${idsArray[index]}&AK=${FlutterTests.AK}&modid=ANDROID&token=immenu%407851&APP_USER_ID=136484661&APP_MODID=ANDROID&mtype=scat&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=61.3.38.129&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233",
                                        pageNo: (widget.pageNo) + 1,
                                      )));
                        }
                      },
                      behavior: HitTestBehavior.deferToChild,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Container(
                                width: gridTileWidth,
                                height: gridTileHeight - 60,
                                child: Image(
                                  image: NetworkImage(imagesArray?[index] ??
                                      "https://ik.imagekit.io/hpapi/harry.jpg"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Container(
                              height: 58,
                              width: gridTileWidth,
                              decoration:
                                  const BoxDecoration(color: Colors.teal),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  nameArray[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }));
                });
          }),
    );
  }

  Future<void> getCategories() async {
    String path = widget.api;
    print("api=$path");

    http.Response response = await http.get(Uri.parse(path));
    var code = json.decode(response.body)['CODE'];
    if (code == "402") {
      var msg = json.decode(response.body)['MESSAGE'];
      print("message=$msg");
    } else if (response.statusCode == 200) {
      print(widget.pageNo);
      if (widget.pageNo == 2) {
        resultsArray = json.decode(response.body)['scats']['scat'];
      } else {
        resultsArray = json.decode(response.body)['mcats']['mcat'];
      }
      fnameArray.clear();
      nameArray.clear();
      imagesArray.clear();
      idsArray.clear();
      for (var i = 0; i < resultsArray.length; i++) {
        nameArray.add(resultsArray[i]['name']);
        if (widget.pageNo == 2) {
          imagesArray.add(resultsArray[i]['auto-image']);
          fnameArray.add(resultsArray[i]['dir-fname']);
        } else {
          fnameArray.add(resultsArray[i]['fname']);
          imagesArray.add(resultsArray[i]['img-mcat-url']);
        }
        idsArray.add(resultsArray[i]['id']);
      }
    }
  }

  openVoiceToTextConverter() {
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => SpeechToTextConverter(
                onTap: (details) {
                  //
                },
                bgColor: Colors.teal,
                size: Size(
                  MediaQuery.of(context).size.width - 60,
                  MediaQuery.of(context).size.height - 300,
                ),
                fromScreen: VoiceSearchFromScreen.categoriesDetail,
                localeId: "en_US",
                selectedIndex: 0,
                cityIndex: 0),
            opaque: false,
            fullscreenDialog: true));
  }
}

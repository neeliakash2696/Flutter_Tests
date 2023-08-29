import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoriesDetail extends StatefulWidget{
  @override
  State<CategoriesDetail> createState() => _CategoriesDetailState();
  String fname;
  String id;
  String name;
  CategoriesDetail({required this.fname,required this.id, required this.name});
}

class _CategoriesDetailState extends State<CategoriesDetail> {
  dynamic resultsArray=[];
  List<String> nameArray=[];
  List<String> imagesArray=[];

  @override
  void initState() {
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child:  Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios, size: 25,color: Colors.black,)
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text(widget.name, style: TextStyle(fontSize: 18))),
                ],
              ),
            ),
            SizedBox(height: 10,),
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
                        Container(
                          child: IconButton(
                            icon: const Icon(Icons.search,size: 30,),
                            onPressed: () {
                            },
                            color: Colors.grey[600],
                          ),
                        ),
                        // SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              hintText: 'Search for Products & Services',
                              alignLabelWithHint: true,
                              border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 8)
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:
                                    AssetImage("images/mic_icon_colored.png"),
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
        builder: (context,snapshot) {
          return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8
                  // mainAxisSpacing: 4.0, // Space between rows
                  // crossAxisSpacing: 4.0,
              ),
              itemCount: resultsArray.length,
              itemBuilder: (context, index) {
                return Card(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                      double gridTileWidth = constraints.maxWidth;
                      double gridTileHeight = constraints.maxHeight;
                      return GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Container(
                                  width: gridTileWidth,
                                  height: gridTileHeight-60,
                                  child: Image(
                                    image: NetworkImage(
                                        imagesArray?[
                                        index] ??
                                            "https://ik.imagekit.io/hpapi/harry.jpg"),
                                    fit: BoxFit.fill,
                                  ),),
                              ),
                              Container(
                                height: 58,
                                  width: gridTileWidth,
                                decoration: BoxDecoration(
                                  color: Colors.teal
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    nameArray[index], textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        // fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),),
                                ),
                              )
                            ],
                          ),
                        ),
                      );}
                    ));
              });
        }
      ),
    ));
  }

  Future<void> getCategories() async{
    String path=
        "https://mapi.indiamart.com/wservce/im/category/?flname=${widget.fname}&VALIDATION_GLID=136484661&APP_SCREEN_NAME=SUBCAT-plant-machinery-34&mid=${widget.id}&AK=eyJ0eXAiOiJKV1QiLCJhbGciOiJzaGEyNTYifQ.eyJpc3MiOiJVU0VSIiwiYXVkIjoiMSoxKjEqMiozKiIsImV4cCI6MTY5MzM3ODIxMywiaWF0IjoxNjkzMjkxODEzLCJzdWIiOiIxMzY0ODQ2NjEiLCJjZHQiOiIyOS0wOC0yMDIzIn0.gz079YW-PtnRvaugw5XjwgQbl-NWky__tnG4DhCpz4E&modid=ANDROID&token=immenu%407851&APP_USER_ID=136484661&APP_MODID=ANDROID&mtype=grp&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=61.3.38.129&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233";
    // print("path=$path")
    http.Response response = await http.get(Uri.parse(path));
    var code = json.decode(response.body)['CODE'];
    if (code == "402") {
      var msg = json.decode(response.body)['MESSAGE'];
      print("message=$msg");
    } else if (response.statusCode == 200) {
      resultsArray = json.decode(response.body)['scats']['scat'];
      nameArray.clear();
      imagesArray.clear();
      for (var i = 0; i < resultsArray.length; i++) {
        nameArray.add(resultsArray[i]['name']);
        imagesArray.add(resultsArray[i]['auto-image']);
      }
      print(imagesArray);

    }
  }
}
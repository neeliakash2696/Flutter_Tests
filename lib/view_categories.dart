import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/categories_detail.dart';
import 'package:http/http.dart' as http;

class ViewCategories extends StatefulWidget{
  @override
  State<ViewCategories> createState() => _ViewCategoriesState();
}

class _ViewCategoriesState extends State<ViewCategories> {
  dynamic resultsArray=[];

  List<String> nameArray=[];
  List<String> fnameArray=[];
  List<String> imagesArray=[];
  List<String> idsArray=[];

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
              child: Text("All Categories",style: TextStyle(
                fontSize: 18
              ),),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 50,
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
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                  fontSize: 15, color: Colors.grey),
                              hintText: 'Search for Products & Services',
                              alignLabelWithHint: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(0),
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7
            ),
            itemCount: resultsArray.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CategoriesDetail(
                                  fname: fnameArray[index],
                                  id: idsArray[index],
                                  name: nameArray[index]
                              )));
                },
                child: GridTile(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200)
                      ),
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
                                  image: CachedNetworkImageProvider(
                                      imagesArray?[
                                      index] ??
                                          "https://ik.imagekit.io/hpapi/harry.jpg"),
                                  fit: BoxFit.fill,
                                ),),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(
                              nameArray[index], textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold
                              ),),
                          )
                        ],
                      ),
                    )),
              );
            });
      }
      ),

    ));
  }

  Future<void> getCategories() async{
    String path=
        "https://mapi.indiamart.com/wservce/im/category/?VALIDATION_GLID=136484661&APP_SCREEN_NAME=Default-Seller&AK=eyJ0eXAiOiJKV1QiLCJhbGciOiJzaGEyNTYifQ.eyJpc3MiOiJVU0VSIiwiYXVkIjoiMSoxKjEqMiozKiIsImV4cCI6MTY5MzM3ODQ4MywiaWF0IjoxNjkzMjkyMDgzLCJzdWIiOiIxMzY0ODQ2NjEiLCJjZHQiOiIyOS0wOC0yMDIzIn0.SJKXklpO2ylDqKDSs1ALLOylAtv1vyQlY3oabhtwdL8&token=immenu%407851&APP_USER_ID=136484661&APP_MODID=ANDROID&mtype=group_v2&APP_ACCURACY=0.0&APP_LATITUDE=0.0&APP_LONGITUDE=0.0&glusrid=136484661&VALIDATION_USER_IP=61.3.38.129&app_version_no=13.2.0_S1&VALIDATION_USERCONTACT=1511122233";
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
      print(imagesArray);

    }
  }
}
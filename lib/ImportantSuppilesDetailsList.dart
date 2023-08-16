// ignore: file_names
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImportantSuppilesDetailsList extends StatefulWidget {
  const ImportantSuppilesDetailsList({super.key});

  @override
  ImportantSuppilesDetailsListState createState() =>
      ImportantSuppilesDetailsListState();
}

class ImportantSuppilesDetailsListState
    extends State<ImportantSuppilesDetailsList> {
  // View Did Load
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Notifications",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0xff432B40),
              fontSize: 16,
              fontFamily: 'HVD Fonts',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Color(0xff432B40),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  var inkWell = InkWell(
                    onTap: () {
                      // Action
                    },
                    child: CarouselSlider(
                      items: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              height: 70,
                              width: 100,
                              alignment: Alignment.topCenter,
                              child: const Image(
                                image: CachedNetworkImageProvider(
                                    "https://ik.imagekit.io/hpapi/harry.jpg"),
                              ),
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 5, 0),
                                    child: Text(
                                      "All Life Portable Oxygen Can",
                                      style: TextStyle(
                                          color: Color(0xff432B40),
                                          fontSize: 16,
                                          fontFamily: 'HVD Fonts',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "images/indian_rupee.png"),
                                                fit: BoxFit.contain),
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Flexible(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "125/Piece",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B40),
                                              fontSize: 14,
                                              fontFamily: 'HVD Fonts',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "images/trustseal_supplier.png"),
                                                fit: BoxFit.contain),
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Flexible(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "Unatti Aerosols Product and Machines",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B40),
                                              fontSize: 14,
                                              fontFamily: 'HVD Fonts',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "images/Location.png"),
                                                fit: BoxFit.contain),
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Flexible(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "New Delhi-Badarpur",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B40),
                                              fontSize: 14,
                                              fontFamily: 'HVD Fonts',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "images/url_mp.png"),
                                                fit: BoxFit.contain),
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Flexible(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "Deals in Noida",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B40),
                                              fontSize: 14,
                                              fontFamily: 'HVD Fonts',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      options: CarouselOptions(
                        height: 380.0,
                        enlargeCenterPage: true,
                        autoPlay: false,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        viewportFraction: 0.8,
                      ),
                    ),
                  );
                  return Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: inkWell,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: file_names
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                        },
                        color: Colors.black,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: 'Oxygen'),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/mic_icon_colored.png"),
                                fit: BoxFit.cover),
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemExtent: MediaQuery.of(context).size.width / 3,
              scrollDirection: Axis.horizontal, // Set horizontal scroll direction
              itemCount: 3, // Number of list tiles
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                      title: Center(
                        child: Text("Item $index"),
                    ),
                    ),
                );
              },

              ),
            ),
            // const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  var inkWell = InkWell(
                    onTap: () {
                      // Action
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              height: 70,
                              width: 20,
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
                                          color: Color(0xff432B20),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "125/Piece",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B20),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "Unatti Aerosols Product and Machines",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B20),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "New Delhi-Badarpur",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B20),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image:
                                                    AssetImage("images/url_mp.png"),
                                                fit: BoxFit.contain),
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Flexible(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Text(
                                            "Deals in Noida",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color(0xff432B20),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomButton(),
                            CustomButton2()
                          ],

                        )
                      ],
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

class CustomButton extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(25, 8, 25, 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal), // Rectangle border
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), // Top-left circular border
              bottomLeft: Radius.circular(25), // Bottom-left circular border
            ),
          ),
          child: Center(
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/call.png"),
                        fit: BoxFit.cover),
                  ),
                  alignment: Alignment.center,
                ),
                Text(
                  'Call Now',
                  style: TextStyle(color: Colors.teal,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }
}class CustomButton2 extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal, // Rectangle border
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25), // Top-left circular border
              bottomRight: Radius.circular(25), // Bottom-left circular border
            ),
          ),
          child: Center(
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/getBestPrice.png"),
                      fit: BoxFit.cover),
              ),
              alignment: Alignment.center,
                ),
                Text(
                  'Get Best Price',
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }
}


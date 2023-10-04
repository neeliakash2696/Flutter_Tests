import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class LoginController extends StatefulWidget {
  @override
  State<LoginController> createState() => LoginControllerState();
}

class LoginControllerState extends State<LoginController> {
  bool checkStatus = false;
  TextEditingController loginTextField = TextEditingController();
  TextEditingController countrySearchTextFiled = TextEditingController();
  var countriesData;
  var results;
  bool searching = false;

  @override
  void initState() {
    super.initState();
    readJson();
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/countrylist.json');
    // print("response $response");
    countriesData = await json.decode(response);
  }

  showCountries() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          autofocus: false,
                          onChanged: (searchingText) {
                            if (searchingText.isNotEmpty) {
                              searching = true;
                              results = countriesData
                                  .where((elem) =>
                                      elem['cnname']
                                          .toString()
                                          .toLowerCase()
                                          .contains(
                                              searchingText.toLowerCase()) ||
                                      elem['cncode']
                                          .toString()
                                          .toLowerCase()
                                          .contains(
                                              searchingText.toLowerCase()))
                                  .toList();
                              setState(() {});
                              print(results);
                            } else {
                              searching = false;
                            }
                          },
                          onEditingComplete: () {},
                          onTapOutside: (event) {},
                          onTap: () {},
                          controller: countrySearchTextFiled,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            labelText: "Search Country",
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            contentPadding: const EdgeInsets.all(8),
                            filled: true,
                            fillColor: const Color.fromRGBO(233, 229, 229, 1),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                color: Color.fromARGB(255, 13, 92, 229)),
                          ),
                        ),
                      )
                    ],
                  ),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                image: CachedNetworkImageProvider(
                                    searching == true
                                        ? results[index]['cflag']
                                        : countriesData[index]['cflag']),
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(searching == true
                                  ? results[index]['cnname']
                                  : countriesData[index]['cnname']),
                              Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      searching == true
                                          ? results[index]['cncode']
                                          : countriesData[index]['cncode'],
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: searching == true
                          ? results.length
                          : countriesData.length),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => KeyboardDismisser(
          gestures: const [
            GestureType.onTap,
            GestureType.onPanUpdateDownDirection,
          ],
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.teal,
              toolbarHeight: 1,
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 60,
                            width: 200,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("images/indiamartLogo.png"),
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                          "Please enter your 10 digit mobile number to begin"),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                        height: 70,
                        width: MediaQuery.of(context).size.width - 20,
                        child: InkWell(
                          onTap: () {
                            showCountries();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "images/indiamartLogo.png"),
                                      fit: BoxFit.fill),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                "12345",
                                style: TextStyle(fontSize: 12),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded),
                              const VerticalDivider(
                                color: Colors.black,
                              ),
                              Expanded(
                                child: TextField(
                                  textInputAction: TextInputAction.go,
                                  keyboardType: TextInputType.number,
                                  autocorrect: false,
                                  autofocus: true,
                                  onChanged: (searchingText) {},
                                  onEditingComplete: () {},
                                  onTapOutside: (event) {},
                                  onTap: () {},
                                  controller: loginTextField,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                              "Don't worry! Your details are safe with us."),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("images/loginShield.png"),
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                                value: checkStatus,
                                activeColor: Colors.teal,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkStatus = value ?? false;
                                  });
                                }),
                            const Text("I accept all the "),
                            InkWell(
                              onTap: () {
                                print("Show terms");
                              },
                              child: Text(
                                "Terms",
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.grey,
                                  decorationThickness: 1,
                                  decorationStyle: TextDecorationStyle.dashed,
                                ),
                              ),
                            ),
                            const Text(" and "),
                            InkWell(
                              onTap: () {
                                print("Show Privacy policy");
                              },
                              child: Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.grey,
                                  decorationThickness: 1,
                                  decorationStyle: TextDecorationStyle.dashed,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      print("Next tapped");
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.teal,
                      child: const Center(
                          child: Text(
                        "NEXT",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600),
                      )),
                    ),
                  )
                ],
              ),
            ),
          ));
}

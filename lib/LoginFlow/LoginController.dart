import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginController extends StatefulWidget {
  @override
  State<LoginController> createState() => LoginControllerState();
}

class LoginControllerState extends State<LoginController> {
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const Text("Please enter your 10 digit mobile number to begin"),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  height: 70,
                  width: MediaQuery.of(context).size.width - 40,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Don't worry! Your details are safe with us."),
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
                child: Center(
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
    );
  }
}

// ignore_for_file: unused_import

// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tests/GlobalUtilities/GlobalConstants.dart'
    as FlutterTests;

class LocationSelector extends StatefulWidget {
  const LocationSelector({Key? key}) : super(key: key);

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  String? _currentAddress;
  Position? _currentPosition;
  TextEditingController searchBar = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode focus = FocusNode();
  List<String> citiesArrayLocal = [];

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      Navigator.pop(context);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        Navigator.pop(context);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      Geolocator.openLocationSettings();
      Navigator.pop(context);
      return false;
    }
    return true;
  }

  Future getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    // EasyLoading.show(status: "Fetching...");
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Can't fetch Location due to ${e.toString()}")));

      debugPrint(e);
      EasyLoading.dismiss();
    });
  }

  Future _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        print(place.locality);
        _currentAddress = '${place.locality}';
        EasyLoading.dismiss();
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Can't fetch Location due to ${e.toString()}")));
      debugPrint(e.toString());
      EasyLoading.dismiss();
    });
  }

  closeKeyboard(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    citiesArrayLocal = FlutterTests.citiesArray;
    getCurrentPosition();
  }

  @override
  void dispose() {
    searchBar.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, _currentAddress);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Choose Location"),
          backgroundColor: Colors.teal,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.teal,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Your Current Location is",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 20),
                          child: GestureDetector(
                            onTap: () {
                              getCurrentPosition().then((value) {
                                Navigator.pop(context, _currentAddress);
                              });
                            },
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          _currentAddress ?? "Fetching...",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              textInputAction: TextInputAction.done,
                              focusNode: focus,
                              autocorrect: false,
                              autofocus: false,
                              onChanged: (searchingText) {
                                if (searchingText.isEmpty == true) {
                                  citiesArrayLocal = FlutterTests.citiesArray;
                                } else {
                                  citiesArrayLocal = citiesArrayLocal
                                      .where((item) => item
                                          .toLowerCase()
                                          .contains(
                                              searchingText.toLowerCase()))
                                      .toList();
                                }
                                setState(() {});
                              },
                              onEditingComplete: () {
                                closeKeyboard(context);
                              },
                              onTapOutside: (event) {
                                closeKeyboard(context);
                              },
                              onTap: () {
                                // TextFeild Clicked
                              },
                              controller: searchBar,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  contentPadding: const EdgeInsets.all(8),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "Search Location"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: citiesArrayLocal.length,
                  itemBuilder: (BuildContext context, int index) {
                    var inkWell = InkWell(
                      onTap: () {
                        // Action
                        _currentAddress = citiesArrayLocal[index];
                        Navigator.pop(context, _currentAddress);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, bottom: 15, left: 20, right: 10),
                            child: Text(
                              citiesArrayLocal[index],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              height: 0.5,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.grey,
                            ),
                          )
                          // Divider(
                          //   thickness: 1,
                          // ),
                        ],
                      ),
                    );
                    return Container(
                      child: inkWell,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

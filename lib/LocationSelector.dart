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

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future getCurrentPosition() async {
    EasyLoading.show(status: "Fetching...");
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
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
      debugPrint(e);
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
    getCurrentPosition();
  }

  @override
  void dispose() {
    searchBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const Text(
                        "Your Current Location is",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () {
                          getCurrentPosition();
                        },
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 40,
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
                            textInputAction: TextInputAction.search,
                            focusNode: focus,
                            autocorrect: false,
                            autofocus: false,
                            onChanged: (searchingText) {
                              //
                            },
                            onEditingComplete: () {
                              print("Search Clicked");
                              closeKeyboard(context);
                            },
                            onTapOutside: (event) {
                              closeKeyboard(context);
                            },
                            onTap: () {
                              //
                            },
                            controller: searchBar,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: EdgeInsets.all(8),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Search Location"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: FlutterTests.citiesArray.length,
                itemBuilder: (BuildContext context, int index) {
                  var inkWell = InkWell(
                    onTap: () {
                      // Action
                      _currentAddress = FlutterTests.citiesArray[index];
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        FlutterTests.citiesArray[index],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
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
    );
  }
}

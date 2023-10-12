library FlutterTests;

import 'package:shared_preferences/shared_preferences.dart';

late String ak ;
late String mobNo ;
late String glid ;
// void fetchSavedData() async{
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     mobNo=sharedPreferences.getString('UserContact')!;
//     glid=sharedPreferences.getString('glid')!;
//     ak=sharedPreferences.getString('AK')!;
// }
// List<String> localSearchArray = [];
final List<String> citiesArray = [
  "All India",
  "Ahmedabad",
  "Bengaluru",
  "Chennai",
  "Coimbatore",
  "Delhi",
  "Faridabad",
  "Gurgaon",
  "Hyderabad",
  "Indore",
  "Jaipur",
  "Kolkata",
  "Ludhiana",
  "Mumbai",
  "New Delhi",
  "Noida",
  "Pune",
  "Rajkot",
  "Surat",
  "Thane",
  "Vadodara",
  "Roorkee"
];
final List<String> cityIdArray = [
  "",
  "70472",
  "70532",
  "70699",
  "70701",
  "69514",
  "70496",
  "70497",
  "70435",
  "70592",
  "70672",
  "70672",
  "70425",
  "70624",
  "70469",
  "70751",
  "70630",
  "70487",
  "70490",
  "70638",
  "70491",
  "73819"
];

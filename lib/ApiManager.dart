// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
// import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:livekeeping/Common/FirestoreService.dart';
// import 'package:livekeeping/Common/Reusable.dart';
// import 'package:livekeeping/Resources/PackageExportService.dart';

// import '../../Views/SessionExpireScreen/SessionExpireScreen.dart';

class ApiManager {
  static const String baseUrl = "https://mapi.indiamart.com"; // base url
  static const String getMethod = "get";
  static const String postMethod = "post";

  bool showLog = false;

  Dio dio = Dio();

  // Function to get the response from the API
  Future<Map> getResponse({
    required BuildContext context,
    required String method,
    required String webLink,
    Map? params,
    required bool showLoading,
    bool? isMultipart,
    bool? useDiffURL,
  }) async {
    try {
      // Check for internet connection

      // Show loading overlay if required
      // if (showLoading) Loader.getInstance().showOverlay(context);

      // Perform the API request
      final response = await _performRequest(
          method, webLink, params, isMultipart, useDiffURL);

      // Dismiss loading overlay if required
      // if (showLoading) Loader.getInstance().dismissOverlay();

      // Process the API response
      return _processResponse(context, response, useDiffURL);
    } catch (e) {
      // Handle any errors that occur during the API request
      return _handleError(e, showLoading, method, params, webLink);
    }
  }

  // Function to perform the API request based on the given method, URL, and parameters
  Future<Response> _performRequest(String method, String webLink, Map? params,
      bool? isMultipart, bool? useDiffURL) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    // Determine the URL based on whether a different URL is being used
    final url = useDiffURL == true ? webLink : "$baseUrl$webLink";
    // Get the token from SharedPreferences

    // Set the request headers
    final options = Options(headers: {
      "Content-Type": "application/json",
    });

    // Perform the request based on the method (GET or POST)
    final response = await (method == getMethod
        ? dio.get(url)
        : dio.post(url,
            data: isMultipart == true
                ? FormData.fromMap(params as Map<String, dynamic>)
                : params,
            options: options));

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final duration = endTime - startTime;
    log("************************** Time **************************\n$duration ms\n****************************************************");
    // Log the API request for monitoring purposes

    // Log the API response if required
    if (showLog && useDiffURL == null) {
      try {
        var encodedJson = jsonDecode(response.data);
      } catch (e) {
        log(response.data.toString());
      }
    }

    return response;
  }

  // Function to process the API response and handle token expiration
  Map _processResponse(
      BuildContext context, Response response, bool? useDiffURL) {
    if (useDiffURL == true) {
      return response.data;
    } else {
      final responseData = jsonDecode(response.data);
      _isTokenExpired(context, responseData);
      return responseData;
    }
  }

  // Function to handle errors that occur during the API request
  Map _handleError(dynamic error, bool showLoading, String method, Map? params,
      String webLink) {
    // if (showLoading) CircularProgressIndicator();

    if (error is FormatException) {
      var uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      return {"error": error.message};
    } else if (error is DioException) {
      final statusCode = error.response!.statusCode!;
      final errorMessage = statusCode == 404
          ? "Page Not Found"
          : statusCode == 500
              ? "Internal Server Error"
              : "Uncaught Error";

      return {"error": errorMessage};
    }

    return {"error": "Unknown Error"};
  }

  // Function to check if the token has expired and show a session expire dialog if required
  void _isTokenExpired(BuildContext context, Map response) {
    // final message = response["message"];
    // if (message ==
    //     "API Key provided is Invalid or Expired. Please provide updated token.") {
    //   sessionExpireDialog++;
    //   if (!isSessionExpiredSceen) {
    //     isSessionExpiredSceen = true;
    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(builder: (context) => const SessionExpireScreen()),
    //       (route) => false,
    //     ).then((value) => sessionExpireDialog = 0);
    //     return;
    //   }
    // }
  }

  static Log_APIResponse(
      {required String methondName,
      required String webUrl,
      required Map? params,
      required Object? response}) {
    if (kDebugMode) {
      if (methondName == ApiManager.getMethod) {
        log("\n\n**************************URL**************************\n\n$webUrl\n\n");
        log("\n\n**************************RESPONSE**************************\n\n${const JsonEncoder.withIndent(' ').convert(response)}\n\n");
      } else {
        log("\n\n**************************URL**************************\n\n$webUrl\n\n");
        log("\n\n**************************REQUESTS**************************\n\n${const JsonEncoder.withIndent(' ').convert(params)}\n\n");
        log("\n\n**************************RESPONSE**************************\n\n${const JsonEncoder.withIndent(' ').convert(response)}\n\n");
      }
    }
  }
}

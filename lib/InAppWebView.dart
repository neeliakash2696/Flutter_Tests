import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// ignore: camel_case_types, must_be_immutable
class webview_class extends StatefulWidget {
  webview_classState createState() => webview_classState();
  String initialUrl;
  String title;
  String navMode;
  webview_class({
    Key? key,
    required this.initialUrl,
    required this.title,
    required this.navMode, // 0 for normal; 1 for forced
  }) : super(key: key);
}

class webview_classState extends State<webview_class> {
  late InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: const Color(0xff432B40),
      ),
      onRefresh: () async {
        if(!kIsWeb) {
          if (Platform.isAndroid) {
            webViewController.reload();
          } else if (Platform.isIOS) {
            webViewController.loadUrl(
                urlRequest: URLRequest(url: await webViewController.getUrl()));
          }
        } else {
          webViewController.reload();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          // centerTitle: true,
          title: Text(
            widget.title,
            // textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 17,),
          ),
          backgroundColor: Colors.teal[400],
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: const Color(0xff432B40),
              onPressed: () {
                if (widget.navMode == "0") {
                  webViewController.canGoBack().then((value) {
                    if (value) {
                      webViewController.goBack();
                    } else {
                      Navigator.pop(context);
                    }
                  });
                } else if (widget.navMode == "1") {
                  Navigator.pop(context);
                }
              }),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest:
                          URLRequest(url: Uri.parse(widget.initialUrl)),
                      initialOptions: options,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController.endRefreshing();
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      onLoadError: (controller, url, code, message) {
                        pullToRefreshController.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                        });
                      },
                      onUpdateVisitedHistory:
                          (controller, url, androidIsReload) {
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print("Console Msg is $consoleMessage");
                      },
                    ),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

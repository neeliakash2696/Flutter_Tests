// import 'dart:html';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdClass extends StatefulWidget {
  @override
  State<AdClass> createState() => _AdClassState();
}

class _AdClassState extends State<AdClass> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    MobileAds.instance.initialize();
    loadAd();
    super.initState();
    // Load ads.
  }

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  /// Loads a banner ad.
  Future<void> loadAd() async {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_bannerAd != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    } else
      return Card(
        color: Colors.grey[200],
        child: Container(
          height: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(3)),
                child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Text(
                      "Ad",
                      style: TextStyle(color: Colors.grey.shade400),
                    )),
              )
            ],
          ),
        ),
      );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


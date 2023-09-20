//
// Created by ckckck on 2018/9/19.
//

// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tests/search.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:ui' show Image;

import 'package:speech_to_text/speech_to_text.dart';

import 'ImportantSuppilesDetailsList.dart';

enum VoiceSearchFromScreen {
  def,
  impSuppliesList,
  viewCategories,
  categoriesDetail
}

class SpeechToTextConverter extends StatefulWidget {
  final Function(TapDownDetails) onTap;
  // Size size;
  Size imgSize;
  Offset imgOffset;
  double waveAmplitude;
  double wavePhase;
  double waveFrequency;
  double heightPercentange;
  bool roundImg;
  String localeId;
  int selectedIndex;
  VoiceSearchFromScreen fromScreen;
  // static var localeid = 'en_US';
  // ImageProvider<dynamic> imageProvider;
  Color bgColor;
  int cityIndex;

  SpeechToTextConverter(
      {required this.onTap,
      // required this.size,
      this.imgSize = const Size(60.0, 60.0),
      this.imgOffset = const Offset(0.0, 0.0),
      this.waveAmplitude = 10.0,
      this.waveFrequency = 1.6,
      this.wavePhase = 10.0,
      required this.bgColor,
      this.roundImg = true,
      this.heightPercentange = 0.43,
      required this.fromScreen,
      required this.localeId,
      required this.selectedIndex,
      required this.cityIndex});

  @override
  State<StatefulWidget> createState() => _SpeechToTextConverterState();
}

class _SpeechToTextConverterState extends State<SpeechToTextConverter>
    with TickerProviderStateMixin {
  // String audioStatus = "Click on Mic when ready";
  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  bool recording = false;
  String voiceConvertedText = 'Listening...';
  late AnimationController _waveControl = new AnimationController(
      vsync: this, duration: const Duration(seconds: 2));
  late Animation<double> _wavePhaseValue =
      Tween(begin: widget.wavePhase, end: 360 + widget.wavePhase)
          .animate(_waveControl);
  Image? image;
  TapDownDetails? details;
  bool _isListeningToStream = false;
  ImageStream? _imageStream;
  // Size? imgSize;
  int timerTime = 0;
  String lastError = '';
  String lastStatus = '';
  final List<String> chipTexts = ["English", "Hindi"];

  @override
  void initState() {
    super.initState();
    // imgSize = widget.imgSize;
    _waveControl = new AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    _wavePhaseValue =
        Tween(begin: widget.wavePhase, end: 360 + widget.wavePhase)
            .animate(_waveControl);
    _wavePhaseValue.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _waveControl.reset();
        _waveControl.forward();
      }
    });
    _waveControl.forward();
    if (speechToText.isListening) {
      cancelListening();
    }
    _initSpeech().then((value) => _startListening(widget.localeId));
  }

  @override
  void didUpdateWidget(SpeechToTextConverter oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if (TickerMode.of(context))
      _listenToStream();
    else
      _stopListeningToStream();

    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  Future _initSpeech() async {
    speechEnabled = await speechToText.initialize();
  }

  late Timer timer;

  void _startListening(String locale) {
    startTimer();
    voiceConvertedText = "Listening...";
    speechToText.listen(
      onResult: _onSpeechResult,
      localeId: locale,
      onDevice: false,
      cancelOnError: false,
      partialResults: true,
      // listenFor: const Duration(seconds: 5),
    );
    print("Started Lsitening=$locale");
    recording = true;
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    // setState(() {
    voiceConvertedText = result.recognizedWords;
    print(widget.localeId);
    print(voiceConvertedText);
    // });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
      print("Error $lastError");
    });
  }

  _stopListening() {
    speechToText.stop();
    print("stopped Listening");
    // audioStatus = "Tap on the Mic to speak again";
    recording = false;
    speechEnabled = false;
  }

  void cancelListening() {
    speechToText.cancel();
    voiceConvertedText = "Tap on the Mic to speak again";
    setState(() {});
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }

  void startTimer() {
    timerTime = 7;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (timerTime == 0) {
          timer.cancel();
          if (voiceConvertedText == "Listening...") {
            voiceConvertedText = "Tap on the Mic to speak again";
            _stopListening();
            setState(() {});
          } else {
            timer.cancel();
            recording = false;
            speechEnabled = false;
            _stopListening();
            proceedForSearch();
          }
        } else {
          setState(() {
            timerTime--;
          });
        }
        // print("time left $timerTime");
      },
    );
  }

  Future proceedForSearch() async {
    switch (widget.fromScreen) {
      case VoiceSearchFromScreen.def:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImportantSuppilesDetailsList(
                      productName: voiceConvertedText,
                      productFname: voiceConvertedText,
                      productIndex: 0,
                      biztype: "",
                      city: widget.cityIndex,
                    )));
        break;
      case VoiceSearchFromScreen.impSuppliesList:
        Navigator.pop(context, voiceConvertedText);
        break;
      case VoiceSearchFromScreen.viewCategories:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Search(
                      productName: voiceConvertedText,
                      productFname: voiceConvertedText,
                      productIndex: 0,
                      biztype: "",
                      city: widget.cityIndex,
                    )));
      case VoiceSearchFromScreen.categoriesDetail:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Search(
                      productName: voiceConvertedText,
                      productFname: voiceConvertedText,
                      productIndex: 0,
                      biztype: "",
                      city: widget.cityIndex,
                    )));
    }
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream?.addListener(ImageStreamListener(_handleImageChanged));
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) return;
    _imageStream?.removeListener(ImageStreamListener(_handleImageChanged));
    _isListeningToStream = false;
  }

  @override
  void dispose() {
    if (timer != null && timer.isActive) {
      timer.cancel();
    }
    _stopListening();
    _waveControl.dispose();
    super.dispose();
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    if (imageInfo == null) {
      return;
    }
    // _caculatePercentangeSize(imageInfo);
    setState(() {
      image = imageInfo.image;
      _waveControl.forward();
    });
  }

  // void _caculatePercentangeSize(ImageInfo imageInfo) {
  //   if (imgSize!.width == 0.0 && imgSize!.height == 0.0) {
  //     imgSize = Size(
  //         imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());
  //   } else if (imgSize!.isEmpty) {
  //     if (imgSize!.width == 0.0) {
  //       imgSize = Size(
  //           imageInfo.image.width * imgSize!.height / imageInfo.image.height,
  //           imgSize!.height);
  //     } else {
  //       imgSize = Size(imgSize!.width,
  //           imageInfo.image.height * imgSize!.width / imageInfo.image.width);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // late Timer timer;
    late int start;
    String tappedIndex = "-1";
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
      backgroundColor: Colors.transparent.withOpacity(0.6),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTapDown: (TapDownDetails details1) {
              details = details1;
            },
            onTap: () {
              _startListening(widget.localeId);
            },
            child: Stack(
              children: [
                Container(
                  child: CustomPaint(
                    painter: _MyWavePaint(
                        details: details,
                        image: image,
                        bgColor: widget.bgColor,
                        // imageSize: Size(
                        //   MediaQuery.of(context).size.width - 60,
                        //   MediaQuery.of(context).size.height * 0.6,
                        // ),
                        heightPercentange: widget.heightPercentange,
                        repaint: _waveControl,
                        imgOffset: widget.imgOffset,
                        roundImg: widget.roundImg,
                        waveFrequency: widget.waveFrequency,
                        wavePhaseValue: _wavePhaseValue,
                        waveAmplitude: widget.waveAmplitude,
                        textForListening: voiceConvertedText),
                    size: Size(
                      MediaQuery.of(context).size.width - 60,
                      MediaQuery.of(context).size.height - 300,
                    ),
                  ),
                ),
                Positioned(
                  left: (MediaQuery.of(context).size.width) /
                      4, // Adjust the horizontal position as needed
                  top: MediaQuery.of(context).size.height -
                      370, // Adjust the vertical position as needed
                  child: Container(
                    height: 50,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: chipTexts.length,
                      itemBuilder: (BuildContext context, int index) {
                        var inkWell = InkWell(
                            onTap: () async {
                              if (index == 0) {
                                widget.localeId = "en_US";
                                widget.selectedIndex = 0;
                              } else if (index == 1) {
                                widget.localeId = "hi_IN";
                                widget.selectedIndex = 1;
                              }
                              if (speechToText.isListening == true) {
                                cancelListening();
                                timer.cancel();
                                EasyLoading.show(status: "Please wait");
                                Future.delayed(Duration(seconds: 1), () {
                                  EasyLoading.dismiss();
                                  _startListening(widget.localeId);
                                });
                              } else {
                                _startListening(widget.localeId);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  if (index == 0) ...[
                                    const SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                  Text(chipTexts[index]),
                                ],
                              ),
                            ));
                        return Card(
                          color: index == widget.selectedIndex
                              ? Colors.teal.shade200
                              : Colors.grey.shade300,
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: inkWell,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyWavePaint extends CustomPainter {
  _MyWavePaint({
    // required this.onChipClicked,
    required this.details,
    required this.image,
    // required this.imageSize,
    required this.imgOffset,
    required this.bgColor,
    required this.heightPercentange,
    required this.waveFrequency,
    required this.wavePhaseValue,
    required this.waveAmplitude,
    required Listenable repaint,
    required this.textForListening,
    this.roundImg = true,
  }) : super(repaint: repaint);

  // final Function(String) onChipClicked;
  TapDownDetails? details;
  String textForListening;
  double waveAmplitude;
  Animation<double> wavePhaseValue;
  double waveFrequency;
  double heightPercentange;
  Offset imgOffset;
  bool roundImg;
  Image? image;
  Color bgColor;
  // Size? imageSize;
  Path path1 = Path();
  Path path2 = Path();
  Path path3 = Path();
  double _tempa = 0.0;
  double _tempb = 0.0;
  double viewWidth = 0.0;
  Paint mPaint = Paint();
  Paint mPaint1 = Paint();
  Rect? rect;
  IconData micIcon = Icons.mic;
  double micIconSize = 48.0; // Customize the mic icon size
  double micIconX = 0.0; // X-coordinate for the mic icon
  double micIconY = 20.0; // Y-coordinate for the mic icon (adjust as needed)
  String? labelText =
      "Tell us what you need"; // Text to be displayed above the microphone icon
  TextStyle labelTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 25.0, // You can adjust the font size
  );
  TextStyle listenTextStyle = TextStyle(
    color: Colors.teal[300],
    fontWeight: FontWeight.bold,
    fontSize: 20.0, // You can adjust the font size
  );

  @override
  void paint(Canvas canvas, Size size) {
    var viewCenterY = size.height * heightPercentange;
    viewWidth = size.width;
    if (bgColor != null) {
      mPaint.color = bgColor;
      if (rect == null) {
        rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
      }
      canvas.drawRect(rect!, mPaint);
      if (labelText != null) {
        final textPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: labelText,
            style: labelTextStyle,
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: size.width);

        double textX = (size.width - textPainter.width) / 2;
        double textY = micIconY;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
    _fillPath(viewCenterY, size);

    mPaint.color = const Color(0xc0ffffff);
    canvas.drawPath(path1, mPaint);

    mPaint.color = const Color(0xB0ffffff);
    canvas.drawPath(path2, mPaint);
    _drawMicIcon(canvas, size);

    mPaint.color = const Color(0x80ffffff);
    canvas.drawPath(path3, mPaint);
    if (textForListening != null) {
      final textPadding =
          const EdgeInsets.all(8.0); // Adjust the padding value as needed

      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: textForListening,
          style: listenTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width);

      double textX = (size.width - textPainter.width) / 2;
      double textY = heightPercentange +
          250; // Adjust the vertical position with top padding
      textPainter.paint(canvas, Offset(textX, size.height - 120));
      mPaint1.color = Colors.teal[300] ?? Colors.grey;
      mPaint1.style = PaintingStyle.stroke;
      List<double> chipPositions = [
        size.width / 2 - 60,
        size.width / 2 + 60
      ]; // Add X coordinates for each chip
    }
  }

  void _drawMicIcon(Canvas canvas, Size size) {
    if (micIcon != null) {
      final iconData = Icons.mic;

      final textSpan = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: micIconSize,
          color: Colors.grey,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final iconX = (size.width - textPainter.width) / 2;
      final iconY = heightPercentange + 100;

      textPainter.paint(canvas, Offset(iconX, iconY));
      final iconRect = Rect.fromPoints(
        Offset(iconX, iconY),
        Offset(iconX + textPainter.width, iconY + textPainter.height),
      );

      if (details != null &&
          iconRect != null &&
          iconRect.contains(details!.localPosition)) {
        // print('Mic clicked');
      }
    }
  }

  void _fillPath(double viewCenterY, Size size) {
    path1.reset();
    path2.reset();
    path3.reset();
    path1.moveTo(
        0.0,
        viewCenterY -
            waveAmplitude * _getSinY(wavePhaseValue.value, waveFrequency, -1));
    path2.moveTo(
        0.0,
        viewCenterY -
            1.3 *
                waveAmplitude *
                _getSinY(wavePhaseValue.value + 90, waveFrequency, -1));
    path3.moveTo(
        0.0,
        viewCenterY +
            waveAmplitude * _getSinY(wavePhaseValue.value, waveFrequency, -1));

    for (int i = 0; i < size.width - 1; i++) {
      path1.lineTo(
          (i + 1).toDouble(),
          viewCenterY -
              waveAmplitude *
                  _getSinY(wavePhaseValue.value, waveFrequency, (i + 1)));
      path2.lineTo(
          (i + 1).toDouble(),
          viewCenterY -
              1.3 *
                  waveAmplitude *
                  _getSinY(
                      wavePhaseValue.value + 90, 0.8 * waveFrequency, (i + 1)));
      path3.lineTo(
          (i + 1).toDouble(),
          viewCenterY +
              waveAmplitude *
                  _getSinY(wavePhaseValue.value, waveFrequency, -1));
    }
    path1.lineTo(size.width, size.height);
    path2.lineTo(size.width, size.height);
    path3.lineTo(size.width, size.height);

    path1.lineTo(0.0, size.height);
    path2.lineTo(0.0, size.height);
    path3.lineTo(0.0, size.height);

    path1.close();
    path2.close();
    path3.close();
  }

  @override
  bool shouldRepaint(_MyWavePaint oldDelegate) {
    return false;
  }

  double _getSinY(
      double startradius, double waveFrequency, int currentposition) {
    if (_tempa == 0) _tempa = pi / viewWidth;
    if (_tempb == 0) {
      _tempb = 2 * pi / 360.0;
    }
    return (sin(
        _tempa * waveFrequency * (currentposition + 1) + startradius * _tempb));
  }
}

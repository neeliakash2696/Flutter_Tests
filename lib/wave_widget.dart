//
// Created by ckckck on 2018/9/19.
//

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_tests/VoiceToTextConverter.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:ui' show Image, ParagraphStyle;

import 'package:speech_to_text/speech_to_text.dart';

import 'ImportantSuppilesDetailsList.dart';

class WaveWidget extends StatefulWidget {
  final Function(TapDownDetails) onTap;
  Size size;
  Size imgSize;
  Offset imgOffset;
  double waveAmplitude;
  double wavePhase;
  double waveFrequency;
  double heightPercentange;
  bool roundImg;
  String textForListening;
  static var localeid = 'en_US';
  // ImageProvider<dynamic> imageProvider;
  Color bgColor;

  WaveWidget(
      {required this.onTap,
      required this.size,
      this.imgSize = const Size(60.0, 60.0),
      this.imgOffset = const Offset(0.0, 0.0),
      this.waveAmplitude = 10.0,
      this.waveFrequency = 1.6,
      this.wavePhase = 10.0,
      required this.bgColor,
      this.roundImg = true,
      this.heightPercentange = 0.6,
      required this.textForListening});

  @override
  State<StatefulWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {
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
  Size? imgSize;
  int timerTime = 0;

  @override
  void initState() {
    super.initState();
    imgSize = widget.imgSize;
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
    _initSpeech().then((value) => _startListening(widget.textForListening));
  }
  // String previousLocaleId = WaveWidget.localeid; // Store the previous localeid

  @override
  void didUpdateWidget(WaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _initSpeech().then((value) => _startListening(WaveWidget.localeid));
    // // Check if localeid has changed
    // if (previousLocaleId != WaveWidget.localeid) {
    //   print("localeidh=${WaveWidget.localeid}");
    //   // Call _startListening with the new localeid
    //   // _stopListening();
    //   previousLocaleId = WaveWidget.localeid; // Update the previous localeid
    // }
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
              _startListening(widget.textForListening);
              print(
                  "Mic icon clicked=$voiceConvertedText"); // You can pass additional details if needed
            },
            child: CustomPaint(
              painter: _MyWavePaint(
                  // onChipClicked: (locale) {
                  //   _stopListening();
                  //   // setState(() {
                  //   if (WaveWidget.localeid != locale) {
                  //     WaveWidget.localeid = locale;
                  //     _startListening(WaveWidget.localeid);
                  //     // _initSpeech().then((value) =>_startListening(WaveWidget.localeid));
                  //   }

                  //   // });
                  // },
                  details: details,
                  image: image,
                  bgColor: widget.bgColor,
                  imageSize: imgSize,
                  heightPercentange: widget.heightPercentange,
                  repaint: _waveControl,
                  imgOffset: widget.imgOffset,
                  roundImg: widget.roundImg,
                  waveFrequency: widget.waveFrequency,
                  wavePhaseValue: _wavePhaseValue,
                  waveAmplitude: widget.waveAmplitude,
                  textForListening: voiceConvertedText),
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }

  Future _initSpeech() async {
    speechEnabled = await speechToText.initialize();
    // setState(() {});
  }

  late Timer timer;

  void _startListening(String locale) async {
    startTimer();
    voiceConvertedText = "Listening...";
    await speechToText.listen(
      onResult: _onSpeechResult,
      localeId: locale,
      onDevice: false,
      // listenFor: const Duration(seconds: 5),
    );
    // voiceConvertedText = "";
    print("Started Lsitening=$locale");
    // audioStatus = "Listening...";
    recording = true;
    setState(() {});
  }

  _stopListening() async {
    await speechToText.stop();
    print("stopped Listening");
    // audioStatus = "Tap on the Mic to speak again";
    recording = false;
    speechEnabled = false;
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      voiceConvertedText = result.recognizedWords;
      print(voiceConvertedText);
    });
  }

  void startTimer() {
    // late int start;
    timerTime = 5;
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
      },
    );
  }

  Future proceedForSearch() async {
    // switch (widget.fromScreen) {
    //   case VoiceSearchFromScreen.def:
    Navigator.pop(context, voiceConvertedText);
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ImportantSuppilesDetailsList(
    //             productName: voiceConvertedText,
    //             productFname: voiceConvertedText,
    //             productIndex: 0,
    //             biztype: "",
    //             screen: "search"
    //         )));
    //   break;
    // case VoiceSearchFromScreen.impSuppliesList:
    //   Navigator.pop(context, voiceConvertedText);
    //   break;
    // case VoiceSearchFromScreen.viewCategories:
    //   Navigator.pop(context);
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => ImportantSuppilesDetailsList(
    //               productName: voiceConvertedText,
    //               productFname: voiceConvertedText,
    //               productIndex: 0,
    //               biztype: "",
    //               screen: "search"
    //           )));
    // case VoiceSearchFromScreen.categoriesDetail:
    //   Navigator.pop(context);
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => ImportantSuppilesDetailsList(
    //               productName: voiceConvertedText,
    //               productFname: voiceConvertedText,
    //               productIndex: 0,
    //               biztype: "",
    //               screen: "search"
    //           )));
    // }
  }

  // _stopListening() async {
  //     await speechToText.stop();
  //   print("stopped Listening");
  //   info = "Tap on the Mic to speak again";
  //     recording = false;
  //     speechEnabled = false;
  //     if (timer != null && timer.isActive) {
  //       timer.cancel();
  //     }
  //   }
  //
  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //   voiceConvertedText = result.recognizedWords;
  //   print("voiceConvertedText=$voiceConvertedText");
  //   });
  // }
  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream?.key) return;

    if (_isListeningToStream)
      _imageStream?.removeListener(_handleImageChanged as ImageStreamListener);

    _imageStream = newStream;
    if (_isListeningToStream)
      _imageStream?.addListener(_handleImageChanged as ImageStreamListener);
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
    // chipclick=false;
    super.dispose();
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    if (imageInfo == null) {
      return;
    }
    _caculatePercentangeSize(imageInfo);
    setState(() {
      image = imageInfo.image;
      _waveControl.forward();
    });
  }

  void _caculatePercentangeSize(ImageInfo imageInfo) {
    if (imgSize!.width == 0.0 && imgSize!.height == 0.0) {
      imgSize = Size(
          imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());
    } else if (imgSize!.isEmpty) {
      if (imgSize!.width == 0.0) {
        imgSize = Size(
            imageInfo.image.width * imgSize!.height / imageInfo.image.height,
            imgSize!.height);
      } else {
        imgSize = Size(imgSize!.width,
            imageInfo.image.height * imgSize!.width / imageInfo.image.width);
      }
    }
  }
}

class _MyWavePaint extends CustomPainter {
  _MyWavePaint({
    // required this.onChipClicked,
    required this.details,
    required this.image,
    required this.imageSize,
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
  Size? imageSize;
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
  int? _value = 0;
  TextStyle labelTextStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 30.0, // You can adjust the font size
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
      mPaint1.color = Colors.teal[300]!;
      mPaint1.style = PaintingStyle.stroke;
      final List<String> chipTexts = ["English", "Hindi"];
      List<bool> chipsSelection = [true, false];
      List<double> chipPositions = [
        size.width / 2 - 60,
        size.width / 2 + 60
      ]; // Add X coordinates for each chip
      Container(
        height: 40,
        width: 40,
        color: Colors.black26,
      );
      List<Widget>.generate(
        chipTexts.length,
        (int index) {
          return ChoiceChip(
            selectedColor: Colors.teal,
            label: Text(
              chipTexts[index],
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            selected: _value == index,
            onSelected: (bool selected) {},
          );
        },
      ).toList();
      // for (int i = 0; i < chipPositions.length; i++) {
      //   final position = chipPositions[i];
      //   final chipY =
      //       size.height - 40; // Adjust the vertical position of the chips
      //   final chipWidth = 100.0; // Adjust the chip width as needed
      //   final chipHeight = 30.0; // Adjust the chip height as needed
      //   final chipRadius =
      //       const Radius.circular(20.0); //  Adjust the chip size as needed
      //   final chipRect = RRect.fromRectAndRadius(
      //     Rect.fromCenter(
      //       center: Offset(position, chipY),
      //       width: chipWidth,
      //       height: chipHeight,
      //     ),
      //     chipRadius,
      //   );
      //   // Draw the chip
      //   final borderPath = Path();
      //   borderPath.addRRect(chipRect);
      //   canvas.drawPath(borderPath, mPaint1);
      //   final paragraphStyle =
      //       ParagraphStyle(textAlign: TextAlign.center, fontSize: 16.0);
      //   // Draw text inside the chip
      //   final textPainter = TextPainter(
      //     text: TextSpan(
      //       text: chipTexts[i],
      //       style: TextStyle(color: Colors.teal[300], fontSize: 16.0),
      //     ),
      //     textDirection: TextDirection.ltr,
      //   );

      //   textPainter.layout(
      //     minWidth: 0,
      //     maxWidth: chipWidth - 16.0,
      //   );
      //   final textX = chipRect.center.dx - textPainter.width / 2;
      //   final textY = chipRect.center.dy - textPainter.height / 2;
      //   textPainter.paint(canvas, Offset(textX, textY));
      //   if (details != null && chipRect.contains(details!.localPosition)) {
      //     print('Chip clicked: ${chipTexts[i]}');
      //     // if (chipTexts[i] == "English") {
      //     //   onChipClicked('en_US');
      //     //   // WaveWidget.localeid = "en_US";
      //     // } else if (chipTexts[i] == "Hindi") {
      //     //   onChipClicked('hi_IN');
      //     //   // WaveWidget.localeid = "hi_IN";
      //     // }
      //   }
      // }
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

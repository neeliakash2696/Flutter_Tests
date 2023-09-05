//
// Created by ckckck on 2018/9/19.
//

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Image;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:ui' show Image;

import 'package:speech_to_text/speech_to_text.dart';

import 'ImportantSuppilesDetailsList.dart';
import 'VoiceToTextConverter.dart';

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
  // ImageProvider<dynamic> imageProvider;
  Color bgColor;

  WaveWidget(
      {
        required this.onTap,
        required this.size,
        this.imgSize = const Size(60.0, 60.0),
        this.imgOffset = const Offset(0.0, 0.0),
        this.waveAmplitude = 10.0,
        this.waveFrequency = 1.6,
        this.wavePhase = 10.0,
        required this.bgColor,
        this.roundImg = true,
        this.heightPercentange = 0.6,
        required this.textForListening
      });

  @override
  State<StatefulWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {

  String info = "Click on Mic when ready";
  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  bool recording = false;
  String voiceConvertedText = 'Listening...';
  late AnimationController _waveControl=new AnimationController(vsync: this, duration: Duration(seconds: 2));
  late Animation<double> _wavePhaseValue=Tween(begin: widget.wavePhase, end: 360 + widget.wavePhase)
      .animate(_waveControl);
  Image? image;
  TapDownDetails? details;
  bool _isListeningToStream = false;
  ImageStream? _imageStream;
   Size? imgSize;

  @override
  void initState() {
    super.initState();
    imgSize = widget.imgSize;
    _waveControl =
    new AnimationController(vsync: this, duration: Duration(seconds: 2));
    _wavePhaseValue =
        Tween(begin: widget.wavePhase, end: 360 + widget.wavePhase)
            .animate(_waveControl);
    _wavePhaseValue.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _waveControl.reset();
        _waveControl.forward();
      }
    });
    // if (widget.imageProvider == null) {
      _waveControl.forward();
    // }
  }

  @override
  void didChangeDependencies() {

      if (TickerMode.of(context))
        _listenToStream();
      else
        _stopListeningToStream();
    // }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(WaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.imageProvider != oldWidget.imageProvider) _resolveImage();
  }

  @override
  void reassemble() {
    // if (widget.imageProvider != null)
    //   _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    // late Timer timer;
    late int start;
    return GestureDetector(
      onTapDown: (TapDownDetails details1){
        details=details1;
      },
        onTap: () {
          _initSpeech().then((value) => _startListening());
          print("Mic icon clicked=$voiceConvertedText"); // You can pass additional details if needed
    },
      child:CustomPaint(
      painter: _MyWavePaint(
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
          waveAmplitude: widget.waveAmplitude, textForListening: voiceConvertedText),
      size: widget.size,
    ));

  }
  Future _initSpeech() async {
    speechEnabled = await speechToText.initialize();
    // setState(() {});
  }

  void _startListening() async {
    startTimer();
    voiceConvertedText = "Listening...";
    await speechToText.listen(onResult: _onSpeechResult);
    // voiceConvertedText = "";
    print("Started Lsitening");
    info = "Listening...";
    recording = true;
    // setState(() {});
  }
  void startTimer() {
    late Timer timer;
    late int start;
    start = 5;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          timer.cancel();
          if (voiceConvertedText == "") {
            _stopListening();
            voiceConvertedText="Tap on mic to speak again";
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
            start--;
          });
        }
      },
    );
  }
  proceedForSearch() {
    // switch (widget.fromScreen) {
    //   case VoiceSearchFromScreen.def:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImportantSuppilesDetailsList(
                    productName: voiceConvertedText,
                    productFname: voiceConvertedText,
                    productIndex: 0,
                    biztype: "",
                    screen: "search"
                )));
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
  _stopListening() async {
    await speechToText.stop();
    print("stopped Listening");
    info = "Tap on the Mic to speak again";
    recording = false;
    speechEnabled = false;
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    // setState(() {
    voiceConvertedText = result.recognizedWords;
    print(voiceConvertedText);
    // });
  }
  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream?.key) return;

    if (_isListeningToStream) _imageStream?.removeListener(_handleImageChanged as ImageStreamListener);

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream?.addListener(_handleImageChanged as ImageStreamListener);
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
    // if (widget.imageProvider != null) {
    //   _stopListeningToStream();
    //   widget.imageProvider.evict();
    // }
    _waveControl.dispose();
    super.dispose();
  }

  // void _resolveImage() {
  //   try {
  //     var asset = widget.imageProvider;
  //     final ImageStream newStream = asset.resolve(
  //         createLocalImageConfiguration(context, size: widget.imgSize));
  //     assert(newStream != null);
  //     _updateSourceStream(newStream);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

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
        this.roundImg = true,})
      : super(repaint: repaint);

  TapDownDetails? details;
  String textForListening;
  /**
   * 振幅
   */
  double waveAmplitude;

  /**
   * 角度
   */
  Animation<double> wavePhaseValue;

  /**
   * 频率
   */
  double waveFrequency;

  /**
   * x轴位置百分比
   */
  double heightPercentange;

  /**
   * 图标偏移
   */
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
  IconData micIcon = Icons.mic; // Add your mic icon
  double micIconSize = 48.0; // Customize the mic icon size
  double micIconX = 0.0; // X-coordinate for the mic icon
  double micIconY = 20.0; // Y-coordinate for the mic icon (adjust as needed)
  String? labelText="Tell us what you need"; // Text to be displayed above the microphone icon
  TextStyle labelTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 30.0, // You can adjust the font size
  );
  TextStyle listenTextStyle = TextStyle(
    color: Colors.teal[300],
    fontWeight: FontWeight.bold,
    fontSize: 20.0, // You can adjust the font size
  );

    // Draw the text above the microphone icon

  @override
  void paint(Canvas canvas, Size size) {
    // final textPainter = TextPainter(
    //   text: TextSpan(
    //     text: labelText,
    //     style: TextStyle(
    //       color: Colors.black, // Customize the text color
    //       fontSize: 16.0, // Customize the text size
    //     ),
    //   ),
    //   textDirection: TextDirection.ltr,
    // );
    //
    // textPainter.layout(
    //   minWidth: 0,
    //   maxWidth: size.width,
    // );
    //
    // textPainter.paint(
    //   canvas,
    //   Offset(
    //     (size.width - textPainter.width) / 2, // Center the text horizontally
    //     size.height - textPainter.height - 16.0, // Adjust the vertical position
    //   ),
    // );
    // final textListening = TextPainter(
    //   text: TextSpan(
    //     text: ,
    //     style: TextStyle(
    //       color: Colors.black, // Customize the text color
    //       fontSize: 16.0, // Customize the text size
    //     ),
    //   ),
    //   textDirection: TextDirection.ltr,
    // );
    //
    // textListening.layout(
    //   minWidth: 0,
    //   maxWidth: size.width,
    // );
    //
    // textListening.paint(
    //   canvas,
    //   Offset(
    //     (size.width - textListening.width) / 2, // Center the text horizontally
    //     size.height - textListening.height - 16.0, // Adjust the vertical position
    //   ),
    // );
    var viewCenterY = size.height * heightPercentange;
    viewWidth = size.width;
    if (bgColor != null) {
      mPaint.color = bgColor;
      if (rect == null) {
        rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
      }
      canvas.drawRect(rect!, mPaint);
      if (labelText != null) {
        final textPadding = EdgeInsets.all(8.0); // Adjust the padding value as needed

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
        double textY = micIconY ; // Adjust the vertical position with top padding
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
    _fillPath(viewCenterY, size);

    mPaint.color = Color(0xc0ffffff);
    canvas.drawPath(path1, mPaint);

    mPaint.color = Color(0xB0ffffff);
    canvas.drawPath(path2, mPaint);
    _drawMicIcon(canvas, size);

    // _drawImg(viewCenterY, canvas);

    mPaint.color = Color(0x80ffffff);
    canvas.drawPath(path3, mPaint);
    // double chipSpacing = 20.0;
    if (textForListening != null) {
      final textPadding = EdgeInsets.all(8.0); // Adjust the padding value as needed

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
      double textY = heightPercentange+250 ; // Adjust the vertical position with top padding
      textPainter.paint(canvas, Offset(textX, heightPercentange+250));
      mPaint1.color = Colors.teal[300]!;
      mPaint1.style = PaintingStyle.stroke;
      final List<String> chipTexts = ["English", "Hindi"];
      List<double> chipPositions = [ 100.0, 180.0]; // Add X coordinates for each chip
      for (int i = 0; i < chipPositions.length; i++) {
        final position = chipPositions[i];
        final chipY = heightPercentange+250 + 50.0; // Adjust the vertical position of the chips
        final chipWidth = 70.0; // Adjust the chip width as needed
        final chipHeight = 30.0; // Adjust the chip height as needed
        final chipRadius = Radius.circular(20.0); //  Adjust the chip size as needed
        final chipRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(position, chipY),
            width: chipWidth,
            height: chipHeight,
          ),
          chipRadius,
        );
        // Draw the chip
        final borderPath = Path();
        borderPath.addRRect(chipRect);
        canvas.drawPath(borderPath, mPaint1);

        // Draw text inside the chip
        final textPainter = TextPainter(
          text: TextSpan(
            text: chipTexts[i], // Get the corresponding text for this chip
            style: TextStyle(
              color: Colors.teal[300], // Customize the text color
              fontSize: 16.0, // Customize the text size
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: chipWidth - 16.0, // Make sure text fits within the chip with some padding
        );
        final textX = position - chipWidth / 2 + 8.0;
        final textY = chipY - textPainter.height / 2;
        textPainter.paint(canvas, Offset(textX, textY));
        if (details != null && chipRect.contains(details!.localPosition)) {
          // The user has clicked on the chip at index 'i'
          print('Chip clicked: ${chipTexts[i]}');
          // You can perform any desired action here
        }
      }

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
      final iconY = heightPercentange+100;

      textPainter.paint(canvas, Offset(iconX, iconY));
      final iconRect = Rect.fromPoints(
        Offset(iconX, iconY),
        Offset(iconX + textPainter.width, iconY + textPainter.height),
      );

      if (details != null && iconRect != null && iconRect.contains(details!.localPosition)) {
        print('Mic clicked');
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

  void _drawImg(double viewCenterY, Canvas canvas) {
    if (image != null) {
      mPaint.color = Color(0xffffffff);
      var offset = Offset(
          viewWidth / 2 - imageSize!.width / 2,
          viewCenterY -
              1.3 *
                  waveAmplitude *
                  _getSinY(wavePhaseValue.value + 90, waveFrequency * 0.8,
                      (viewWidth / 2 + 1).toInt()) -
              imageSize!.height);
      var destRect = Rect.fromLTRB(
          offset.dx + imgOffset.dx,
          offset.dy + imgOffset.dy,
          offset.dx + imgOffset.dx + imageSize!.width,
          offset.dy + imageSize!.height + imgOffset.dy);
      if (roundImg) {
        var clipOvalRect = destRect;
        canvas.save();
        /**
         * 计算圆形裁剪区域
         */
        if (destRect.width != destRect.height) {
          var djust = (destRect.width - destRect.height).abs() / 2;
          if (destRect.width > destRect.height) {
            clipOvalRect = Rect.fromLTRB(destRect.left + djust, destRect.top,
                destRect.right - djust, destRect.bottom);
          } else {
            clipOvalRect = Rect.fromLTRB(destRect.left, destRect.top + djust,
                destRect.right, destRect.bottom - djust);
          }
        }
        canvas.clipPath(Path()..addOval(clipOvalRect));
      }
      canvas.drawImageRect(
          image!,
          Rect.fromLTRB(
              0.0, 0.0, image!.width.toDouble(), image!.height.toDouble()),
          destRect,
          mPaint);
      if (roundImg) {
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_MyWavePaint oldDelegate) {
    return false;
  }

  double _getSinY(
      double startradius, double waveFrequency, int currentposition) {
    //避免重复计算，提取公用值
    if (_tempa == 0) _tempa = pi / viewWidth;
    if (_tempb == 0) {
      _tempb = 2 * pi / 360.0;
    }
    return (sin(
        _tempa * waveFrequency * (currentposition + 1) + startradius * _tempb));
  }

}

// ignore_for_file: must_be_immutable, unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceToTextConverter extends StatefulWidget {
  @override
  VoiceToTextConverterState createState() => VoiceToTextConverterState();

  VoiceToTextConverter({
    Key? key,
  }) : super(key: key);
}

class VoiceToTextConverterState extends State<VoiceToTextConverter> {
  String info = "Click on Mic when ready";
  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  bool recording = false;
  String voiceConvertedText = '';
  late Timer timer;
  late int start;

  // View Did Load
  @override
  void initState() {
    super.initState();
    _initSpeech().then((value) => _startListening());
  }

  @override
  void dispose() {
    timer.cancel();
    recording = false;
    speechEnabled = false;
    super.dispose();
  }

  Future _initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    startTimer();
    voiceConvertedText = "";
    await speechToText.listen(onResult: _onSpeechResult);
    voiceConvertedText = "";
    print("Started Lsitening");
    info = "Listening...";
    recording = true;
    setState(() {});
  }

  _stopListening() async {
    await speechToText.stop();
    print("stopped Listening");
    info = "Tap on the Mic to speak again";
    recording = false;
    speechEnabled = false;
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      voiceConvertedText = result.recognizedWords;
      print(voiceConvertedText);
    });
  }

  void startTimer() {
    start = 5;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          timer.cancel();
          if (voiceConvertedText == "") {
            _stopListening();
            setState(() {});
          } else {
            timer.cancel();
            recording = false;
            speechEnabled = false;
            _stopListening();
            Navigator.pop(context, voiceConvertedText);
          }
        } else {
          setState(() {
            start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
      backgroundColor: Colors.transparent.withOpacity(0.6),
      body: Center(
          child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 300,
          width: 200,
          color: Colors.teal,
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Column(
              children: [
                const Text(
                  "Tell us What you need",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                    onTap: () {
                      print("when clicked $recording");
                      if (recording) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                    child: recording
                        ? Container(
                            height: 70,
                            width: 70,
                            decoration: const BoxDecoration(
                              color: Colors.teal,
                              image: DecorationImage(
                                  image: AssetImage("images/Microphone.gif"),
                                  fit: BoxFit.fill),
                            ),
                            alignment: Alignment.center,
                          )
                        : const Icon(
                            Icons.mic_rounded,
                            size: 70,
                            color: Colors.white,
                          )),
                Container(
                  color: Colors.white,
                  height: 156,
                  width: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$voiceConvertedText",
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "$info",
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

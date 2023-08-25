// ignore_for_file: must_be_immutable, unrelated_type_equality_checks

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
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool recording = false;
  String _lastWords = '';

  // View Did Load
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    super.dispose();
    _stopListening();
    recording = false;
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    print("Started Lsitening");
    info = "Start Speaking";
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    print("stopped Listening");
    info = "stopped Listening";
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      print(_lastWords);
    });
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
                Text(
                  "Tell us What you need",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      print("when clicked $recording");
                      if (recording) {
                        _stopListening();
                        info = "stopped Listening";
                        recording = false;
                      } else {
                        _startListening();
                        recording = true;
                      }
                    });
                  },
                  child: Icon(
                    Icons.mic_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 156,
                  width: 300,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "$info",
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "$_lastWords",
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                          ),
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

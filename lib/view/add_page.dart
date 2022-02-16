import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/sound_player.dart';
import 'package:word_learn/sound_recorder.dart';

class AddPage extends StatefulWidget {
  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final recorder = SoundRecorder();
  final player = SoundPlayer();

  CollectionReference words = FirebaseFirestore.instance.collection('words');

  final wordController = TextEditingController();
  final translationController = TextEditingController();

  bool hasInput = false;

  void _checkInput() {
    setState(() {
      hasInput = wordController.text.isNotEmpty &&
          translationController.text.isNotEmpty;
    });
  }

  void _submit() {
    if (hasInput) {
      words.add({
        'word': wordController.text,
        'translation': translationController.text,
      }).then((value) {
        print("User Added");
        Navigator.pop(context);
      }).catchError((error) => print("Failed to add user: $error"));
    } else {
      // just return
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    recorder.init();
    wordController.addListener(_checkInput);
    translationController.addListener(_checkInput);
    // player.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    player.dispose();

    wordController.dispose();
    translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('New Word'),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Word',
                    hintText: 'Type here...'),
                textInputAction: TextInputAction.next,
                controller: wordController,
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Translation',
                    hintText: 'Type here...'),
                controller: translationController,
                onSubmitted: (text) => _submit(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              buildRecordButton(),
              ElevatedButton(
                onPressed: () {
                  player.play();
                },
                child: const Text("play"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submit,
        label: Text(hasInput ? 'Done' : 'Cancel'),
        icon: Icon(hasInput ? Icons.done : Icons.close),
        backgroundColor: hasInput ? Colors.green : Colors.red,
      ),
    );
  }

  var p = 0.8;
  var duration = const Duration(); // in milliseconds
  var position = const Duration();

  Widget buildRecordButton() {
    final isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.mic;
    final text = isRecording ? 'STOP' : 'START';
    final primary = isRecording ? Colors.red : Colors.white;
    final onPrimary = isRecording ? Colors.white : Colors.black;
    player.audioPlayer?.onProgress?.listen((event) {
      setState(() {
        duration = event.duration;
        position = event.position;
        // p = event.position.inMilliseconds / event.duration.inMilliseconds;
        // print(p);
      });
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: hasRecording
          ? _buildPlayerWidget(progress: p)
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.green.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTapDown: (tapDownDetails) async {
                      final isRecording = await recorder.record();
                      setState(() {});
                    },
                    onTapUp: (tapDownDetails) async {
                      print('YESSSSS');
                      final isRecording = await recorder.stop();
                      setState(() {
                        hasRecording = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        color: isRecording ? Colors.red : Colors.amber,
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: const Text("Record"),
                    ),
                  ),
                ],
              ),
            ),
    );
    // return ElevatedButton.icon(
    //   style: ElevatedButton.styleFrom(
    //     minimumSize: const Size(175, 50),
    //     primary: primary,
    //     onPrimary: onPrimary,
    //   ),
    //   icon: Icon(icon),
    //   label: Text(
    //     text,
    //     style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    //   ),
    //   onPressed: () async {
    //     final isRecording = await recorder.toggleRecording();
    //     setState(() {});
    //   },
    // );
  }

  var hasRecording = true;
  var isPl = false;

  Widget _buildPlayerWidget({progress = 0.0}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: Colors.green.withOpacity(0.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4.0),
          IconButton(
            color: Colors.green,
            onPressed: () {
              setState(() {
                player.togglePlaying(whenFinished: () {
                  setState(() {
                    isPl = false;
                    position = duration;
                  });
                });
                isPl = !player.isPlaying;
              });
            },
            icon: isPl ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
          ),
          Text(isPl ? _printDuration(position) : _printDuration(duration)),
          Expanded(
            child: Slider(
              value: position.inMilliseconds.toDouble(),
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              onChangeStart: (value) {
                if (!isPl) {
                  player.play();
                }
                player.pause();
              },
              onChangeEnd: (value) {
                setState(() {
                  if (isPl) {
                    player.audioPlayer?.resumePlayer();
                  }
                });
              },
              onChanged: (value) {
                setState(() {
                  player.audioPlayer
                      ?.seekToPlayer(Duration(milliseconds: value.toInt()));
                  position = Duration(milliseconds: value.toInt());
                });
              },
            ),
          ),
          IconButton(
            color: Colors.green,
            onPressed: () {
              setState(() {
                hasRecording = false;
              });
            },
            icon: const Icon(Icons.clear),
          ),
          const SizedBox(width: 4.0),
        ],
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0").substring(0, 2);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMillis = twoDigits(duration.inMilliseconds.remainder(1000));
    return "$twoDigitSeconds:$twoDigitMillis";
  }
}

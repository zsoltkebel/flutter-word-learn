import 'package:flutter/material.dart';
import 'package:word_learn/non-ui/sound_recorder.dart';
import 'package:word_learn/view/components/recorder_ui.dart';

class InputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final String label;
  final FocusNode? focusNode;
  final String? pathToAudioFile;

  const InputWidget({
    Key? key,
    this.pathToAudioFile,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.label = '',
    this.focusNode,
  }) : super(key: key);

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  late final textController = widget.controller ?? TextEditingController();

  bool hasText = false;
  bool hasRecording = false;

  @override
  void initState() {
    super.initState();

    textController.addListener(() {
      setState(() {
        hasText = textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
          child: Row(
            children: [
              Text(
                widget.label.toUpperCase(),
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(width: 8.0),
              AnimatedScale(
                curve: Curves.bounceInOut,
                scale: hasText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Icon(
                  Icons.title,
                  size: 12.0,
                  color: Theme.of(context)
                      .textTheme
                      .caption
                      ?.color
                      ?.withOpacity(0.3),
                ),
              ),
              const SizedBox(width: 4.0),
              AnimatedScale(
                curve: Curves.bounceInOut,
                scale: hasRecording ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Icon(
                  Icons.record_voice_over_rounded,
                  size: 12.0,
                  color: Theme.of(context)
                      .textTheme
                      .caption
                      ?.color
                      ?.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
        RecorderUI(
          pathToAudioFile: widget.pathToAudioFile,
          onRecordingStopped: () async {
            setState(() {
              hasRecording = true;
            });
          },
          onDiscardRecording: () {
            setState(() {
              hasRecording = false;
            });
          },
          duration: const Duration(seconds: 5),
          //TODO actual audio file length
          // enabled: textController.text.isNotEmpty,
          child: _buildTextFormField(
            controller: textController,
            inputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    TextEditingController? controller,
    String hint = 'Type here ...',
    Function(String)? onFieldSubmitted,
    TextInputAction inputAction = TextInputAction.next,
  }) =>
      TextFormField(
        focusNode: widget.focusNode,
        controller: controller,
        minLines: 1,
        maxLines: 2,
        autofocus: true,
        textInputAction: inputAction,
        keyboardType: TextInputType.text,
        style: Theme.of(context).textTheme.titleLarge,
        onChanged: (text) {
          setState(() {});
        },
        decoration: InputDecoration(
          // labelText: 'Translation',
          border: InputBorder.none,
          hintText: hint,
        ),
        onFieldSubmitted: onFieldSubmitted,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (text) => text != null && text.isEmpty
            ? 'Please don\'t leave this blank'
            : null,
      );
}

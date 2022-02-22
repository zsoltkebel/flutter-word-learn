import 'dart:io';

import 'package:flutter/material.dart';
import 'package:word_learn/view/components/info_section.dart';
import 'package:word_learn/view/components/recorder_ui.dart';

class InputWidget extends StatefulWidget {
  final TextEditingController? textController;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(File?)? onRecordingFileChanged;
  final String label;
  final FocusNode? focusNode;
  final String? pathToAudioFile;

  const InputWidget({
    Key? key,
    this.pathToAudioFile,
    this.textController,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onRecordingFileChanged,
    this.label = '',
    this.focusNode,
  }) : super(key: key);

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  late final textController = widget.textController ?? TextEditingController();

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
        InfoSection(
          caption: widget.label,
          hasText: hasText,
          hasRecording: hasRecording,
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
          onRecordingFileChanged: widget.onRecordingFileChanged,
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

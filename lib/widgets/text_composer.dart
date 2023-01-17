import 'package:flutter/material.dart';

class TextComposer extends StatefulWidget {
  const TextComposer(this.sendMessage, {super.key});

  final Function(String message) sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  // States
  bool _isEmpty = true;

  // Controllers
  final TextEditingController textComposerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => {},
          icon: const Icon(Icons.photo_camera),
        ),
        Expanded(
          child: TextField(
            controller: textComposerController,
            // ".collapsed" Remove o espaço extra em baixo do input de texto
            decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
            onChanged: (value) => setState(() {
              _isEmpty = value.isEmpty;
            }),
            onSubmitted: (value) => sendMessage(value),
          ),
        ),
        IconButton(
          onPressed: _isEmpty ? null : () => sendMessage(textComposerController.text),
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  // Methods
  void sendMessage(String message) {
    widget.sendMessage(message);
    textComposerController.clear();
    setState(() {
      _isEmpty = true;
    });
  }
}

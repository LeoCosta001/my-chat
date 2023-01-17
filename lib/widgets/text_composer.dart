import 'package:flutter/material.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({super.key});

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  // States
  bool _isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: (() {}),
          icon: const Icon(Icons.photo_camera),
        ),
        Expanded(
          child: TextField(
            // ".collapsed" Remove o espaço extra em baixo do input de texto
            decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
            onChanged: (value) => setState(() {
              _isEmpty = value.isEmpty;
            }),
            onSubmitted: (value) {},
          ),
        ),
        IconButton(
          onPressed: _isEmpty ? null : () {},
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}

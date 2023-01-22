import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer(
    this.sendMessage, {
    super.key,
    required this.isLogged,
    required this.onPressLoginButton,
  });

  final Function({String? message, XFile? imageFile}) sendMessage;
  final bool isLogged;
  final Function onPressLoginButton;

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
    return widget.isLogged
        ? Container(
            // Aplica sombra externa
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(5.0, 5.0),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
                // Faz com que a sombra fique apenas fora (sem isso o primeiro elemento aplica sombra internamente)
                BoxShadow(color: Colors.white),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      ImagePicker().pickImage(source: ImageSource.camera).then((XFile? newImage) {
                        if (newImage != null) {
                          widget.sendMessage(imageFile: newImage);
                        }
                      });
                    },
                    icon: const Icon(Icons.photo_camera),
                  ),
                  Expanded(
                    child: Container(
                      // Define um background customizado (bordas arredondadas, tamanho, cor de fundo, etc) para o "TextField"
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        color: Colors.white60,
                      ),
                      child: TextField(
                        controller: textComposerController,
                        // ".collapsed" Remove o espaço extra em baixo do input de texto
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Send a message',
                        ),
                        // decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
                        onChanged: (value) => setState(() {
                          _isEmpty = value.isEmpty;
                        }),
                        onSubmitted: (value) => sendMessage(value),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isEmpty ? null : () => sendMessage(textComposerController.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextButton.icon(
              onPressed: () => widget.onPressLoginButton(),
              icon: const Icon(
                Icons.login,
                color: Colors.white,
              ),
              label: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
            ),
          );
  }

  // Methods
  void sendMessage(String message) {
    widget.sendMessage(message: message);
    textComposerController.clear();
    setState(() {
      _isEmpty = true;
    });
  }
}

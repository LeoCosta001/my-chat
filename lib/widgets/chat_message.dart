import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:my_chat/widgets/chat_bubbles_shape.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(this.data, this.isSender, {super.key});

  final Map<String, dynamic> data;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Row(
        // Faz com que o avatar fique no topo do bloco de mensagem
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          if (!isSender)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data['userPhoto']),
              ),
            ),
          // Balão de mensagem
          Expanded(
            // Este builder obtem o tamanho total do widget
            child: Row(
              mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSender) const ChatBubblesShapeDirection(true),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.blueAccent : const Color(0xFFE7ECF6),
                      borderRadius: BorderRadius.only(
                        topLeft: isSender ? const Radius.circular(12) : Radius.zero,
                        topRight: isSender ? Radius.zero : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    // Conteúdo do balão de mensagem
                    child: Column(
                      // Define se o conteúdo do balão será alinhado á direita ou esquerda
                      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // Nome do usuário e/ou hora
                        // if (!isSender)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            isSender
                                ? '${DateTime.fromMillisecondsSinceEpoch(data['createAt']).hour}:${DateTime.fromMillisecondsSinceEpoch(data['createAt']).minute} ~'
                                : '~ ${data['userName']} - ${DateTime.fromMillisecondsSinceEpoch(data['createAt']).hour}:${DateTime.fromMillisecondsSinceEpoch(data['createAt']).minute}',
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Conteúdo de imagem
                        if (data['imageUrl'] != null)
                          Image.network(
                            data['imageUrl'],
                            height: 150,
                            // Define uma tamanho para o componente antes mesmo da imagem começar a ser carregada
                            cacheHeight: 150,
                            // Exibe um loading durante o carregamento da imagem
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: isSender ? Colors.white10 : Colors.black12,
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Center(
                                  // Exibe um indicador de progresso de acordo com o que já foi carregado
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        // Conteúdo de texto
                        if (data['text'] != null)
                          Text(
                            data['text'],
                            // Define de qual lado começa a quebra de linha
                            textAlign: isSender ? TextAlign.end : TextAlign.start,
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isSender) const ChatBubblesShapeDirection(false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Set bubbles arrow direction
class ChatBubblesShapeDirection extends StatelessWidget {
  const ChatBubblesShapeDirection(this.reverse, {super.key});

  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return reverse
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: CustomPaint(
              painter: ChatBubblesShape(const Color(0xFFE7ECF6)),
            ),
          )
        : CustomPaint(
            painter: ChatBubblesShape(Colors.blueAccent),
          );
  }
}

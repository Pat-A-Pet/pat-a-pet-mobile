import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({
    super.key,
    required this.channel,
  });

  final Channel channel;

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelHeader(
        title: Text(
          widget.channel.name ?? 'Adoption Chat',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamChannel(
              channel: widget.channel,
              child: StreamMessageListView(
                messageBuilder: (context, details, messages, defaultMessage) {
                  return defaultMessage.copyWith();
                },
              ),
            ),
          ),
          StreamMessageInput(),
        ],
      ),
    );
  }
}

import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final streamClient = StreamChatClient(
  dotenv.env['STREAM_API_KEY']!,
  logLevel: Level.INFO,
);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/configs/stream_chat_client_config.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/pages/chat/chatting_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final userController = Get.find<UserController>();
  bool isConnecting = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    connectUser();
  }

  void connectUser() async {
    try {
      setState(() {
        isConnecting = true;
        errorMessage = null;
      });

      final res = await http.post(
        Uri.parse(ApiConfig.fetchChatToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userController.id}),
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to fetch chat token: ${res.statusCode}');
      }

      final responseBody = json.decode(res.body);
      final token = responseBody['token'];

      if (token == null) {
        throw Exception('Token not found in response');
      }

      await streamClient.connectUser(
        User(
          id: userController.id,
          extraData: {
            'name': userController.fullname,
          },
        ),
        token,
      );

      setState(() {
        isConnecting = false;
      });
    } catch (e) {
      setState(() {
        isConnecting = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isConnecting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    }

    return StreamChat(
      client: streamClient,
      child: Scaffold(
        appBar: AppBar(title: const Text('Inbox')),
        body: StreamChannelListView(
          controller: StreamChannelListController(
            client: streamClient,
            filter: Filter.in_('members', [userController.id]),
            channelStateSort: const [SortOption('last_message_at')],
          ),
          onChannelTap: (channel) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return StreamChannel(
                    channel: channel,
                    child:
                        const ChattingScreen(), // ← you'll need to create this page
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}


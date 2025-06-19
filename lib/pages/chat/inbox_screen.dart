import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/pages/chat/chatting_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      appBar: const CustomAppbar(),
      body: StreamChannelListView(
        controller: StreamChannelListController(
          client: StreamChat.of(context).client,
          filter: Filter.in_('members', [userController.id]),
          channelStateSort: const [SortOption('last_message_at')],
        ),
// In inbox_screen.dart
        onChannelTap: (channel) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StreamChannel(
                channel: channel,
                child: ChattingScreen(
                  channel: channel,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

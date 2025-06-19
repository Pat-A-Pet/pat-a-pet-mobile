import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pat_a_pet/components/strocked_icon.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/configs/stream_chat_client_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';
import 'package:pat_a_pet/pages/chat/chatting_screen.dart';
import 'package:pat_a_pet/pages/pet_detail_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AdoptionsPetCard extends StatefulWidget {
  final Pet pet;
  final bool isCompletedAdoption;

  const AdoptionsPetCard(
      {super.key, required this.pet, this.isCompletedAdoption = false});

  @override
  State<AdoptionsPetCard> createState() => _AdoptionsPetCardState();
}

class _AdoptionsPetCardState extends State<AdoptionsPetCard> {
  final _secureStorage = FlutterSecureStorage();
  final userController = Get.find<UserController>();
  bool _isCanceling = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isCompletedAdoption) {}

    final request =
        widget.pet.adoptionRequests?.cast<AdoptionRequest>().firstWhere(
              (req) => req.userId == userController.id,
              orElse: () => AdoptionRequest(
                id: '',
                userId: '',
                status: 'adopted',
                createdAt: DateTime.now(),
              ),
            );

    if (request == null) return SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailPage(pet: widget.pet),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    widget.pet.imageUrls[0],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const StrokedIcon(
                        strokeColor: Colors.black,
                        strokeWidth: 0.6,
                        icon: Icons.location_on,
                        size: 16,
                        fillColor: ConstantsColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.pet.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ConstantsColors.textPrimary,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status badge (Available / Adopted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: request.status == 'pending'
                          ? ConstantsColors.secondary
                          : request.status == 'adopted'
                              ? ConstantsColors.primary
                              : request.status == 'rejected'
                                  ? Colors.red
                                  : ConstantsColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.status == 'pending'
                          ? "Pending"
                          : request.status == 'adopted'
                              ? "Adopted"
                              : request.status == 'rejected'
                                  ? "Rejected"
                                  : "No Request",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Edit + Delete buttons
                  if (request.status != 'rejected' &&
                      widget.isCompletedAdoption == false)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        StrokedIcon(
                          strokeColor: Colors.black,
                          strokeWidth: 0.6,
                          icon: Icons.cancel,
                          size: 20,
                          fillColor: ConstantsColors.secondary,
                          onTap: _showCancelConfirmationDialog,
                        ),
                        const SizedBox(width: 12),
                        StrokedIcon(
                          strokeColor: Colors.black,
                          strokeWidth: 0.6,
                          icon: Icons.chat,
                          size: 20,
                          fillColor: ConstantsColors.secondary,
                          onTap: () async {
                            try {
                              final token =
                                  await _secureStorage.read(key: 'jwt');
                              final channelId = request.channelId;

                              if (channelId == null) {
                                // Create new channel if doesn't exist
                                final response = await http.post(
                                  Uri.parse(ApiConfig.createChannel),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    'petId': widget.pet.id,
                                    'requesterId': userController.id,
                                    'ownerId': widget.pet.owner.id,
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  final data = jsonDecode(response.body);
                                  final newChannelId = data['channelId'];

                                  final channel = streamClient
                                      .channel('messaging', id: newChannelId);
                                  await channel.watch();

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
                                }
                              } else {
                                // Use existing channel
                                final channel = streamClient
                                    .channel('messaging', id: channelId);
                                await channel.watch();

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
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error starting chat: ${e.toString()}')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelAdoptionRequest() async {
    setState(() {
      _isCanceling = true;
    });

    final token = await _secureStorage.read(key: "jwt");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication required')),
      );
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.cancelRequestAdoption(widget.pet.id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userController.id,
        }),
      );
      print("reponse body: ${response.body}");
      print("reponse code: ${response.statusCode}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adoption request canceled successfully')),
        );
        // Optionally refresh the parent widget's data
        // if (mounted) {
        //   Navigator.of(context).pop(); // Close if in dialog
        //   // Or trigger a refresh in the parent widget
        // }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel request: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling request: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCanceling = false;
        });
      }
    }
  }

  Future<void> _showCancelConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Adoption Request'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to cancel your adoption request for ${widget.pet.name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: _isCanceling
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await _cancelAdoptionRequest();
                    },
              child: _isCanceling
                  ? CircularProgressIndicator()
                  : Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pat_a_pet/components/strocked_icon.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/configs/stream_chat_client_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';
import 'package:pat_a_pet/pages/chat/chatting_screen.dart';
import 'package:pat_a_pet/pages/my_pet_hub/my_pets/create_edit_pet_listing.dart';
import 'package:pat_a_pet/pages/pet_detail_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class YourPetCard extends StatefulWidget {
  final Pet pet;

  const YourPetCard({super.key, required this.pet});

  @override
  State<YourPetCard> createState() => _YourPetCardState();
}

class _YourPetCardState extends State<YourPetCard> {
  final _secureStorage = FlutterSecureStorage();
  bool _isLoadingRequests = false;
  List<dynamic> _adoptionRequests = [];
  bool _isProcessingRequest = false;
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
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
                // Add adoption requests badge if there are pending requests
                if (widget.pet.adoptionRequests!.isNotEmpty &&
                    widget.pet.status == "available")
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.pet.adoptionRequests!.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      color: widget.pet.status == 'available'
                          ? ConstantsColors.secondary
                          : ConstantsColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.pet.status == 'available'
                          ? "Available"
                          : "Adopted",
                      style: TextStyle(
                        color: widget.pet.status == 'available'
                            ? Colors.black87
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),

                  if (widget.pet.adoptedBy != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'by: ${widget.pet.adoptedBy?.fullname}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ConstantsColors.textPrimary,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Adoption requests button (only show if pet is available)
                  if (widget.pet.adoptionRequests!.isNotEmpty &&
                      widget.pet.status == "available")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showAdoptionRequestsDialog(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: Colors.orange.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Requests',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Edit + Delete buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StrokedIcon(
                        strokeColor: Colors.black,
                        strokeWidth: 0.6,
                        icon: Icons.edit,
                        size: 20,
                        fillColor: ConstantsColors.secondary,
                        onTap: _showEditPetListingDialog,
                      ),
                      const SizedBox(width: 12),
                      StrokedIcon(
                        strokeColor: Colors.black,
                        strokeWidth: 0.6,
                        icon: Icons.delete,
                        size: 20,
                        fillColor: ConstantsColors.secondary,
                        onTap: _confirmDelete,
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

  Future<void> _handleRequest(String requestId, String action) async {
    setState(() => _isProcessingRequest = true);

    try {
      final token = await _secureStorage.read(key: 'jwt');
      final response = await http.patch(
        Uri.parse(
          ApiConfig.updateRequestStatus(widget.pet.id, requestId),
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'action': action}),
      );

      print("response body: ${response.body}");
      print("response code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Refresh the requests
        await _fetchAdoptionRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Request ${action == 'approve' ? 'approved' : 'rejected'}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to process request: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling request: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessingRequest = false);
    }
  }

  Future<void> _fetchAdoptionRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final token = await _secureStorage.read(key: 'jwt');
      final response = await http.get(
        Uri.parse(ApiConfig.getAllAdoptionsOwner(widget.pet.id)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _adoptionRequests = jsonDecode(response.body);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading requests: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _showAdoptionRequestsDialog() async {
    await _fetchAdoptionRequests();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Adoption Requests'),
            content: SizedBox(
              width: double.maxFinite,
              child: _isLoadingRequests
                  ? const Center(child: CircularProgressIndicator())
                  : _adoptionRequests.isEmpty
                      ? const Text('No adoption requests yet')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _adoptionRequests.length,
                          itemBuilder: (context, index) {
                            final request = _adoptionRequests[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: request['user'][
                                                          'profilePictureUrl'] ==
                                                      null ||
                                                  request['user']
                                                          ['profilePictureUrl']
                                                      .isEmpty
                                              ? const AssetImage(
                                                  'assets/images/logo.png')
                                              : NetworkImage(request['user']
                                                  ['profilePictureUrl']),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            request['user']['fullname'] ??
                                                'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                request['status']),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            request['status']
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (request['status'] == 'pending')
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.chat),
                                                onPressed: () {
                                                  _startChatWithBuyer(request);
                                                },
                                              ),
                                              IconButton(
                                                icon: _isProcessingRequest
                                                    ? const CircularProgressIndicator()
                                                    : const Icon(Icons.check,
                                                        color: Colors.green),
                                                onPressed: _isProcessingRequest
                                                    ? null
                                                    : () => _handleRequest(
                                                        request['_id'],
                                                        'approve'),
                                              ),
                                              IconButton(
                                                icon: _isProcessingRequest
                                                    ? const CircularProgressIndicator()
                                                    : const Icon(Icons.close,
                                                        color: Colors.red),
                                                onPressed: _isProcessingRequest
                                                    ? null
                                                    : () => _handleRequest(
                                                        request['_id'],
                                                        'reject'),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _startChatWithBuyer(Map<String, dynamic> request) async {
    try {
      // 1. Get the JWT token for your backend API
      final token = await _secureStorage.read(key: 'jwt');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // 2. Get or refresh the Stream Chat token
      final tokenResponse = await http.post(
        Uri.parse(ApiConfig.fetchChatToken),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'userId': userController.id}),
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception('Failed to get Stream Chat token');
      }

      final responseBody = json.decode(tokenResponse.body);
      final chatToken = responseBody['token'];

      // 3. Connect or reconnect the user
      await streamClient.disconnectUser();
      await streamClient.connectUser(
        User(
          id: userController.id,
          extraData: {'name': userController.fullname},
        ),
        chatToken,
      );

      // 4. Create the channel via your backend
      final channelResponse = await http.post(
        Uri.parse(ApiConfig.createChannel),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'petId': widget.pet.id,
          'requesterId': request['user']['_id'],
          'ownerId': userController.id,
        }),
      );

      if (channelResponse.statusCode == 200) {
        final data = jsonDecode(channelResponse.body);
        final channelId = data['channelId'];

        // 5. Initialize and watch the channel
        final channel = streamClient.channel('messaging', id: channelId);
        await channel.watch();

        // 6. Navigate to chat screen
        if (mounted) {
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
        throw Exception('Failed to create channel: ${channelResponse.body}');
      }
    } catch (e) {
      print('Chat initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: ${e.toString()}')),
        );
      }
    }
  }

  void _showEditPetListingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: CreateEditPetListingScreen(
          pet: widget.pet,
          isEditMode: true,
          // onPetCreated: () {},
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet Listing'),
        content:
            const Text('Are you sure you want to delete this pet listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              await _deletePetListing(); // Call the delete function
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePetListing() async {
    final token = await _secureStorage.read(key: 'jwt');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deletePetListing(widget.pet.id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pet listing deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // You might want to refresh the parent widget's state here
          // For example, if this is in a list, you could call a callback
          // to refresh the list
          // Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete pet: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting pet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

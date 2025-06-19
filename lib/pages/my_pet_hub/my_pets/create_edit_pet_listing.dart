// create_edit_pet_listing_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/models/pet.dart';

class CreateEditPetListingScreen extends StatefulWidget {
  final Pet? pet;
  final bool isEditMode;

  const CreateEditPetListingScreen({
    super.key,
    this.pet,
    this.isEditMode = false,
  });

  @override
  State<CreateEditPetListingScreen> createState() =>
      _CreateEditPetListingScreenState();
}

class _CreateEditPetListingScreenState
    extends State<CreateEditPetListingScreen> {
  final _secureStorage = const FlutterSecureStorage();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();
  final TextEditingController _specialNeedsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adoptionFeeController = TextEditingController();

  bool _showGenderError = false;
  bool _isSubmitting = false;
  int _currentPage = 0;

  // Image management
  List<String> _existingImageUrls = [];
  List<XFile> _newImages = [];
  List<String> _imagesToDelete = [];

  // Form data
  String? _selectedGender;
  bool _vaccinated = false;
  bool _neutered = false;
  bool _microchipped = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.pet != null) {
      _initializeFormData();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    _medicalConditionsController.dispose();
    _specialNeedsController.dispose();
    _descriptionController.dispose();
    _adoptionFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: CustomAppbar(
          title:
              widget.isEditMode ? "Edit Pet Listing" : "Create New Pet Listing",
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitConfirmationDialog().then((exit) {
                if (exit) Navigator.pop(context);
              }),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentPage + 1) / 2,
              backgroundColor: Colors.grey[200],
              color: ConstantsColors.primary,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                children: [
                  KeepAliveWrapper(child: _buildPage1()),
                  KeepAliveWrapper(child: _buildPage2()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    if (_currentPage == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }
    return await _showExitConfirmationDialog();
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content:
                const Text('Are you sure you want to discard your changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _initializeFormData() {
    final pet = widget.pet!;
    _nameController.text = pet.name;
    _speciesController.text = pet.species;
    _breedController.text = pet.breed;
    _ageController.text = pet.age.toString();
    _selectedGender = pet.sex;
    _colorController.text = pet.color;
    _weightController.text = pet.weight;
    _locationController.text = pet.location;
    _vaccinated = pet.vaccinated;
    _neutered = pet.neutered;
    _microchipped = pet.microchipped;
    _medicalConditionsController.text = pet.medicalConditions;
    _specialNeedsController.text = pet.specialNeeds;
    _descriptionController.text = pet.description;
    _adoptionFeeController.text = pet.adoptionFee.toString();
    _existingImageUrls = List.from(pet.imageUrls);
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          int totalImages = _existingImageUrls.length + _newImages.length;
          int availableSlots = 10 - totalImages;

          if (availableSlots > 0) {
            int imagesToAdd = pickedFiles.length > availableSlots
                ? availableSlots
                : pickedFiles.length;
            _newImages.addAll(pickedFiles.take(imagesToAdd));

            if (pickedFiles.length > availableSlots) {
              Get.snackbar(
                'Limit Exceeded',
                'Only $availableSlots more images can be added (maximum 10 total)',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          } else {
            Get.snackbar(
              'Limit Reached',
              'You can upload up to 10 images maximum',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitPet() async {
    if (!_validateForms()) {
      // Show more detailed error
      Get.snackbar(
        'Validation Error',
        'Please complete all required fields',
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Upload new images if any
      List<String> newImageUrls = [];
      if (_newImages.isNotEmpty) {
        newImageUrls = await _uploadImages();
      }

      // 2. Prepare final image URLs (existing + new)
      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      // 3. Validate that we have at least one image
      if (allImageUrls.isEmpty) {
        Get.snackbar(
          'Error',
          'At least one image is required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 4. Prepare pet data
      final petData = {
        'name': _nameController.text.trim(),
        'species': _speciesController.text.trim(),
        'breed': _breedController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender,
        'color': _colorController.text.trim(),
        'weight': _weightController.text.trim(),
        'location': _locationController.text.trim(),
        'vaccinated': _vaccinated,
        'neutered': _neutered,
        'microchipped': _microchipped,
        'medicalConditions': _medicalConditionsController.text.trim(),
        'specialNeeds': _specialNeedsController.text.trim(),
        'description': _descriptionController.text.trim(),
        'adoptionFee': double.parse(_adoptionFeeController.text.trim()),
        'imageUrls': allImageUrls,
      };

      // 5. Make API call
      final response = await _makeApiCall(petData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _handleSuccess();
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      _handleSubmissionError(e);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateForms() {
    debugPrint('=== Validating Forms ===');

    // Validate page 1
    if (_formKey1.currentState == null) {
      debugPrint('Form 1 state is null!');
      _goToPage(0);
      return false;
    }

    if (!_formKey1.currentState!.validate()) {
      debugPrint('Form 1 validation failed');
      _goToPage(0);
      return false;
    }

    // Validate gender selection
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      debugPrint('Gender not selected');
      setState(() => _showGenderError = true);
      _goToPage(0);
      return false;
    }

    // Validate page 2
    if (_formKey2.currentState == null) {
      debugPrint('Form 2 state is null!');
      _goToPage(1);
      return false;
    }

    if (!_formKey2.currentState!.validate()) {
      debugPrint('Form 2 validation failed');
      _goToPage(1);
      return false;
    }

    // Validate images
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      debugPrint('No images selected');
      Get.snackbar('Error', 'At least one image is required');
      _goToPage(1);
      return false;
    }

    debugPrint('All validations passed!');
    return true;
  }

  void _goToPage(int page) {
    if (_currentPage != page) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    final token = await _secureStorage.read(key: 'jwt');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final uri = Uri.parse(ApiConfig.uploadPetImages);
    var request = http.MultipartRequest('POST', uri);

    // Add headers correctly for multipart request
    request.headers['Authorization'] = 'Bearer $token';

    // Don't set Content-Type header manually for multipart - it will be set automatically
    // with the correct boundary parameter

    // Add each image to the request
    for (final image in _newImages) {
      final file = await http.MultipartFile.fromPath(
        'images', // This should match what your server expects
        image.path,
        contentType: MediaType(
            'image', 'jpeg'), // Adjust if needed for other image types
      );
      request.files.add(file);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final images = jsonResponse['images'] as List;
        return images.map((img) => img['url'] as String).toList();
      } else {
        throw Exception(
            'Failed to upload images: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }

  Future<http.Response> _makeApiCall(Map<String, dynamic> data) async {
    final token = await _secureStorage.read(key: 'jwt');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final endpoint = widget.isEditMode && widget.pet != null
        ? ApiConfig.updatePetListing(widget.pet!.id)
        : ApiConfig.createPetListing;

    if (widget.isEditMode && widget.pet != null) {
      return await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
    } else {
      return await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
    }
  }

  void _handleSuccess() {
    Navigator.pop(context, true);
    Get.snackbar(
      'Success',
      widget.isEditMode
          ? 'Pet updated successfully!'
          : 'Pet created successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _handleApiError(http.Response response) {
    String errorMessage =
        'Failed to ${widget.isEditMode ? 'update' : 'create'} listing';

    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
    } catch (e) {
      if (response.body.isNotEmpty && response.body.length < 100) {
        errorMessage = response.body;
      }
    }

    Get.snackbar(
      'Error',
      'Status ${response.statusCode}: $errorMessage',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleSubmissionError(dynamic e) {
    debugPrint('Error during submission: $e');
    Get.snackbar(
      'Error',
      'An error occurred: ${e.toString()}',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Widget _buildPage1() {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextFormField(
                  label: 'Name*',
                  controller: _nameController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Species*',
                  controller: _speciesController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Breed*',
                  controller: _breedController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Age* (in years)',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: _validateNumericField,
                ),
                const SizedBox(height: 16),
                _buildGenderRadioGroup(),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Color*',
                  controller: _colorController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Weight* (in kilograms)',
                  controller: _weightController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(
        text: 'Continue',
        onPressed: _goToNextPage,
      ),
    );
  }

  Widget _buildPage2() {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSwitchTile(
                    'Vaccinated', _vaccinated, (val) => _vaccinated = val),
                _buildSwitchTile(
                    'Neutered', _neutered, (val) => _neutered = val),
                _buildSwitchTile('Microchipped', _microchipped,
                    (val) => _microchipped = val),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Medical Conditions*',
                  controller: _medicalConditionsController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Special Needs*',
                  controller: _specialNeedsController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Description*',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildImageUploadSection(),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Location*',
                  controller: _locationController,
                  validator: _validateRequiredField,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Adoption Fee* (no comma or period, e.g. 700000)',
                  controller: _adoptionFeeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateAdoptionFee,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(
        text: widget.isEditMode ? 'Update Listing' : 'Create Listing',
        onPressed: _isSubmitting ? null : _submitPet,
        isLoading: _isSubmitting,
      ),
    );
  }

  Widget _buildBottomButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: ConstantsColors.primary,
            disabledBackgroundColor: ConstantsColors.primary.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images* (At least 1 required)',
          style: TextStyle(fontFamily: 'PT Sans', fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: (_existingImageUrls.length + _newImages.length) >= 10
                  ? null
                  : _pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantsColors.primary,
                disabledBackgroundColor: Colors.grey,
              ),
              icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
              label: const Text(
                'Select Images',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_existingImageUrls.length + _newImages.length}/10)',
              style: TextStyle(
                color: (_existingImageUrls.length + _newImages.length) >= 10
                    ? Colors.red
                    : (_existingImageUrls.length + _newImages.length) == 0
                        ? Colors.red
                        : Colors.grey,
                fontWeight: (_existingImageUrls.length + _newImages.length) == 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_existingImageUrls.isNotEmpty || _newImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _existingImageUrls.length + _newImages.length,
            itemBuilder: (context, index) {
              if (index < _existingImageUrls.length) {
                return _buildImageThumbnail(
                  imageUrl: _existingImageUrls[index],
                  onRemove: () => _removeExistingImage(index),
                );
              } else {
                final newImageIndex = index - _existingImageUrls.length;
                return _buildImageThumbnail(
                  file: File(_newImages[newImageIndex].path),
                  onRemove: () => _removeNewImage(newImageIndex),
                );
              }
            },
          ),
      ],
    );
  }

  Widget _buildImageThumbnail({
    String? imageUrl,
    File? file,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Image.file(
                    file!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderRadioGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender*',
          style: TextStyle(
            fontFamily: 'PT Sans',
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderRadioButton('Male'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderRadioButton('Female'),
            ),
          ],
        ),
        if (_showGenderError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Please select a gender',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderRadioButton(String gender) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedGender = gender;
        _showGenderError = false;
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: gender,
              groupValue: _selectedGender,
              activeColor: ConstantsColors.primary,
              onChanged: (val) => setState(() {
                _selectedGender = val;
                _showGenderError = false;
              }),
            ),
            Text(
              gender,
              style: const TextStyle(fontFamily: 'PT Sans'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontFamily: 'PT Sans')),
      value: value,
      onChanged: (val) => setState(() => onChanged(val)),
      contentPadding: EdgeInsets.zero,
      activeTrackColor: ConstantsColors.primary,
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLines,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'PT Sans', fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        errorMaxLines: 2,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
    );
  }

  String? _validateRequiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateNumericField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    final num = int.parse(value.trim());
    if (num <= 0) {
      return 'Please enter a positive number';
    }
    return null;
  }

  String? _validateAdoptionFee(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    final fee = double.parse(value.trim());
    if (fee < 0) {
      return 'Adoption fee cannot be negative';
    }
    return null;
  }

  void _goToNextPage() {
    if (_formKey1.currentState!.validate()) {
      if (_selectedGender == null || _selectedGender!.isEmpty) {
        setState(() => _showGenderError = true);
        return;
      }
      setState(() => _showGenderError = false); // Reset error when valid
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _imagesToDelete.add(_existingImageUrls[index]);
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

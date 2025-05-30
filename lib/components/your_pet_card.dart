import 'package:flutter/material.dart';
import 'package:pat_a_pet/components/strocked_icon.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/models/pet.dart';
import 'package:pat_a_pet/pages/pet_detail_page.dart';

class YourPetCard extends StatefulWidget {
  final Pet pet;

  const YourPetCard({super.key, required this.pet});

  @override
  State<YourPetCard> createState() => _YourPetCardState();
}

class _YourPetCardState extends State<YourPetCard> {
  void _showEditPetListingDialog() {
    final _formKey = GlobalKey<FormState>();
    String imagePath = widget.pet.imagePath; // placeholder image
    String name = widget.pet.name;
    String location = widget.pet.location;
    String sex = widget.pet.sex;
    String color = widget.pet.color;
    String breed = widget.pet.breed;
    String weight = widget.pet.weight;
    String description = widget.pet.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Edit Pet Listing'),
          content: Form(
            key: _formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                children: [
                  // Image picker placeholder button (just for demo)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Pick Image(s)',
                      style:
                          TextStyle(fontFamily: "Nunito", color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantsColors.primary),
                  ),
                  // Pet name
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                  ),

                  // Location
                  TextFormField(
                    initialValue: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: (value) => location = value,
                  ),

                  // Sex
                  TextFormField(
                    initialValue: sex,
                    decoration: const InputDecoration(labelText: 'Sex'),
                    onChanged: (value) => sex = value,
                  ),

                  // Color
                  TextFormField(
                    initialValue: color,
                    decoration: const InputDecoration(labelText: 'Color'),
                    onChanged: (value) => color = value,
                  ),

                  // Breed
                  TextFormField(
                    initialValue: breed,
                    decoration: const InputDecoration(labelText: 'Breed'),
                    onChanged: (value) => breed = value,
                  ),

                  // Weight
                  TextFormField(
                    initialValue: weight,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    onChanged: (value) => weight = value,
                  ),

                  // Description
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (value) => description = value,
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    // Update the pet data with new values
                    widget.pet.imagePath = imagePath;
                    widget.pet.name = name;
                    widget.pet.location = location;
                    widget.pet.sex = sex;
                    widget.pet.color = color;
                    widget.pet.breed = breed;
                    widget.pet.weight = weight;
                    widget.pet.description = description;

                    // TODO: Call your DB update function here if you add backend
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantsColors.primary),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontFamily: "Nunito", color: Colors.white),
              ),
            ),
          ],
        );
      },
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
            onPressed: () {
              Navigator.pop(context); // Close confirmation dialog
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
                  child: Image.asset(
                    widget.pet.imagePath,
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

                  // Adopted By (if exists)

                  // Status badge (Available / Adopted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.pet.status == 'Available'
                          ? ConstantsColors.secondary
                          : ConstantsColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.pet.status,
                      style: TextStyle(
                        color: widget.pet.status == 'Available'
                            ? Colors.black87
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  if (widget.pet.adoptedBy != null) ...[
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'by: ${widget.pet.adoptedBy}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ConstantsColors.textPrimary,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],

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
                        onTap: () {
                          _showEditPetListingDialog(); // handle edit
                        },
                      ),
                      const SizedBox(width: 12),
                      StrokedIcon(
                        strokeColor: Colors.black,
                        strokeWidth: 0.6,
                        icon: Icons.delete,
                        size: 20,
                        fillColor: ConstantsColors.secondary,
                        onTap: () {
                          // handle delete
                          _confirmDelete();
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
}

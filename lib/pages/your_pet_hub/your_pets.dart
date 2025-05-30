import 'package:flutter/material.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/your_pet_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/models/pet.dart';

class YourPets extends StatefulWidget {
  const YourPets({super.key});

  @override
  State<YourPets> createState() => _YourPetsState();
}

class _YourPetsState extends State<YourPets> {
  final pets = [
    Pet(
        imagePath: 'assets/images/logo.png',
        name: 'Buddy',
        location: 'New York',
        sex: 'Male',
        color: 'Brown',
        breed: 'Golden Retriever',
        weight: '25kg',
        owner: 'John Doe',
        description: 'A friendly and playful dog that loves the outdoors.',
        status: "Adopted",
        adoptedBy: "Bryan"),
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
  ];
  void _showCreateNewPetListingDialog() {
    final _formKey = GlobalKey<FormState>();
    String imagePath = 'assets/images/logo.png'; // placeholder image
    String name = '';
    String location = '';
    String sex = '';
    String color = '';
    String breed = '';
    String weight = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Create New Pet Listing'),
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
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                  ),

                  // Location
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: (value) => location = value,
                  ),

                  // Sex
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Sex'),
                    onChanged: (value) => sex = value,
                  ),

                  // Color
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Color'),
                    onChanged: (value) => color = value,
                  ),

                  // Breed
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Breed'),
                    onChanged: (value) => breed = value,
                  ),

                  // Weight
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Weight'),
                    onChanged: (value) => weight = value,
                  ),

                  // Description
                  TextFormField(
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
                    pets.add(
                      Pet(
                        imagePath: imagePath,
                        name: name,
                        location: location,
                        sex: sex,
                        color: color,
                        breed: breed,
                        weight: weight,
                        owner: "John Doe",
                        description: description,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantsColors.primary),
              child: const Text(
                'Add Pet',
                style: TextStyle(fontFamily: "Nunito", color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Your Pets",
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.builder(
                  itemCount: pets.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.60,
                  ),
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return YourPetCard(
                      pet: pet,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          right: MediaQuery.of(context).size.width * 0.43,
          left: MediaQuery.of(context).size.width * 0.43,
          child: FloatingActionButton(
            onPressed: () {
              _showCreateNewPetListingDialog();
            },
            backgroundColor: ConstantsColors.primary,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/constants/colors.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});
  final bool patientSignUp = true;

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  //final TextEditingController _genderController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startDateOfPracticeController =
      TextEditingController();
  final TextEditingController _graduationUniversityController =
      TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  bool _isLoading = false;
  bool _isHidden1 = true;
  bool _isHidden2 = true;
  bool _isTermsChecked = false;
  String? _selectedGender;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1687A7), // header, selected date, buttons
              onPrimary: Colors.white, // text color on primary color
              onSurface: Colors.black, // default text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1687A7), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (widget.patientSignUp) {
          _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        } else {
          _startDateOfPracticeController.text =
              DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      });
    }
  }

  // Future<void> _registerUser() async {
  //   if (_formKey.currentState!.validate()) {
  //     if (!_isTermsChecked) {
  //       Get.snackbar("Error", "You must accept the terms and conditions");
  //       return;
  //     }
  //     try {
  //       setState(() => _isLoading = true);
  //
  //       final userData = {
  //         'fullname': _fullNameController.text,
  //         'email': _emailController.text,
  //         'password': _passwordController.text,
  //         'role': widget.patientSignUp ? "patient" : "doctor",
  //       };
  //
  //       if (widget.patientSignUp) {
  //         userData['gender'] = _selectedGender!;
  //         userData['birthdate'] = _dateController.text;
  //       } else {
  //         userData['startDateOfPractice'] = _startDateOfPracticeController.text;
  //         userData['graduationUniversity'] =
  //             _graduationUniversityController.text;
  //         userData['specialization'] = _specializationController.text;
  //       }
  //
  //       final response = await http.post(
  //         Uri.parse(ApiConfig.signup),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode(userData),
  //       );
  //
  //       final responseBody = jsonDecode(response.body);
  //
  //       if (response.statusCode == 201) {
  //         if (userData['role'] == "patient") {
  //           Get.offAll(() => const LoginScreen());
  //           Get.snackbar(
  //             'Registration Successful',
  //             'Welcome patient ${userData['fullname']}! Please log in to continue.',
  //             snackPosition: SnackPosition.BOTTOM,
  //           );
  //         } else {
  //           _fullNameController.clear();
  //           _emailController.clear();
  //           _passwordController.clear();
  //           _confirmPasswordController.clear();
  //           _startDateOfPracticeController.clear();
  //           _graduationUniversityController.clear();
  //           _specializationController.clear();
  //           setState(() {
  //             _isTermsChecked = false;
  //           });
  //           Get.snackbar(
  //             'Docter ${userData['fullname']} Registered',
  //             'Docter account created successfully and can be used by the doctor to login.',
  //             snackPosition: SnackPosition.BOTTOM,
  //           );
  //           Get.back();
  //         }
  //       } else {
  //         final error = responseBody['error'] ?? 'Sign up failed';
  //         Get.snackbar('Error', error);
  //       }
  //     } on SocketException {
  //       Get.snackbar('Error', 'No internet connection');
  //     } on TimeoutException {
  //       Get.snackbar('Error', 'Connection timeout');
  //     } catch (e) {
  //       // Add detailed error logging
  //       print('Registration Error: $e');
  //       if (e is http.ClientException) {
  //         Get.snackbar('Error', 'Connection failed: ${e.message}');
  //       } else {
  //         Get.snackbar('Error', 'An unexpected error occurred: $e');
  //       }
  //     } finally {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          /// Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person),
              labelStyle: TextStyle(fontSize: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your full name";
              }
              return null;
            },
          ),
          //Row(
          //  children: [
          //    Expanded(
          //      child: TextFormField(
          //        decoration: const InputDecoration(
          //          labelText: TTexts.firstName,
          //          prefixIcon: Icon(Iconsax.user),
          //        ),
          //      ),
          //    ),
          //    const SizedBox(width: TSizes.spaceBtwInputFields),
          //    Expanded(
          //      child: TextFormField(
          //        decoration: const InputDecoration(
          //          labelText: TTexts.lastName,
          //          prefixIcon: Icon(Iconsax.user),
          //        ),
          //      ),
          //    ),
          //  ],
          //),
          const SizedBox(height: 30),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.patientSignUp) ...[
                const Row(
                  children: [
                    Text(
                      "Gender",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedGender = "male";
                        });
                      },
                      child: Row(
                        children: [
                          Radio<String>(
                            activeColor: ConstantsColors.secondary,
                            value: "male",
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                          const Icon(
                            Icons.male,
                            color: Colors.black,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "Male",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedGender = "female";
                        });
                      },
                      child: Row(
                        children: [
                          Radio<String>(
                            activeColor: ConstantsColors.secondary,
                            value: "female",
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                          const Icon(
                            Icons.female,
                            color: Colors.black,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "Female",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ]
            ],
          ),

          /// Gender
          //// NOTE: Jadiin radio button
          //TextFormField(
          //  controller: _genderController,
          //  decoration: const InputDecoration(
          //    labelText: TTexts.gender,
          //    prefixIcon: Icon(Iconsax.user),
          //    labelStyle: TextStyle(fontSize: 14),
          //  ),
          //  validator: (value) {
          //    if (value == null || value.isEmpty) {
          //      return "Please enter your gender";
          //    }
          //    return null;
          //  },
          //),

          if (widget.patientSignUp) ...[
            TextFormField(
              controller: _dateController,
              readOnly: true, // Prevent manual input
              onTap: () => _selectDate(context), // Open Date Picker on tap
              decoration: const InputDecoration(
                labelText: "Birth Date",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your birth date";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
          ] else ...[
            TextFormField(
              controller: _startDateOfPracticeController,
              readOnly: true, // Prevent manual input
              onTap: () => _selectDate(context), // Open Date Picker on tap
              decoration: const InputDecoration(
                labelText: "Start Date of Practice",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the doctor's year of experience";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _graduationUniversityController,
              decoration: const InputDecoration(
                labelText: "Graduation University",
                prefixIcon: Icon(Icons.school),
                labelStyle: TextStyle(fontSize: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the doctor's graduation university";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _specializationController,
              decoration: const InputDecoration(
                labelText: "Specialization",
                prefixIcon: Icon(Icons.work),
                labelStyle: TextStyle(fontSize: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the doctor's specialization";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
          ],

          /// Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
              labelStyle: TextStyle(fontSize: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          /// Password
          TextFormField(
            controller: _passwordController,
            obscureText: _isHidden1,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(Icons.password),
              suffixIcon: IconButton(
                icon: Icon(_isHidden1
                    ? Icons.visibility_off
                    : Icons.visibility), // Toggle icon
                onPressed: () {
                  setState(() {
                    _isHidden1 = !_isHidden1; // Toggle visibility
                  });
                },
              ),
              labelStyle: const TextStyle(fontSize: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          /// Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _isHidden2,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              prefixIcon: const Icon(Icons.password),
              suffixIcon: IconButton(
                icon: Icon(_isHidden2
                    ? Icons.visibility_off
                    : Icons.visibility), // Toggle icon
                onPressed: () {
                  setState(() {
                    _isHidden2 = !_isHidden2; // Toggle visibility
                  });
                },
              ),
              labelStyle: const TextStyle(fontSize: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please reenter your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          /// Terms & Conditions Checkbox
          // TTermsAndConditionsCheckbox(
          //   value: _isTermsChecked,
          //   onChanged: (value) =>
          //       setState(() => _isTermsChecked = value ?? false),
          // ),
          // const SizedBox(height: TSizes.spaceBtwSections),

          /// Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(ConstantsColors.primary),
                side: WidgetStateProperty.all(
                  const BorderSide(color: Colors.black, width: 0),
                ),
              ),
              // onPressed: () => Get.to(() => const VerifyEmailScreen()),
              // onPressed: () => Get.to(() => const LoginScreen()),
              // onPressed: _isLoading ? null : _registerUser,
              onPressed: () {},
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      "Create Account",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

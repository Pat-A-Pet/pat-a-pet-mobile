import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/signin/signin_screen.dart';
import 'package:pat_a_pet/pages/signup/terms_and_condition.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});
  final bool patientSignUp = true;

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _isHidden1 = true;
  bool _isHidden2 = true;
  bool _isTermsChecked = false;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (!_isTermsChecked) {
        Get.snackbar("Error", "You must accept the terms and conditions");
        return;
      }
      try {
        setState(() => _isLoading = true);

        final userData = {
          'fullname': _fullNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        };

        final response = await http.post(
          Uri.parse(ApiConfig.signup),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 201) {
          _fullNameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          setState(() {
            _isTermsChecked = false;
          });
          Get.snackbar(
            'Registration Successful',
            'Welcome owner! Please sign in to continue.',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.off(SigninScreen());
        } else {
          final error = responseBody['error'] ?? 'Sign up failed';
          Get.snackbar('Error', error);
        }
      } on SocketException {
        Get.snackbar('Error', 'No internet connection');
      } on TimeoutException {
        Get.snackbar('Error', 'Connection timeout');
      } catch (e) {
        // Add detailed error logging
        if (e is http.ClientException) {
          Get.snackbar('Error', 'Connection failed: ${e.message}');
        } else {
          Get.snackbar('Error', 'An unexpected error occurred: $e');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
          const SizedBox(height: 30),
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
          TermsAndConditions(
            value: _isTermsChecked,
            onChanged: (value) =>
                setState(() => _isTermsChecked = value ?? false),
          ),
          const SizedBox(height: 30),
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
              onPressed: _isLoading ? null : _registerUser,
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

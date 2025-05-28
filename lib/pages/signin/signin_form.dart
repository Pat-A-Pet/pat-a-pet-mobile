import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pat_a_pet/components/navigation_menu.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/pages/signup/signup_screen.dart';

class SigninForm extends StatefulWidget {
  const SigninForm({
    super.key,
  });

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  bool _isHidden = true;

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        final response = await http.post(
          Uri.parse(ApiConfig.signin),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final token = responseBody['token'];
          final user = responseBody['user'];
          final userController = Get.find<UserController>();
          userController.setUser(user);
          await secureStorage.write(key: 'jwt', value: token);

          Get.offAll(() => const NavigationMenu());
        } else {
          final error = responseBody['error'] ?? 'Sign in failed';
          Get.snackbar('Error', error);
        }
      } on SocketException {
        Get.snackbar('Error', 'No internet connection');
      } on TimeoutException {
        Get.snackbar('Error', 'Connection timeout');
      } catch (e) {
        Get.snackbar('Error', 'An unexpected error occurred: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            /// Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "Email",
                  labelStyle: TextStyle(fontFamily: "PT Sans", fontSize: 14)),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter email';
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
              obscureText: _isHidden,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.password),
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(_isHidden
                      ? Icons.visibility_off
                      : Icons.visibility), // Toggle icon
                  onPressed: () {
                    setState(() {
                      _isHidden = !_isHidden; // Toggle visibility
                    });
                  },
                ),
                labelStyle:
                    const TextStyle(fontFamily: "PT Sans", fontSize: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            const SizedBox(height: 50),

            SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.055,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(ConstantsColors.primary),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Colors.black, width: 0),
                      ),
                    ),
                    onPressed: _isLoading ? null : loginUser,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Signin",
                            style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ))),
            const SizedBox(height: 30),

            /// Create Account Button
            SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.055,
                child: OutlinedButton(
                    onPressed: () => Get.to(() => const SignupScreen()),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ))),
            // const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}

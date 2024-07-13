import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lesson_76/restaurant_app/ui/screens/home_screen.dart';
import 'package:flutter_lesson_76/restaurant_app/ui/screens/register_screen.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/custom_functions.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _onLoginTapped() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await _authController
          .loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((_) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => HomeScreen()),
            (route)=> false
        );
      }).catchError((dynamic error) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
          ),
        );
      });
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 300,
                      child: Lottie.asset("assets/icons/login.json"),
                    ),
                    const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            hint: "Your email",
                            validator: CustomFunctions.emailValidator,
                            isObscure: false,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _passwordController,
                            hint: "Your password",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please, enter your password";
                              }
                              return null;
                            },
                            isObscure: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.push(context,CupertinoPageRoute(builder: (context) => RegisterScreen(),)),
                          child: const Text("Don't have an account? Register here"),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_emailController.text.isNotEmpty) {
                              await _auth
                                  .sendPasswordResetEmail(
                                  email: _emailController.text)
                                  .then(
                                    (value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                      Text('Password reset email sent'),
                                    ),
                                  );
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('Enter your email in the email field'),
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(''),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF007AFF),
                        strokeAlign: BorderSide.strokeAlignCenter,
                        strokeWidth: 3,
                      ),
                    )
                        : GestureDetector(
                      onTap: _onLoginTapped,
                      child: Center(
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Color(0xff002DE3)),
                          ),
                          onPressed: _onLoginTapped,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

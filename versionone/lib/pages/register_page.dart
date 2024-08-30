// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:versionone/component/button.dart';
import 'package:versionone/component/textfield.dart';
import 'package:versionone/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confrmPasswordController = TextEditingController();

  //sign up function
  void signUp() async {
    if (passwordController.text == confrmPasswordController) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password do not match"),
        ),
      );
      return;
    }

    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailandPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 120.0),
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              //logo
              Icon(
                Icons.message,
                size: 100,
                color: Colors.black,
              ),
              SizedBox(
                height: 10,
              ),

              //Nama aplikasi
              Text(
                "Chatter",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 50,
              ),

              //email textfield
              CustomTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              SizedBox(
                height: 10,
              ),

              //password textfield
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              SizedBox(
                height: 10,
              ),

              //konfirmasi password
              CustomTextField(
                controller: confrmPasswordController,
                hintText: "Konfirmasi password",
                obscureText: true,
              ),
              SizedBox(
                height: 50,
              ),

              //sign up button
              CustomButton(onTap: signUp, text: "Sign Up"),
              SizedBox(
                height: 25,
              ),

              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun?",
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      " Masuk Sekarang",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}

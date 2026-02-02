import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/user_data.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFbdd2df);
    const Color grey = Color(0xFF909090);

    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 150),
              const Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _label("Login"),
              _inputBox(hint: "Enter login", controller: _loginController),

              const SizedBox(height: 20),

              _label("E-mail"),
              _inputBox(hint: "Enter email", controller: _emailController),

              const SizedBox(height: 20),

              _label("Password"),
              _inputBox(hint: "Enter password", obscure: true),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (_) {},
                  ),
                  const Text("Remember me"),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 363,
                height: 60,
                child: TextButton(
                  onPressed: () {
                    final String username = _loginController.text.isEmpty
                        ? "User"
                        : _loginController.text;
                    final String? emailInput = _emailController.text.isEmpty
                        ? null
                        : _emailController.text;

                    final userData = UserData.initial(username, emailInput);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(userData: userData),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF5A7A8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Row(
                children: const [
                  Expanded(child: Divider(thickness: 2, color: grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Or Log in with"),
                  ),
                  Expanded(child: Divider(thickness: 2, color: grey)),
                ],
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButtonGoogle(),
                  const SizedBox(width: 15),
                  _socialButtonApple(),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 5),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _inputBox({
    required String hint,
    bool obscure = false,
    TextEditingController? controller,
  }) {
    return Container(
      width: 363,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xffdde9f1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _socialButtonGoogle() {
    return Container(
      width: 174,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/google.png', width: 30, height: 30),
          const SizedBox(width: 8),
          const Text("Google"),
        ],
      ),
    );
  }

  Widget _socialButtonApple() {
    return Container(
      width: 174,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/apple.png', width: 30, height: 30),
          const SizedBox(width: 8),
          const Text("Apple"),
        ],
      ),
    );
  }
}
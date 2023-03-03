import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koyevi_kurye/view/auth/login/login_notifier.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final ChangeNotifierProvider<LoginNotifier> provider;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    provider = ChangeNotifierProvider((ref) => LoginNotifier());
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/png/login.png"),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(hintText: "Kullanıcı adı"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: "Şifre"),
                onSubmitted: (value) {
                  ref.read(provider).login(
                        _usernameController.text,
                        _passwordController.text,
                      );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(provider).login(
                        _usernameController.text,
                        _passwordController.text,
                      );
                },
                child: const Text("Giriş yap"),
              ),
            ],
          ),
        )),
      )),
    );
  }
}

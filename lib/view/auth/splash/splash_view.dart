import 'package:flutter/material.dart';
import 'package:koyevi_kurye/core/services/authservice/authservice.dart';
import 'package:koyevi_kurye/core/services/authservice/user_model.dart';
import 'package:koyevi_kurye/core/services/network/network_service.dart';
import 'package:koyevi_kurye/core/services/network/response_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Image.asset("assets/images/png/splash.png"),
        ),
      ),
    );
  }

  _checkLogin() async {
    if (AuthService.instance.isLoggedIn) {
      try {
        ResponseModel loginResponse = await NetworkService.get(
            "courier/Login/${AuthService.instance.user.username}/${AuthService.instance.user.password}");
        if (loginResponse.success) {
          if (loginResponse.data != false) {
            AuthService.instance.login(UserModel(
                id: loginResponse.data["ID"],
                username: AuthService.instance.user.username,
                password: AuthService.instance.user.password,
                name: loginResponse.data["Name"]));
          } else {
            AuthService.instance.logout();
          }
        } else {
          AuthService.instance.logout();
        }
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Hata"),
                  content: const Text("Bir hata oluştu"),
                  actions: [
                    TextButton(
                        onPressed: _checkLogin,
                        child: const Text("Tekrar dene"))
                  ],
                ));
      }
    } else {
      AuthService.instance.logout();
    }
  }
}
